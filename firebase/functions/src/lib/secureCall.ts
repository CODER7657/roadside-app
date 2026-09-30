// The one wrapper every callable goes through (PLAN §12.6, firebase/functions/CLAUDE.md).
//
//   1. App Check enforced (and checked again inside the handler outside the emulator)
//   2. request.auth required
//   3. role claim (and optionally mechanicStatus) checked
//   4. input parsed with a strict zod schema: unknown fields are rejected
//   5. per-uid sliding-window rate limit
//   6. a customer or mechanic who asked to delete their account is refused: their ID token
//      stays valid up to an hour after requestAccountDeletion revokes it (#167)
//   7. anything that isn't an HttpsError becomes `internal` with a safe message key;
//      no stack traces or internal data reach the client

import * as logger from 'firebase-functions/logger';
import {
  HttpsError,
  onCall,
  type CallableFunction,
  type CallableRequest,
} from 'firebase-functions/v2/https';
import { z } from 'zod';
import type { MechanicStatus, Role } from '../models/enums.js';
import type { RoleClaims } from '../models/documents.js';
import { REGION, db } from './admin.js';
import { enforceRateLimit, type RateLimit } from './rateLimit.js';

export interface SecureCallOptions<S extends z.ZodObject> {
  /** Function name, used as the rate-limit key and in logs. */
  name: string;
  /** Roles allowed to call this function. */
  roles: readonly Role[];
  /** If set, a mechanic caller must also have one of these `mechanicStatus` claims. */
  mechanicStatuses?: readonly MechanicStatus[];
  /** Input schema. `.strict()` is applied here, so unknown top-level fields are always rejected. */
  input: S;
  rateLimit?: RateLimit;
  /** Replay protection. Only for verifyStartOtp, confirmPayment, requestAccountDeletion. */
  consumeAppCheckToken?: boolean;
  /** Only requestAccountDeletion: a repeat request after the first one still answers. */
  allowPendingDeletion?: boolean;
  timeoutSeconds?: number;
}

export interface SecureContext<T> {
  uid: string;
  role: Role;
  claims: RoleClaims;
  data: T;
  request: CallableRequest<unknown>;
}

/** True if [uid]'s profile has `deletionRequestedAt` (users/{uid} or mechanics/{uid}). */
export type DeletionCheck = (role: 'customer' | 'mechanic', uid: string) => Promise<boolean>;

const firestoreDeletionCheck: DeletionCheck = async (role, uid) => {
  const profile = await db().doc(role === 'mechanic' ? `mechanics/${uid}` : `users/${uid}`).get();
  return Boolean(profile.get('deletionRequestedAt'));
};

let deletionCheck: DeletionCheck = firestoreDeletionCheck;

/** Tests without Firestore only. */
export function setDeletionCheck(next: DeletionCheck | null): void {
  deletionCheck = next ?? firestoreDeletionCheck;
}

export function secureCall<S extends z.ZodObject, R>(
  opts: SecureCallOptions<S>,
  handler: (ctx: SecureContext<z.infer<S>>) => Promise<R>,
): CallableFunction<unknown, Promise<R>> {
  const schema = opts.input.strict();

  return onCall(
    {
      region: REGION,
      enforceAppCheck: true,
      consumeAppCheckToken: opts.consumeAppCheckToken ?? false,
      timeoutSeconds: opts.timeoutSeconds,
    },
    async (request: CallableRequest<unknown>): Promise<R> => {
      // The SDK already rejects missing App Check tokens; this guards against a
      // misconfigured deploy. The emulator doesn't attach `request.app`.
      if (!request.app && process.env.FUNCTIONS_EMULATOR !== 'true') {
        throw new HttpsError('unauthenticated', 'error_app_check');
      }

      const auth = request.auth;
      if (!auth) throw new HttpsError('unauthenticated', 'error_unauthenticated');
      const uid = auth.uid;

      const claims = auth.token as RoleClaims;
      const role = claims.role;
      if (!role || !opts.roles.includes(role)) {
        throw new HttpsError('permission-denied', 'error_permission_denied');
      }
      if (
        role === 'mechanic' &&
        opts.mechanicStatuses &&
        (!claims.mechanicStatus || !opts.mechanicStatuses.includes(claims.mechanicStatus))
      ) {
        throw new HttpsError('permission-denied', 'error_mechanic_not_approved');
      }

      const parsed = schema.safeParse(request.data ?? {});
      if (!parsed.success) {
        // Only the field paths go back; never the rejected values.
        const fields = parsed.error.issues.map((i) => i.path.join('.') || '(root)');
        throw new HttpsError('invalid-argument', 'error_invalid_input', { fields });
      }

      try {
        if (opts.rateLimit) await enforceRateLimit(uid, opts.name, opts.rateLimit);
        if ((role === 'customer' || role === 'mechanic') && !opts.allowPendingDeletion) {
          if (await deletionCheck(role, uid)) throw new HttpsError('permission-denied', 'error_account_deleted');
        }
        // .strict() only rejects unknown keys; the output shape is still z.infer<S>.
        const data = parsed.data as z.infer<S>;
        return await handler({ uid, role, claims, data, request });
      } catch (err) {
        if (err instanceof HttpsError) throw err;
        // uid + function name only; the error message may carry user data.
        logger.error(`${opts.name} failed`, {
          uid,
          errorName: err instanceof Error ? err.name : typeof err,
          errorCode: (err as { code?: unknown })?.code ?? null,
        });
        throw new HttpsError('internal', 'error_internal');
      }
    },
  );
}

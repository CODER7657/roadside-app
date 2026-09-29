// Sliding-window rate limit stored in rateLimits/{uid} (PLAN §8, §12.6). Server only.

import { HttpsError } from 'firebase-functions/v2/https';
import { db } from './admin.js';

export interface RateLimit {
  /** Max calls allowed inside the window. */
  max: number;
  windowSeconds: number;
}

/** rateLimits/{uid}: one list of call times (ms since epoch) per callable. */
export interface RateLimitDoc {
  calls: Record<string, number[]>;
}

/**
 * Records one call of `key` for `uid`, or throws `resource-exhausted` if the
 * caller already made `limit.max` calls in the last `limit.windowSeconds`.
 */
export async function enforceRateLimit(
  uid: string,
  key: string,
  limit: RateLimit,
  now: number = Date.now(),
): Promise<void> {
  const ref = db().collection('rateLimits').doc(uid);
  const windowStart = now - limit.windowSeconds * 1000;

  const allowed = await db().runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const data = snap.data() as RateLimitDoc | undefined;
    const recent = (data?.calls?.[key] ?? []).filter((t) => t > windowStart);
    if (recent.length >= limit.max) return false;
    recent.push(now);
    tx.set(ref, { calls: { [key]: recent } }, { merge: true });
    return true;
  });

  if (!allowed) throw new HttpsError('resource-exhausted', 'error_rate_limited');
}

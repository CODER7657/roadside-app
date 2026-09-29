import type { CallableRequest } from 'firebase-functions/v2/https';

export const emulatorRunning = Boolean(process.env.FIRESTORE_EMULATOR_HOST);
export const authEmulatorRunning = Boolean(process.env.FIREBASE_AUTH_EMULATOR_HOST);

// Tests that call functions directly use their own emulator project, so the real
// triggers running in the Functions emulator (project demo-roadside) never react to
// their data. End-to-end trigger tests opt back in with triggerProjectApp().
// Each test file runs in its own process, and nothing calls db() at import time.
export const TRIGGER_PROJECT = 'demo-roadside';
if (emulatorRunning) process.env.GCLOUD_PROJECT = 'demo-roadside-unit';

interface FakeCall {
  data?: unknown;
  uid?: string;
  claims?: Record<string, unknown>;
  withAppCheck?: boolean;
}

/** Builds the request a callable's `.run()` receives, as the SDK would after verifying tokens. */
export function fakeRequest({
  data = {},
  uid,
  claims = {},
  withAppCheck = true,
}: FakeCall): CallableRequest<unknown> {
  return {
    data,
    auth: uid
      ? ({ uid, token: { uid, ...claims }, rawToken: 'test' } as unknown as CallableRequest['auth'])
      : undefined,
    app: withAppCheck
      ? ({ appId: 'test-app', token: {} } as unknown as CallableRequest['app'])
      : undefined,
    rawRequest: {} as CallableRequest['rawRequest'],
    acceptsStreaming: false,
  };
}

/** Resolves to the HttpsError code + message a call rejects with. */
export async function rejection(p: Promise<unknown>): Promise<{ code: string; message: string }> {
  try {
    await p;
  } catch (err) {
    const e = err as { code: string; message: string };
    return { code: e.code, message: e.message };
  }
  throw new Error('expected the call to reject');
}

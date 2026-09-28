# firebase/functions — P2 (Hem)

- TypeScript, Node 22, `firebase-functions` 2nd gen, region `asia-south1`.
- Every callable uses the shared `secureCall()` wrapper: `enforceAppCheck: true`, auth required, role claim check, `zod` schema with `.strict()`, rate limit (`rateLimits/{uid}`), `HttpsError` with a safe message key. `consumeAppCheckToken: true` on `verifyStartOtp`, `confirmPayment`, `requestAccountDeletion`.
- Status changes run in Firestore transactions using the transition table (mirror of `packages/roadside_core`). Unknown transitions throw `failed-precondition`.
- `createBooking` resolves `cityId` from `serviceAreas` and rejects `out_of_area`; dispatch filters by `cityId` (Ankleshwar↔Bharuch may cross-match at 10 km).
- Dispatch ignores `mechanicType`. Snapshot it into `mechanicCard` (with `shopName` or `experienceYears` + `travelVehicleRegNo`). `logVerificationCall` is an admin-only callable; approval of an independent mechanic fails without it (PLAN §10.0).
- Secrets via `defineSecret()`. Logs: `uid` + `bookingId` only — never phone numbers, OTPs, addresses, coordinates.
- Before every PR: `npm run lint`, `npm run build`, `firebase emulators:exec --project demo-roadside --only firestore,auth,functions "npm test"`.

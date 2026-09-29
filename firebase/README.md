# firebase/

Owner: P3 (Ayush) for rules, indexes, seed and config; P2 (Hem) for `functions/`.

| File | What |
|---|---|
| `firestore.rules` | Deny-by-default Firestore rules (PLAN §8, §12.4) |
| `storage.rules` | Deny-all placeholder until #47 |
| `firestore.indexes.json` | Composite indexes for history, admin lists and offers |
| `firebase.json` | Rules, indexes, Functions (`functions/`) and emulator ports |
| `rules_tests/` | Jest + `@firebase/rules-unit-testing`, allow + deny per collection and role |
| `seed/` | `serviceAreas` (3 cities), `appConfig/public`, `prices/*` |

## Run the rules tests

Needs Node 22 and JDK 21.

```bash
npm ci --prefix firebase/rules_tests
cd firebase
firebase emulators:exec --project demo-roadside --only firestore,storage "npm --prefix rules_tests test"
```

## Seed

```bash
npm ci --prefix firebase/seed
cd firebase
# emulator
firebase emulators:exec --project demo-roadside --only firestore "npm --prefix seed run seed"
# dev project (Application Default Credentials)
npm --prefix seed run seed -- --project roadside-dev --support-phone +91XXXXXXXXXX
```

Existing documents are kept; `--overwrite` replaces them. `roadside-prod` also needs `--allow-prod`.
Prices in `seed/data/prices.json` are placeholders until the client confirms them (admins edit
them in A4 afterwards).

## What clients may write

Everything else is read-only or Functions-only. Use `roadside_core` models and its stamp helpers:
the rules compare timestamps with `request.time`, so they must be server timestamps.

| Path | Who | Write with |
|---|---|---|
| `users/{uid}` | the customer | create: `stampNew(user.toJson())` (phone = Auth phone); update: name, language, emergencyContacts (≤ 3), fcmToken, consent + `stampUpdate` |
| `users/{uid}/vehicles/*` | the customer | `stampNew(vehicle.toJson())` with `normalizeRegNo()`; update + delete |
| `mechanics/{uid}` | the mechanic | M1: `stampNew(mechanic.toJson())`, only its own type's fields, `status` pending. While pending: profile fields. After review: `fcmToken` only |
| `mechanics/{uid}/private/kyc` | the mechanic | once, while pending, in the same batch as the profile or after it; paths under `mechanics/{uid}/kyc/` |
| `presence/{uid}` | approved mechanic | `stampUpdate(presence.toJson())`. First write sets `cityId` = profile city and `activeBookingId: null`; later only `isOnline`, `location`, `updatedAt` |
| `liveLocations/{bookingId}` | assigned mechanic, job active | `stampUpdate(liveLocation.toJson())`, `expireAt` ≈ now + 24 h |
| `bookings/{id}/messages/*` | participants, job active | `stampCreated(message.toJson())`, `senderId` = self, ≤ 500 chars |
| `reviews/{bookingId}` | the customer, completed booking | `stampCreated(review.toJson())`, once |
| `complaints/*` | booking participants | `stampCreated(complaint.toJson())`, `status: open` |
| `inbox/{uid}/items/*` | the owner | `read` only |
| `prices`, `serviceAreas`, `appConfig/public`, `complaints` (resolve) | admins | in a batch with an `auditLogs` entry (`at: serverTimestamp()`) |

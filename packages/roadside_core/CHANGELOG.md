## 0.1.0

First version of the shared contract (#44).

- `freezed` + `json_serializable` models for every PLAN §8 collection, including `serviceAreas`,
  `cityId` on bookings/mechanics/presence, and `mechanicType` with workshop/independent fields.
- Enums with their exact Firestore strings.
- The §9 status transition table (`kTransitions`, `canTransition`, `nextStatuses`) and UI helpers
  (`isActive`, `customerCanCancel`, `journeyStop`).
- Validators: phone (E.164 / Indian mobile), registration numbers (standard + BH), UPI ID,
  per-type mechanic profile and KYC checks.
- `resolveCity`, `distanceKm`, `encodeGeohash` (same results as Functions).
- `LaneLog` with redaction of phones, OTPs, addresses, coordinates, UPI IDs and tokens in release.
- `RoadsideRefs` typed Firestore references, `stampNew` / `stampUpdate`.
- `package:roadside_core/fakes.dart`: deterministic fakes of every model.
- Contract test that fails when the Dart and TypeScript models drift.

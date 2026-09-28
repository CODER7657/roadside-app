# packages/roadside_core — P3 (Ayush). Shared by all three apps: changes need P1 + P2 approval (CODEOWNERS)

- Create with `flutter create --template=package packages/roadside_core` (this file survives).
- `freezed` + `json_serializable` models for **every** PLAN §8 collection (incl. `serviceAreas`, `cityId` on bookings/mechanics/presence). No field that isn't in §8.
- `Mechanic.mechanicType` (`workshop` | `independent`) with type-specific required fields and validators (PLAN §8, §10.0); `MechanicCard` carries the type for the TrustPass.
- The §9 status transition table + helpers used by apps for UI logic (Functions has the TypeScript mirror — change both in one PR).
- Validators: E.164 phone, Indian + BH registration numbers, UPI ID (`^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$`).
- `LaneLog`: redacts phones, OTPs, addresses and coordinates in release builds.
- Fakes/fixtures for every model so P1/P2 can build screens before the backend is wired.

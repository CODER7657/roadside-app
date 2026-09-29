# roadside_core

The shared contract for the customer app, mechanic app and admin panel: Firestore models
(PLAN.md §8), the booking status machine (§9), validators, service-area lookup and `LaneLog` (§12.7).

Owner: P3 (Ayush). Changes need P1 + P2 approval. The TypeScript mirror lives in
`firebase/functions/src/models/`; change both in the same PR. `test/contract_test.dart` fails
when they drift.

## Add it to an app

```yaml
dependencies:
  roadside_core:
    path: ../packages/roadside_core
```

## What's inside

| Import | What |
|---|---|
| `package:roadside_core/roadside_core.dart` | Models, enums, `kTransitions`, validators, `resolveCity`, `encodeGeohash`, `LaneLog`, `RoadsideRefs` |
| `package:roadside_core/fakes.dart` | `RoadsideFakes`: every model, deterministic (fixed clock), for tests, Widgetbook and fake repositories |

### Reading and writing Firestore

Read through the typed refs; write plain maps with server timestamps (the rules compare
`createdAt` / `updatedAt` with `request.time`):

```dart
final refs = RoadsideRefs(FirebaseFirestore.instance);

// read
Stream<Booking?> booking = refs.booking(id).snapshots().map((s) => s.data());
Stream<List<Vehicle>> vehicles =
    refs.vehicles(uid).snapshots().map((q) => q.docs.map((d) => d.data()).toList());

// create / update
await refs.raw(refs.vehicles(uid).doc()).set(stampNew(vehicle.toJson()));
await refs.raw(refs.user(uid)).update(stampUpdate({'language': Language.gu.value}));
await refs.raw(refs.messages(bookingId).doc()).set(stampCreated(message.toJson()));
```

`firebase/README.md` lists which stamp each path takes (e.g. `presence` and `liveLocations`
always use `stampUpdate`).

Enums carry their Firestore string in `.value`; use it in queries:
`refs.bookings.where('status', whereIn: kActiveStatuses.map((s) => s.value).toList())`.

Clients never write `bookings`, `offers`, OTPs, ratings or statuses; those go through the
callables in PLAN §9.

### Building screens before the backend exists

```dart
import 'package:roadside_core/fakes.dart';

RoadsideFakes.booking(status: BookingStatus.arriving);           // independent mechanic
RoadsideFakes.booking(status: BookingStatus.arriving, independent: false); // workshop
RoadsideFakes.bookingsByStatus;   // one per status
RoadsideFakes.offer();            // M4 incoming request
RoadsideFakes.pendingMechanic;    // A2 approvals / M2 pending (independent, Ankleshwar)
RoadsideFakes.serviceAreas;       // the three launch cities
RoadsideFakes.price(VehicleType.car, ProblemType.flatTyre);
```

### Status logic in the UI

```dart
booking.status.customerCanCancel;   // show "Cancel"?
booking.status.journeyStop;         // which Journey Rail stop is lit
nextStatuses(booking.status, Actor.mechanic);
```

### Forms

Validators return `null` or an error key from `ValidationError` (add each key to your ARB files):

```dart
TextFormField(validator: (v) => errorText(validateRegNo(v)));   // then store normalizeRegNo(v)
TextFormField(validator: (v) => errorText(validatePhone(v)));   // then store normalizePhone(v)
mechanicProfileErrors(mechanic);   // {field: errorKey} per workshop / independent rules
mechanicKycErrors(kyc, mechanic.mechanicType);
```

### Logging

`print` is banned. Use `LaneLog` and log ids, not personal data. Release builds redact phones,
OTPs, addresses, coordinates, UPI IDs and tokens anyway.

```dart
LaneLog.i('booking created', {'bookingId': id});
LaneLog.e('createBooking failed', error: e, stackTrace: st);
```

Route it to Crashlytics once in `main_*.dart`: see the header of `lib/src/lane_log.dart`.

## Changing a model

1. Edit the model in `lib/src/models/` **and** its interface in `firebase/functions/src/models/`.
2. Regenerate and check:
   ```bash
   dart run build_runner build
   dart format .
   flutter analyze --fatal-infos
   flutter test
   ```
3. Bump `version` in `pubspec.yaml` and add a `CHANGELOG.md` entry.

Generated files (`*.freezed.dart`, `*.g.dart`) are committed: apps use this package by path and
don't run its code generation.

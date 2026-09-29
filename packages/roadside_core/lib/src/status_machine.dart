// Booking status machine (PLAN.md §9). Mirror of firebase/functions/src/models/status.ts.
// Change both in the same PR. Apps use it for UI logic only: every real status change is made
// by a Cloud Function in a transaction.

import 'enums.dart';

/// One allowed move from [from] to [to], made by one of [by].
class Transition {
  const Transition(this.from, this.to, this.by);

  final BookingStatus from;
  final BookingStatus to;
  final List<Actor> by;
}

const List<Transition> kTransitions = [
  Transition(BookingStatus.requested, BookingStatus.accepted, [Actor.mechanic]), // respondToOffer
  Transition(BookingStatus.requested, BookingStatus.noMechanicFound, [Actor.system]), // dispatch sweep
  Transition(BookingStatus.requested, BookingStatus.cancelled, [Actor.customer, Actor.admin]),

  Transition(BookingStatus.accepted, BookingStatus.arriving, [Actor.mechanic]), // startTrip
  // cancelBooking → re-dispatch
  Transition(BookingStatus.accepted, BookingStatus.requested, [Actor.mechanic]),
  Transition(BookingStatus.accepted, BookingStatus.cancelled, [Actor.customer, Actor.admin]),

  Transition(BookingStatus.arriving, BookingStatus.arrived, [Actor.mechanic]), // markArrived
  // cancelBooking → re-dispatch
  Transition(BookingStatus.arriving, BookingStatus.requested, [Actor.mechanic]),
  Transition(BookingStatus.arriving, BookingStatus.cancelled, [Actor.customer, Actor.admin]),

  Transition(BookingStatus.arrived, BookingStatus.inProgress, [Actor.mechanic]), // verifyStartOtp
  Transition(BookingStatus.arrived, BookingStatus.cancelled, [Actor.customer, Actor.mechanic, Actor.admin]),

  Transition(BookingStatus.inProgress, BookingStatus.completed, [Actor.mechanic]), // completeJob
];

/// Statuses that count as "the customer has an active booking".
const List<BookingStatus> kActiveStatuses = [
  BookingStatus.requested,
  BookingStatus.accepted,
  BookingStatus.arriving,
  BookingStatus.arrived,
  BookingStatus.inProgress,
];

bool canTransition(BookingStatus from, BookingStatus to, Actor by) =>
    kTransitions.any((t) => t.from == from && t.to == to && t.by.contains(by));

/// The statuses [by] may move a booking to from [from].
List<BookingStatus> nextStatuses(BookingStatus from, Actor by) => [
  for (final t in kTransitions)
    if (t.from == from && t.by.contains(by)) t.to,
];

/// The six stops of the Journey Rail: Requested · Accepted · On the way · Arrived · Working · Done.
enum JourneyStop { requested, accepted, onTheWay, arrived, working, done }

extension BookingStatusX on BookingStatus {
  bool get isActive => kActiveStatuses.contains(this);

  /// The booking can't change any more.
  bool get isTerminal =>
      this == BookingStatus.completed ||
      this == BookingStatus.cancelled ||
      this == BookingStatus.noMechanicFound;

  /// The customer may cancel (any time before `in_progress`).
  bool get customerCanCancel => canTransition(this, BookingStatus.cancelled, Actor.customer);

  /// The mechanic knows the pickup address and customer phone (after accept).
  bool get isAssigned =>
      this == BookingStatus.accepted ||
      this == BookingStatus.arriving ||
      this == BookingStatus.arrived ||
      this == BookingStatus.inProgress ||
      this == BookingStatus.completed;

  /// The Journey Rail stop for this status; null when the booking ended without a job.
  JourneyStop? get journeyStop => switch (this) {
    BookingStatus.requested => JourneyStop.requested,
    BookingStatus.accepted => JourneyStop.accepted,
    BookingStatus.arriving => JourneyStop.onTheWay,
    BookingStatus.arrived => JourneyStop.arrived,
    BookingStatus.inProgress => JourneyStop.working,
    BookingStatus.completed => JourneyStop.done,
    BookingStatus.cancelled || BookingStatus.noMechanicFound => null,
  };
}

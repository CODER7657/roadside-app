import 'package:flutter_test/flutter_test.dart';
import 'package:roadside_core/roadside_core.dart';

void main() {
  test('happy path is allowed for the mechanic', () {
    const path = [
      BookingStatus.requested,
      BookingStatus.accepted,
      BookingStatus.arriving,
      BookingStatus.arrived,
      BookingStatus.inProgress,
      BookingStatus.completed,
    ];
    for (var i = 0; i < path.length - 1; i++) {
      expect(
        canTransition(path[i], path[i + 1], Actor.mechanic),
        isTrue,
        reason: '${path[i]} → ${path[i + 1]}',
      );
    }
  });

  test('customers and admins cancel before in_progress, never after', () {
    for (final s in [
      BookingStatus.requested,
      BookingStatus.accepted,
      BookingStatus.arriving,
      BookingStatus.arrived,
    ]) {
      expect(canTransition(s, BookingStatus.cancelled, Actor.customer), isTrue);
      expect(canTransition(s, BookingStatus.cancelled, Actor.admin), isTrue);
    }
    expect(canTransition(BookingStatus.inProgress, BookingStatus.cancelled, Actor.customer), isFalse);
    expect(BookingStatus.inProgress.customerCanCancel, isFalse);
    expect(BookingStatus.arriving.customerCanCancel, isTrue);
  });

  test('mechanic cancels before arrival by re-dispatch, after arrival by cancelling', () {
    expect(canTransition(BookingStatus.arriving, BookingStatus.requested, Actor.mechanic), isTrue);
    expect(canTransition(BookingStatus.arriving, BookingStatus.cancelled, Actor.mechanic), isFalse);
    expect(canTransition(BookingStatus.arrived, BookingStatus.cancelled, Actor.mechanic), isTrue);
    expect(canTransition(BookingStatus.arrived, BookingStatus.requested, Actor.mechanic), isFalse);
  });

  test('nobody skips steps or leaves a terminal status', () {
    expect(canTransition(BookingStatus.accepted, BookingStatus.arrived, Actor.mechanic), isFalse);
    expect(canTransition(BookingStatus.requested, BookingStatus.accepted, Actor.customer), isFalse);
    for (final end in BookingStatus.values.where((s) => s.isTerminal)) {
      for (final actor in Actor.values) {
        expect(nextStatuses(end, actor), isEmpty, reason: '$end by $actor');
      }
    }
  });

  test('only the system gives up with no_mechanic_found', () {
    expect(nextStatuses(BookingStatus.requested, Actor.system), [BookingStatus.noMechanicFound]);
  });

  test('active and terminal statuses split the set', () {
    for (final s in BookingStatus.values) {
      expect(s.isActive ^ s.isTerminal, isTrue, reason: '$s');
    }
  });

  test('journey stops', () {
    expect(BookingStatus.arriving.journeyStop, JourneyStop.onTheWay);
    expect(BookingStatus.inProgress.journeyStop, JourneyStop.working);
    expect(BookingStatus.cancelled.journeyStop, isNull);
    expect(BookingStatus.requested.isAssigned, isFalse);
    expect(BookingStatus.accepted.isAssigned, isTrue);
  });
}

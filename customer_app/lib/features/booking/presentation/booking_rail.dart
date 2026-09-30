import 'package:flutter/widgets.dart';
import 'package:lane_ui/lane_ui.dart' hide PriceRange;
import 'package:roadside_core/roadside_core.dart' as core show JourneyStop;
import 'package:roadside_core/roadside_core.dart' hide JourneyStop;

import '../../../l10n/app_localizations.dart';

/// PLAN §9's six stops as a JourneyRail, in roadside_core's order; the booking says where it is.
Widget bookingRail(AppLocalizations l10n, Booking booking) => JourneyRail(
  stops: [
    for (final stop in core.JourneyStop.values)
      JourneyStop(
        label: switch (stop) {
          core.JourneyStop.requested => l10n.stop_requested,
          core.JourneyStop.accepted => l10n.stop_accepted,
          core.JourneyStop.onTheWay => l10n.stop_on_the_way,
          core.JourneyStop.arrived => l10n.stop_arrived,
          core.JourneyStop.working => l10n.stop_working,
          core.JourneyStop.done => l10n.stop_done,
        },
        signal: switch (stop) {
          core.JourneyStop.requested => LaneSignal.wait,
          core.JourneyStop.accepted || core.JourneyStop.onTheWay => LaneSignal.route,
          core.JourneyStop.arrived || core.JourneyStop.done => LaneSignal.go,
          core.JourneyStop.working => LaneSignal.work,
        },
      ),
  ],
  current: booking.status.journeyStop?.index ?? 0,
);

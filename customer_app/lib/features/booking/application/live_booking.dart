import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadside_core/roadside_core.dart';

import 'estimate.dart';

/// One booking as it changes (U8–U10). Null when it doesn't exist or isn't the customer's.
final liveBookingProvider = StreamProvider.autoDispose.family<Booking?, String>(
  (ref, bookingId) => ref.watch(bookingRepositoryProvider).watch(bookingId),
);

/// The start code the customer reads out to the mechanic (PLAN §9, `private/otp`).
final startCodeProvider = StreamProvider.autoDispose.family<String?, String>(
  (ref, bookingId) => ref.watch(bookingRepositoryProvider).watchOtp(bookingId).map((otp) => otp?.code),
);

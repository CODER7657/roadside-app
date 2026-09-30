import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadside_core/roadside_core.dart';

import '../data/location.dart';
import '../data/plus_code.dart';
import 'booking_draft.dart';

final locationServiceProvider = Provider<LocationService>((ref) => const GeolocatorLocationService());

/// The phone's geocoder until the map provider is chosen (then its geocoding API).
final reverseGeocoderProvider = Provider<ReverseGeocoder>((ref) => const PlatformReverseGeocoder());

/// Where the pin starts when there's no GPS reading: central Ahmedabad, the first city.
const fallbackCenter = (lat: 23.0225, lng: 72.5714);

/// PLAN §11: a pin further than this from the phone's reading needs "booking for someone else".
const maxPinDistanceKm = 2.0;

enum PickupStatus {
  /// Waiting for a good GPS reading.
  locating,

  /// Have a reading (or the customer placed the pin by hand).
  ready,

  /// No location permission: the customer can still drag the pin.
  noPermission,

  /// GPS switched off.
  gpsOff,

  /// No reading in 15 s.
  noFix,
}

@immutable
class PickupState {
  const PickupState({
    this.status = PickupStatus.locating,
    this.fix,
    this.pin,
    this.dragging = false,
    this.address,
    this.addressLoading = false,
    this.landmark = '',
    this.forSomeoneElse = false,
  });

  final PickupStatus status;

  /// The best GPS reading.
  final LocationFix? fix;

  /// The point under the pin.
  final LatLng? pin;
  final bool dragging;
  final String? address;
  final bool addressLoading;
  final String landmark;
  final bool forSomeoneElse;

  String? get plusCode => pin == null ? null : encodePlusCode(pin!.lat, pin!.lng);

  bool get farFromFix =>
      fix != null &&
      pin != null &&
      distanceKm(fix!.position.lat, fix!.position.lng, pin!.lat, pin!.lng) > maxPinDistanceKm;

  bool get canConfirm => pin != null && !dragging && !addressLoading && (!farFromFix || forSomeoneElse);

  PickupState copyWith({
    PickupStatus? status,
    LocationFix? fix,
    LatLng? pin,
    bool? dragging,
    String? Function()? address,
    bool? addressLoading,
    String? landmark,
    bool? forSomeoneElse,
  }) => PickupState(
    status: status ?? this.status,
    fix: fix ?? this.fix,
    pin: pin ?? this.pin,
    dragging: dragging ?? this.dragging,
    address: address != null ? address() : this.address,
    addressLoading: addressLoading ?? this.addressLoading,
    landmark: landmark ?? this.landmark,
    forSomeoneElse: forSomeoneElse ?? this.forSomeoneElse,
  );
}

/// U6's state: finds the phone, follows the pin, looks up its address and hands the
/// confirmed pickup to the booking draft.
class PickupNotifier extends Notifier<PickupState> {
  /// Ignores an address that arrives after the pin moved again.
  int _lookup = 0;
  String _languageCode = 'en';

  /// Each [locate] call is a run; only the latest one may change the state.
  int _run = 0;

  /// Completed to stop the GPS of the current run.
  Completer<void>? _stop;

  @override
  PickupState build() {
    // Leaving U6 switches GPS off at once, not after the 15 s wait.
    ref.onDispose(_stopLocating);
    return const PickupState();
  }

  void _stopLocating() {
    final stop = _stop;
    if (stop != null && !stop.isCompleted) stop.complete();
  }

  LocationService get _location => ref.read(locationServiceProvider);

  /// Starts locating. [permitted] is the C7 explainer's answer. Without a reading the pin
  /// starts at [fallbackCenter] and the customer drags it.
  Future<void> locate({required bool permitted, required String languageCode}) async {
    _languageCode = languageCode;
    // A newer call replaces an older one (e.g. back from Settings twice): one GPS at a time.
    _stopLocating();
    final run = ++_run;
    if (!permitted) return _manual(PickupStatus.noPermission);
    final enabled = await _location.serviceEnabled();
    if (!ref.mounted || run != _run) return;
    if (!enabled) return _manual(PickupStatus.gpsOff);
    state = state.copyWith(status: PickupStatus.locating);
    final stop = _stop = Completer<void>();
    LocationFix? fix;
    try {
      fix = await bestFix(
        _location.fixes(),
        stop: stop.future,
        onFix: (f) {
          // Follow improving readings while the customer hasn't touched the pin.
          if (ref.mounted && run == _run && state.status == PickupStatus.locating && !state.dragging) {
            state = state.copyWith(fix: f, pin: f.position);
          }
        },
      );
    } catch (e, s) {
      LaneLog.w('pickup location failed', error: e, stackTrace: s);
    }
    if (!ref.mounted || run != _run) return;
    if (fix == null) return _manual(PickupStatus.noFix);
    final keepPin = state.pin != null && state.status != PickupStatus.locating;
    state = state.copyWith(status: PickupStatus.ready, fix: fix, pin: keepPin ? state.pin : fix.position);
    await _lookupAddress();
  }

  Future<void> _manual(PickupStatus status) async {
    if (!ref.mounted) return;
    state = state.copyWith(status: status, pin: state.pin ?? fallbackCenter);
    await _lookupAddress();
  }

  void dragStarted() => state = state.copyWith(dragging: true);

  /// The map settled with [center] under the pin.
  Future<void> dragEnded(LatLng center) async {
    state = state.copyWith(
      dragging: false,
      pin: center,
      // A pin placed by hand counts as ready even while GPS is still searching.
      status: state.status == PickupStatus.locating ? PickupStatus.ready : state.status,
    );
    await _lookupAddress();
  }

  /// "Go to my location": the pin back on the GPS reading.
  Future<void> recenter() async {
    final fix = state.fix;
    if (fix == null) return;
    state = state.copyWith(pin: fix.position);
    await _lookupAddress();
  }

  void setLandmark(String text) => state = state.copyWith(landmark: text);
  void setForSomeoneElse(bool value) => state = state.copyWith(forSomeoneElse: value);

  Future<void> _lookupAddress() async {
    final pin = state.pin;
    if (pin == null) return;
    final id = ++_lookup;
    state = state.copyWith(addressLoading: true);
    String? address;
    try {
      address = await ref.read(reverseGeocoderProvider).addressAt(pin, languageCode: _languageCode);
    } catch (e, s) {
      // Offline or no geocoder: the Plus Code stands in for the address.
      LaneLog.w('reverse geocode failed', error: e, stackTrace: s);
    }
    if (!ref.mounted || id != _lookup) return;
    state = state.copyWith(address: () => address, addressLoading: false);
  }

  /// Saves the pickup in the booking draft. False if it can't be confirmed yet.
  bool confirm() {
    final s = state;
    if (!s.canConfirm) return false;
    final plusCode = s.plusCode!;
    ref
        .read(bookingDraftProvider.notifier)
        .setPickup(
          PickupDraft(
            lat: s.pin!.lat,
            lng: s.pin!.lng,
            // A road with no address: the Plus Code is the address.
            address: s.address ?? plusCode,
            landmark: s.landmark.trim(),
            plusCode: plusCode,
            // Unknown without a reading; the pin is confirmed, so `createBooking` accepts it.
            accuracyMeters: s.fix?.accuracyMeters ?? unknownAccuracyMeters,
          ),
        );
    return true;
  }

  /// `createBooking`'s upper bound for `accuracyMeters`.
  static const unknownAccuracyMeters = 10000.0;
}

final pickupProvider = NotifierProvider.autoDispose<PickupNotifier, PickupState>(PickupNotifier.new);

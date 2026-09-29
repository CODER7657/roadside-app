// Fakes for every model so screens, Widgetbook use-cases and golden tests can be built before
// the backend is wired. Deterministic: everything is relative to [RoadsideFakes.now].
// The scene matches the mockups: a customer in Thaltej, the mechanic coming from Bodakdev.
//
// Import `package:roadside_core/fakes.dart` from tests, Widgetbook and fake repositories only.

import 'package:cloud_firestore/cloud_firestore.dart';

import '../enums.dart';
import '../geo.dart';
import '../models/booking.dart';
import '../models/common.dart';
import '../models/mechanic.dart';
import '../models/platform.dart';
import '../models/user.dart';

abstract final class RoadsideFakes {
  /// Fixed clock for all fakes (29 Sep 2026, 10:30 IST).
  static final DateTime now = DateTime.utc(2026, 9, 29, 5);

  static const String customerId = 'fake-customer-riya';
  static const String workshopMechanicId = 'fake-mechanic-imran';
  static const String independentMechanicId = 'fake-mechanic-kiran';
  static const String pendingMechanicId = 'fake-mechanic-pending';
  static const String adminId = 'fake-admin';
  static const String bookingId = 'fakeBooking00000001';
  static const String offerId = 'fakeOffer0000000001';

  // Thaltej (pickup) and Bodakdev (mechanic's start), Ahmedabad.
  static const GeoPoint thaltej = GeoPoint(23.0497, 72.5117);
  static const GeoPoint bodakdev = GeoPoint(23.0395, 72.5066);
  static const GeoPoint ankleshwarGidc = GeoPoint(21.6264, 73.0152);

  // ---------------------------------------------------------------- platform

  static const String supportPhone = '+919800000000';

  static Map<CityId, ServiceArea> get serviceAreas => {
    CityId.ahmedabad: ServiceArea(
      name: const LocalizedText(en: 'Ahmedabad', hi: 'अहमदाबाद', gu: 'અમદાવાદ'),
      center: const GeoPoint(23.0225, 72.5714),
      radiusKm: 25,
      active: true,
      supportPhone: supportPhone,
      launchedAt: now,
    ),
    CityId.ankleshwar: ServiceArea(
      name: const LocalizedText(en: 'Ankleshwar', hi: 'अंकलेश्वर', gu: 'અંકલેશ્વર'),
      center: const GeoPoint(21.6264, 73.0152),
      radiusKm: 12,
      active: true,
      supportPhone: supportPhone,
      launchedAt: now,
    ),
    CityId.bharuch: ServiceArea(
      name: const LocalizedText(en: 'Bharuch', hi: 'भरूच', gu: 'ભરૂચ'),
      center: const GeoPoint(21.7051, 72.9959),
      radiusKm: 12,
      active: true,
      supportPhone: supportPhone,
      launchedAt: now,
    ),
  };

  static const AppConfig appConfig = AppConfig(
    minSupportedBuild: 1,
    supportPhone: supportPhone,
    dispatchEnabled: true,
  );

  /// App config in maintenance, for the kill-switch / force-update screens.
  static const AppConfig appConfigMaintenance = AppConfig(
    minSupportedBuild: 999,
    maintenanceMessage: 'We are updating the app. Back in 30 minutes.',
    supportPhone: supportPhone,
    dispatchEnabled: false,
  );

  static const Map<ProblemType, String> _includes = {
    ProblemType.flatTyre: 'Puncture repair or spare fitting',
    ProblemType.battery: 'Jump start and battery check',
    ProblemType.wontStart: 'Diagnosis and minor fix on the spot',
    ProblemType.overheating: 'Coolant top-up and hose check',
    ProblemType.accident: 'On-site assessment and first repair',
    ProblemType.fuel: 'Fuel delivery (fuel paid separately)',
    ProblemType.other: 'Diagnosis on the spot',
  };

  /// A price for every vehicle × problem (`prices/{vehicleType_problemType}`).
  static Price price(VehicleType vehicleType, ProblemType problemType) {
    final twoWheeler = vehicleType == VehicleType.bike || vehicleType == VehicleType.scooter;
    final (min, max) = switch (problemType) {
      ProblemType.flatTyre => twoWheeler ? (150, 300) : (350, 600),
      ProblemType.battery => twoWheeler ? (250, 500) : (400, 900),
      ProblemType.wontStart => twoWheeler ? (200, 500) : (400, 1000),
      ProblemType.overheating => twoWheeler ? (250, 600) : (400, 1000),
      ProblemType.accident => twoWheeler ? (300, 1000) : (500, 1500),
      ProblemType.fuel => twoWheeler ? (150, 300) : (250, 450),
      ProblemType.other => twoWheeler ? (200, 500) : (300, 800),
    };
    final highway = vehicleType == VehicleType.car && problemType == ProblemType.flatTyre;
    return Price(
      vehicleType: vehicleType,
      problemType: problemType,
      min: min,
      max: max,
      includes: _includes[problemType]!,
      cityOverrides: highway
          ? const {
              CityId.ankleshwar: PriceRange(min: 400, max: 700),
              CityId.bharuch: PriceRange(min: 400, max: 700),
            }
          : null,
      createdAt: now,
      updatedAt: now,
    );
  }

  static List<Price> get prices => [
    for (final v in VehicleType.values)
      for (final p in ProblemType.values) price(v, p),
  ];

  // ---------------------------------------------------------------- customer

  static AppUser get customer => AppUser(
    name: 'Riya Shah',
    phone: '+919800000001',
    language: Language.en,
    emergencyContacts: const [
      Contact(name: 'Amit Shah', phone: '+919800000002'),
      Contact(name: 'Neha Shah', phone: '+919800000003'),
    ],
    consent: Consent(version: '2026-09', acceptedAt: now.subtract(const Duration(days: 3))),
    createdAt: now.subtract(const Duration(days: 3)),
    updatedAt: now.subtract(const Duration(days: 3)),
  );

  static Vehicle get car => Vehicle(
    type: VehicleType.car,
    brand: 'Maruti Suzuki',
    model: 'Swift',
    regNo: 'GJ01AB1234',
    fuel: Fuel.petrol,
    isDefault: true,
    createdAt: now.subtract(const Duration(days: 3)),
    updatedAt: now.subtract(const Duration(days: 3)),
  );

  static Vehicle get scooter => Vehicle(
    type: VehicleType.scooter,
    brand: 'Honda',
    model: 'Activa 6G',
    regNo: 'GJ01CD5678',
    fuel: Fuel.petrol,
    createdAt: now.subtract(const Duration(days: 2)),
    updatedAt: now.subtract(const Duration(days: 2)),
  );

  static Vehicle get ev => Vehicle(
    type: VehicleType.ev,
    brand: 'Tata',
    model: 'Nexon EV',
    regNo: '22BH1234AA',
    fuel: Fuel.electric,
    createdAt: now.subtract(const Duration(days: 1)),
    updatedAt: now.subtract(const Duration(days: 1)),
  );

  static List<Vehicle> get vehicles => [car, scooter, ev];

  // ---------------------------------------------------------------- mechanics

  static Mechanic get workshopMechanic => Mechanic(
    name: 'Imran Shaikh',
    profilePhotoUrl: 'https://example.invalid/mechanics/imran.jpg',
    mechanicType: MechanicType.workshop,
    shopName: 'Shaikh Auto Works',
    shopAddress: 'Shop 4, Judges Bungalow Rd, Bodakdev, Ahmedabad',
    shopPhotoUrl: 'https://example.invalid/mechanics/imran-shop.jpg',
    cityId: CityId.ahmedabad,
    vehicleTypes: const [VehicleType.car, VehicleType.bike, VehicleType.scooter],
    services: const [
      ProblemType.flatTyre,
      ProblemType.battery,
      ProblemType.wontStart,
      ProblemType.overheating,
    ],
    status: MechanicStatus.approved,
    rating: 4.8,
    ratingCount: 212,
    jobsCompleted: 240,
    createdAt: now.subtract(const Duration(days: 60)),
    updatedAt: now.subtract(const Duration(days: 1)),
  );

  static Mechanic get independentMechanic => Mechanic(
    name: 'Kiran Patel',
    profilePhotoUrl: 'https://example.invalid/mechanics/kiran.jpg',
    mechanicType: MechanicType.independent,
    baseArea: const BaseArea(locality: 'Bodakdev', geopoint: bodakdev),
    experienceYears: 6,
    toolkitPhotoUrls: const [
      'https://example.invalid/mechanics/kiran-toolkit-1.jpg',
      'https://example.invalid/mechanics/kiran-toolkit-2.jpg',
    ],
    travelVehicle: const TravelVehicle(type: VehicleType.bike, regNo: 'GJ01EF4321'),
    cityId: CityId.ahmedabad,
    vehicleTypes: const [VehicleType.car, VehicleType.bike, VehicleType.scooter, VehicleType.ev],
    services: ProblemType.values,
    status: MechanicStatus.approved,
    rating: 4.6,
    ratingCount: 58,
    jobsCompleted: 64,
    createdAt: now.subtract(const Duration(days: 30)),
    updatedAt: now.subtract(const Duration(days: 1)),
  );

  /// A just-registered independent mechanic in Ankleshwar, for A2 approvals and M2 pending.
  static Mechanic get pendingMechanic => Mechanic(
    name: 'Suresh Vasava',
    profilePhotoUrl: 'https://example.invalid/mechanics/suresh.jpg',
    mechanicType: MechanicType.independent,
    baseArea: const BaseArea(locality: 'GIDC Ankleshwar', geopoint: ankleshwarGidc),
    experienceYears: 9,
    toolkitPhotoUrls: const [
      'https://example.invalid/mechanics/suresh-toolkit-1.jpg',
      'https://example.invalid/mechanics/suresh-toolkit-2.jpg',
      'https://example.invalid/mechanics/suresh-toolkit-3.jpg',
    ],
    travelVehicle: const TravelVehicle(type: VehicleType.scooter, regNo: 'GJ16GH7788'),
    cityId: CityId.ankleshwar,
    vehicleTypes: const [VehicleType.bike, VehicleType.scooter],
    services: const [ProblemType.flatTyre, ProblemType.battery, ProblemType.wontStart],
    createdAt: now.subtract(const Duration(hours: 5)),
    updatedAt: now.subtract(const Duration(hours: 5)),
  );

  static MechanicKyc get workshopKyc => MechanicKyc(
    phone: '+919800000011',
    idProofPath: 'mechanics/$workshopMechanicId/kyc/id-proof.jpg',
    upiId: 'imran.shaikh@okaxis',
    upiName: 'IMRAN SHAIKH',
    kycCheckedBy: adminId,
    kycCheckedAt: now.subtract(const Duration(days: 59)),
    createdAt: now.subtract(const Duration(days: 60)),
    updatedAt: now.subtract(const Duration(days: 59)),
  );

  static MechanicKyc get independentKyc => MechanicKyc(
    phone: '+919800000012',
    idProofPath: 'mechanics/$independentMechanicId/kyc/id-proof.jpg',
    upiId: 'kiranpatel@oksbi',
    upiName: 'KIRAN PATEL',
    kycCheckedBy: adminId,
    kycCheckedAt: now.subtract(const Duration(days: 29)),
    selfieWithIdPath: 'mechanics/$independentMechanicId/kyc/selfie-with-id.jpg',
    addressProofPath: 'mechanics/$independentMechanicId/kyc/address-proof.jpg',
    referenceContact: const Contact(name: 'Patel Motors', phone: '+919800000020'),
    verificationCall: VerificationCall(
      doneBy: adminId,
      at: now.subtract(const Duration(days: 29)),
      notes: 'Video call, ID matched, 6 years at Patel Motors confirmed.',
    ),
    createdAt: now.subtract(const Duration(days: 30)),
    updatedAt: now.subtract(const Duration(days: 29)),
  );

  /// KYC of [pendingMechanic]: submitted, not yet checked, no verification call.
  static MechanicKyc get pendingKyc => MechanicKyc(
    phone: '+919800000013',
    idProofPath: 'mechanics/$pendingMechanicId/kyc/id-proof.jpg',
    upiId: 'suresh.v@ybl',
    upiName: 'SURESH VASAVA',
    selfieWithIdPath: 'mechanics/$pendingMechanicId/kyc/selfie-with-id.jpg',
    addressProofPath: 'mechanics/$pendingMechanicId/kyc/address-proof.jpg',
    createdAt: now.subtract(const Duration(hours: 5)),
    updatedAt: now.subtract(const Duration(hours: 5)),
  );

  static Presence presence({bool isOnline = true, String? activeBookingId}) => Presence(
    isOnline: isOnline,
    location: GeoLocation(geopoint: bodakdev, geohash: encodeGeohash(bodakdev.latitude, bodakdev.longitude)),
    updatedAt: now,
    cityId: CityId.ahmedabad,
    activeBookingId: activeBookingId,
  );

  static MechanicCard cardFor(Mechanic m, MechanicKyc kyc) => MechanicCard(
    name: m.name,
    photoUrl: m.profilePhotoUrl,
    mechanicType: m.mechanicType,
    shopName: m.shopName,
    experienceYears: m.experienceYears,
    travelVehicleRegNo: m.travelVehicle?.regNo,
    rating: m.rating,
    jobsCompleted: m.jobsCompleted,
    phone: kyc.phone,
    upiId: kyc.upiId,
    upiName: kyc.upiName,
  );

  // ---------------------------------------------------------------- bookings

  static Offer offer({OfferState state = OfferState.pending}) => Offer(
    bookingId: bookingId,
    mechanicId: independentMechanicId,
    vehicleType: VehicleType.car,
    problemType: ProblemType.flatTyre,
    regNo: 'GJ01AB1234',
    distanceKm: 2.47,
    areaName: 'Thaltej',
    priceEstimate: const PriceRange(min: 350, max: 600),
    expiresAt: now.add(const Duration(seconds: 30)),
    state: state,
    createdAt: now,
    updatedAt: now,
  );

  static const List<BookingStatus> _happyPath = [
    BookingStatus.requested,
    BookingStatus.accepted,
    BookingStatus.arriving,
    BookingStatus.arrived,
    BookingStatus.inProgress,
    BookingStatus.completed,
  ];

  /// A car flat-tyre booking in Thaltej at [status], with history, timestamps and cards that
  /// match. [independent] picks which mechanic accepted it.
  static Booking booking({
    BookingStatus status = BookingStatus.arriving,
    bool independent = true,
    PaymentStatus? paymentStatus,
  }) {
    final mechanicId = independent ? independentMechanicId : workshopMechanicId;
    final card = independent
        ? cardFor(independentMechanic, independentKyc)
        : cardFor(workshopMechanic, workshopKyc);

    // How far along the happy path the booking got before ending (for cancelled / not found).
    final reached = switch (status) {
      BookingStatus.cancelled => 2, // cancelled while the mechanic was on the way
      BookingStatus.noMechanicFound => 0,
      _ => _happyPath.indexOf(status),
    };
    final start = now.subtract(const Duration(minutes: 40));
    DateTime at(int step) => start.add(Duration(minutes: step * 6));

    final history = [
      for (var i = 0; i <= reached; i++)
        StatusHistoryEntry(status: _happyPath[i], at: at(i), by: i == 0 ? customerId : mechanicId),
      if (status == BookingStatus.cancelled)
        StatusHistoryEntry(status: status, at: at(reached + 1), by: customerId),
      if (status == BookingStatus.noMechanicFound)
        StatusHistoryEntry(status: status, at: at(1), by: 'system'),
    ];
    final assigned = reached >= 1;
    final done = status == BookingStatus.completed;

    return Booking(
      customerId: customerId,
      mechanicId: assigned ? mechanicId : null,
      cityId: CityId.ahmedabad,
      vehicle: const BookingVehicle(
        type: VehicleType.car,
        brand: 'Maruti Suzuki',
        model: 'Swift',
        regNo: 'GJ01AB1234',
      ),
      problemType: ProblemType.flatTyre,
      description: 'Rear left tyre is flat, spare is in the boot.',
      pickup: Pickup(
        geopoint: thaltej,
        geohash: encodeGeohash(thaltej.latitude, thaltej.longitude),
        address: 'Near Thaltej Cross Roads, SG Highway, Ahmedabad',
        landmark: 'Opposite the petrol pump',
        plusCode: '3GXV+V5 Ahmedabad',
        accuracyMeters: 12,
      ),
      status: status,
      statusHistory: history,
      currentOfferId: status == BookingStatus.requested ? offerId : null,
      triedMechanicIds: assigned ? const [] : const [workshopMechanicId],
      searchRadiusKm: status == BookingStatus.noMechanicFound ? 10 : 3,
      priceEstimate: const PriceRange(min: 350, max: 600),
      finalAmount: done ? 450 : null,
      mechanicCard: assigned ? card : null,
      customerCard: assigned ? const Contact(name: 'Riya Shah', phone: '+919800000001') : null,
      paymentStatus: paymentStatus ?? (done ? PaymentStatus.customerMarkedPaid : PaymentStatus.pending),
      beforePhotoUrls: reached >= 4 ? const ['https://example.invalid/bookings/before-1.jpg'] : const [],
      afterPhotoUrls: done ? const ['https://example.invalid/bookings/after-1.jpg'] : const [],
      timestamps: BookingTimestamps(
        requested: at(0),
        accepted: reached >= 1 ? at(1) : null,
        arriving: reached >= 2 ? at(2) : null,
        arrived: reached >= 3 ? at(3) : null,
        started: reached >= 4 ? at(4) : null,
        completed: done ? at(5) : null,
        cancelled: status == BookingStatus.cancelled ? at(reached + 1) : null,
      ),
      cancelledBy: status == BookingStatus.cancelled ? Actor.customer : null,
      cancelReason: status == BookingStatus.cancelled ? const CancelReason(code: 'fixed_myself') : null,
      idempotencyKey: 'fake-idempotency-key-0001',
      createdAt: at(0),
      updatedAt: history.last.at,
    );
  }

  /// One booking in every status, for history lists and status screens.
  static Map<BookingStatus, Booking> get bookingsByStatus => {
    for (final s in BookingStatus.values) s: booking(status: s),
  };

  /// Past bookings for U15 history / M9 earnings.
  static List<Booking> get history => [
    booking(status: BookingStatus.completed, paymentStatus: PaymentStatus.confirmed),
    booking(status: BookingStatus.cancelled),
    booking(status: BookingStatus.noMechanicFound),
  ];

  static const BookingOtp otp = BookingOtp(code: '4821');

  static BookingOtp get otpLocked =>
      BookingOtp(code: '4821', attempts: 5, lockedUntil: now.add(const Duration(minutes: 10)));

  static List<ChatMessage> get messages => [
    ChatMessage(senderId: customerId, text: 'I am standing near the petrol pump.', createdAt: now),
    ChatMessage(
      senderId: independentMechanicId,
      text: 'On my way, 6 minutes.',
      createdAt: now.add(const Duration(seconds: 40)),
    ),
  ];

  static LiveLocation get liveLocation => LiveLocation(
    mechanicGeopoint: bodakdev,
    heading: 20,
    speed: 7.5,
    etaMinutes: 6,
    updatedAt: now,
    expireAt: now.add(const Duration(hours: 24)),
  );

  static ShareLink get shareLink =>
      ShareLink(bookingId: bookingId, createdBy: customerId, expiresAt: now.add(const Duration(hours: 3)));

  static Review get review => Review(
    customerId: customerId,
    mechanicId: independentMechanicId,
    stars: 5,
    tags: const ['on_time', 'polite', 'fair_price'],
    comment: 'Fixed the puncture in 10 minutes.',
    createdAt: now,
  );

  static Complaint get complaint => Complaint(
    bookingId: bookingId,
    raisedBy: independentMechanicId,
    category: 'payment',
    text: 'Customer marked paid ₹450, mechanic says not received.',
    createdAt: now,
  );

  static List<InboxItem> get inbox => const [
    InboxItem(
      type: 'booking_status',
      titleKey: 'inbox_booking_accepted_title',
      bodyKey: 'inbox_booking_accepted_body',
      args: {'mechanicName': 'Kiran'},
      bookingId: bookingId,
    ),
    InboxItem(
      type: 'booking_status',
      titleKey: 'inbox_booking_arriving_title',
      bodyKey: 'inbox_booking_arriving_body',
      args: {'etaMinutes': '6'},
      bookingId: bookingId,
      read: true,
    ),
  ];

  static AuditLog get auditLog => AuditLog(
    actorUid: adminId,
    action: 'mechanic.approve',
    target: 'mechanics/$independentMechanicId',
    before: const {'status': 'pending'},
    after: const {'status': 'approved'},
    at: now.subtract(const Duration(days: 29)),
  );
}

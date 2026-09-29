// Validators shared by the apps, the rules and Functions (PLAN.md §8, §12.4, §12.9).
//
// Each validator returns null when the value is fine, or an error key (see [ValidationError])
// that the app turns into text through its ARB files. They fit `TextFormField.validator`:
//
//   validator: (v) => l10n.error(validateRegNo(v)),

import 'enums.dart';
import 'models/mechanic.dart';

/// Limits from PLAN §8 / §12.4. The Firestore rules and Functions use the same numbers.
const int kMaxEmergencyContacts = 3;
const int kMaxChatLength = 500;
const int kMaxReviewCommentLength = 500;
const int kMaxDescriptionLength = 500;
const int kMaxBookingPhotos = 4;
const int kMinToolkitPhotos = 2;
const int kMaxToolkitPhotos = 5;
const int kMaxNameLength = 60;
const int kMaxExperienceYears = 60;

/// Error keys returned by the validators. Apps need an ARB entry for each.
abstract final class ValidationError {
  static const required = 'error_field_required';
  static const tooLong = 'error_field_too_long';
  static const phoneInvalid = 'error_phone_invalid';
  static const regNoInvalid = 'error_reg_no_invalid';
  static const upiInvalid = 'error_upi_invalid';
  static const experienceInvalid = 'error_experience_invalid';
  static const toolkitPhotosTooFew = 'error_toolkit_photos_too_few';
  static const tooManyContacts = 'error_emergency_contacts_too_many';
}

final RegExp _e164 = RegExp(r'^\+[1-9][0-9]{7,14}$');
final RegExp _indianMobile = RegExp(r'^\+91[6-9][0-9]{9}$');
final RegExp _upi = RegExp(r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$');
final RegExp _regNoStandard = RegExp(r'^([A-Z]{2})([0-9]{1,2})([A-Z]{0,3})([0-9]{4})$');
final RegExp _regNoBh = RegExp(r'^[0-9]{2}BH[0-9]{4}[A-Z]{1,2}$');

/// RTO state/UT codes accepted in the standard series (incl. older codes still on the road).
const Set<String> kRtoStateCodes = {
  'AN', 'AP', 'AR', 'AS', 'BR', 'CG', 'CH', 'DD', 'DL', 'DN', 'GA', 'GJ', 'HP', 'HR', 'JH', 'JK', //
  'KA', 'KL', 'LA', 'LD', 'MH', 'ML', 'MN', 'MP', 'MZ', 'NL', 'OD', 'OR', 'PB', 'PY', 'RJ', 'SK', //
  'TG', 'TN', 'TR', 'TS', 'UA', 'UK', 'UP', 'WB',
};

/// Any E.164 number (emergency contacts may be outside India).
bool isE164(String phone) => _e164.hasMatch(phone);

/// An Indian mobile in E.164 (`+91` + 10 digits starting 6–9), as used for login.
bool isIndianMobile(String phone) => _indianMobile.hasMatch(phone);

/// Turns what people type (`98765 43210`, `09876543210`, `+91-98765-43210`) into E.164.
/// Numbers that already start with `+` are only stripped of spaces and dashes.
/// Returns null when it can't be an Indian mobile or an E.164 number.
String? normalizePhone(String input) {
  final hasPlus = input.trim().startsWith('+');
  final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
  final String candidate;
  if (hasPlus) {
    candidate = '+$digits';
  } else if (digits.length == 10) {
    candidate = '+91$digits';
  } else if (digits.length == 11 && digits.startsWith('0')) {
    candidate = '+91${digits.substring(1)}';
  } else if (digits.length == 12 && digits.startsWith('91')) {
    candidate = '+$digits';
  } else {
    return null;
  }
  return isE164(candidate) ? candidate : null;
}

String? validatePhone(String? input, {bool indianMobileOnly = true}) {
  if (input == null || input.trim().isEmpty) return ValidationError.required;
  final phone = normalizePhone(input);
  if (phone == null) return ValidationError.phoneInvalid;
  if (indianMobileOnly && !isIndianMobile(phone)) return ValidationError.phoneInvalid;
  return null;
}

/// Upper-cases, drops spaces and dashes, and zero-pads the last number: `gj 1 ab 23` → `GJ01AB0023`.
String normalizeRegNo(String input) {
  final s = input.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  if (_regNoBh.hasMatch(s)) return s;
  final m = RegExp(r'^([A-Z]{2})([0-9]{1,2})([A-Z]{0,3})([0-9]{1,4})$').firstMatch(s);
  if (m == null) return s;
  return '${m[1]}${m[2]!.padLeft(2, '0')}${m[3]}${m[4]!.padLeft(4, '0')}';
}

/// A normalised registration number: standard (`GJ01AB1234`, `DL03CAB1234`) or BH series
/// (`22BH1234AA`). The rules accept the same shapes.
bool isValidRegNo(String regNo) {
  if (_regNoBh.hasMatch(regNo)) return true;
  final m = _regNoStandard.firstMatch(regNo);
  return m != null && kRtoStateCodes.contains(m[1]);
}

String? validateRegNo(String? input) {
  if (input == null || input.trim().isEmpty) return ValidationError.required;
  return isValidRegNo(normalizeRegNo(input)) ? null : ValidationError.regNoInvalid;
}

bool isValidUpiId(String upiId) => _upi.hasMatch(upiId);

String? validateUpiId(String? input) {
  if (input == null || input.trim().isEmpty) return ValidationError.required;
  return isValidUpiId(input.trim()) ? null : ValidationError.upiInvalid;
}

/// Required text up to [maxLength] characters.
String? validateRequiredText(String? input, {int maxLength = kMaxNameLength}) {
  if (input == null || input.trim().isEmpty) return ValidationError.required;
  if (input.trim().length > maxLength) return ValidationError.tooLong;
  return null;
}

String? validateExperienceYears(int? years) {
  if (years == null) return ValidationError.required;
  return years < 0 || years > kMaxExperienceYears ? ValidationError.experienceInvalid : null;
}

bool _blank(String? s) => s == null || s.trim().isEmpty;

/// Missing or invalid fields of a mechanic profile for its type (PLAN §8, §10.0), as
/// `{field: errorKey}`. Empty when the profile can be submitted.
Map<String, String> mechanicProfileErrors(Mechanic m) {
  final errors = <String, String>{};
  void check(String field, String? error) {
    if (error != null) errors[field] = error;
  }

  check('name', validateRequiredText(m.name));
  if (_blank(m.profilePhotoUrl)) errors['profilePhotoUrl'] = ValidationError.required;
  if (m.vehicleTypes.isEmpty) errors['vehicleTypes'] = ValidationError.required;
  if (m.services.isEmpty) errors['services'] = ValidationError.required;

  switch (m.mechanicType) {
    case MechanicType.workshop:
      check('shopName', validateRequiredText(m.shopName));
      check('shopAddress', validateRequiredText(m.shopAddress, maxLength: 300));
      if (_blank(m.shopPhotoUrl)) errors['shopPhotoUrl'] = ValidationError.required;
    case MechanicType.independent:
      if (m.baseArea == null || _blank(m.baseArea!.locality)) errors['baseArea'] = ValidationError.required;
      check('experienceYears', validateExperienceYears(m.experienceYears));
      final photos = m.toolkitPhotoUrls ?? const <String>[];
      if (photos.length < kMinToolkitPhotos) errors['toolkitPhotoUrls'] = ValidationError.toolkitPhotosTooFew;
      if (m.travelVehicle == null) {
        errors['travelVehicle'] = ValidationError.required;
      } else if (!isValidRegNo(m.travelVehicle!.regNo)) {
        errors['travelVehicle'] = ValidationError.regNoInvalid;
      }
  }
  return errors;
}

/// Missing or invalid KYC fields for [type], as `{field: errorKey}`.
Map<String, String> mechanicKycErrors(MechanicKyc k, MechanicType type) {
  final errors = <String, String>{};
  if (_blank(k.idProofPath)) errors['idProofPath'] = ValidationError.required;
  final upi = validateUpiId(k.upiId);
  if (upi != null) errors['upiId'] = upi;
  final upiName = validateRequiredText(k.upiName);
  if (upiName != null) errors['upiName'] = upiName;
  if (type == MechanicType.independent) {
    if (_blank(k.selfieWithIdPath)) errors['selfieWithIdPath'] = ValidationError.required;
    if (_blank(k.addressProofPath)) errors['addressProofPath'] = ValidationError.required;
    final ref = k.referenceContact;
    if (ref != null && (validatePhone(ref.phone, indianMobileOnly: false) != null)) {
      errors['referenceContact'] = ValidationError.phoneInvalid;
    }
  }
  return errors;
}

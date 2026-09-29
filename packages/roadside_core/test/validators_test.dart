import 'package:flutter_test/flutter_test.dart';
import 'package:roadside_core/fakes.dart';
import 'package:roadside_core/roadside_core.dart';

void main() {
  group('phone', () {
    test('normalises what people type into E.164', () {
      expect(normalizePhone('98765 43210'), '+919876543210');
      expect(normalizePhone('098765-43210'), '+919876543210');
      expect(normalizePhone('91 98765 43210'), '+919876543210');
      expect(normalizePhone('+91 98765 43210'), '+919876543210');
      expect(normalizePhone('+44 20 7946 0958'), '+442079460958');
      expect(normalizePhone('12345'), isNull);
    });

    test('login numbers must be Indian mobiles', () {
      expect(validatePhone('9876543210'), isNull);
      expect(validatePhone('5876543210'), ValidationError.phoneInvalid); // mobiles start 6–9
      expect(validatePhone('+442079460958'), ValidationError.phoneInvalid);
      expect(validatePhone('+442079460958', indianMobileOnly: false), isNull);
      expect(validatePhone(''), ValidationError.required);
      expect(validatePhone(null), ValidationError.required);
    });

    test('isE164', () {
      expect(isE164('+919876543210'), isTrue);
      expect(isE164('919876543210'), isFalse);
      expect(isE164('+0123456789'), isFalse);
    });
  });

  group('registration number', () {
    test('normalises spacing, case and padding', () {
      expect(normalizeRegNo('gj 01 ab 1234'), 'GJ01AB1234');
      expect(normalizeRegNo('GJ-1-AB-23'), 'GJ01AB0023');
      expect(normalizeRegNo('dl 3 cab 1234'), 'DL03CAB1234');
      expect(normalizeRegNo('22 bh 1234 aa'), '22BH1234AA');
    });

    test('accepts standard and BH series', () {
      for (final ok in [
        'GJ01AB1234',
        'GJ16GH7788',
        'DL03CAB1234',
        'MH12A1234',
        'GJ012345',
        '22BH1234AA',
        '21BH0001A',
      ]) {
        expect(isValidRegNo(ok), isTrue, reason: ok);
      }
    });

    test('rejects unknown states and bad shapes', () {
      for (final bad in ['XX01AB1234', 'GJ01ABCD1234', 'GJAB1234', '22BH123AA', '22BH1234ABC', '']) {
        expect(isValidRegNo(bad), isFalse, reason: bad);
      }
      expect(validateRegNo('xx 01 ab 1234'), ValidationError.regNoInvalid);
      expect(validateRegNo('gj 1 ab 1'), isNull);
      expect(validateRegNo(' '), ValidationError.required);
    });
  });

  group('UPI', () {
    test('matches the §12.9 pattern', () {
      for (final ok in ['kiranpatel@oksbi', 'imran.shaikh@okaxis', '9876543210@ybl', 'a_b-c.d@paytm']) {
        expect(isValidUpiId(ok), isTrue, reason: ok);
      }
      for (final bad in ['kiran', 'k@1', '@oksbi', 'kiran@ok sbi', 'x@oksbi']) {
        expect(isValidUpiId(bad), isFalse, reason: bad);
      }
      expect(validateUpiId(' kiranpatel@oksbi '), isNull);
    });
  });

  group('mechanic profile by type', () {
    test('the fakes are complete', () {
      expect(mechanicProfileErrors(RoadsideFakes.workshopMechanic), isEmpty);
      expect(mechanicProfileErrors(RoadsideFakes.independentMechanic), isEmpty);
      expect(mechanicProfileErrors(RoadsideFakes.pendingMechanic), isEmpty);
    });

    test('workshop needs shop fields', () {
      final m = RoadsideFakes.workshopMechanic.copyWith(shopName: null, shopPhotoUrl: '');
      expect(mechanicProfileErrors(m).keys, containsAll(['shopName', 'shopPhotoUrl']));
    });

    test('independent needs base area, experience, 2+ toolkit photos and a valid travel plate', () {
      final m = RoadsideFakes.independentMechanic.copyWith(
        baseArea: null,
        experienceYears: 99,
        toolkitPhotoUrls: ['one.jpg'],
        travelVehicle: const TravelVehicle(type: VehicleType.bike, regNo: 'NOPE'),
      );
      expect(mechanicProfileErrors(m), {
        'baseArea': ValidationError.required,
        'experienceYears': ValidationError.experienceInvalid,
        'toolkitPhotoUrls': ValidationError.toolkitPhotosTooFew,
        'travelVehicle': ValidationError.regNoInvalid,
      });
    });

    test('independent KYC needs selfie with ID and address proof', () {
      expect(mechanicKycErrors(RoadsideFakes.pendingKyc, MechanicType.independent), isEmpty);
      expect(mechanicKycErrors(RoadsideFakes.workshopKyc, MechanicType.workshop), isEmpty);
      expect(mechanicKycErrors(RoadsideFakes.workshopKyc, MechanicType.independent).keys, [
        'selfieWithIdPath',
        'addressProofPath',
      ]);
      final badUpi = RoadsideFakes.workshopKyc.copyWith(upiId: 'nope');
      expect(mechanicKycErrors(badUpi, MechanicType.workshop), {'upiId': ValidationError.upiInvalid});
    });
  });

  test('required text', () {
    expect(validateRequiredText('Riya'), isNull);
    expect(validateRequiredText('  '), ValidationError.required);
    expect(validateRequiredText('x' * 61), ValidationError.tooLong);
  });
}

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The mechanic privacy notice version the user agrees to (PLAN §12.12). It covers KYC and
/// on-the-job location, so it's versioned separately from the customer notice. Bump it when
/// the text changes; everyone is asked again.
const kConsentVersion = '2026-09-mech-v1';

/// Loaded in `bootstrap` before `runApp`, so screens read it synchronously.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Overridden in bootstrap()'),
);

/// When and to which notice version the user agreed. Kept on the phone until sign-in,
/// then saved with the account (#123).
@immutable
class ConsentRecord {
  const ConsentRecord({required this.version, required this.acceptedAt});

  final String version;
  final DateTime acceptedAt;
}

/// Route paths of the first-run screens, in order.
abstract final class FirstRunStep {
  static const language = '/language';
  static const onboarding = '/onboarding';
  static const consent = '/consent';
}

/// Where the user is in C1–C4.
@immutable
class FirstRunState {
  const FirstRunState({this.languageCode, this.onboarded = false, this.consent});

  /// `en`, `hi` or `gu` once chosen on C2; null follows the phone.
  final String? languageCode;
  final bool onboarded;
  final ConsentRecord? consent;

  Locale? get locale => languageCode == null ? null : Locale(languageCode!);

  bool get hasCurrentConsent => consent?.version == kConsentVersion;

  /// The first C screen still to do, or null when first run is complete.
  String? get nextStep {
    if (languageCode == null) return FirstRunStep.language;
    if (!onboarded) return FirstRunStep.onboarding;
    if (!hasCurrentConsent) return FirstRunStep.consent;
    return null;
  }

  FirstRunState copyWith({String? languageCode, bool? onboarded, ConsentRecord? consent}) => FirstRunState(
    languageCode: languageCode ?? this.languageCode,
    onboarded: onboarded ?? this.onboarded,
    consent: consent ?? this.consent,
  );
}

/// The clock consent is stamped with. Tests override it.
final firstRunClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final firstRunProvider = NotifierProvider<FirstRunController, FirstRunState>(FirstRunController.new);

class FirstRunController extends Notifier<FirstRunState> {
  static const _kLanguage = 'first_run.language';
  static const _kOnboarded = 'first_run.onboarded';
  static const _kConsentVersion = 'first_run.consent_version';
  static const _kConsentAt = 'first_run.consent_at';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  FirstRunState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final version = prefs.getString(_kConsentVersion);
    final at = DateTime.tryParse(prefs.getString(_kConsentAt) ?? '');
    return FirstRunState(
      languageCode: prefs.getString(_kLanguage),
      onboarded: prefs.getBool(_kOnboarded) ?? false,
      consent: version != null && at != null ? ConsentRecord(version: version, acceptedAt: at) : null,
    );
  }

  Future<void> setLanguage(String code) async {
    state = state.copyWith(languageCode: code);
    await _prefs.setString(_kLanguage, code);
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(onboarded: true);
    await _prefs.setBool(_kOnboarded, true);
  }

  Future<void> acceptConsent() async {
    final record = ConsentRecord(
      version: kConsentVersion,
      acceptedAt: ref.read(firstRunClockProvider)().toUtc(),
    );
    state = state.copyWith(consent: record);
    await _prefs.setString(_kConsentVersion, record.version);
    await _prefs.setString(_kConsentAt, record.acceptedAt.toIso8601String());
  }
}

// Third-party notices for the "Open-source licenses" screen (docs/licenses.md).
// Fonts, ThreeUI and Phosphor aren't pub packages, so Flutter doesn't list them by itself.
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract final class LaneLicenses {
  static bool _registered = false;

  static const _base = 'packages/lane_ui/assets/licenses';
  static const _entries = <(List<String>, String)>[
    (['Onest'], 'OFL-onest.txt'),
    (['Instrument Serif'], 'OFL-instrumentserif.txt'),
    (['JetBrains Mono'], 'OFL-jetbrainsmono.txt'),
    (['Anek Devanagari'], 'OFL-anekdevanagari.txt'),
    (['Anek Gujarati'], 'OFL-anekgujarati.txt'),
    (['ThreeUI Community'], 'LICENSE-threeui-MIT.txt'),
    (['Phosphor Icons'], 'LICENSE-phosphor-MIT.txt'),
  ];

  /// Adds the notices to [LicenseRegistry] once. `LaneApp` calls this.
  static void register() {
    if (_registered) return;
    _registered = true;
    LicenseRegistry.addLicense(() async* {
      for (final (packages, file) in _entries) {
        yield LicenseEntryWithLineBreaks(packages, await rootBundle.loadString('$_base/$file'));
      }
    });
  }
}

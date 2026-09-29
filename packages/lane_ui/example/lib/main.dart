// The "Done when" check for issue #4: a blank app on LaneApp that switches
// Day / Night / Glare / Saver and renders every type style in en / hi / gu.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:lane_ui/specimen.dart';

void main() => runApp(const ProviderScope(child: SpecimenApp()));

class SpecimenApp extends StatefulWidget {
  const SpecimenApp({super.key});

  @override
  State<SpecimenApp> createState() => _SpecimenAppState();
}

class _SpecimenAppState extends State<SpecimenApp> {
  var _locale = const Locale('en');

  @override
  Widget build(BuildContext context) => LaneApp(
    locale: _locale,
    supportedLocales: const [Locale('en'), Locale('hi'), Locale('gu')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: LaneSpecimen(locale: _locale, onLocale: (l) => setState(() => _locale = l)),
  );
}

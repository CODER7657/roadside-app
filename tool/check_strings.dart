// Fails if an app's ARB files are incomplete (PLAN.md §7.3, §14). Runs in CI on every app PR.
//
//   dart run tool/check_strings.dart [app_dir ...]   (default: all three apps that exist)
//
// For each app, reads l10n.yaml (arb-dir, template-arb-file) and checks every translation (hi, gu)
// against the English template:
//   - every key exists, and no translation has a key the template doesn't (stale)
//   - no empty translation
//   - every placeholder declared in the template's @key metadata appears in the translation
//   - keys are snake_case `screen_element_purpose` (at least two parts)
//   - @@locale matches the file name
// No dependencies: plain dart:io + dart:convert, so it runs without a pubspec.

import 'dart:convert';
import 'dart:io';

const requiredLocales = ['hi', 'gu'];
const defaultApps = ['customer_app', 'mechanic_app', 'admin_panel'];
final keyPattern = RegExp(r'^[a-z][a-z0-9]*(_[a-z0-9]+)+$');

void main(List<String> args) {
  final apps = args.isEmpty ? defaultApps.where((a) => Directory(a).existsSync()).toList() : args;
  var problems = 0;
  for (final app in apps) {
    final errors = checkApp(app);
    if (errors == null) {
      stdout.writeln('– $app: no ARB files yet');
    } else if (errors.isEmpty) {
      stdout.writeln('✓ $app: ARB files complete');
    } else {
      stdout.writeln('✗ $app: ${errors.length} problem(s)');
      for (final e in errors) {
        stdout.writeln('  $e');
      }
      problems += errors.length;
    }
  }
  if (apps.isEmpty) stdout.writeln('✓ no apps with ARB files yet');
  exit(problems == 0 ? 0 : 1);
}

/// Every problem in [appDir]'s ARB files, as readable lines. Empty when complete, null when the
/// app has no ARB files yet (scaffold in progress).
List<String>? checkApp(String appDir) {
  final config = _readL10nYaml(appDir);
  final arbDir = Directory('$appDir/${config['arb-dir'] ?? 'lib/l10n'}');
  final templateName = config['template-arb-file'] ?? 'app_en.arb';
  final templateFile = File('${arbDir.path}/$templateName');
  if (!templateFile.existsSync()) {
    return arbDir.existsSync() ? ['template ${templateFile.path} not found'] : null;
  }

  final errors = <String>[];
  final template = _readArb(templateFile, errors);
  if (template == null) return errors;
  final templateLocale = _localeOf(templateName);
  _checkLocale(templateFile, template, templateLocale, errors);

  final keys = _messageKeys(template);
  for (final key in keys) {
    if (!keyPattern.hasMatch(key))
      errors.add('$templateName: key "$key" is not snake_case screen_element_purpose');
  }

  final prefix = templateName.substring(0, templateName.length - '$templateLocale.arb'.length);
  for (final locale in requiredLocales) {
    final name = '$prefix$locale.arb';
    final file = File('${arbDir.path}/$name');
    if (!file.existsSync()) {
      errors.add('$name is missing');
      continue;
    }
    final arb = _readArb(file, errors);
    if (arb == null) continue;
    _checkLocale(file, arb, locale, errors);
    final translated = _messageKeys(arb);

    for (final key in keys) {
      if (!translated.contains(key)) {
        errors.add('$name: missing "$key"');
        continue;
      }
      final value = arb[key];
      if (value is! String || value.trim().isEmpty) {
        errors.add('$name: "$key" is empty');
        continue;
      }
      for (final p in _placeholders(template, key)) {
        if (!RegExp('\\{$p[},\\s]').hasMatch(value)) errors.add('$name: "$key" drops the {$p} placeholder');
      }
    }
    for (final key in translated.difference(keys)) {
      errors.add('$name: "$key" is not in $templateName (stale?)');
    }
  }
  return errors;
}

Map<String, String> _readL10nYaml(String appDir) {
  final file = File('$appDir/l10n.yaml');
  if (!file.existsSync()) return const {};
  return {
    for (final line in file.readAsLinesSync())
      if (RegExp(r'^([\w-]+):\s*(\S+)').firstMatch(line) case final m?) m[1]!: m[2]!,
  };
}

Map<String, dynamic>? _readArb(File file, List<String> errors) {
  try {
    final decoded = jsonDecode(file.readAsStringSync());
    if (decoded is Map<String, dynamic>) return decoded;
    errors.add('${file.uri.pathSegments.last}: not a JSON object');
  } on FormatException catch (e) {
    errors.add('${file.uri.pathSegments.last}: invalid JSON (${e.message})');
  }
  return null;
}

String _localeOf(String fileName) => RegExp(r'_([a-zA-Z_]+)\.arb$').firstMatch(fileName)?[1] ?? '';

void _checkLocale(File file, Map<String, dynamic> arb, String locale, List<String> errors) {
  final declared = arb['@@locale'];
  if (declared != null && declared != locale) {
    errors.add('${file.uri.pathSegments.last}: @@locale is "$declared", expected "$locale"');
  }
}

Set<String> _messageKeys(Map<String, dynamic> arb) => arb.keys.where((k) => !k.startsWith('@')).toSet();

Iterable<String> _placeholders(Map<String, dynamic> template, String key) {
  final meta = template['@$key'];
  if (meta is Map && meta['placeholders'] is Map) return (meta['placeholders'] as Map).keys.cast<String>();
  return const [];
}

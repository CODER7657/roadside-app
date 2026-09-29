// Open Location Code ("Plus Code") encoding, for roads with no street address (PLAN §11).
// Spec: https://github.com/google/open-location-code/blob/main/Documentation/Specification/specification.md
// Written here because the `open_location_code` package hasn't been published since
// January 2024 (PLAN §3's 12-month rule). Encoding only; the app never decodes.

const _alphabet = '23456789CFGHJMPQRVWX';

/// Degrees per step at 10 digits: 1/8000 (about 14 m).
const _pairPrecision = 8000;

/// The full 10-digit code for a point, e.g. `8FVC2222+22` (a cell about 14 × 14 m).
String encodePlusCode(double lat, double lng) {
  // Latitude in [-90, 90): the north pole belongs to the cell just below it.
  final clippedLat = lat.clamp(-90.0, 90.0);
  var latVal = ((clippedLat + 90) * _pairPrecision).floor();
  if (latVal >= 180 * _pairPrecision) latVal = 180 * _pairPrecision - 1;
  // Longitude wrapped into [-180, 180).
  final lngVal = (((lng + 180) % 360) * _pairPrecision).floor();

  final code = StringBuffer();
  final pairs = <String>[];
  for (var i = 0; i < 5; i++) {
    pairs.add('${_alphabet[latVal ~/ _pow20(4 - i) % 20]}${_alphabet[lngVal ~/ _pow20(4 - i) % 20]}');
  }
  for (final (i, pair) in pairs.indexed) {
    if (i == 4) code.write('+');
    code.write(pair);
  }
  return code.toString();
}

int _pow20(int n) {
  var v = 1;
  for (var i = 0; i < n; i++) {
    v *= 20;
  }
  return v;
}

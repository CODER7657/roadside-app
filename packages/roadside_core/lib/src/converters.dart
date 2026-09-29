// JSON converters between Firestore types and the models.
//
// `toJson()` on a model returns a map that can be written to Firestore as-is: dates become
// `Timestamp`s and points stay `GeoPoint`s. `fromJson()` also accepts plain JSON (ISO strings,
// epoch millis, `{latitude, longitude}` maps) so fixtures and tests work without Firebase.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// `Timestamp` ⇄ `DateTime` (UTC).
class TimestampConverter implements JsonConverter<DateTime, Object> {
  const TimestampConverter();

  @override
  DateTime fromJson(Object json) => switch (json) {
    final Timestamp t => t.toDate().toUtc(),
    final DateTime d => d.toUtc(),
    final int millis => DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true),
    final String iso => DateTime.parse(iso).toUtc(),
    _ => throw ArgumentError.value(json, 'json', 'Not a timestamp'),
  };

  @override
  Object toJson(DateTime date) => Timestamp.fromDate(date);
}

/// `GeoPoint` passthrough that also reads `{latitude, longitude}` maps.
class GeoPointConverter implements JsonConverter<GeoPoint, Object> {
  const GeoPointConverter();

  @override
  GeoPoint fromJson(Object json) => switch (json) {
    final GeoPoint p => p,
    {'latitude': final num lat, 'longitude': final num lng} => GeoPoint(lat.toDouble(), lng.toDouble()),
    _ => throw ArgumentError.value(json, 'json', 'Not a geopoint'),
  };

  @override
  Object toJson(GeoPoint point) => point;
}

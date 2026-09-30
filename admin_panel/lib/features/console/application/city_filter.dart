import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadside_core/roadside_core.dart';

/// The console-wide city filter: null = All cities. Every admin list, map and dashboard
/// reads it (PLAN §10 admin), so switching screens keeps the choice.
final cityFilterProvider = NotifierProvider<CityFilter, CityId?>(CityFilter.new);

class CityFilter extends Notifier<CityId?> {
  @override
  CityId? build() => null;

  void select(CityId? city) => state = city;
}

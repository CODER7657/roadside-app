import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadside_core/roadside_core.dart';

import '../../auth/application/admin_session.dart';
import '../data/price_repository.dart';

/// Upper bound the rules accept for a price (firestore.rules isRange).
const kMaxPrice = 100000;

/// One cell of the A4 grid: a price document in one scope. [city] null = the default range;
/// a city = that city's override.
typedef PriceCell = ({String priceId, CityId? city});

/// The text in a cell's two fields.
typedef RangeText = ({String min, String max});

enum PriceError { required, notANumber, outOfRange, minNotBelowMax }

/// Checks a cell. City overrides may be left blank (= use the default); defaults may not.
PriceError? validateRange(RangeText text, {required bool optional}) {
  final min = text.min.trim();
  final max = text.max.trim();
  if (min.isEmpty && max.isEmpty && optional) return null;
  if (min.isEmpty || max.isEmpty) return PriceError.required;
  final a = int.tryParse(min);
  final b = int.tryParse(max);
  if (a == null || b == null) return PriceError.notANumber;
  if (a < 1 || b > kMaxPrice) return PriceError.outOfRange;
  if (a >= b) return PriceError.minNotBelowMax;
  return null;
}

/// What's stored for [cell]: the default range, the city's override, or blank.
RangeText storedText(Price? price, CityId? city) {
  if (price == null) return (min: '', max: '');
  if (city == null) return (min: '${price.min}', max: '${price.max}');
  final o = price.cityOverrides?[city];
  return o == null ? (min: '', max: '') : (min: '${o.min}', max: '${o.max}');
}

class PriceEditorState {
  const PriceEditorState({this.drafts = const {}, this.saving = false, this.revision = 0});

  /// Edited cells only.
  final Map<PriceCell, RangeText> drafts;
  final bool saving;

  /// Bumped on discard and save, so the fields re-read the stored values.
  final int revision;

  PriceEditorState copyWith({Map<PriceCell, RangeText>? drafts, bool? saving}) =>
      PriceEditorState(drafts: drafts ?? this.drafts, saving: saving ?? this.saving, revision: revision);

  RangeText textOf(PriceCell cell, Map<String, Price> prices) =>
      drafts[cell] ?? storedText(prices[cell.priceId], cell.city);

  PriceError? errorOf(PriceCell cell, Map<String, Price> prices) {
    final draft = drafts[cell];
    return draft == null ? null : validateRange(draft, optional: cell.city != null);
  }

  /// Drafts that differ from what's stored.
  Iterable<PriceCell> changedCells(Map<String, Price> prices) => drafts.entries
      .where((e) {
        final stored = storedText(prices[e.key.priceId], e.key.city);
        return e.value.min.trim() != stored.min || e.value.max.trim() != stored.max;
      })
      .map((e) => e.key);

  bool hasErrors(Map<String, Price> prices) => drafts.keys.any((c) => errorOf(c, prices) != null);

  /// One edit per changed price document, with its full new default range and overrides.
  List<PriceEdit> edits(Map<String, Price> prices) {
    final byPrice = <String, List<PriceCell>>{};
    for (final c in changedCells(prices)) {
      (byPrice[c.priceId] ??= []).add(c);
    }
    return [for (final MapEntry(key: id, value: cells) in byPrice.entries) _edit(id, cells, prices[id])];
  }

  PriceEdit _edit(String id, List<PriceCell> cells, Price? before) {
    final (vehicleType, problemType) = _parseId(id);
    var range = before == null ? null : PriceRange(min: before.min, max: before.max);
    final overrides = {...?before?.cityOverrides};
    for (final cell in cells) {
      final t = drafts[cell]!;
      final city = cell.city;
      if (city == null) {
        range = PriceRange(min: int.parse(t.min.trim()), max: int.parse(t.max.trim()));
      } else if (t.min.trim().isEmpty && t.max.trim().isEmpty) {
        overrides.remove(city);
      } else {
        overrides[city] = PriceRange(min: int.parse(t.min.trim()), max: int.parse(t.max.trim()));
      }
    }
    if (range == null) throw StateError('$id has no default price yet: set "All cities" first');
    return PriceEdit(
      vehicleType: vehicleType,
      problemType: problemType,
      before: before,
      range: range,
      cityOverrides: overrides,
    );
  }

  static (VehicleType, ProblemType) _parseId(String id) {
    final vehicle = VehicleType.values.firstWhere((v) => id.startsWith('${v.value}_'));
    return (vehicle, ProblemType.fromValue(id.substring(vehicle.value.length + 1)));
  }
}

enum SaveResult { saved, nothingToSave, invalid, missingDefault, failed }

final priceEditorProvider = NotifierProvider<PriceEditor, PriceEditorState>(PriceEditor.new);

class PriceEditor extends Notifier<PriceEditorState> {
  @override
  PriceEditorState build() => const PriceEditorState();

  void edit(PriceCell cell, RangeText text) => state = state.copyWith(drafts: {...state.drafts, cell: text});

  void discard() => state = PriceEditorState(revision: state.revision + 1);

  Future<SaveResult> save(Map<String, Price> prices) async {
    if (state.hasErrors(prices)) return SaveResult.invalid;
    final List<PriceEdit> edits;
    try {
      edits = state.edits(prices);
    } on StateError {
      return SaveResult.missingDefault;
    }
    if (edits.isEmpty) return SaveResult.nothingToSave;
    final session = ref.read(adminSessionProvider);
    if (session is! SessionAdmin) return SaveResult.failed;

    state = state.copyWith(saving: true);
    try {
      await ref.read(priceRepositoryProvider).save(edits, actorUid: session.user.uid);
      state = PriceEditorState(revision: state.revision + 1);
      LaneLog.i('prices saved', {'count': edits.length});
      return SaveResult.saved;
    } catch (e, st) {
      LaneLog.e('saving prices failed', error: e, stackTrace: st);
      state = state.copyWith(saving: false);
      return SaveResult.failed;
    }
  }
}

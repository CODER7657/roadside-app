import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:roadside_core/roadside_core.dart';

import '../../../_local_ui/price_range_field.dart';
import '../../../l10n/app_localizations.dart';
import '../../console/application/city_filter.dart';
import '../../console/presentation/labels.dart';
import '../application/price_editor.dart';
import '../data/price_repository.dart';

/// A4 Price editor (PLAN §8 prices, wireframe A4): problem × vehicle grid of "₹ min – max".
/// The console's city filter picks the scope: All cities edits the defaults, a city edits
/// its overrides (blank = use the default). Save writes all changes and their audit entries
/// in one batch; createBooking prices new bookings from them straight away.
class PricesScreen extends ConsumerWidget {
  const PricesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final prices = ref.watch(pricesProvider);
    // Riverpod retries failed providers; while it does, keep showing the error.
    if (prices.hasValue) return _Editor(prices: prices.requireValue);
    if (prices.hasError) {
      return ErrorState(message: l10n.prices_load_failed, onRetry: () => ref.invalidate(pricesProvider));
    }
    final rowGap = context.lane.space.s12;
    return SkeletonGroup(
      child: Column(
        children: [
          for (var i = 0; i < ProblemType.values.length + 1; i++)
            Padding(
              padding: EdgeInsets.only(bottom: rowGap),
              child: SkeletonBlock(height: context.lane.touch.min),
            ),
        ],
      ),
    );
  }
}

class _Editor extends ConsumerWidget {
  const _Editor({required this.prices});

  /// Narrower than this, the grid scrolls sideways instead of squashing the cells.
  static const minGridWidth = 960.0;

  /// Narrower than this, the save actions go under the heading.
  static const stackHeaderBelow = 760.0;

  final Map<String, Price> prices;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final city = ref.watch(cityFilterProvider);
    final editor = ref.watch(priceEditorProvider);
    final changed = editor.changedCells(prices).length;
    final hasErrors = editor.hasErrors(prices);

    Future<void> save() async {
      final result = await ref.read(priceEditorProvider.notifier).save(prices);
      if (!context.mounted) return;
      final message = switch (result) {
        SaveResult.saved => l10n.prices_saved_toast,
        SaveResult.failed => l10n.prices_save_failed,
        SaveResult.missingDefault => l10n.prices_missing_default,
        SaveResult.invalid || SaveResult.nothingToSave => null,
      };
      if (message != null) LaneToast.show(context, message);
    }

    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          city == null ? l10n.prices_scope_default : l10n.prices_scope_city(cityLabel(l10n, city)),
          style: lane.text.title,
        ),
        Gap(lane.space.s4),
        Text(
          city == null ? l10n.prices_scope_default_help : l10n.prices_scope_city_help,
          style: lane.text.caption.copyWith(color: lane.color.inkMuted),
        ),
      ],
    );
    final actions = Wrap(
      spacing: lane.space.s8,
      runSpacing: lane.space.s8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          l10n.prices_unsaved(changed),
          style: lane.text.caption.copyWith(color: changed > 0 ? lane.color.ink : lane.color.inkMuted),
        ),
        LaneButton.ghost(
          label: l10n.prices_discard,
          onPressed: changed == 0 || editor.saving
              ? null
              : () => ref.read(priceEditorProvider.notifier).discard(),
        ),
        LaneButton.primary(
          label: l10n.prices_save,
          loading: editor.saving,
          onPressed: changed == 0 || hasErrors || editor.saving ? null : save,
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, box) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (box.maxWidth < stackHeaderBelow) ...[
            heading,
            Gap(lane.space.s16),
            actions,
          ] else
            Row(
              children: [
                Expanded(child: heading),
                Gap(lane.space.s16),
                actions,
              ],
            ),
          Gap(lane.space.s24),
          Expanded(
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: box.maxWidth < minGridWidth ? minGridWidth : box.maxWidth,
                  child: _Grid(prices: prices, city: city, editor: editor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Grid extends ConsumerWidget {
  const _Grid({required this.prices, required this.city, required this.editor});

  final Map<String, Price> prices;
  final CityId? city;
  final PriceEditorState editor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final header = lane.text.caps.copyWith(color: lane.color.inkMuted);
    final tight = lane.space.s4;
    final rowLabelTop = lane.space.s16;
    final cellInset = EdgeInsets.all(tight);
    final rowLabelInset = EdgeInsets.symmetric(horizontal: tight, vertical: rowLabelTop);

    String? errorText(PriceError? e) => switch (e) {
      null => null,
      PriceError.required => l10n.prices_error_required,
      PriceError.notANumber => l10n.prices_error_number,
      PriceError.outOfRange => l10n.prices_error_range,
      PriceError.minNotBelowMax => l10n.prices_error_order,
    };

    Widget cell(VehicleType vehicle, ProblemType problem) {
      final id = Price.idFor(vehicle, problem);
      final key = (priceId: id, city: city);
      final text = editor.textOf(key, prices);
      final fallback = storedText(prices[id], null);
      final vehicleName = vehicleLabel(l10n, vehicle);
      final problemName = problemLabel(l10n, problem);
      return Padding(
        padding: cellInset,
        child: PriceRangeField(
          key: ValueKey('price-$id-${city?.value ?? 'default'}-${editor.revision}'),
          min: text.min,
          max: text.max,
          minHint: city == null ? null : fallback.min,
          maxHint: city == null ? null : fallback.max,
          minLabel: l10n.prices_min_label(vehicleName, problemName),
          maxLabel: l10n.prices_max_label(vehicleName, problemName),
          changed: editor.changedCells(prices).contains(key),
          errorText: errorText(editor.errorOf(key, prices)),
          enabled: !editor.saving,
          onChanged: (min, max) => ref.read(priceEditorProvider.notifier).edit(key, (min: min, max: max)),
        ),
      );
    }

    return Table(
      columnWidths: const {0: FlexColumnWidth(1.3)},
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      children: [
        TableRow(
          children: [
            Padding(
              padding: cellInset,
              child: Text(l10n.prices_column_problem, style: header),
            ),
            for (final v in VehicleType.values)
              Padding(
                padding: cellInset,
                child: Text(vehicleLabel(l10n, v), style: header),
              ),
          ],
        ),
        for (final p in ProblemType.values)
          TableRow(
            children: [
              Padding(
                padding: rowLabelInset,
                child: Text(problemLabel(l10n, p), style: lane.text.label),
              ),
              for (final v in VehicleType.values) cell(v, p),
            ],
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:roadside_core/roadside_core.dart';

import '../../../app/validation_messages.dart';
import '../../../l10n/app_localizations.dart';
import '../application/vehicles.dart';
import '../data/vehicle_repository.dart';
import 'vehicle_labels.dart';

/// U2 Add vehicle: type tiles, brand, model, registration number (Indian or BH series),
/// fuel, and whether it's the default. Brand and model are limited to 40 characters, as
/// the Firestore rules are.
class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  static const _maxText = 40;

  /// Longest plate with spaces or dashes typed in, e.g. `GJ-01-AB-1234`.
  static const _maxRegNo = 16;

  VehicleType _type = VehicleType.car;
  Fuel _fuel = Fuel.petrol;
  String _brand = '';
  String _model = '';
  String _regNo = '';
  bool? _makeDefault;
  bool _submitted = false;
  bool _saving = false;

  String? get _brandError => validateRequiredText(_brand, maxLength: _maxText);
  String? get _modelError => validateRequiredText(_model, maxLength: _maxText);
  String? get _regError => validateRegNo(_regNo);

  void _pickType(VehicleType t) => setState(() {
    _type = t;
    // An EV runs on electricity; switching away from EV doesn't guess.
    if (t == VehicleType.ev) _fuel = Fuel.electric;
  });

  Future<void> _save() async {
    setState(() => _submitted = true);
    if (_brandError != null || _modelError != null || _regError != null) {
      await LaneHaptics.error();
      return;
    }
    setState(() => _saving = true);
    final hasVehicles = (ref.read(vehiclesProvider).value ?? const []).isNotEmpty;
    await ref
        .read(vehicleRepositoryProvider)
        .add(
          VehicleDraft(
            type: _type,
            brand: _brand,
            model: _model,
            regNo: _regNo,
            fuel: _fuel,
            makeDefault: _makeDefault ?? !hasVehicles,
          ),
        );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final hasVehicles = (ref.watch(vehiclesProvider).value ?? const []).isNotEmpty;
    String? shown(String? key) => _submitted ? validationMessage(l10n, key) : null;
    // Named token: tool/lint_design.sh misreads `s8` as a magic number (#46).
    final labelGap = lane.space.s8;
    Widget label(String text) => Padding(
      padding: EdgeInsets.only(bottom: labelGap),
      child: Text(text, style: lane.text.label.copyWith(color: lane.color.ink)),
    );

    return LaneFlowScaffold(
      step: 1,
      totalSteps: 1,
      stepLabel: l10n.vehicle_add_step,
      title: l10n.vehicle_add_title,
      primary: LaneButton.primary(label: l10n.vehicle_save, loading: _saving, onPressed: _save),
      children: [
        label(l10n.vehicle_type_label),
        LaneTileGrid(
          children: [
            for (final t in VehicleType.values)
              ProblemTile(
                icon: LaneIcons.forVehicle(t.value),
                label: l10n.vehicleType(t),
                selected: _type == t,
                onTap: () => _pickType(t),
              ),
          ],
        ),
        SizedBox(height: lane.space.s24),
        LaneTextField(
          label: l10n.vehicle_brand_label,
          hint: l10n.vehicle_brand_hint,
          maxLength: _maxText,
          textCapitalization: TextCapitalization.words,
          errorText: shown(_brandError),
          onChanged: (v) => setState(() => _brand = v),
        ),
        SizedBox(height: lane.space.s16),
        LaneTextField(
          label: l10n.vehicle_model_label,
          hint: l10n.vehicle_model_hint,
          maxLength: _maxText,
          textCapitalization: TextCapitalization.words,
          errorText: shown(_modelError),
          onChanged: (v) => setState(() => _model = v),
        ),
        SizedBox(height: lane.space.s16),
        LaneTextField(
          label: l10n.vehicle_reg_label,
          hint: l10n.vehicle_reg_hint,
          maxLength: _maxRegNo,
          textCapitalization: TextCapitalization.characters,
          errorText: shown(_regError),
          onChanged: (v) => setState(() => _regNo = v),
        ),
        if (_regNo.isNotEmpty && _regError == null) ...[
          SizedBox(height: lane.space.s8),
          Align(
            alignment: Alignment.centerLeft,
            child: PlateChip(regNo: normalizeRegNo(_regNo)),
          ),
        ],
        SizedBox(height: lane.space.s24),
        label(l10n.vehicle_fuel_label),
        Wrap(
          spacing: lane.space.s8,
          runSpacing: lane.space.s8,
          children: [
            for (final f in Fuel.values)
              LaneChip(
                label: l10n.fuel(f),
                selected: _fuel == f,
                onSelected: (_) => setState(() => _fuel = f),
              ),
          ],
        ),
        if (hasVehicles) ...[
          SizedBox(height: lane.space.s16),
          LaneSwitch(
            label: l10n.vehicle_make_default,
            value: _makeDefault ?? false,
            onChanged: (v) => setState(() => _makeDefault = v),
          ),
        ],
      ],
    );
  }
}

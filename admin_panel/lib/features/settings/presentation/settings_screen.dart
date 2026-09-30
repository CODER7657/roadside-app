import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:roadside_core/roadside_core.dart' hide JourneyStop;

import '../../../l10n/app_localizations.dart';
import '../../auth/application/admin_session.dart';
import '../../bookings/data/bookings_repository.dart';
import '../../console/presentation/labels.dart';
import '../data/settings_repository.dart';

/// A6 Settings (PLAN §10 admin 6, wireframe A6): `appConfig/public` (force update, maintenance,
/// support phone, dispatch kill switch), each city on/off and its radius, and the admin list
/// (read only: admins come from tool/admin). Every save writes an audit entry in the same batch.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const splitAbove = 900.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final config = ref.watch(appConfigProvider);
    final areas = ref.watch(serviceAreasProvider);

    if ((config.hasError && !config.hasValue) || (areas.hasError && !areas.hasValue)) {
      return ErrorState(
        message: l10n.settings_load_failed,
        onRetry: () => ref
          ..invalidate(appConfigProvider)
          ..invalidate(serviceAreasProvider),
      );
    }
    if (!config.hasValue || !areas.hasValue) {
      return SkeletonGroup(child: SkeletonBlock(height: lane.touch.critical * 4));
    }

    final left = _ConfigForm(config: config.requireValue);
    final right = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Section(
          title: l10n.settings_areas_title,
          children: [
            for (final city in CityId.values)
              if (areas.requireValue[city] case final area?)
                _AreaRow(key: ValueKey('area-${city.value}'), city: city, area: area)
              else
                Text(l10n.settings_area_missing(cityLabel(l10n, city)), style: lane.text.caption),
          ],
        ),
        Gap(lane.space.s24),
        const _Admins(),
      ],
    );
    return LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
        child: box.maxWidth >= splitAbove
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: left),
                  Gap(lane.space.s24),
                  Expanded(child: right),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [left, Gap(lane.space.s24), right],
              ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final inset = lane.space.s24;
    return DecoratedBox(
      decoration: BoxDecoration(color: lane.color.surface, borderRadius: lane.radius.r16),
      child: Padding(
        padding: EdgeInsets.all(inset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title.toUpperCase(), style: lane.text.caps.copyWith(color: lane.color.inkMuted)),
            Gap(lane.space.s16),
            ...children,
          ],
        ),
      ),
    );
  }
}

Future<String?> _actor(WidgetRef ref) async {
  final session = ref.read(adminSessionProvider);
  return session is SessionAdmin ? session.user.uid : null;
}

class _ConfigForm extends ConsumerStatefulWidget {
  const _ConfigForm({required this.config});

  /// Null when appConfig/public doesn't exist yet; saving creates it.
  final AppConfig? config;

  @override
  ConsumerState<_ConfigForm> createState() => _ConfigFormState();
}

class _ConfigFormState extends ConsumerState<_ConfigForm> {
  late final _build = TextEditingController(text: '${widget.config?.minSupportedBuild ?? 1}');
  late final _message = TextEditingController(text: widget.config?.maintenanceMessage ?? '');
  late final _phone = TextEditingController(text: widget.config?.supportPhone ?? '');
  late bool _dispatch = widget.config?.dispatchEnabled ?? true;
  bool _saving = false;

  @override
  void dispose() {
    _build.dispose();
    _message.dispose();
    _phone.dispose();
    super.dispose();
  }

  AppConfig? _draft() {
    final build = int.tryParse(_build.text.trim());
    final phone = normalizePhone(_phone.text);
    final message = _message.text.trim();
    if (build == null || build < 0 || phone == null || message.length > 500) return null;
    return AppConfig(
      minSupportedBuild: build,
      maintenanceMessage: message.isEmpty ? null : message,
      supportPhone: phone,
      dispatchEnabled: _dispatch,
    );
  }

  Future<void> _save(AppConfig next) async {
    final l10n = AppLocalizations.of(context);
    final actor = await _actor(ref);
    if (actor == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(settingsRepositoryProvider).saveConfig(next, before: widget.config, actorUid: actor);
      LaneLog.i('app config saved', {'dispatchEnabled': next.dispatchEnabled});
      if (mounted) LaneToast.show(context, l10n.settings_saved);
    } catch (e, st) {
      LaneLog.w('saving app config failed', error: e, stackTrace: st);
      if (mounted) LaneToast.show(context, l10n.approvals_error_unknown);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final draft = _draft();
    final changed = draft != null && draft != widget.config;
    final phoneError = _phone.text.trim().isNotEmpty && normalizePhone(_phone.text) == null;

    return _Section(
      title: l10n.settings_app_title,
      children: [
        LaneTextField(
          label: l10n.settings_min_build_label,
          helper: l10n.settings_min_build_help,
          controller: _build,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => setState(() {}),
        ),
        Gap(lane.space.s16),
        LaneTextField(
          label: l10n.settings_maintenance_label,
          helper: l10n.settings_maintenance_help,
          controller: _message,
          maxLines: 3,
          maxLength: 500,
          onChanged: (_) => setState(() {}),
        ),
        Gap(lane.space.s16),
        LaneTextField(
          label: l10n.settings_support_phone_label,
          hint: l10n.settings_support_phone_hint,
          controller: _phone,
          keyboardType: TextInputType.phone,
          errorText: phoneError ? l10n.settings_phone_invalid : null,
          onChanged: (_) => setState(() {}),
        ),
        Gap(lane.space.s16),
        LaneSwitch(
          label: l10n.settings_dispatch_label,
          subtitle: _dispatch ? l10n.settings_dispatch_on : l10n.settings_dispatch_off,
          value: _dispatch,
          onChanged: (on) => setState(() => _dispatch = on),
        ),
        Gap(lane.space.s16),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: LaneButton.primary(
            label: l10n.settings_save,
            loading: _saving,
            onPressed: changed && !_saving ? () => _save(draft) : null,
          ),
        ),
      ],
    );
  }
}

class _AreaRow extends ConsumerStatefulWidget {
  const _AreaRow({super.key, required this.city, required this.area});

  final CityId city;
  final ServiceArea area;

  @override
  ConsumerState<_AreaRow> createState() => _AreaRowState();
}

class _AreaRowState extends ConsumerState<_AreaRow> {
  late final _radius = TextEditingController(text: _km(widget.area.radiusKm));
  late bool _active = widget.area.active;
  bool _saving = false;

  static String _km(double km) => km == km.roundToDouble() ? '${km.round()}' : '$km';

  @override
  void dispose() {
    _radius.dispose();
    super.dispose();
  }

  double? get _radiusKm {
    final v = double.tryParse(_radius.text.trim());
    return v == null || v <= 0 || v > 100 ? null : v;
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final actor = await _actor(ref);
    final km = _radiusKm;
    if (actor == null || km == null) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(settingsRepositoryProvider)
          .saveArea(
            widget.city,
            widget.area.copyWith(active: _active, radiusKm: km),
            before: widget.area,
            actorUid: actor,
          );
      LaneLog.i('service area saved', {'city': widget.city.value, 'active': _active});
      if (mounted) LaneToast.show(context, l10n.settings_saved);
    } catch (e, st) {
      LaneLog.w('saving service area failed', error: e, stackTrace: st);
      if (mounted) LaneToast.show(context, l10n.approvals_error_unknown);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final name = cityLabel(l10n, widget.city);
    final km = _radiusKm;
    final changed = km != null && (km != widget.area.radiusKm || _active != widget.area.active);
    final gap = lane.space.s16;
    return Padding(
      padding: EdgeInsets.only(bottom: gap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LaneSwitch(
            label: name,
            subtitle: _active ? l10n.settings_area_on : l10n.settings_area_off(name),
            value: _active,
            onChanged: (on) => setState(() => _active = on),
          ),
          Gap(lane.space.s8),
          LaneTextField(
            label: l10n.settings_area_radius_label(name),
            controller: _radius,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            errorText: km == null ? l10n.settings_area_radius_invalid : null,
            onChanged: (_) => setState(() {}),
          ),
          if (changed) ...[
            Gap(lane.space.s8),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: LaneButton.secondary(
                label: l10n.settings_area_save(name),
                loading: _saving,
                onPressed: _saving ? null : _save,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Admins extends ConsumerWidget {
  const _Admins();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final admins = ref.watch(adminsProvider).value ?? const <AdminEntry>[];
    return _Section(
      title: l10n.settings_admins_title,
      children: [
        for (final a in admins) Text(a.email, style: lane.text.body),
        Gap(lane.space.s8),
        Text(l10n.settings_admins_note, style: lane.text.caption.copyWith(color: lane.color.inkMuted)),
      ],
    );
  }
}

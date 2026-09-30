import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:roadside_core/roadside_core.dart';

import '../../../_local_ui/first_run_widgets.dart';
import '../../../_local_ui/photo_slot.dart';
import '../../../app/router.dart';
import '../../../app/secure_window.dart';
import '../../../l10n/app_localizations.dart';
import '../../permissions/application/permission_service.dart';
import '../../permissions/presentation/permission_explainer_screen.dart';
import '../application/registration.dart';
import '../data/mechanic_photos.dart';
import 'registration_labels.dart';

/// M1 Registration (PLAN §10, §10.0): four steps, starting with "Do you have a workshop?".
/// The workshop path asks for the shop; the independent path (M1·Ind) for experience, base
/// area, toolkit photos, travel vehicle, selfie with ID and address proof. Everything after
/// approval is the same for both.
class RegistrationScreen extends ConsumerWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(registrationProvider);
    final controller = ref.read(registrationProvider.notifier);
    final total = RegistrationStep.values.length;
    final index = state.step.index;
    final last = index == total - 1;

    ref.listen(registrationProvider.select((s) => s.submitted), (_, submitted) {
      if (submitted) context.go(AppRoutes.pending);
    });

    final title = switch (state.step) {
      RegistrationStep.type => l10n.register_type_title,
      RegistrationStep.aboutYou => l10n.register_about_title,
      RegistrationStep.work => l10n.register_work_title,
      RegistrationStep.idAndPay => l10n.register_id_title,
    };
    final body = switch (state.step) {
      RegistrationStep.type => const _TypeStep(),
      RegistrationStep.aboutYou => const _AboutStep(),
      RegistrationStep.work => const _WorkStep(),
      RegistrationStep.idAndPay => const _IdStep(),
    };

    final flow = LaneFlowScaffold(
      // A fresh scaffold per step, so each step opens scrolled to the top.
      key: ValueKey(state.step),
      step: index + 1,
      totalSteps: total,
      stepLabel: l10n.flow_step_label(index + 1, total),
      title: title,
      showBack: index > 0,
      onBack: controller.back,
      primary: LaneButton.primary(
        label: last ? l10n.register_submit : l10n.register_next,
        critical: last,
        loading: state.submitting,
        onPressed: state.submitting ? null : (last ? controller.submit : controller.next),
      ),
      children: [
        if (state.submitError != null)
          _SubmitErrorBanner(
            message: state.submitError == SubmitError.upload
                ? l10n.register_error_upload
                : l10n.register_error_save,
          ),
        body,
      ],
    );
    // PLAN §12.7: the ID proof and UPI details never show in screenshots or the recents preview.
    return state.step == RegistrationStep.idAndPay ? SecureScreen(child: flow) : flow;
  }
}

/// Shared by the step widgets.
extension on WidgetRef {
  RegistrationState get reg => watch(registrationProvider);
  RegistrationController get regController => read(registrationProvider.notifier);
}

class _SubmitErrorBanner extends StatelessWidget {
  const _SubmitErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    // Named tokens: tool/lint_design.sh misreads token names like `s16` as magic numbers.
    final below = lane.space.s16;
    final inset = lane.space.s12;
    return Semantics(
      liveRegion: true,
      child: Container(
        margin: EdgeInsets.only(bottom: below),
        padding: EdgeInsets.all(inset),
        decoration: BoxDecoration(color: lane.color.signal.stopTint, borderRadius: lane.radius.r12),
        child: Row(
          children: [
            LaneIcon(LaneIcons.warning, size: lane.space.s24, color: lane.color.signal.stop),
            SizedBox(width: lane.space.s12),
            Expanded(
              child: Text(message, style: lane.text.body.copyWith(color: lane.color.ink)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section heading inside a step.
class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final above = lane.space.s24;
    final below = lane.space.s8;
    return Padding(
      padding: EdgeInsets.only(top: above, bottom: below),
      child: Text(text, style: lane.text.title.copyWith(color: lane.color.ink)),
    );
  }
}

// Step 1: workshop or independent, and city.
class _TypeStep extends ConsumerWidget {
  const _TypeStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final s = ref.reg;
    final c = ref.regController;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.register_type_question, style: lane.text.bodyLarge.copyWith(color: lane.color.ink)),
        SizedBox(height: lane.space.s12),
        LanguageTile(
          nativeName: l10n.register_type_workshop,
          selected: s.draft.mechanicType == MechanicType.workshop,
          onTap: () => c.update((d) => d.copyWith(mechanicType: MechanicType.workshop)),
        ),
        SizedBox(height: lane.space.s12),
        LanguageTile(
          nativeName: l10n.register_type_independent,
          selected: s.draft.mechanicType == MechanicType.independent,
          onTap: () => c.update((d) => d.copyWith(mechanicType: MechanicType.independent)),
        ),
        FieldError(l10n.error(s.errors['mechanicType'])),
        _Heading(l10n.register_city_label),
        Wrap(
          spacing: lane.space.s8,
          runSpacing: lane.space.s8,
          children: [
            for (final city in CityId.values)
              LaneChip(
                label: l10n.city(city),
                selected: s.draft.cityId == city,
                onSelected: (_) => c.update((d) => d.copyWith(cityId: city)),
              ),
          ],
        ),
        FieldError(l10n.error(s.errors['cityId'])),
        SizedBox(height: lane.space.s8),
        Text(l10n.register_city_help, style: lane.text.caption.copyWith(color: lane.color.inkMuted)),
      ],
    );
  }
}

/// Asks camera or gallery, then picks into [slot] (or a new toolkit photo).
Future<void> _pickPhoto(BuildContext context, WidgetRef ref, {RegistrationPhoto? slot}) async {
  final l10n = AppLocalizations.of(context);
  final source = await showLaneSheet<PhotoSource>(
    context,
    builder: (sheet) => LaneSheet(
      title: l10n.register_photo_source_title,
      primary: LaneButton.primary(
        label: l10n.register_photo_camera,
        onPressed: () => Navigator.of(sheet).pop(PhotoSource.camera),
      ),
      secondary: LaneButton.secondary(
        label: l10n.register_photo_gallery,
        onPressed: () => Navigator.of(sheet).pop(PhotoSource.gallery),
      ),
    ),
  );
  if (source == null) return;
  // PLAN §13: the C7 explainer comes before Android's camera prompt. The gallery needs no
  // permission (Android's photo picker).
  if (source == PhotoSource.camera) {
    if (!context.mounted || !await ensurePermission(context, ref, AppPermission.camera)) return;
  }
  final c = ref.read(registrationProvider.notifier);
  try {
    if (slot == null) {
      await c.addToolkitPhoto(source);
    } else {
      await c.pickPhoto(slot, source);
    }
  } on PhotoTooLargeException {
    if (context.mounted) LaneToast.show(context, l10n.register_photo_too_large);
  }
}

// Step 2: about you (+ shop, or independent details).
class _AboutStep extends ConsumerWidget {
  const _AboutStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final s = ref.reg;
    final d = s.draft;
    final c = ref.regController;
    String? err(String field) => l10n.error(s.errors[field]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LaneTextField(
          key: const ValueKey('name'),
          label: l10n.register_name_label,
          initialValue: d.name,
          errorText: err('name'),
          textInputAction: TextInputAction.next,
          // The person-name keyboard: no autocorrect, which "fixed" names into other words.
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          autofillHints: const [AutofillHints.name],
          onChanged: (v) => c.update((x) => x.copyWith(name: v)),
        ),
        SizedBox(height: lane.space.s16),
        PhotoSlot(
          label: l10n.register_photo_profile,
          addLabel: l10n.register_photo_add,
          bytes: d.photos[RegistrationPhoto.profile],
          hasError: err('profilePhotoUrl') != null,
          onTap: () => _pickPhoto(context, ref, slot: RegistrationPhoto.profile),
        ),
        FieldError(err('profilePhotoUrl')),
        if (!d.isIndependent) ...[
          _Heading(l10n.register_shop_heading),
          LaneTextField(
            key: const ValueKey('shopName'),
            label: l10n.register_shop_name_label,
            initialValue: d.shopName,
            errorText: err('shopName'),
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            onChanged: (v) => c.update((x) => x.copyWith(shopName: v)),
          ),
          SizedBox(height: lane.space.s12),
          LaneTextField(
            key: const ValueKey('shopAddress'),
            label: l10n.register_shop_address_label,
            initialValue: d.shopAddress,
            errorText: err('shopAddress'),
            maxLength: 300,
            onChanged: (v) => c.update((x) => x.copyWith(shopAddress: v)),
          ),
          SizedBox(height: lane.space.s12),
          PhotoSlot(
            label: l10n.register_photo_shop,
            addLabel: l10n.register_photo_add,
            bytes: d.photos[RegistrationPhoto.shop],
            hasError: err('shopPhotoUrl') != null,
            onTap: () => _pickPhoto(context, ref, slot: RegistrationPhoto.shop),
          ),
          FieldError(err('shopPhotoUrl')),
        ] else ...[
          _Heading(l10n.register_independent_heading),
          LaneTextField(
            key: const ValueKey('experience'),
            label: l10n.register_experience_label,
            initialValue: d.experienceYears,
            errorText: err('experienceYears'),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (v) => c.update((x) => x.copyWith(experienceYears: v)),
          ),
          SizedBox(height: lane.space.s12),
          LaneTextField(
            key: const ValueKey('baseArea'),
            label: l10n.register_base_area_label,
            hint: l10n.register_base_area_hint,
            initialValue: d.baseLocality,
            errorText: err('baseArea'),
            onChanged: (v) => c.update((x) => x.copyWith(baseLocality: v)),
          ),
          _Heading(l10n.register_travel_heading),
          Wrap(
            spacing: lane.space.s8,
            runSpacing: lane.space.s8,
            children: [
              for (final t in kTravelVehicleTypes)
                LaneChip(
                  label: l10n.vehicleType(t),
                  icon: LaneIcon(vehicleIcon(t), size: lane.space.s20),
                  selected: d.travelVehicleType == t,
                  onSelected: (_) => c.update((x) => x.copyWith(travelVehicleType: t)),
                ),
            ],
          ),
          SizedBox(height: lane.space.s12),
          LaneTextField(
            key: const ValueKey('travelRegNo'),
            label: l10n.register_travel_reg_label,
            hint: l10n.register_travel_reg_hint,
            initialValue: d.travelRegNo,
            errorText: err('travelVehicle'),
            textCapitalization: TextCapitalization.characters,
            onChanged: (v) => c.update((x) => x.copyWith(travelRegNo: v)),
          ),
          _Heading(l10n.register_toolkit_heading),
          Text(l10n.register_toolkit_help, style: lane.text.caption.copyWith(color: lane.color.inkMuted)),
          SizedBox(height: lane.space.s8),
          Wrap(
            spacing: lane.space.s8,
            runSpacing: lane.space.s8,
            children: [
              for (final (i, bytes) in d.toolkitPhotos.indexed)
                PhotoSlot(
                  label: l10n.register_photo_toolkit(i + 1),
                  addLabel: l10n.register_photo_add,
                  bytes: bytes,
                  removeLabel: l10n.register_photo_remove,
                  onRemove: () => c.removeToolkitPhoto(i),
                  onTap: () {},
                ),
              if (d.toolkitPhotos.length < kMaxToolkitPhotos)
                PhotoSlot(
                  label: l10n.register_photo_toolkit(d.toolkitPhotos.length + 1),
                  addLabel: l10n.register_photo_add,
                  hasError: err('toolkitPhotoUrls') != null,
                  onTap: () => _pickPhoto(context, ref),
                ),
            ],
          ),
          FieldError(err('toolkitPhotoUrls')),
        ],
      ],
    );
  }
}

// Step 3: vehicle types and services.
class _WorkStep extends ConsumerWidget {
  const _WorkStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final s = ref.reg;
    final d = s.draft;
    final c = ref.regController;

    Set<T> toggle<T>(Set<T> set, T v) => set.contains(v) ? ({...set}..remove(v)) : {...set, v};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.register_vehicles_label, style: lane.text.label.copyWith(color: lane.color.ink)),
        SizedBox(height: lane.space.s8),
        Wrap(
          spacing: lane.space.s8,
          runSpacing: lane.space.s8,
          children: [
            for (final t in VehicleType.values)
              LaneChip(
                label: l10n.vehicleType(t),
                icon: LaneIcon(vehicleIcon(t), size: lane.space.s20),
                selected: d.vehicleTypes.contains(t),
                onSelected: (_) => c.update((x) => x.copyWith(vehicleTypes: toggle(x.vehicleTypes, t))),
              ),
          ],
        ),
        FieldError(l10n.error(s.errors['vehicleTypes'])),
        _Heading(l10n.register_services_label),
        LaneTileGrid(
          children: [
            for (final p in ProblemType.values)
              ProblemTile(
                icon: problemIcon(p),
                label: l10n.problemType(p),
                selected: d.services.contains(p),
                onTap: () => c.update((x) => x.copyWith(services: toggle(x.services, p))),
              ),
          ],
        ),
        FieldError(l10n.error(s.errors['services'])),
      ],
    );
  }
}

// Step 4: ID documents and UPI.
class _IdStep extends ConsumerWidget {
  const _IdStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final s = ref.reg;
    final d = s.draft;
    final c = ref.regController;
    String? err(String field) => l10n.error(s.errors[field]);

    Widget doc(RegistrationPhoto slot, String label, String field) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PhotoSlot(
          label: label,
          addLabel: l10n.register_photo_add,
          bytes: d.photos[slot],
          hasError: err(field) != null,
          onTap: () => _pickPhoto(context, ref, slot: slot),
        ),
        FieldError(err(field)),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.register_id_private, style: lane.text.caption.copyWith(color: lane.color.inkMuted)),
        SizedBox(height: lane.space.s12),
        Wrap(
          spacing: lane.space.s12,
          runSpacing: lane.space.s12,
          children: [
            doc(RegistrationPhoto.idProof, l10n.register_photo_id_proof, 'idProofPath'),
            if (d.isIndependent) ...[
              doc(RegistrationPhoto.selfieWithId, l10n.register_photo_selfie, 'selfieWithIdPath'),
              doc(RegistrationPhoto.addressProof, l10n.register_photo_address_proof, 'addressProofPath'),
            ],
          ],
        ),
        _Heading(l10n.register_upi_heading),
        LaneTextField(
          key: const ValueKey('upiId'),
          label: l10n.register_upi_id_label,
          hint: l10n.register_upi_id_hint,
          initialValue: d.upiId,
          errorText: err('upiId'),
          keyboardType: TextInputType.emailAddress,
          onChanged: (v) => c.update((x) => x.copyWith(upiId: v)),
        ),
        SizedBox(height: lane.space.s12),
        LaneTextField(
          key: const ValueKey('upiName'),
          label: l10n.register_upi_name_label,
          initialValue: d.upiName,
          errorText: err('upiName'),
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          onChanged: (v) => c.update((x) => x.copyWith(upiName: v)),
        ),
        if (d.isIndependent) ...[
          _Heading(l10n.register_reference_heading),
          Text(l10n.register_reference_help, style: lane.text.caption.copyWith(color: lane.color.inkMuted)),
          SizedBox(height: lane.space.s8),
          LaneTextField(
            key: const ValueKey('referenceName'),
            label: l10n.register_reference_name_label,
            initialValue: d.referenceName,
            errorText: err('referenceContact'),
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            onChanged: (v) => c.update((x) => x.copyWith(referenceName: v)),
          ),
          SizedBox(height: lane.space.s12),
          LaneTextField(
            key: const ValueKey('referencePhone'),
            label: l10n.register_reference_phone_label,
            hint: l10n.register_reference_phone_hint,
            initialValue: d.referencePhone,
            keyboardType: TextInputType.phone,
            onChanged: (v) => c.update((x) => x.copyWith(referencePhone: v)),
          ),
        ],
      ],
    );
  }
}

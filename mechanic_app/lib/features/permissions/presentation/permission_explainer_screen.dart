import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart';

import '../../../l10n/app_localizations.dart';
import '../application/permission_service.dart';

/// Route of the explainer for one permission.
String permissionRoute(AppPermission p) => '/permission/${p.name}';

/// Asks for [permission] the Play-compliant way: if it isn't granted yet, the C7
/// explainer comes first and the system prompt only after "Allow". Returns whether the
/// app may now use it.
Future<bool> ensurePermission(BuildContext context, WidgetRef ref, AppPermission permission) async {
  if (await ref.read(permissionServiceProvider).status(permission) == PermissionAccess.granted) return true;
  if (!context.mounted) return false;
  return await context.push<bool>(permissionRoute(permission)) ?? false;
}

/// C7 Permission explainer (PLAN §13 prominent disclosure): why we need it, in plain
/// words, before the system prompt. If the user blocked it, "Open settings" instead;
/// coming back from Settings re-checks.
class PermissionExplainerScreen extends ConsumerStatefulWidget {
  const PermissionExplainerScreen({super.key, required this.permission});

  final AppPermission permission;

  @override
  ConsumerState<PermissionExplainerScreen> createState() => _PermissionExplainerScreenState();
}

class _PermissionExplainerScreenState extends ConsumerState<PermissionExplainerScreen>
    with WidgetsBindingObserver {
  PermissionAccess? _access;

  PermissionService get _service => ref.read(permissionServiceProvider);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Back from the phone's Settings: it may be allowed now.
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final access = await _service.status(widget.permission);
    if (!mounted) return;
    if (access == PermissionAccess.granted) return _done(true);
    setState(() => _access = access);
  }

  void _done(bool granted) {
    if (context.canPop()) context.pop(granted);
  }

  Future<void> _allow() async {
    if (_access == PermissionAccess.blocked) {
      await _service.openSettings();
      return;
    }
    final access = await _service.request(widget.permission);
    if (!mounted) return;
    if (access == PermissionAccess.granted) return _done(true);
    setState(() => _access = access);
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final (icon, title, body) = switch (widget.permission) {
      AppPermission.location => (
        LaneIcons.location,
        l10n.permission_location_title,
        l10n.permission_location_body,
      ),
      // Pictograms until lane_ui has camera and bell glyphs.
      AppPermission.camera => (LaneIcons.shield, l10n.permission_camera_title, l10n.permission_camera_body),
      AppPermission.notifications => (
        LaneIcons.chat,
        l10n.permission_notifications_title,
        l10n.permission_notifications_body,
      ),
      AppPermission.fullScreenOffers => (
        LaneIcons.wrench,
        l10n.permission_full_screen_title,
        l10n.permission_full_screen_body,
      ),
    };
    final blocked = _access == PermissionAccess.blocked;

    if (_access == null) {
      return Scaffold(body: Center(child: SkeletonGroup.lines()));
    }
    return LaneStatusScaffold(
      visual: LaneIcon(icon, size: lane.space.s64 * 2),
      title: title,
      message: blocked ? '$body\n\n${l10n.permission_blocked_body}' : body,
      primary: LaneButton.primary(
        label: blocked ? l10n.permission_open_settings : l10n.permission_allow,
        onPressed: _allow,
      ),
      secondary: LaneButton.ghost(label: l10n.permission_not_now, onPressed: () => _done(false)),
    );
  }
}

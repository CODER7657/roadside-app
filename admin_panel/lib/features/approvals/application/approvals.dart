import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadside_core/roadside_core.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../console/application/city_filter.dart';
import '../data/mechanic_admin_api.dart';
import '../data/mechanics_repository.dart';

/// A2 filters on top of the console's city filter (PLAN §10 admin 2).
class ApprovalFilters {
  const ApprovalFilters({this.status = MechanicStatus.pending, this.type, this.search = ''});

  final MechanicStatus status;

  /// Null = both types.
  final MechanicType? type;
  final String search;

  ApprovalFilters copyWith({MechanicStatus? status, MechanicType? Function()? type, String? search}) =>
      ApprovalFilters(
        status: status ?? this.status,
        type: type != null ? type() : this.type,
        search: search ?? this.search,
      );
}

final approvalFiltersProvider = NotifierProvider<ApprovalFiltersController, ApprovalFilters>(
  ApprovalFiltersController.new,
);

class ApprovalFiltersController extends Notifier<ApprovalFilters> {
  @override
  ApprovalFilters build() => const ApprovalFilters();

  void status(MechanicStatus s) => state = state.copyWith(status: s);

  void type(MechanicType? t) => state = state.copyWith(type: () => t);

  void search(String text) => state = state.copyWith(search: text);
}

/// Mechanics in the selected status, before the city / type / search filters.
final mechanicsByStatusProvider = StreamProvider.family<List<MechanicEntry>, MechanicStatus>(
  (ref, status) => ref.watch(mechanicsRepositoryProvider).watch(status),
);

/// The list shown on the left.
final filteredMechanicsProvider = Provider<AsyncValue<List<MechanicEntry>>>((ref) {
  final filters = ref.watch(approvalFiltersProvider);
  final city = ref.watch(cityFilterProvider);
  final query = filters.search.trim().toLowerCase();
  return ref
      .watch(mechanicsByStatusProvider(filters.status))
      .whenData(
        (list) => [
          for (final e in list)
            if ((city == null || e.mechanic.cityId == city) &&
                (filters.type == null || e.mechanic.mechanicType == filters.type) &&
                (query.isEmpty || e.mechanic.name.toLowerCase().contains(query)))
              e,
        ],
      );
});

final kycProvider = StreamProvider.family<MechanicKyc?, String>(
  (ref, uid) => ref.watch(mechanicsRepositoryProvider).watchKyc(uid),
);

/// Selected mechanic's uid. The screen falls back to the first in the list.
final selectedMechanicProvider = NotifierProvider<SelectedMechanic, String?>(SelectedMechanic.new);

class SelectedMechanic extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? uid) => state = uid;
}

/// What the admin checked by eye before approving (PLAN §10.0). Per type.
enum ChecklistItem {
  // workshop
  shopPhoto(MechanicType.workshop),
  idProof(MechanicType.workshop),
  services(MechanicType.workshop),
  // independent
  selfieMatchesId(MechanicType.independent),
  addressProof(MechanicType.independent),
  toolkitPhotos(MechanicType.independent);

  const ChecklistItem(this.type);

  final MechanicType type;

  static List<ChecklistItem> forType(MechanicType type) => [
    for (final i in values)
      if (i.type == type) i,
  ];
}

/// Ticked items per mechanic uid. Kept for the session only: the audited decision is the
/// approval itself (and the verification call, which the server records).
final checklistProvider = NotifierProvider<Checklist, Map<String, Set<ChecklistItem>>>(Checklist.new);

class Checklist extends Notifier<Map<String, Set<ChecklistItem>>> {
  @override
  Map<String, Set<ChecklistItem>> build() => const {};

  void toggle(String uid, ChecklistItem item, bool on) {
    final items = {...?state[uid]};
    on ? items.add(item) : items.remove(item);
    state = {...state, uid: items};
  }
}

/// Whether Approve is enabled: a pending mechanic with KYC, every item of its type ticked, and
/// for independent mechanics a logged verification call (PLAN §10.0).
bool canApprove(Mechanic m, MechanicKyc? kyc, Set<ChecklistItem> ticked) =>
    m.status == MechanicStatus.pending &&
    kyc != null &&
    ChecklistItem.forType(m.mechanicType).every(ticked.contains) &&
    (m.mechanicType == MechanicType.workshop || kyc.verificationCall != null);

enum ApprovalAction { approve, block, logCall, openDocument }

/// Runs admin actions and tracks which one is in flight.
final approvalActionsProvider = NotifierProvider<ApprovalActions, ApprovalAction?>(ApprovalActions.new);

class ApprovalActions extends Notifier<ApprovalAction?> {
  @override
  ApprovalAction? build() => null;

  MechanicAdminApi get _api => ref.read(mechanicAdminApiProvider);

  Future<T> _run<T>(ApprovalAction action, String uid, Future<T> Function() body) async {
    state = action;
    try {
      final result = await body();
      LaneLog.i('admin action', {'action': action.name, 'uid': uid});
      return result;
    } catch (e, st) {
      LaneLog.w('admin action failed', error: e, stackTrace: st, fields: {'action': action.name, 'uid': uid});
      rethrow;
    } finally {
      state = null;
    }
  }

  Future<void> approve(String uid) => _run(ApprovalAction.approve, uid, () => _api.approve(uid));

  Future<void> block(String uid, String reason) =>
      _run(ApprovalAction.block, uid, () => _api.block(uid, reason: reason.trim()));

  Future<void> logCall(String uid, String notes) =>
      _run(ApprovalAction.logCall, uid, () => _api.logVerificationCall(uid, notes: notes.trim()));

  Future<Uri?> documentUrl(String uid, KycDocument doc) =>
      _run(ApprovalAction.openDocument, uid, () async => (await _api.kycDocumentUrls(uid))[doc]);
}

/// Opens a signed document URL in a new tab; nothing is saved on the admin's computer
/// (PLAN §12.11). Overridden in tests.
final documentOpenerProvider = Provider<Future<void> Function(Uri url)>(
  (ref) =>
      (url) => launchUrl(url, webOnlyWindowName: '_blank'),
);

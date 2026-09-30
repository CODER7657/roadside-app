// A2 Mechanic approvals (#50): per-type checklist, the independent-mechanic verification call,
// approve / block through the admin callables (#130), KYC documents via signed URLs.

import 'package:admin_panel/app/firebase_providers.dart';
import 'package:admin_panel/app/router.dart';
import 'package:admin_panel/features/approvals/application/approvals.dart';
import 'package:admin_panel/features/approvals/data/mechanic_admin_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:roadside_core/fakes.dart';
import 'package:roadside_core/roadside_core.dart';

import 'support.dart';

const independentUid = RoadsideFakes.pendingMechanicId; // Suresh Vasava, Ankleshwar, independent
const workshopUid = 'fake-mechanic-pending-workshop';

/// Records calls; writes what the real callables (#130) would, so the screen reacts.
class FakeMechanicAdminApi implements MechanicAdminApi {
  FakeMechanicAdminApi(this.db);

  final FakeFirebaseFirestore db;
  final calls = <String>[];
  AdminActionFailure? failWith;
  Map<KycDocument, Uri> urls = {KycDocument.idProof: Uri.parse('https://storage.example/signed-id?exp=300')};

  void _maybeFail() {
    if (failWith case final f?) throw AdminActionException(f);
  }

  @override
  Future<void> approve(String uid) async {
    _maybeFail();
    calls.add('approve $uid');
    await db.doc('mechanics/$uid').update({'status': 'approved'});
  }

  @override
  Future<void> block(String uid, {required String reason}) async {
    _maybeFail();
    calls.add('block $uid: $reason');
    await db.doc('mechanics/$uid').update({'status': 'blocked'});
  }

  @override
  Future<void> logVerificationCall(String uid, {required String notes}) async {
    _maybeFail();
    calls.add('call $uid: $notes');
    await db.doc('mechanics/$uid/private/kyc').update({
      'verificationCall': {'doneBy': 'admin-1', 'at': Timestamp.now(), 'notes': notes},
    });
  }

  @override
  Future<Map<KycDocument, Uri>> kycDocumentUrls(String uid) async {
    _maybeFail();
    calls.add('urls $uid');
    return urls;
  }
}

Mechanic workshop() => RoadsideFakes.workshopMechanic.copyWith(
  name: 'Ravi Desai',
  status: MechanicStatus.pending,
  rating: 0,
  ratingCount: 0,
  jobsCompleted: 0,
  cityId: CityId.bharuch,
  createdAt: RoadsideFakes.now.subtract(const Duration(hours: 2)),
);

void main() {
  group('canApprove (PLAN §10.0)', () {
    final all = ChecklistItem.values.toSet();

    test('workshop: pending, KYC and its three checks', () {
      final m = workshop();
      expect(canApprove(m, RoadsideFakes.workshopKyc, all), isTrue);
      expect(canApprove(m, null, all), isFalse);
      expect(canApprove(m, RoadsideFakes.workshopKyc, {ChecklistItem.shopPhoto}), isFalse);
      expect(
        canApprove(m.copyWith(status: MechanicStatus.approved), RoadsideFakes.workshopKyc, all),
        isFalse,
      );
    });

    test('independent: also needs the logged verification call', () {
      final m = RoadsideFakes.pendingMechanic;
      expect(canApprove(m, RoadsideFakes.pendingKyc, all), isFalse);
      final called = RoadsideFakes.pendingKyc.copyWith(
        verificationCall: VerificationCall(doneBy: 'a', at: RoadsideFakes.now, notes: 'ok'),
      );
      expect(canApprove(m, called, all), isTrue);
      expect(canApprove(m, called, {ChecklistItem.selfieMatchesId}), isFalse);
    });
  });

  group('A2 screen', () {
    late FakeFirebaseFirestore db;
    late FakeMechanicAdminApi api;
    late List<Uri> opened;

    Future<void> openApprovals(WidgetTester tester) async {
      db = FakeFirebaseFirestore();
      await db.doc('mechanics/$independentUid').set(RoadsideFakes.pendingMechanic.toJson());
      await db.doc('mechanics/$independentUid/private/kyc').set(RoadsideFakes.pendingKyc.toJson());
      await db.doc('mechanics/$workshopUid').set(workshop().toJson());
      await db.doc('mechanics/$workshopUid/private/kyc').set(RoadsideFakes.workshopKyc.toJson());
      await db
          .doc('mechanics/${RoadsideFakes.independentMechanicId}')
          .set(RoadsideFakes.independentMechanic.toJson()); // approved: not in the Pending list
      api = FakeMechanicAdminApi(db);
      opened = [];
      await pumpPanel(
        tester,
        overrides: [
          firestoreProvider.overrideWithValue(db),
          mechanicAdminApiProvider.overrideWithValue(api),
          documentOpenerProvider.overrideWithValue((url) async => opened.add(url)),
        ],
      );
      auth.emit(admin);
      await settle(tester);
      container.read(routerProvider).go('/approvals');
      await settle(tester);
    }

    Finder fieldLabelled(String label) => find.descendant(
      of: find.byWidgetPredicate((w) => w is LaneTextField && w.label == label),
      matching: find.byType(EditableText),
    );

    Future<void> tapLabel(WidgetTester tester, String label) async {
      final byText = find.text(label);
      await tester.ensureVisible(
        byText.evaluate().isNotEmpty ? byText.first : find.bySemanticsLabel(label).first,
      );
      await tester.tap(byText.evaluate().isNotEmpty ? byText.first : find.bySemanticsLabel(label).first);
      await settle(tester);
    }

    testPanel('lists pending mechanics, newest first; filters by type and city', (tester) async {
      await openApprovals(tester);
      expect(find.text('Ravi Desai'), findsWidgets);
      expect(find.text('Suresh Vasava'), findsWidgets);
      expect(find.text('Kiran Patel'), findsNothing); // approved

      await tapLabel(tester, 'Independent');
      expect(find.text('Ravi Desai'), findsNothing);
      await tapLabel(tester, 'All types');
      await tapLabel(tester, 'Bharuch');
      expect(find.text('Suresh Vasava'), findsNothing);
      expect(find.text('Ravi Desai'), findsWidgets);
    });

    testPanel('independent: Approve stays off until the checklist and the call are done', (tester) async {
      await openApprovals(tester);
      await tapLabel(tester, 'Suresh Vasava');
      expect(find.text('Suresh Vasava · Independent'), findsOneWidget);
      expect(find.text('Tick every checklist item to approve.'), findsOneWidget);

      for (final item in [
        'Selfie matches the ID',
        'Address proof checked',
        'Toolkit photos show real tools',
      ]) {
        await tapLabel(tester, item);
      }
      expect(find.text('Log the verification call to approve an independent mechanic.'), findsOneWidget);
      await tapLabel(tester, 'Approve');
      expect(api.calls, isEmpty); // still disabled

      await tester.enterText(fieldLabelled('Verification call notes'), 'Video call, ID matched');
      await settle(tester);
      await tapLabel(tester, 'Log verification call');
      expect(api.calls, ['call $independentUid: Video call, ID matched']);
      expect(find.textContaining('Call logged'), findsOneWidget);

      await tapLabel(tester, 'Approve');
      expect(api.calls.last, 'approve $independentUid');
      expect(find.text('Approved. They can go online now.'), findsOneWidget);
      expect((await db.doc('mechanics/$independentUid').get()).get('status'), 'approved');
    });

    testPanel('workshop: three checks, no call needed', (tester) async {
      await openApprovals(tester);
      await tapLabel(tester, 'Ravi Desai');
      expect(find.text('Log verification call'), findsNothing);
      for (final item in [
        'Shop photo shows a real workshop',
        'ID proof matches the name',
        'Services and vehicles make sense',
      ]) {
        await tapLabel(tester, item);
      }
      await tapLabel(tester, 'Approve');
      expect(api.calls, ['approve $workshopUid']);
    });

    testPanel('block needs a reason', (tester) async {
      await openApprovals(tester);
      await tapLabel(tester, 'Ravi Desai');
      await tapLabel(tester, 'Block');
      await tapLabel(tester, 'Block mechanic');
      expect(api.calls, isEmpty);
      await tester.enterText(fieldLabelled('Why are you blocking them?'), "ID proof doesn't match");
      await settle(tester);
      await tapLabel(tester, 'Block mechanic');
      expect(api.calls, ["block $workshopUid: ID proof doesn't match"]);
      expect(find.text("Blocked. They're signed out everywhere."), findsOneWidget);
    });

    testPanel('KYC documents open as signed URLs in a new tab', (tester) async {
      await openApprovals(tester);
      await tapLabel(tester, 'Suresh Vasava');
      await tapLabel(tester, 'Open ID proof');
      expect(api.calls, ['urls $independentUid']);
      expect(opened, [Uri.parse('https://storage.example/signed-id?exp=300')]);

      await tapLabel(tester, 'Open address proof'); // not returned by the server
      expect(opened, hasLength(1));
      expect(find.text("That document isn't available."), findsOneWidget);
    });

    testPanel('says so while the admin callables are not deployed yet', (tester) async {
      await openApprovals(tester);
      api.failWith = AdminActionFailure.unavailable;
      await tapLabel(tester, 'Ravi Desai');
      await tapLabel(tester, 'Open ID proof');
      expect(find.text("That action isn't available yet. Try again later."), findsOneWidget);
      expect(opened, isEmpty);
    });

    testPanel('empty list', (tester) async {
      await openApprovals(tester);
      await tapLabel(tester, 'Blocked');
      expect(find.text('Nothing here: no mechanics with status Blocked.'), findsOneWidget);
    });
  });
}

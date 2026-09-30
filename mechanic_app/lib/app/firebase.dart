import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'env.dart';
import 'flavor.dart';

/// What `bootstrap` connected to.
enum FirebaseMode {
  /// No Firebase config (tests, CI, a checkout without `google-services.json`): the in-memory
  /// fakes run the app.
  none,

  /// The local Emulator Suite (`USE_EMULATORS=true`, dev only).
  emulators,

  /// The flavour's own project, from `android/app/src/<flavour>/google-services.json`.
  project,
}

/// The Firebase services the data layer uses, all on one app (the default app, or the
/// emulators' demo app). The repositories switch from their fakes to these once a mechanic is
/// signed in (#123).
@immutable
class FirebaseServices {
  const FirebaseServices({
    required this.mode,
    required this.firestore,
    required this.functions,
    required this.storage,
  });

  final FirebaseMode mode;
  final FirebaseFirestore firestore;

  /// Callables in `asia-south1` (PLAN §3).
  final FirebaseFunctions functions;
  final FirebaseStorage storage;
}

/// Null when the app runs without Firebase. Overridden in `bootstrap`.
final firebaseServicesProvider = Provider<FirebaseServices?>((ref) => null);

/// Region of every callable and bucket (PLAN §3).
const kFirebaseRegion = 'asia-south1';

/// Project the emulators run as (`firebase/README.md`).
const kEmulatorProjectId = 'demo-roadside';

/// Connects to the flavour's project, or to the emulators. Returns null when this build has no
/// Firebase config, so the app still starts (on the fakes) instead of crashing.
Future<FirebaseServices?> connectFirebase(AppFlavor flavor) async {
  if (AppEnv.useEmulators) {
    assert(flavor == AppFlavor.dev, 'Emulators are for the dev flavour only');
    // A named app, so the demo project never mixes with a default app that
    // google-services.json may have started natively.
    final app = await Firebase.initializeApp(
      name: 'emulators',
      options: const FirebaseOptions(
        apiKey: 'demo-key',
        appId: '1:0:android:0',
        messagingSenderId: '0',
        projectId: kEmulatorProjectId,
        storageBucket: '$kEmulatorProjectId.appspot.com',
      ),
    );
    const host = AppEnv.emulatorHost;
    final firestore = FirebaseFirestore.instanceFor(app: app)..useFirestoreEmulator(host, 8080);
    final functions = FirebaseFunctions.instanceFor(app: app, region: kFirebaseRegion)
      ..useFunctionsEmulator(host, 5001);
    final storage = FirebaseStorage.instanceFor(app: app);
    await storage.useStorageEmulator(host, 9199);
    return FirebaseServices(
      mode: FirebaseMode.emulators,
      firestore: firestore,
      functions: functions,
      storage: storage,
    );
  }

  final FirebaseApp app;
  try {
    // Options come from the flavour's google-services.json (git-ignored, PLAN §12.8).
    app = await Firebase.initializeApp();
  } on Object {
    return null;
  }
  return FirebaseServices(
    mode: FirebaseMode.project,
    firestore: FirebaseFirestore.instanceFor(app: app),
    functions: FirebaseFunctions.instanceFor(app: app, region: kFirebaseRegion),
    storage: FirebaseStorage.instanceFor(app: app),
  );
}

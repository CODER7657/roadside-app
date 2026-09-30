import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firestore for the console. Overridden in `bootstrap` (real or emulator) and in tests (fake).
final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => throw UnimplementedError('Overridden in bootstrap()'),
);

/// Callables in `asia-south1` (PLAN §3). Overridden in `bootstrap`.
final functionsProvider = Provider<FirebaseFunctions>(
  (ref) => throw UnimplementedError('Overridden in bootstrap()'),
);

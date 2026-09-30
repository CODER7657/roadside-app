import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firestore for the console. Overridden in `bootstrap` (real or emulator) and in tests (fake).
final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => throw UnimplementedError('Overridden in bootstrap()'),
);

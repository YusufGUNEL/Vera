import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/fcm_service.dart';
import '../../../core/firebase/firebase_bootstrap.dart';
import '../../home/data/firebase_import_artifacts_service.dart';

class AccountDeletionService {
  AccountDeletionService(
    this._bootstrapState,
    this._fcmService,
    this._artifactsService,
  );

  final FirebaseBootstrapState _bootstrapState;
  final FcmService _fcmService;
  final FirebaseImportArtifactsService _artifactsService;

  bool get isEnabled =>
      _bootstrapState.ready && FirebaseAuth.instance.currentUser != null;

  Future<void> deleteCurrentAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (!_bootstrapState.ready || user == null) return;

    await _fcmService.deleteToken();
    await _deleteUserData(user.uid);
    await user.delete();
  }

  Future<void> _deleteUserData(String uid) async {
    final db = FirebaseFirestore.instance;
    final userDoc = db.collection('users').doc(uid);

    await _artifactsService.clearAll();
    await _deleteStorageFolder(uid);

    for (final path in const [
      ['banks'],
      ['importedTransactions'],
      ['importArtifacts'],
      ['upcomingBills'],
      ['subscriptions'],
      ['wealthActions'],
      ['umaAudit'],
      ['umaFeedback'],
      ['fcmTokens'],
      ['wealthData'],
      ['private'],
    ]) {
      await _deleteCollection(userDoc.collection(path.first));
    }

    await userDoc.delete();
  }

  Future<void> _deleteCollection(
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    while (true) {
      final snap = await collection.limit(200).get();
      if (snap.docs.isEmpty) return;

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  Future<void> _deleteStorageFolder(String uid) async {
    try {
      final root = FirebaseStorage.instance.ref().child('users').child(uid);
      await _deleteStorageRef(root);
    } catch (_) {
      // Storage can be unavailable until the bucket is provisioned.
    }
  }

  Future<void> _deleteStorageRef(Reference ref) async {
    final listing = await ref.listAll();
    for (final prefix in listing.prefixes) {
      await _deleteStorageRef(prefix);
    }
    for (final item in listing.items) {
      await item.delete();
    }
  }
}

final accountDeletionServiceProvider = Provider<AccountDeletionService>((ref) {
  return AccountDeletionService(
    ref.watch(firebaseBootstrapProvider),
    ref.watch(fcmServiceProvider),
    ref.watch(firebaseImportArtifactsServiceProvider),
  );
});

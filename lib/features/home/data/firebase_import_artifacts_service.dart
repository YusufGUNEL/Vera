import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_bootstrap.dart';
import '../../auth/data/firebase_auth_service.dart';
import '../../receipt_scan/domain/parsed_receipt.dart';
import '../../statement_import/domain/parsed_statement.dart';
import 'transaction.dart';

class FirebaseImportArtifactsService {
  FirebaseImportArtifactsService(this._bootstrapState, this._authService);

  final FirebaseBootstrapState _bootstrapState;
  final FirebaseAuthService _authService;

  bool get isEnabled => _bootstrapState.ready && _authService.currentUser != null;

  CollectionReference<Map<String, dynamic>>? get _collection {
    final user = _authService.currentUser;
    if (user == null || !_bootstrapState.ready) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('importArtifacts');
  }

  Reference? get _storageRoot {
    final user = _authService.currentUser;
    if (user == null || !_bootstrapState.ready) return null;
    return FirebaseStorage.instance.ref().child('users').child(user.uid).child(
          'imports',
        );
  }

  Future<void> uploadReceipt({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    required ParsedReceipt receipt,
    required List<Txn> transactions,
  }) async {
    await _uploadArtifact(
      type: 'receipt',
      fileName: fileName,
      bytes: bytes,
      mimeType: mimeType,
      metadata: {
        'merchant': receipt.merchant,
        'total': receipt.total,
        'currency': receipt.currency,
        'category': receipt.category,
        'date': receipt.date,
        'source': receipt.source.name,
      },
      transactions: transactions,
    );
  }

  Future<void> uploadStatement({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    required ParsedStatement statement,
    required List<Txn> transactions,
  }) async {
    await _uploadArtifact(
      type: 'statement',
      fileName: fileName,
      bytes: bytes,
      mimeType: mimeType,
      metadata: {
        'bank': statement.bank,
        'period': statement.period,
        'accountLast4': statement.accountLast4,
        'openingBalance': statement.openingBalance,
        'closingBalance': statement.closingBalance,
        'source': statement.source.name,
      },
      transactions: transactions,
    );
  }

  Future<void> clearAll() async {
    final collection = _collection;
    if (collection == null) return;
    final snap = await collection.get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snap.docs) {
      final storagePath = doc.data()['storagePath'] as String?;
      if (storagePath != null && storagePath.isNotEmpty) {
        try {
          await FirebaseStorage.instance.ref(storagePath).delete();
        } catch (_) {
          // Keep cleanup best-effort so reset does not fail on already-removed files.
        }
      }
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> _uploadArtifact({
    required String type,
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    required Map<String, dynamic> metadata,
    required List<Txn> transactions,
  }) async {
    final collection = _collection;
    final storageRoot = _storageRoot;
    if (collection == null || storageRoot == null) return;

    final now = DateTime.now();
    final safeName = _safeFileName(fileName);
    final docId = '${type}_${now.millisecondsSinceEpoch}';
    final storagePath = '${storageRoot.fullPath}/$type/$docId-$safeName';
    final ref = FirebaseStorage.instance.ref(storagePath);

    await ref.putData(
      bytes,
      SettableMetadata(
        contentType: mimeType,
        customMetadata: {
          'type': type,
          'fileName': fileName,
          'transactionCount': transactions.length.toString(),
        },
      ),
    );
    final downloadUrl = await ref.getDownloadURL();

    await collection.doc(docId).set({
      'id': docId,
      'type': type,
      'fileName': fileName,
      'mimeType': mimeType,
      'storagePath': storagePath,
      'downloadUrl': downloadUrl,
      'transactionCount': transactions.length,
      'transactionIds': [for (final txn in transactions) txn.id],
      'transactionPreview': [
        for (final txn in transactions.take(5))
          {
            'id': txn.id,
            'name': txn.name,
            'amount': txn.amount,
            'when': txn.when,
          },
      ],
      'metadata': metadata,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  String _safeFileName(String name) {
    return name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
  }
}

final firebaseImportArtifactsServiceProvider =
    Provider<FirebaseImportArtifactsService>((ref) {
  return FirebaseImportArtifactsService(
    ref.watch(firebaseBootstrapProvider),
    ref.watch(firebaseAuthServiceProvider),
  );
});

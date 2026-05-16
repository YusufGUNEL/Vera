import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/receipt_repository.dart';
import '../domain/parsed_receipt.dart';

enum ReceiptScanStatus { idle, scanning, ready, error }

class ReceiptState {
  const ReceiptState({
    this.status = ReceiptScanStatus.idle,
    this.receipt,
    this.error,
    this.sourceBytes,
    this.fileName,
    this.mimeType,
  });

  final ReceiptScanStatus status;
  final ParsedReceipt? receipt;
  final String? error;
  final Uint8List? sourceBytes;
  final String? fileName;
  final String? mimeType;

  ReceiptState copyWith({
    ReceiptScanStatus? status,
    ParsedReceipt? receipt,
    String? error,
    Uint8List? sourceBytes,
    String? fileName,
    String? mimeType,
    bool clearReceipt = false,
    bool clearError = false,
    bool clearSource = false,
  }) {
    return ReceiptState(
      status: status ?? this.status,
      receipt: clearReceipt ? null : (receipt ?? this.receipt),
      error: clearError ? null : (error ?? this.error),
      sourceBytes: clearSource ? null : (sourceBytes ?? this.sourceBytes),
      fileName: clearSource ? null : (fileName ?? this.fileName),
      mimeType: clearSource ? null : (mimeType ?? this.mimeType),
    );
  }
}

class ReceiptController extends StateNotifier<ReceiptState> {
  ReceiptController(this._repository) : super(const ReceiptState());

  final ReceiptRepository _repository;

  Future<void> scan({
    required Uint8List bytes,
    required String mimeType,
    required String fileName,
  }) async {
    state = state.copyWith(
      status: ReceiptScanStatus.scanning,
      clearReceipt: true,
      clearError: true,
      clearSource: true,
    );
    try {
      final receipt = await _repository.parse(
        imageBytes: bytes,
        mimeType: mimeType,
      );
      state = state.copyWith(
        status: ReceiptScanStatus.ready,
        receipt: receipt,
        sourceBytes: bytes,
        fileName: fileName,
        mimeType: mimeType,
      );
    } catch (e) {
      state = state.copyWith(
        status: ReceiptScanStatus.error,
        error: e.toString(),
      );
    }
  }

  void reset() {
    state = const ReceiptState();
  }
}

final receiptControllerProvider =
    StateNotifierProvider<ReceiptController, ReceiptState>((ref) {
  return ReceiptController(ref.watch(receiptRepositoryProvider));
});

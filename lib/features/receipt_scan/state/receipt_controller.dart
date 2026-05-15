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
  });

  final ReceiptScanStatus status;
  final ParsedReceipt? receipt;
  final String? error;

  ReceiptState copyWith({
    ReceiptScanStatus? status,
    ParsedReceipt? receipt,
    String? error,
    bool clearReceipt = false,
    bool clearError = false,
  }) {
    return ReceiptState(
      status: status ?? this.status,
      receipt: clearReceipt ? null : (receipt ?? this.receipt),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ReceiptController extends StateNotifier<ReceiptState> {
  ReceiptController(this._repository) : super(const ReceiptState());

  final ReceiptRepository _repository;

  Future<void> scan({
    required Uint8List bytes,
    required String mimeType,
  }) async {
    state = state.copyWith(
      status: ReceiptScanStatus.scanning,
      clearReceipt: true,
      clearError: true,
    );
    try {
      final receipt = await _repository.parse(
        imageBytes: bytes,
        mimeType: mimeType,
      );
      state = state.copyWith(
        status: ReceiptScanStatus.ready,
        receipt: receipt,
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

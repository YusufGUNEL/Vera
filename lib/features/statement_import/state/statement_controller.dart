import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/statement_repository.dart';
import '../domain/parsed_statement.dart';

enum StatementStatus { idle, parsing, ready, error }

class StatementState {
  const StatementState({
    this.status = StatementStatus.idle,
    this.statement,
    this.error,
    this.sourceBytes,
    this.fileName,
    this.mimeType,
  });

  final StatementStatus status;
  final ParsedStatement? statement;
  final String? error;
  final Uint8List? sourceBytes;
  final String? fileName;
  final String? mimeType;

  StatementState copyWith({
    StatementStatus? status,
    ParsedStatement? statement,
    String? error,
    Uint8List? sourceBytes,
    String? fileName,
    String? mimeType,
    bool clearStatement = false,
    bool clearError = false,
    bool clearSource = false,
  }) {
    return StatementState(
      status: status ?? this.status,
      statement: clearStatement ? null : (statement ?? this.statement),
      error: clearError ? null : (error ?? this.error),
      sourceBytes: clearSource ? null : (sourceBytes ?? this.sourceBytes),
      fileName: clearSource ? null : (fileName ?? this.fileName),
      mimeType: clearSource ? null : (mimeType ?? this.mimeType),
    );
  }
}

class StatementController extends StateNotifier<StatementState> {
  StatementController(this._repository) : super(const StatementState());

  final StatementRepository _repository;

  Future<void> parse({
    required Uint8List bytes,
    required String mimeType,
    required String fileName,
  }) async {
    state = state.copyWith(
      status: StatementStatus.parsing,
      clearStatement: true,
      clearError: true,
      clearSource: true,
    );
    try {
      final statement = await _repository.parse(
        bytes: bytes,
        mimeType: mimeType,
      );
      state = state.copyWith(
        status: StatementStatus.ready,
        statement: statement,
        sourceBytes: bytes,
        fileName: fileName,
        mimeType: mimeType,
      );
    } catch (_) {
      state = state.copyWith(
        status: StatementStatus.ready,
        statement: const ParsedStatement(source: StatementSource.fallback),
        sourceBytes: bytes,
        fileName: fileName,
        mimeType: mimeType,
      );
    }
  }

  void reset() {
    state = const StatementState();
  }
}

final statementControllerProvider =
    StateNotifierProvider<StatementController, StatementState>((ref) {
  return StatementController(ref.watch(statementRepositoryProvider));
});

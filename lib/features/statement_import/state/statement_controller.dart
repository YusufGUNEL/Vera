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
  });

  final StatementStatus status;
  final ParsedStatement? statement;
  final String? error;

  StatementState copyWith({
    StatementStatus? status,
    ParsedStatement? statement,
    String? error,
    bool clearStatement = false,
    bool clearError = false,
  }) {
    return StatementState(
      status: status ?? this.status,
      statement: clearStatement ? null : (statement ?? this.statement),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class StatementController extends StateNotifier<StatementState> {
  StatementController(this._repository) : super(const StatementState());

  final StatementRepository _repository;

  Future<void> parse({
    required Uint8List bytes,
    required String mimeType,
  }) async {
    state = state.copyWith(
      status: StatementStatus.parsing,
      clearStatement: true,
      clearError: true,
    );
    try {
      final statement = await _repository.parse(
        bytes: bytes,
        mimeType: mimeType,
      );
      state = state.copyWith(
        status: StatementStatus.ready,
        statement: statement,
      );
    } catch (e) {
      state = state.copyWith(
        status: StatementStatus.error,
        error: e.toString(),
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

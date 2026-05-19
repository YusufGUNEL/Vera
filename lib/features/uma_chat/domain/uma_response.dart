enum UmaResponseKind {
  answer,
  proposal,
  toolSuccess,
  toolFailure,
  fallback,
}

enum UmaSourceType {
  transaction,
  subscriptions,
  goal,
  security,
  wealth,
  readiness,
  memory,
}

enum UmaNextStepType {
  askUma,
  importStatement,
  scanReceipt,
  addManualTransaction,
  openSubscriptions,
  openSecurity,
  reviewGoal,
  confirmTool,
}

enum UmaToolPolicyStatus {
  allowed,
  needsConfirmation,
  blocked,
  missingContext,
}

class UmaSourceRef {
  const UmaSourceRef({
    required this.label,
    required this.detail,
    required this.type,
  });

  final String label;
  final String detail;
  final UmaSourceType type;
}

class UmaNextStep {
  const UmaNextStep({
    required this.label,
    required this.type,
    this.prompt,
  });

  final String label;
  final UmaNextStepType type;
  final String? prompt;
}

class UmaToolPolicyResult {
  const UmaToolPolicyResult({
    required this.status,
    required this.reason,
  });

  final UmaToolPolicyStatus status;
  final String reason;
}

class UmaPendingToolCall {
  const UmaPendingToolCall({
    required this.name,
    required this.args,
    required this.summary,
  });

  final String name;
  final Map<String, Object?> args;
  final String summary;
}

class UmaResponseEnvelope {
  const UmaResponseEnvelope({
    required this.kind,
    required this.text,
    required this.confidence,
    this.why,
    this.nextStep,
    this.toolPolicy,
    this.pendingToolCall,
    this.toolOutcome,
    this.sources = const [],
  });

  final UmaResponseKind kind;
  final String text;
  final double confidence;
  final String? why;
  final UmaNextStep? nextStep;
  final UmaToolPolicyResult? toolPolicy;
  final UmaPendingToolCall? pendingToolCall;
  final String? toolOutcome;
  final List<UmaSourceRef> sources;
}

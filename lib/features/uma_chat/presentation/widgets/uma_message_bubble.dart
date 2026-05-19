import 'package:flutter/material.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/uma_message.dart';
import '../../domain/uma_response.dart';

class UmaMessageBubble extends StatelessWidget {
  const UmaMessageBubble({
    required this.message,
    this.onConfirmTool,
    super.key,
  });

  final UmaMessage message;
  final VoidCallback? onConfirmTool;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final isMe = message.role == UmaRole.user;
    final kind = message.kind ??
        (isMe ? UmaMessageKind.user : UmaMessageKind.assistant);
    final spec = _bubbleSpec(kind, t, context.l10n);
    final envelope = message.envelope;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: spec.background,
            border: Border.all(color: spec.border),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMe ? 18 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (spec.badge != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: spec.badgeSoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    spec.badge!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: spec.badgeColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              SelectableText(
                message.text,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  letterSpacing: -0.1,
                  color: spec.text,
                ),
              ),
              if (envelope != null) ...[
                const SizedBox(height: 10),
                _MetaRow(confidence: envelope.confidence),
                if (envelope.why != null && envelope.why!.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    envelope.why!,
                    style: TextStyle(
                      fontSize: 12,
                      color: t.ink2,
                      height: 1.35,
                    ),
                  ),
                ],
                if (envelope.sources.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final source in envelope.sources)
                        _SourceChip(source: source),
                    ],
                  ),
                ],
                if (envelope.pendingToolCall != null && onConfirmTool != null) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onConfirmTool,
                      style: FilledButton.styleFrom(
                        backgroundColor: t.uma,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: Text(
                        context.l10n.umaConfirmAction,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ] else if (envelope.nextStep != null) ...[
                  const SizedBox(height: 10),
                  _NextStepChip(step: envelope.nextStep!),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.confidence});

  final double confidence;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    final pct = (confidence * 100).round().clamp(0, 100);
    final color = confidence >= 0.75
        ? t.green
        : confidence >= 0.5
            ? t.gold
            : t.red;
    return Row(
      children: [
        Icon(Icons.radar_outlined, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          l10n.umaConfidenceLabel('$pct'),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _SourceChip extends StatelessWidget {
  const _SourceChip({required this.source});

  final UmaSourceRef source;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: t.bgSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: t.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            source.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: t.muted,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            source.detail,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: t.ink2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _NextStepChip extends StatelessWidget {
  const _NextStepChip({required this.step});

  final UmaNextStep step;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: t.umaSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_forward, size: 14, color: t.uma),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              step.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: t.uma,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BubbleSpec {
  const _BubbleSpec({
    required this.background,
    required this.border,
    required this.text,
    required this.badgeColor,
    required this.badgeSoft,
    this.badge,
  });

  final Color background;
  final Color border;
  final Color text;
  final Color badgeColor;
  final Color badgeSoft;
  final String? badge;
}

_BubbleSpec _bubbleSpec(UmaMessageKind kind, AppTokens t, AppStrings l10n) {
  return switch (kind) {
    UmaMessageKind.user => _BubbleSpec(
        background: t.brand,
        border: t.brand,
        text: t.brandFG,
        badgeColor: t.brandFG,
        badgeSoft: t.brand.withValues(alpha: 0.15),
      ),
    UmaMessageKind.toolSuccess => _BubbleSpec(
        background: t.green.withValues(alpha: 0.1),
        border: t.green.withValues(alpha: 0.26),
        text: t.ink,
        badgeColor: t.green,
        badgeSoft: t.green.withValues(alpha: 0.14),
        badge: l10n.umaToolBadge,
      ),
    UmaMessageKind.toolFailure => _BubbleSpec(
        background: t.gold.withValues(alpha: 0.12),
        border: t.gold.withValues(alpha: 0.26),
        text: t.ink,
        badgeColor: t.gold,
        badgeSoft: t.gold.withValues(alpha: 0.14),
        badge: l10n.umaFallbackBadge,
      ),
    UmaMessageKind.fallback => _BubbleSpec(
        background: t.gold.withValues(alpha: 0.12),
        border: t.gold.withValues(alpha: 0.26),
        text: t.ink,
        badgeColor: t.gold,
        badgeSoft: t.gold.withValues(alpha: 0.14),
        badge: l10n.umaFallbackBadge,
      ),
    UmaMessageKind.system => _BubbleSpec(
        background: t.bgSoft,
        border: t.line,
        text: t.ink2,
        badgeColor: t.muted,
        badgeSoft: t.card,
        badge: l10n.umaSystemBadge,
      ),
    UmaMessageKind.assistant => _BubbleSpec(
        background: t.card,
        border: t.line,
        text: t.ink,
        badgeColor: t.uma,
        badgeSoft: t.umaSoft,
        badge: l10n.umaAssistantBadge,
      ),
  };
}

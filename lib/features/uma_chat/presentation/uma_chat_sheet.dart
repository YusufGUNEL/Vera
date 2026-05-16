import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_tokens.dart';
import '../data/uma_repository.dart';
import '../domain/uma_audit_event.dart';
import '../domain/uma_feedback.dart';
import '../domain/uma_message.dart';
import '../state/uma_controller.dart';
import 'widgets/uma_message_bubble.dart';
import 'widgets/uma_order_card.dart';

class UmaChatSheet extends ConsumerStatefulWidget {
  const UmaChatSheet({super.key});

  @override
  ConsumerState<UmaChatSheet> createState() => _UmaChatSheetState();
}

class _UmaChatSheetState extends ConsumerState<UmaChatSheet> {
  final _scrollController = ScrollController();
  final _inputController = TextEditingController();
  bool _showSettings = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    ref.read(umaControllerProvider.notifier).send(text);
    _inputController.clear();
  }

  Future<void> _openFeedbackSheet(
    BuildContext context,
    int messageIndex,
    UmaMessage message,
    UmaFeedbackVote vote,
  ) async {
    final controller =
        TextEditingController(text: message.feedback?.note ?? '');
    final note = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FeedbackNoteSheet(
        controller: controller,
        vote: vote,
      ),
    );
    controller.dispose();
    if (!mounted || note == null) return;
    await ref.read(umaControllerProvider.notifier).setFeedback(
          messageIndex,
          vote,
          note: note,
        );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final state = ref.watch(umaControllerProvider);
    ref.listen(umaControllerProvider, (_, __) => _scrollToBottom());

    final mq = MediaQuery.of(context);
    final sheetHeight = mq.size.height * 0.88;

    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Container(
        height: sheetHeight,
        decoration: BoxDecoration(
          color: t.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            _DragHandle(),
            _Header(
              showSettings: _showSettings,
              onToggleSettings: () =>
                  setState(() => _showSettings = !_showSettings),
              onClose: () => Navigator.of(context).pop(),
            ),
            if (_showSettings) _SettingsDrawer(state: state),
            Expanded(
              child: Stack(
                children: [
                  ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    itemCount: state.messages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final message = state.messages[i];
                      return Column(
                        crossAxisAlignment: message.role == UmaRole.user
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          UmaMessageBubble(message: message),
                          if (message.card != null)
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.78,
                              ),
                              child: UmaOrderCard(
                                card: message.card!,
                                onForward: () => ref
                                    .read(umaControllerProvider.notifier)
                                    .forwardOrder(i),
                                onDismiss: () => ref
                                    .read(umaControllerProvider.notifier)
                                    .dismissOrder(i),
                              ),
                            ),
                          if (message.role == UmaRole.uma)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.78,
                                ),
                                child: _FeedbackBar(
                                  message: message,
                                  onVote: (vote) => ref
                                      .read(umaControllerProvider.notifier)
                                      .setFeedback(i, vote),
                                  onAddNote: (vote) =>
                                      _openFeedbackSheet(context, i, message, vote),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  if (state.toast != null)
                    Positioned(
                      top: 8,
                      left: 12,
                      right: 12,
                      child: _Toast(text: state.toast!),
                    ),
                ],
              ),
            ),
            _SuggestionStrip(onTap: _send, disabled: state.thinking),
            _Input(
              controller: _inputController,
              onSubmit: _send,
              busy: state.thinking,
            ),
          ],
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: t.isDark ? t.line : const Color(0xFFD9D4C8),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.showSettings,
    required this.onToggleSettings,
    required this.onClose,
  });

  final bool showSettings;
  final VoidCallback onToggleSettings;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 12, 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.line)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.4, -0.4),
                colors: [t.umaLight, t.uma],
              ),
            ),
            alignment: Alignment.center,
            child:
                const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Uma',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: t.ink,
                    letterSpacing: -0.3,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: t.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      context.l10n.umaStatusOnline,
                      style: TextStyle(fontSize: 11, color: t.green),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onToggleSettings,
            icon: Icon(Icons.settings_outlined, color: t.ink2, size: 19),
            style: IconButton.styleFrom(
              backgroundColor: showSettings ? t.bgSoft : Colors.transparent,
              shape: const CircleBorder(),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close, color: t.ink2, size: 20),
          ),
        ],
      ),
    );
  }
}

class _SettingsDrawer extends ConsumerWidget {
  const _SettingsDrawer({required this.state});
  final UmaState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        color: t.bgSoft,
        border: Border(bottom: BorderSide(color: t.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.umaActionPolicy,
            style: TextStyle(
              fontSize: 11,
              color: t.muted,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.umaActionPolicyDesc,
            style: TextStyle(
              fontSize: 12,
              color: t.ink2,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          for (final option in [
            (
              AutoExecMode.confirm,
              l10n.requireConfirmation,
              l10n.requireConfirmationDesc,
            ),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => ref
                    .read(umaControllerProvider.notifier)
                    .setAutoExec(option.$1),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: t.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: state.autoExec == option.$1
                          ? t.uma
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: state.autoExec == option.$1
                                ? t.uma
                                : const Color(0xFFC8C3B8),
                            width: 2,
                          ),
                          color: state.autoExec == option.$1
                              ? t.uma
                              : Colors.transparent,
                        ),
                        alignment: Alignment.center,
                        child: state.autoExec == option.$1
                            ? const Icon(Icons.circle,
                                color: Colors.white, size: 7)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.$2,
                              style: TextStyle(
                                fontSize: 14,
                                color: t.ink,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              option.$3,
                              style: TextStyle(color: t.muted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          FutureBuilder(
            future: ref.read(umaRepositoryProvider).loadAuditEvents(),
            builder: (context, snapshot) {
              final items = snapshot.data ?? const <UmaAuditEvent>[];
              return GestureDetector(
                onTap: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const _AuditLogSheet(),
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: t.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: t.line),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: t.umaSoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.verified_outlined,
                            size: 17, color: t.uma),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Audit trail',
                              style: TextStyle(
                                fontSize: 14,
                                color: t.ink,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              items.isEmpty
                                  ? 'No signed Uma actions yet.'
                                  : '${items.length} signed actions recorded on this device.',
                              style: TextStyle(
                                color: t.muted,
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: t.muted, size: 18),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SuggestionStrip extends StatelessWidget {
  const _SuggestionStrip({required this.onTap, required this.disabled});
  final ValueChanged<String> onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    final suggestions = [
      l10n.umaSuggestionBuyGold,
      l10n.umaSuggestionPay,
      l10n.umaSuggestionSubs,
      l10n.umaSuggestionMoveSavings,
      l10n.umaSuggestionAnalyze,
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: suggestions.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final suggestion = suggestions[i];
            return Material(
              color: t.card,
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                onTap: disabled ? null : () => onTap(suggestion),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: t.line),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 12, color: t.uma),
                      const SizedBox(width: 5),
                      Text(
                        suggestion,
                        style: TextStyle(
                          fontSize: 13,
                          color: t.ink2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Input extends StatelessWidget {
  const _Input({
    required this.controller,
    required this.onSubmit,
    required this.busy,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmit;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
        decoration: BoxDecoration(
          color: t.card,
          border: Border(top: BorderSide(color: t.line)),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 4, 6, 4),
          decoration: BoxDecoration(
            color: t.bgSoft,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: !busy,
                  textInputAction: TextInputAction.send,
                  onSubmitted: onSubmit,
                  style: TextStyle(fontSize: 15, color: t.ink),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText: busy
                        ? context.l10n.umaThinking
                        : context.l10n.umaAskHint,
                    hintStyle: TextStyle(color: t.muted, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: busy ? null : () => onSubmit(controller.text),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: busy ? t.brand.withValues(alpha: 0.4) : t.brand,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: busy
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: t.brandFG,
                          ),
                        )
                      : Icon(Icons.arrow_upward, color: t.brandFG, size: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Toast extends StatelessWidget {
  const _Toast({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: t.brand,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: t.brand.withValues(alpha: 0.35),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, color: t.accentPop, size: 16),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: t.brandFG,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackBar extends StatelessWidget {
  const _FeedbackBar({
    required this.message,
    required this.onVote,
    required this.onAddNote,
  });

  final UmaMessage message;
  final ValueChanged<UmaFeedbackVote> onVote;
  final ValueChanged<UmaFeedbackVote> onAddNote;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    final selectedVote = message.feedback?.vote;
    final note = message.feedback?.note?.trim();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: t.bgSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.umaFeedbackLabel,
                style: TextStyle(
                  color: t.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              const Spacer(),
              _FeedbackChip(
                icon: Icons.thumb_up_alt_outlined,
                label: l10n.umaFeedbackHelpful,
                selected: selectedVote == UmaFeedbackVote.helpful,
                onTap: () => onVote(UmaFeedbackVote.helpful),
              ),
              const SizedBox(width: 6),
              _FeedbackChip(
                icon: Icons.thumb_down_alt_outlined,
                label: l10n.umaFeedbackNotHelpful,
                selected: selectedVote == UmaFeedbackVote.notHelpful,
                onTap: () => onVote(UmaFeedbackVote.notHelpful),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => onAddNote(
                  selectedVote ?? UmaFeedbackVote.notHelpful,
                ),
                style: TextButton.styleFrom(
                  foregroundColor: t.uma,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minimumSize: const Size(0, 0),
                ),
                icon: const Icon(Icons.edit_note, size: 16),
                label: Text(
                  note == null || note.isEmpty
                      ? l10n.umaFeedbackAddNote
                      : l10n.umaFeedbackEditNote,
                ),
              ),
              if (note != null && note.isNotEmpty) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    note,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: t.ink2,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _FeedbackChip extends StatelessWidget {
  const _FeedbackChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? t.card : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? t.uma : t.line),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: selected ? t.uma : t.muted),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? t.uma : t.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackNoteSheet extends StatelessWidget {
  const _FeedbackNoteSheet({
    required this.controller,
    required this.vote,
  });

  final TextEditingController controller;
  final UmaFeedbackVote vote;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: t.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: t.line,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  vote == UmaFeedbackVote.helpful
                      ? l10n.umaFeedbackHelpfulTitle
                      : l10n.umaFeedbackNotHelpfulTitle,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: t.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.umaFeedbackNoteHint,
                  style: TextStyle(
                    fontSize: 12,
                    color: t.muted,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: controller,
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: l10n.umaFeedbackPlaceholder,
                    filled: true,
                    fillColor: t.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: t.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: t.line),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: t.uma, width: 1.4),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.of(context).pop(controller.text.trim()),
                        child: Text(l10n.umaFeedbackSave),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(''),
                        style: FilledButton.styleFrom(
                          backgroundColor: t.brand,
                          foregroundColor: t.brandFG,
                        ),
                        child: Text(l10n.umaFeedbackSkipNote),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuditLogSheet extends ConsumerWidget {
  const _AuditLogSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    return Container(
      decoration: BoxDecoration(
        color: t.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 6),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: t.line,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Uma audit trail',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: t.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Signed local log of Uma replies, forwarded bank actions, and your feedback decisions.',
                          style: TextStyle(
                            fontSize: 12,
                            color: t.muted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: t.ink2),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: ref.read(umaRepositoryProvider).loadAuditEvents(),
                builder: (context, snapshot) {
                  final items = snapshot.data ?? const <UmaAuditEvent>[];
                  if (items.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No signed actions yet. Ask Uma to do something and the trust trail will appear here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: t.muted,
                            height: 1.45,
                          ),
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, index) {
                      final item = items[index];
                      return _AuditTile(item: item);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuditTile extends StatelessWidget {
  const _AuditTile({required this.item});

  final UmaAuditEvent item;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final spec = _auditSpec(item.action, t);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: spec.soft,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(spec.icon, size: 16, color: spec.color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  spec.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: t.ink,
                  ),
                ),
              ),
              Text(
                _fmtAuditTime(item.timestamp),
                style: TextStyle(fontSize: 11, color: t.muted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.summary,
            style: TextStyle(
              fontSize: 13,
              color: t.ink2,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _AuditPill(label: item.signature),
              if (item.intent != null && item.intent!.isNotEmpty)
                _AuditPill(label: item.intent!),
              if (item.note != null && item.note!.trim().isNotEmpty)
                const _AuditPill(label: 'Note attached'),
            ],
          ),
        ],
      ),
    );
  }
}

class _AuditPill extends StatelessWidget {
  const _AuditPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: t.bgSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: t.muted,
        ),
      ),
    );
  }
}

class _AuditSpec {
  const _AuditSpec({
    required this.label,
    required this.icon,
    required this.color,
    required this.soft,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color soft;
}

_AuditSpec _auditSpec(UmaAuditAction action, AppTokens t) {
  return switch (action) {
    UmaAuditAction.replyGenerated => _AuditSpec(
        label: 'Reply generated',
        icon: Icons.auto_awesome,
        color: t.uma,
        soft: t.umaSoft,
      ),
    UmaAuditAction.orderForwarded => _AuditSpec(
        label: 'Forwarded to bank',
        icon: Icons.open_in_new,
        color: t.green,
        soft: t.green.withValues(alpha: 0.12),
      ),
    UmaAuditAction.orderDismissed => _AuditSpec(
        label: 'Kept for review',
        icon: Icons.pause_circle_outline,
        color: t.gold,
        soft: t.gold.withValues(alpha: 0.14),
      ),
    UmaAuditAction.feedbackHelpful => _AuditSpec(
        label: 'Helpful feedback',
        icon: Icons.thumb_up_alt_outlined,
        color: t.brand,
        soft: t.brand.withValues(alpha: 0.12),
      ),
    UmaAuditAction.feedbackNotHelpful => _AuditSpec(
        label: 'Correction feedback',
        icon: Icons.thumb_down_alt_outlined,
        color: t.red,
        soft: t.red.withValues(alpha: 0.1),
      ),
  };
}

String _fmtAuditTime(DateTime time) {
  final hh = time.hour.toString().padLeft(2, '0');
  final mm = time.minute.toString().padLeft(2, '0');
  return '${time.day}.${time.month} $hh:$mm';
}

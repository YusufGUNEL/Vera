import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_tokens.dart';
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
              onUseMicHint: () {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Voice command UI is next on the roadmap. For now, try one of the quick actions.',
                      ),
                    ),
                  );
              },
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
    required this.onUseMicHint,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmit;
  final bool busy;
  final VoidCallback onUseMicHint;

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
              IconButton(
                onPressed: busy ? null : onUseMicHint,
                icon: Icon(Icons.mic_none_rounded, color: t.ink2, size: 18),
                tooltip: context.l10n.voiceCommandTooltip,
              ),
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

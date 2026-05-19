import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/responsive.dart';
import '../../state/notification_center_controller.dart';

class NotificationCenterSheet extends ConsumerWidget {
  const NotificationCenterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l10n = context.l10n;
    final responsive = context.responsive;
    final state = ref.watch(notificationCenterControllerProvider);
    final notices = state.visibleNotices;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollCtrl) => Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: responsive.sheetMaxWidth),
          child: Container(
            decoration: BoxDecoration(
              color: t.bg,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
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
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final stackActions = constraints.maxWidth < 360;
                      final titleRow = Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: t.uma.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.notifications_outlined,
                              color: t.uma,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.notifTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: t.ink,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.notifSubtitle(notices.length),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      TextStyle(fontSize: 12, color: t.muted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                      if (!stackActions || notices.isEmpty) {
                        return Row(
                          children: [
                            Expanded(child: titleRow),
                            if (notices.isNotEmpty)
                              Flexible(
                                child: Wrap(
                                  alignment: WrapAlignment.end,
                                  spacing: 4,
                                  runSpacing: 0,
                                  children: [
                                    TextButton(
                                      onPressed: () => ref
                                          .read(
                                            notificationCenterControllerProvider
                                                .notifier,
                                          )
                                          .markAllRead(),
                                      child: Text(
                                        l10n.notifMarkAllRead,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => ref
                                          .read(
                                            notificationCenterControllerProvider
                                                .notifier,
                                          )
                                          .dismissAllVisible(),
                                      child: Text(
                                        l10n.notifClear,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          titleRow,
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 4,
                            runSpacing: 0,
                            children: [
                              TextButton(
                                onPressed: () => ref
                                    .read(
                                      notificationCenterControllerProvider
                                          .notifier,
                                    )
                                    .markAllRead(),
                                child: Text(l10n.notifMarkAllRead),
                              ),
                              TextButton(
                                onPressed: () => ref
                                    .read(
                                      notificationCenterControllerProvider
                                          .notifier,
                                    )
                                    .dismissAllVisible(),
                                child: Text(l10n.notifClear),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Expanded(
                  child: notices.isEmpty
                      ? _EmptyState()
                      : ListView.separated(
                          controller: scrollCtrl,
                          padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
                          itemCount: notices.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) =>
                              _NoticeTile(notice: notices[i]),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 40, color: t.green),
            const SizedBox(height: 10),
            Text(
              l10n.notifEmpty,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: t.muted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoticeTile extends ConsumerWidget {
  const _NoticeTile({required this.notice});

  final AppNotice notice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final accent = switch (notice.accent) {
      NoticeAccent.red => t.red,
      NoticeAccent.gold => t.gold,
      NoticeAccent.muted => t.muted,
      NoticeAccent.blue => t.blue,
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(t.vibe.radius - 2),
        border: Border.all(color: t.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(notice.icon, color: accent, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notice.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: t.ink,
                        ),
                      ),
                    ),
                    Text(
                      notice.when,
                      style: TextStyle(fontSize: 11, color: t.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notice.body,
                  style: TextStyle(
                    fontSize: 12,
                    color: t.ink2,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => ref
                          .read(notificationCenterControllerProvider.notifier)
                          .markRead(notice.id),
                      icon: const Icon(Icons.done, size: 16),
                      label: Text(context.l10n.notifRead),
                      style: TextButton.styleFrom(
                        foregroundColor: accent,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minimumSize: const Size(0, 0),
                      ),
                    ),
                    const SizedBox(width: 14),
                    TextButton.icon(
                      onPressed: () => ref
                          .read(notificationCenterControllerProvider.notifier)
                          .dismiss(notice.id),
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: Text(context.l10n.notifDismiss),
                      style: TextButton.styleFrom(
                        foregroundColor: t.muted,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minimumSize: const Size(0, 0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

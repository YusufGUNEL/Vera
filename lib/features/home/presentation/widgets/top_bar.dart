import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../auth/state/auth_controller.dart';
import '../../../profile_settings/presentation/profile_settings_sheet.dart';

class TopBar extends ConsumerWidget {
  const TopBar({this.onScanTap, this.onImportTap, super.key});

  final VoidCallback? onScanTap;
  final VoidCallback? onImportTap;

  void _openProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => const ProfileSettingsSheet(),
    );
  }

  void _showNotifications(BuildContext context) {
    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.comingSoon),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l10n = context.l10n;
    final auth = ref.watch(authControllerProvider);
    final name = auth.displayName ?? l10n.defaultUserName;
    final initials = auth.initials;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _openProfile(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [t.brandSoft, t.brand],
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: TextStyle(
                  color: t.brandFG,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.helloLabel,
                  style: TextStyle(fontSize: 12, color: t.muted, height: 1.2),
                ),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: t.ink,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          if (onImportTap != null) ...[
            Material(
              color: t.card,
              shape: CircleBorder(side: BorderSide(color: t.line)),
              child: InkWell(
                onTap: onImportTap,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.upload_file_outlined,
                    color: t.ink,
                    size: 19,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (onScanTap != null) ...[
            Material(
              color: t.card,
              shape: CircleBorder(side: BorderSide(color: t.line)),
              child: InkWell(
                onTap: onScanTap,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.document_scanner_outlined,
                    color: t.ink,
                    size: 19,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Material(
            color: t.card,
            shape: CircleBorder(side: BorderSide(color: t.line)),
            child: InkWell(
              onTap: () => _showNotifications(context),
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.notifications_outlined, color: t.ink, size: 19),
                    Positioned(
                      top: 9,
                      right: 11,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: t.uma,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
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

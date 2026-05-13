import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../profile_settings/presentation/profile_settings_sheet.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  void _openProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (_) => const ProfileSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
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
                'MA',
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
                Text('Hello,',
                    style: TextStyle(fontSize: 12, color: t.muted, height: 1.2)),
                Text(
                  'Mert Aksoy',
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: t.card,
              shape: BoxShape.circle,
              border: Border.all(color: t.line),
            ),
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
        ],
      ),
    );
  }
}

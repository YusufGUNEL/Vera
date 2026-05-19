import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_tokens.dart';

class DragDropZone extends StatefulWidget {
  const DragDropZone({
    required this.onFileDropped,
    required this.child,
    this.enabled = true,
    this.showIdleHint = true,
    super.key,
  });

  final void Function(Uint8List bytes, String filename) onFileDropped;
  final Widget child;
  final bool enabled;
  final bool showIdleHint;

  @override
  State<DragDropZone> createState() => _DragDropZoneState();
}

class _DragDropZoneState extends State<DragDropZone> {
  bool _isDragging = false;

  bool get _supportsDrop {
    if (!widget.enabled) return false;
    if (kIsWeb) return true;
    return defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.android;
  }

  @override
  Widget build(BuildContext context) {
    if (!_supportsDrop) {
      return widget.child;
    }

    final t = context.tokens;
    final l10n = context.l10n;

    return DropTarget(
      onDragEntered: (_) => setState(() => _isDragging = true),
      onDragExited: (_) => setState(() => _isDragging = false),
      onDragDone: (details) async {
        setState(() => _isDragging = false);
        if (details.files.isEmpty) return;

        final file = details.files.first;
        final bytes = await file.readAsBytes();
        widget.onFileDropped(bytes, file.name);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isDragging ? t.umaSoft.withValues(alpha: 0.35) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isDragging ? t.uma : t.line,
            width: _isDragging ? 2 : 1.5,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.showIdleHint && !_isDragging)
                  _IdleDropHint(l10n: l10n, tokens: t),
                widget.child,
              ],
            ),
            if (_isDragging)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: t.bg.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.upload_file, color: t.uma, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          l10n.dragDropActive,
                          style: TextStyle(
                            color: t.ink,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _IdleDropHint extends StatelessWidget {
  const _IdleDropHint({
    required this.l10n,
    required this.tokens,
  });

  final AppStrings l10n;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: t.umaSoft.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.uma.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.file_upload_outlined, color: t.uma, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dragDropHint,
                  style: TextStyle(
                    color: t.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.dragDropOr,
                  style: TextStyle(color: t.muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

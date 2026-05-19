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
    super.key,
  });

  /// Çağrıldığında dosyanın içeriğini ve adını döndürür.
  final void Function(Uint8List bytes, String filename) onFileDropped;
  
  /// İçine yerleştirilecek normal butonlar/içerikler
  final Widget child;
  
  final bool enabled;

  @override
  State<DragDropZone> createState() => _DragDropZoneState();
}

class _DragDropZoneState extends State<DragDropZone> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    // Sadece masaüstü veya Web ortamında sürükle-bırak desteği verelim
    final isMobile = !kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android);
    
    if (!widget.enabled || isMobile) {
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
          color: _isDragging ? t.umaSoft.withValues(alpha: 0.5) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isDragging ? t.uma : Colors.transparent,
            width: 2,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            widget.child,
            if (_isDragging)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: t.bg.withValues(alpha: 0.85),
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

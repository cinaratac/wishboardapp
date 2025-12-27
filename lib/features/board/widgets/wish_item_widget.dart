import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wish_item.dart';
import '../providers/board_provider.dart';

class WishItemWidget extends ConsumerStatefulWidget {
  final WishItem item;
  // Yeni eklediğimiz callback:
  final ValueChanged<bool> onInteractionChanged;

  const WishItemWidget({
    super.key,
    required this.item,
    required this.onInteractionChanged,
  });

  @override
  ConsumerState<WishItemWidget> createState() => _WishItemWidgetState();
}

class _WishItemWidgetState extends ConsumerState<WishItemWidget> {
  Offset? _initialPosition;
  double? _initialScale;
  double? _initialRotation;

  @override
  Widget build(BuildContext context) {
    final isSelected =
        ref.watch(boardProvider).selectedItemId == widget.item.id;

    return Positioned(
      left: widget.item.position.dx,
      top: widget.item.position.dy,
      child: Listener(
        // ÇÖZÜM: Parmak bu resme değdiği AN arka planı kilitliyoruz.
        onPointerDown: (_) => widget.onInteractionChanged(true),
        onPointerUp: (_) => widget.onInteractionChanged(false),
        onPointerCancel: (_) => widget.onInteractionChanged(false),

        child: GestureDetector(
          behavior: HitTestBehavior.opaque, // Boşlukları bile yakala
          onTap: () {
            ref.read(boardProvider.notifier).selectItem(widget.item.id);
          },
          onScaleStart: (details) {
            ref.read(boardProvider.notifier).selectItem(widget.item.id);
            _initialPosition = widget.item.position;
            _initialScale = widget.item.scale;
            _initialRotation = widget.item.rotation;
          },
          onScaleUpdate: (details) {
            if (_initialPosition == null) return;
            final notifier = ref.read(boardProvider.notifier);

            notifier.updateItemPosition(
              widget.item.id,
              widget.item.position + details.focalPointDelta,
            );

            if (details.pointerCount > 1) {
              final newScale = (_initialScale! * details.scale).clamp(0.2, 5.0);
              final newRotation = _initialRotation! + details.rotation;
              notifier.updateItemTransform(
                widget.item.id,
                newScale,
                newRotation,
              );
            }
          },
          child: Transform(
            transform: Matrix4.identity()
              ..scale(widget.item.scale)
              ..rotateZ(widget.item.rotation),
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                border: isSelected
                    ? Border.all(color: Colors.blueAccent, width: 2)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: _buildImage(widget.item.imagePath),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, width: 150, fit: BoxFit.cover);
    }
    return Image.file(File(path), width: 150, fit: BoxFit.cover);
  }
}

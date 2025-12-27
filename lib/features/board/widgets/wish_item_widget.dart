import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wish_item.dart';
import '../providers/board_provider.dart';

class WishItemWidget extends ConsumerWidget {
  final WishItem item;

  const WishItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = ref.watch(boardProvider).selectedItemId == item.id;

    return Positioned(
      left: item.position.dx,
      top: item.position.dy,
      child: GestureDetector(
        onTap: () => ref.read(boardProvider.notifier).selectItem(item.id),
        onPanUpdate: (details) {
          // Sürükleme işlemi
          final newPos = item.position + details.delta;
          ref.read(boardProvider.notifier).updateItemPosition(item.id, newPos);
        },
        child: Transform(
          transform: Matrix4.identity()
            ..scale(item.scale)
            ..rotateZ(item.rotation),
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: isSelected
                  ? Border.all(color: Colors.blueAccent, width: 2)
                  : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.file(
                File(item.imagePath),
                width: 150,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

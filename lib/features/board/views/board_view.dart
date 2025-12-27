import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/board_provider.dart';
import '../widgets/wish_item_widget.dart';

class BoardView extends ConsumerWidget {
  const BoardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardState = ref.watch(boardProvider);
    final picker = ImagePicker();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: Stack(
        children: [
          // 1. Arka Plan Canvas Alanı
          InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(2000),
            minScale: 0.1,
            maxScale: 5.0,
            child: Container(
              width: 5000,
              height: 5000,
              color: Colors.white,
              child: Stack(
                children: boardState.items.map((item) {
                  return WishItemWidget(key: ValueKey(item.id), item: item);
                }).toList(),
              ),
            ),
          ),

          // 2. Kontrol Butonları (Üstte sabit)
          Positioned(
            bottom: 30,
            right: 20,
            child: Column(
              children: [
                if (boardState.selectedItemId != null)
                  FloatingActionButton(
                    heroTag: "delete",
                    onPressed: () => ref
                        .read(boardProvider.notifier)
                        .removeItem(boardState.selectedItemId!),
                    backgroundColor: Colors.redAccent,
                    child: const Icon(Icons.delete),
                  ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "add",
                  onPressed: () async {
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      ref.read(boardProvider.notifier).addItem(image.path);
                    }
                  },
                  child: const Icon(Icons.add_a_photo),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

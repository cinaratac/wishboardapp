import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/wish_item.dart';
import '../providers/board_provider.dart';
import '../widgets/wish_item_widget.dart';

class BoardView extends ConsumerStatefulWidget {
  const BoardView({super.key});

  @override
  ConsumerState<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends ConsumerState<BoardView> {
  final TransformationController _transformController =
      TransformationController();
  final ImagePicker _picker = ImagePicker();

  // ÇÖZÜMÜN KALBİ: Canvas'ın hareket edip edemeyeceğini kontrol eden değişken
  bool _isCanvasInteractive = true;

  @override
  void initState() {
    super.initState();
    final matrix = Matrix4.identity()..translate(-2500.0, -2500.0);
    _transformController.value = matrix;
  }

  // Resimlerden gelen sinyali işleyen fonksiyon
  void _onItemInteraction(bool isInteracting) {
    if (_isCanvasInteractive != !isInteracting) {
      setState(() {
        // Eğer resimle etkileşim varsa (isInteracting = true), Canvas dursun (Interactive = false)
        _isCanvasInteractive = !isInteracting;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final boardState = ref.watch(boardProvider);

    WishItem? selectedItem;
    if (boardState.selectedItemId != null) {
      try {
        selectedItem = boardState.items.firstWhere(
          (e) => e.id == boardState.selectedItemId,
        );
      } catch (e) {
        selectedItem = null;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: Stack(
        children: [
          // 1. SONSUZ CANVAS
          GestureDetector(
            onTap: () {
              ref.read(boardProvider.notifier).selectItem(null);
              FocusScope.of(context).unfocus();
            },
            child: InteractiveViewer(
              transformationController: _transformController,
              // ÇÖZÜM BURADA: Resme dokunuluyorsa pan ve scale'i kapatıyoruz
              panEnabled: _isCanvasInteractive,
              scaleEnabled: _isCanvasInteractive,

              boundaryMargin: const EdgeInsets.all(double.infinity),
              minScale: 0.1,
              maxScale: 5.0,
              constrained: false,
              child: Container(
                width: 5000,
                height: 5000,
                color: const Color(0xFFF0F0F0),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.05,
                        child: GridPaper(color: Colors.black, interval: 200),
                      ),
                    ),
                    // Resimler
                    ...boardState.items.map((item) {
                      return WishItemWidget(
                        key: ValueKey(item.id),
                        item: item,
                        // Callback fonksiyonunu her bir resme gönderiyoruz
                        onInteractionChanged: _onItemInteraction,
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          // ... (Side Menu ve Ekle Butonu kodları aynen kalacak, buraya kopyalamadım)
          // Aşağıdaki menü ve buton kodları önceki cevabındakiyle AYNIDIR.
          // Sadece yukarıdaki InteractiveViewer kısmı değişti.
          _buildSideMenu(context, selectedItem),
          _buildAddButton(context),
        ],
      ),
    );
  }

  // Kod kalabalığı olmasın diye menü ve butonu aşağıya fonksiyon olarak ayırdım
  // (Senin mevcut kodundaki animatedPositioned ve floatingActionButton buraya gelecek)
  Widget _buildSideMenu(BuildContext context, WishItem? selectedItem) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      right: selectedItem != null ? 0 : -320,
      top: 0,
      bottom: 0,
      width: 300,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 20,
          left: 20,
          right: 20,
          bottom: 20,
        ),
        child: selectedItem == null
            ? const SizedBox()
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Düzenle",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () =>
                              ref.read(boardProvider.notifier).selectItem(null),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: _buildPreviewImage(selectedItem.imagePath),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Dilek Notu",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: TextEditingController(text: selectedItem.note)
                        ..selection = TextSelection.collapsed(
                          offset: selectedItem.note.length,
                        ),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Bu görselin anlamı ne?",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) => ref
                          .read(boardProvider.notifier)
                          .updateItemNote(selectedItem!.id, val),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.flip_to_front),
                            label: const Text("Öne Al"),
                            onPressed: () => ref
                                .read(boardProvider.notifier)
                                .bringToFront(selectedItem!.id),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.flip_to_back),
                            label: const Text("Arkaya"),
                            onPressed: () => ref
                                .read(boardProvider.notifier)
                                .sendToBack(selectedItem!.id),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text("Kaldır"),
                        onPressed: () => ref
                            .read(boardProvider.notifier)
                            .removeItem(selectedItem!.id),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Center(
        child: FloatingActionButton.extended(
          heroTag: "add_photo",
          onPressed: () async {
            final XFile? image = await _picker.pickImage(
              source: ImageSource.gallery,
            );
            if (image != null) {
              final screenSize = MediaQuery.of(context).size;
              final centerOffset = _transformController.toScene(
                Offset(screenSize.width / 2, screenSize.height / 2),
              );
              ref
                  .read(boardProvider.notifier)
                  .addItem(image.path, centerOffset - const Offset(75, 75));
            }
          },
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_photo_alternate),
          label: const Text("Dilek Ekle"),
        ),
      ),
    );
  }

  Widget _buildPreviewImage(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover);
    }
    return Image.file(File(path), fit: BoxFit.cover);
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/board_provider.dart';
import '../widgets/wish_item_widget.dart';

class BoardView extends ConsumerWidget {
  const BoardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardState = ref.watch(boardProvider);
    final picker = ImagePicker();
    // Screenshot controller'ı her build'de yeniden oluşturmamak için
    // normalde stateful widget içinde tutardık ama şimdilik burada basit tutalım.
    // Riverpod ile tutmak daha doğru olur ama basitlik adına burada tanımlıyoruz.
    final ScreenshotController screenshotController = ScreenshotController();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7), // Daha soft, kağıdımsı gri
      body: Stack(
        children: [
          // 1. Arka Plan Canvas Alanı
          InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(
              double.infinity,
            ), // Sonsuz hissi
            minScale: 0.1,
            maxScale: 5.0,
            child: Screenshot(
              controller: screenshotController,
              child: Container(
                // Export alırken arka planın beyaz görünmesi için
                color: const Color(0xFFF5F5F7),
                width: 4000, // Yeterince geniş bir alan
                height: 4000,
                child: Stack(
                  // Center the content initially
                  alignment: Alignment.center,
                  children: [
                    // Grid veya doku eklenebilir
                    ...boardState.items.map((item) {
                      return WishItemWidget(key: ValueKey(item.id), item: item);
                    }),
                  ],
                ),
              ),
            ),
          ),

          // 2. Alt Bar (Ritüel Araçları)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Fotoğraf Ekle
                    IconButton(
                      icon: const Icon(Icons.add_a_photo, color: Colors.white),
                      tooltip: "Dilek Ekle",
                      onPressed: () async {
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (image != null) {
                          ref.read(boardProvider.notifier).addItem(image.path);
                        }
                      },
                    ),
                    const SizedBox(width: 20),
                    // Ayırıcı
                    Container(width: 1, height: 24, color: Colors.white24),
                    const SizedBox(width: 20),
                    // Paylaş / Kaydet
                    IconButton(
                      icon: const Icon(Icons.ios_share, color: Colors.white),
                      tooltip: "Ritüeli Tamamla (Paylaş)",
                      onPressed: () async {
                        if (boardState.items.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Henüz bir dilek eklemedin."),
                            ),
                          );
                          return;
                        }

                        // Yükleme göstergesi
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (c) => const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        );

                        try {
                          // Sadece görünür alanı değil, tüm container'ı çekmeye çalışır.
                          // PixelRatio'yu yüksek tutarak kaliteyi artırıyoruz.
                          final Uint8List? imageBytes =
                              await screenshotController.capture(
                                pixelRatio: 2.0,
                                delay: const Duration(milliseconds: 100),
                              );

                          Navigator.pop(context); // Loader'ı kapat

                          if (imageBytes != null) {
                            final directory =
                                await getApplicationDocumentsDirectory();
                            final imagePath = await File(
                              '${directory.path}/wishboard_ritual.png',
                            ).create();
                            await imagePath.writeAsBytes(imageBytes);

                            // Share Plus ile paylaş
                            await Share.shareXFiles([
                              XFile(imagePath.path),
                            ], text: 'Benim Wishboard Ritüelim ✨');
                          }
                        } catch (e) {
                          Navigator.pop(context); // Hata olsa da loader'ı kapat
                          debugPrint("Hata: $e");
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Yardımcı ipucu metni (Sadece boşken)
          if (boardState.items.isEmpty)
            Positioned.fill(
              child: Center(
                child: Text(
                  "Ruhunu yansıtan görselleri eklemeye başla...",
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.3),
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

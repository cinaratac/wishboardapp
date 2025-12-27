import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wish_item.dart';
import '../providers/board_provider.dart';

class WishItemWidget extends ConsumerWidget {
  final WishItem item;

  const WishItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sadece seçili olup olmadığını anlamak için (Border vs.)
    // final isSelected = ref.watch(boardProvider).selectedItemId == item.id;

    return Positioned(
      left: item.position.dx,
      top: item.position.dy,
      child: GestureDetector(
        // Tek dokunuşla Modal'ı açıyoruz
        onTap: () {
          ref.read(boardProvider.notifier).selectItem(item.id);
          _showEditModal(context, ref, item);
        },
        // Sürükleme işlemi
        onPanUpdate: (details) {
          final newPos = item.position + details.delta;
          ref.read(boardProvider.notifier).updateItemPosition(item.id, newPos);
        },
        child: Transform(
          transform: Matrix4.identity()
            ..scale(item.scale)
            ..rotateZ(item.rotation),
          alignment: Alignment.center,
          child: Container(
            // Seçiliyken border göstermek yerine modal açtığımız için sade bıraktık
            // İstersen hafif bir gölge ekleyebilirsin
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8), // Hafif yumuşak köşeler
              child: Image.file(
                File(item.imagePath),
                width: 150, // Baz genişlik
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditModal(BuildContext context, WidgetRef ref, WishItem item) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(
        0.7,
      ), // Odaklanma hissi için koyu arka plan
      builder: (context) {
        // Dialog içinde anlık değişimleri görmek için stateful builder'a gerek yok,
        // çünkü provider değiştikçe arka plandaki board zaten güncelleniyor.
        // Ancak Slider değerlerini akıcı yönetmek için yerel değişkenler kullanabiliriz.

        return _EditDialogContent(item: item);
      },
    );
  }
}

class _EditDialogContent extends ConsumerStatefulWidget {
  final WishItem item;
  const _EditDialogContent({required this.item});

  @override
  ConsumerState<_EditDialogContent> createState() => _EditDialogContentState();
}

class _EditDialogContentState extends ConsumerState<_EditDialogContent> {
  late double _currentScale;
  late double _currentRotation;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _currentScale = widget.item.scale;
    _currentRotation = widget.item.rotation;
    _noteController = TextEditingController(text: widget.item.note);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _updateTransform() {
    ref
        .read(boardProvider.notifier)
        .updateItemTransform(widget.item.id, _currentScale, _currentRotation);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF2C2C2E), // Apple-style dark modal
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gizli Not Alanı
            TextField(
              controller: _noteController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Bu dileğin senin için anlamı ne?",
                hintStyle: TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Color(0xFF1C1C1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                ref
                    .read(boardProvider.notifier)
                    .updateItemNote(widget.item.id, val);
              },
            ),
            const SizedBox(height: 20),

            // Scale Slider
            Row(
              children: [
                const Icon(Icons.zoom_in, color: Colors.white70),
                Expanded(
                  child: Slider(
                    value: _currentScale,
                    min: 0.5,
                    max: 3.0,
                    activeColor: const Color(0xFFE0C3FC),
                    inactiveColor: Colors.white24,
                    onChanged: (val) {
                      setState(() => _currentScale = val);
                      _updateTransform();
                    },
                  ),
                ),
              ],
            ),

            // Rotation Slider
            Row(
              children: [
                const Icon(Icons.rotate_right, color: Colors.white70),
                Expanded(
                  child: Slider(
                    value: _currentRotation,
                    min: 0,
                    max: math.pi * 2,
                    activeColor: const Color(0xFFE0C3FC),
                    inactiveColor: Colors.white24,
                    onChanged: (val) {
                      setState(() => _currentRotation = val);
                      _updateTransform();
                    },
                  ),
                ),
              ],
            ),

            const Divider(color: Colors.white24, height: 30),

            // Alt Butonlar (Katman & Sil)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(
                  icon: Icons.flip_to_front,
                  label: "Öne Al",
                  onTap: () {
                    ref
                        .read(boardProvider.notifier)
                        .bringToFront(widget.item.id);
                    Navigator.pop(context);
                  },
                ),
                _actionButton(
                  icon: Icons.flip_to_back,
                  label: "Arkaya At",
                  onTap: () {
                    ref.read(boardProvider.notifier).sendToBack(widget.item.id);
                    Navigator.pop(context);
                  },
                ),
                _actionButton(
                  icon: Icons.delete_outline,
                  label: "Sil",
                  color: Colors.redAccent,
                  onTap: () {
                    ref.read(boardProvider.notifier).removeItem(widget.item.id);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white70,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

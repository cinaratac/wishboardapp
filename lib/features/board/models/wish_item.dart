import 'dart:ui';

class WishItem {
  final String id;
  final String imagePath; // Görselin dosya yolu
  final Offset position; // Ekrandaki x,y konumu
  final double scale; // Büyüklük oranı (1.0 normal)
  final double rotation; // Döndürme açısı (radyan)
  final int zIndex; // Katman sırası
  final String note; // Kullanıcının eklediği gizli not

  WishItem({
    required this.id,
    required this.imagePath,
    this.position = const Offset(100, 100), // Varsayılan başlangıç konumu
    this.scale = 1.0,
    this.rotation = 0.0,
    this.zIndex = 0,
    this.note = '',
  });

  // State değişmez (immutable) olduğu için güncelleme yaparken kopyasını oluşturuyoruz
  WishItem copyWith({
    String? id,
    String? imagePath,
    Offset? position,
    double? scale,
    double? rotation,
    int? zIndex,
    String? note,
  }) {
    return WishItem(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      zIndex: zIndex ?? this.zIndex,
      note: note ?? this.note,
    );
  }
}

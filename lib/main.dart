import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Henüz view'ı oluşturmadık ama import'unu ekleyelim, hata verirse yorum satırına alabilirsin.
import 'features/board/views/board_view.dart';

void main() {
  runApp(const ProviderScope(child: WishboardApp()));
}

class WishboardApp extends StatelessWidget {
  const WishboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wishboard Ritual',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Sessiz ve soft bir tema
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE0C3FC), // Pastel mor/lila tonu
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      // BoardView'ı bir sonraki adımda oluşturacağız
      home: const BoardView(),
    );
  }
}

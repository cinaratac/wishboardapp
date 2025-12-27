import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Doğru import'u yaptığınızdan emin olun
import 'package:wishboard/main.dart';

void main() {
  testWidgets('App starts correctly test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // ProviderScope eklemeyi unutmuyoruz.
    await tester.pumpWidget(const ProviderScope(child: WishboardApp()));

    // Basit bir smoke test: Ekranda bir scaffold veya container var mı?
    // Şimdilik sadece uygulamanın çökmeden açıldığını doğruluyoruz.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

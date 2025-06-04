// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stay_fit/src/app.dart'; // App widget'ımızı import ediyoruz

void main() {
  testWidgets('App builds and shows Home Page title', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    // ProviderScope ile sarmalıyoruz çünkü uygulamamız Riverpod kullanıyor.
    await tester.pumpWidget(const ProviderScope(child: App()));

    // Uygulamanın yüklendiğini ve ilk sayfanın (Ana Sayfa) başlığının göründüğünü doğrulayın.
    // GoRouter'ın ilk rotayı yüklemesi için bir frame daha bekleyebiliriz.
    await tester.pumpAndSettle();

    expect(find.text('Ana Sayfa (Tartım)'), findsOneWidget);

    // Örnek olarak, FAB butonunun varlığını da kontrol edebiliriz.
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}

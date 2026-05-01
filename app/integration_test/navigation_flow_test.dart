/// Integration testler — gerçek Flutter engine + uygulamanın tamamı.
///
/// Çalıştırma:
///   flutter test integration_test/navigation_flow_test.dart
///
/// NOT: Bu testler backend bağımsız — sadece UI flow doğrular.
/// Gerçek backend entegrasyonu için ayrı E2E suite gerekir (şu an kapsam dışı).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nuveli/features/auth/screens/login_screen.dart';
import 'package:nuveli/features/auth/screens/signup_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login ekranı form flow', () {
    testWidgets('email + password alanları navigate edilebilir',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: LoginScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Email ve password field'ları görünür
      expect(find.byType(TextFormField), findsNWidgets(2));

      // Email yazabilir
      await tester.enterText(find.byType(TextFormField).first, 'test@test.com');
      await tester.pump();
      expect(find.text('test@test.com'), findsOneWidget);

      // Password yazabilir
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.pump();

      // "Giriş Yap" butonu var
      expect(find.text('Giriş Yap'), findsWidgets);

      // "Kaydol" linki var
      expect(find.text('Kaydol'), findsOneWidget);

      // "Şifremi unuttum" linki var
      expect(find.text('Şifremi unuttum'), findsOneWidget);
    });

    testWidgets('boş form submit validation hatası gösterir', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: LoginScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Giriş Yap'a tıkla (form boş)
      await tester.tap(find.text('Giriş Yap').last);
      await tester.pump();

      // Email ve password gerekli mesajları
      expect(find.text('Email gerekli'), findsOneWidget);
      expect(find.text('Şifre gerekli'), findsOneWidget);
    });

    testWidgets('geçersiz email formatı reddedilir', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: LoginScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'not-email');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.text('Giriş Yap').last);
      await tester.pump();

      expect(find.text('Geçerli bir email gir'), findsOneWidget);
    });

    testWidgets('6 karakterden kısa şifre reddedilir', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: LoginScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'user@test.com');
      await tester.enterText(find.byType(TextFormField).last, '123');
      await tester.tap(find.text('Giriş Yap').last);
      await tester.pump();

      expect(find.text('En az 6 karakter'), findsOneWidget);
    });
  });

  group('Signup ekranı form flow', () {
    testWidgets('signup form doğru alanlara sahip', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: SignUpScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // 3 field: email, password, confirm password
      expect(find.byType(TextFormField), findsNWidgets(3));

      // Kaydol butonu
      expect(find.text('Kaydol'), findsWidgets);

      // Terms notice
      expect(
        find.textContaining('Kullanım Koşulları'),
        findsOneWidget,
      );
    });

    testWidgets('şifre güçlülük göstergesi yazdıkça görünür',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: SignUpScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Başta strength bar görünmemeli
      expect(find.byType(LinearProgressIndicator), findsNothing);

      // Password yaz
      final passwordField = find.byType(TextFormField).at(1);
      await tester.enterText(passwordField, 'abc');
      await tester.pump();

      // Zayıf
      expect(find.text('Zayıf'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Güçlü password
      await tester.enterText(passwordField, 'Abcdef1!');
      await tester.pump();

      expect(find.textContaining('güçlü'), findsOneWidget);
    });

    testWidgets('şifreler eşleşmiyor hatası', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: SignUpScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'user@test.com');
      await tester.enterText(fields.at(1), 'password123');
      await tester.enterText(fields.at(2), 'different123');

      await tester.tap(find.text('Kaydol').last);
      await tester.pump();

      expect(find.text('Şifreler eşleşmiyor'), findsOneWidget);
    });
  });
}

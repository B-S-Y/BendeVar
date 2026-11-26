import 'package:bende_var/features/auth/view/login_page.dart';
import 'package:bende_var/features/auth/viewmodel/auth_view_model.dart';
import 'package:bende_var/data/mock/mock_repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:bende_var/features/create_listing/view/create_listing_page.dart';
import 'package:provider/provider.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(initTestEnv);

  for (final theme in [ThemeMode.light, ThemeMode.dark]) {
    for (final lang in ['tr', 'en']) {
      testWidgets('Karşılama ve Giriş: $theme / $lang hatasız açılır', (
        tester,
      ) async {
        await pumpApp(tester, theme: theme, locale: Locale(lang));
        expect(tester.takeException(), isNull);
        expect(find.text('Bende Var'), findsOneWidget);
        expect(
          find.text(lang == 'tr' ? 'Giriş yap' : 'Sign in'),
          findsOneWidget,
        );
        await tester.tap(find.text(lang == 'tr' ? 'Giriş yap' : 'Sign in'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          find.text(lang == 'tr' ? 'Tekrar hoş geldin' : 'Welcome back'),
          findsOneWidget,
        );
      });
    }
  }

  testWidgets('Giriş: düğme pasif, .edu.tr olmayan e-posta hata gösterir', (
    tester,
  ) async {
    useAndroidScreen(tester);
    final vm = AuthViewModel(MockAuthRepository());
    await tester.pumpWidget(
      ChangeNotifierProvider.value(value: vm, child: wrap(const LoginPage())),
    );
    await tester.pumpAndSettle();
    final btn = find.widgetWithText(ElevatedButton, 'Giriş yap');
    expect(tester.widget<ElevatedButton>(btn).onPressed, isNull);
    await tester.enterText(
      find.byKey(const Key('email-field')),
      'ad@gmail.com',
    );
    await tester.enterText(find.byKey(const Key('password-field')), 'x');
    await tester.pump();
    expect(tester.widget<ElevatedButton>(btn).onPressed, isNotNull);
    await tester.tap(btn);
    await tester.pumpAndSettle();
    expect(find.textContaining('.edu.tr'), findsWidgets);
  });

  testWidgets('Tam akış: giriş → ana sayfa → ilan ver → ana sayfanın en üstü', (
    tester,
  ) async {
    await pumpApp(tester);
    await signIn(tester);
    expect(find.textContaining('İlanlar · '), findsOneWidget);
    expect(find.text('Casio fx-991EX hesap makinesi'), findsOneWidget);

    // Favori kalbi aç/kapa.
    await tester.tap(find.byTooltip('Favorilere ekle').first);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Favorilerden çıkar'), findsOneWidget);

    // Logo → 3.01 paneli
    await tester.tap(find.byKey(const Key('nav-logo')));
    await tester.pumpAndSettle();
    expect(find.text('Elindeki eşyayı ödünç ver'), findsOneWidget);
    expect(find.text('Aradığın eşyayı ödünç al'), findsOneWidget);
    await tester.tap(find.text('Bende var'));
    await tester.pumpAndSettle();

    // Boş form → doğrulama hataları
    expect(find.text('Yeni ilan'), findsOneWidget);
    await tester.tap(find.text('Yayınla'));
    await tester.pumpAndSettle();
    expect(find.text('Bu alan boş bırakılamaz.'), findsOneWidget);

    // Formu doldur
    await tester.enterText(
      find.byKey(const Key('title-field')),
      'Fizik 1 soru bankası',
    );
    await tester.tap(find.text('Ders kitabı'));
    await tester.tap(find.text('Az kullanılmış'));
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(const Key('date-from')),
      200,
      scrollable: find
          .descendant(
            of: find.byType(CreateListingPage),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.drag(
      find
          .descendant(
            of: find.byType(CreateListingPage),
            matching: find.byType(Scrollable),
          )
          .first,
      const Offset(0, -150),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('date-from')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tamam').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('date-to')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tamam').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yayınla'));
    await tester.pumpAndSettle();
    expect(find.text('İlanın yayınlandı'), findsOneWidget);

    await tester.tap(find.text('Ana sayfaya dön'));
    await tester.pumpAndSettle();
    final top = tester.getTopLeft(find.text('Fizik 1 soru bankası')).dy;
    final second = tester
        .getTopLeft(find.text('Casio fx-991EX hesap makinesi'))
        .dy;
    expect(top, lessThan(second));
  });

  testWidgets('Mesajlar: sohbet aç, mesaj gönder, listede görünür', (
    tester,
  ) async {
    await pumpApp(tester);
    await signIn(tester);
    await tester.tap(find.byIcon(LucideIcons.messageCircle));
    await tester.pumpAndSettle();
    expect(find.text('Okunmamış'), findsOneWidget);
    await tester.tap(find.text('Oğuz E.'));
    await tester.pumpAndSettle();
    expect(find.text('Anlaşma detayı'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('message-field')),
      'Yarın görüşürüz',
    );
    await tester.tap(find.byKey(const Key('send-button')));
    await tester.pumpAndSettle();
    expect(find.text('Yarın görüşürüz'), findsOneWidget);
    await tester.tap(find.byTooltip('Geri'));
    await tester.pumpAndSettle();
    expect(find.text('Yarın görüşürüz'), findsOneWidget);
  });

  testWidgets('Profil: tema/dil sheet ve çıkış onayı', (tester) async {
    await pumpApp(tester);
    await signIn(tester);
    await tester.tap(find.byIcon(LucideIcons.user));
    await tester.pumpAndSettle();
    expect(find.text('Elif Yıldırım'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Tema ve dil'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -150));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tema ve dil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Appearance and language'), findsOneWidget);
    await tester.tap(find.text('Türkçe'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kapat'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Çıkış yap'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Çıkış yap'));
    await tester.pumpAndSettle();
    expect(find.text('Çıkış yapmak istiyor musun?'), findsOneWidget);
    await tester.tap(find.text('Çıkış yap').last);
    await tester.pumpAndSettle();
    expect(find.text('İhtiyacın topluluğunda.'), findsOneWidget);
  });
}

import 'package:bende_var/core/widgets/institution_email_field.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(initTestEnv);

  testWidgets('A5: Türkçe karakter/büyük harf ipucu yalnızca ilk çevirmede', (
    tester,
  ) async {
    useAndroidScreen(tester);
    final ctrl = InstitutionEmailController();
    addTearDown(ctrl.dispose);
    await tester.pumpWidget(
      wrap(InstitutionEmailField(fieldKey: const Key('e'), controller: ctrl)),
    );
    const hint = Key('email-convert-hint');

    // Düz küçük ASCII: ipucu yok.
    await tester.enterText(find.byKey(const Key('e')), 'elif');
    await tester.pump();
    expect(find.byKey(hint), findsNothing);

    await tester.enterText(find.byKey(const Key('e')), 'ELİF');
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(ctrl.text, 'elif');
    expect(find.byKey(hint), findsOneWidget);
    expect(
      find.text(
        'E-posta adreslerinde Türkçe karakter ve büyük harf kullanılmaz, '
        'otomatik düzelttik.',
      ),
      findsOneWidget,
    );

    // Süre dolunca kaybolur.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.byKey(hint), findsNothing);

    // İkinci çeviride tekrar gösterilmez.
    await tester.enterText(find.byKey(const Key('e')), 'ÇAĞLA');
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(ctrl.text, 'cagla');
    expect(find.byKey(hint), findsNothing);
  });

  testWidgets('A4: kilit kutusu açılınca "Tekrar hoş geldin" tam görünür', (
    tester,
  ) async {
    await pumpApp(tester);
    tester.view.physicalSize = const Size(720, 1280);
    await tester.tap(find.text('Giriş yap').first);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('email-field')),
      'elif@std.yildiz.edu.tr',
    );
    await tester.enterText(find.byKey(const Key('password-field')), 'yanlis1');
    await tester.pump();

    final title = find.text('Tekrar hoş geldin');
    for (var i = 0; i < 4; i++) {
      // Formu aşağı kaydır, sonra hata gelsin.
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Giriş yap'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
    }
    expect(find.textContaining('Çok fazla hatalı deneme'), findsOneWidget);
    final viewport = tester.getRect(find.byType(SingleChildScrollView).first);
    expect(tester.getTopLeft(title).dy, greaterThanOrEqualTo(viewport.top));
  });
}

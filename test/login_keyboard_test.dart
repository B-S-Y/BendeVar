import 'package:bende_var/features/auth/view/login_form.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'test_helpers.dart';

/// Gerçek uygulama gibi: Karşılama → Giriş yap (dış Scaffold yok).
Future<void> _openLogin(WidgetTester tester, double height) async {
  await pumpApp(tester);
  tester.view.physicalSize = Size(720, height * 2);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Giriş yap').first);
  await tester.pumpAndSettle();
}

bool _textFieldFocused() {
  final focus = FocusManager.instance.primaryFocus;
  return focus?.context?.findAncestorWidgetOfExactType<EditableText>() != null;
}

void main() {
  setUpAll(initTestEnv);

  testWidgets('Giriş açılınca otomatik odak yok; klavye yalnızca dokununca', (
    tester,
  ) async {
    await _openLogin(tester, 917);
    expect(_textFieldFocused(), isFalse);
    expect(tester.testTextInput.isVisible, isFalse);
    await tester.tap(find.byKey(const Key('email-field')));
    await tester.pump();
    expect(_textFieldFocused(), isTrue);
    expect(tester.testTextInput.isVisible, isTrue);
  });

  for (final h in [917.0, 640.0, 568.0]) {
    testWidgets('Klavye açılırken alan tek yönde kalkar, başlık ekranda: $h', (
      tester,
    ) async {
      await _openLogin(tester, h);
      final email = find.byKey(const Key('email-field'));
      await tester.tap(email);
      await tester.pump();

      // Klavye kademeli açılır (Android IME animasyonu gibi).
      const keyboard = 300.0;
      var last = double.infinity;
      for (var i = 0; i <= 10; i++) {
        tester.view.viewInsets = FakeViewPadding(bottom: 2 * keyboard * i / 10);
        await tester.pump(const Duration(milliseconds: 16));
        final top = tester.getTopLeft(email).dy;
        // Tek hareket: geri sekme yok (y hiç artmaz).
        expect(top, lessThanOrEqualTo(last + 0.5), reason: 'kare $i');
        last = top;
        // Odak kaybolmaz.
        expect(_textFieldFocused(), isTrue, reason: 'kare $i');
      }
      await tester.pump(const Duration(milliseconds: 500));

      // Panel ekranın üstüne itilmez: başlık satırı (geri düğmesi) görünür.
      final header = tester.getRect(find.byType(LoginHeader));
      expect(header.top, greaterThanOrEqualTo(0));
      // Alan klavyenin üstünde ve ekranın içinde.
      final field = tester.getRect(email);
      expect(field.top, greaterThanOrEqualTo(0));
      expect(field.bottom, lessThanOrEqualTo(h - keyboard));
      expect(tester.takeException(), isNull);

      tester.view.resetViewInsets();
      await tester.pump(const Duration(milliseconds: 500));
    });
  }
}

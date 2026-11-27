import 'package:bende_var/features/auth/view/auth_motion.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(initTestEnv);

  for (final locale in [const Locale('tr'), const Locale('en')]) {
    testWidgets('Karşılama: slogan altında satır yok, boşluk token '
        '(${locale.languageCode})', (tester) async {
      await pumpApp(tester, locale: locale);
      expect(find.text('Okul e-postanla giriş yap.'), findsNothing);
      expect(find.text('Sign in with your school email.'), findsNothing);
      final slogan = find.textContaining(
        locale.languageCode == 'tr' ? 'ihtiyacı olan bulur.' : 'in need, find.',
      );
      final login = find.widgetWithText(
        ElevatedButton,
        locale.languageCode == 'tr' ? 'Giriş yap' : 'Sign in',
      );
      final gap = tester.getRect(login).top - tester.getRect(slogan).bottom;
      // Düğmenin dokunma alanı (padded) birkaç dp ekleyebilir.
      expect(gap, greaterThanOrEqualTo(AuthMotion.sloganButtonGap));
      expect(gap, lessThan(AuthMotion.sloganButtonGap + 8));
    });
  }

  for (final (w, h) in [(360.0, 800.0), (412.0, 917.0)]) {
    for (final scale in [1.3, 1.5, 2.0]) {
      testWidgets('Karşılama taşmaz: ${w.toInt()}×${h.toInt()} ×$scale', (
        tester,
      ) async {
        useAndroidScreen(tester);
        tester.view.physicalSize = Size(w * 2, h * 2);
        tester.view.padding = const FakeViewPadding(top: 64, bottom: 96);
        tester.view.viewPadding = const FakeViewPadding(top: 64, bottom: 96);
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await pumpApp(tester);
        tester.view.physicalSize = Size(w * 2, h * 2);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        // İkinci düğme alt sistem çubuğunun üstünde.
        final signup = find.widgetWithText(OutlinedButton, 'Kayıt ol');
        final rect = tester.getRect(
          signup.evaluate().isNotEmpty ? signup : find.text('Kayıt ol').first,
        );
        expect(rect.bottom, lessThanOrEqualTo(h - 48));
      });
    }
  }
}

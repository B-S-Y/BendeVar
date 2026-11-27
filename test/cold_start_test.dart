import 'package:bende_var/app/app.dart';
import 'package:bende_var/app/di.dart';
import 'package:bende_var/app/locale_controller.dart';
import 'package:bende_var/app/theme_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_helpers.dart';

/// Panel içeriğinin (başlık) şu anki opaklığı: 0 = animasyon başlamadı/sürüyor.
double _contentOpacity(WidgetTester tester) => tester
    .widget<Opacity>(
      find
          .ancestor(
            of: find.textContaining('ihtiyacı olan bulur.'),
            matching: find.byType(Opacity),
          )
          .first,
    )
    .opacity;

void main() {
  setUpAll(initTestEnv);

  testWidgets('Soğuk açılış: açılış animasyonu baştan sona oynar', (
    tester,
  ) async {
    useAndroidScreen(tester);
    // Gerçek cihaz gibi: animasyonlar açık.
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final localeCtrl = LocaleController(prefs);
    await localeCtrl.setChoice(LocaleChoice.tr);
    await tester.pumpWidget(
      BendeVarApp(
        deps: AppDependencies(),
        themeController: ThemeController(prefs),
        localeController: localeCtrl,
      ),
    );
    // İlk kare + ağır bir kare atlaması (soğuk açılış): animasyon yutulmamalı.
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
    expect(_contentOpacity(tester), 0, reason: 'açılış henüz bitmemeli');

    // Normal kare akışıyla sonuna kadar oynar.
    for (var i = 0; i < 90; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(_contentOpacity(tester), 1);
    await tester.tap(find.text('Giriş yap'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.text('Tekrar hoş geldin'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}

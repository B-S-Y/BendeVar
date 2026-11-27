import 'package:bende_var/core/theme/app_colors.dart';
import 'package:bende_var/core/widgets/envelope_animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import 'test_helpers.dart';

double _badgeScale(WidgetTester tester) {
  final t = tester.widget<Transform>(
    find
        .ancestor(
          of: find.byIcon(LucideIcons.check),
          matching: find.byType(Transform),
        )
        .first,
  );
  return t.transform.storage[0];
}

void main() {
  setUpAll(initTestEnv);

  testWidgets('Zarf: bir kez oynar, açık zarf ve tikle durur', (tester) async {
    useAndroidScreen(tester);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures();
    await tester.pumpWidget(wrap(const Center(child: EnvelopeAnimation())));
    // Başta tik yok (ölçek 0).
    expect(_badgeScale(tester), 0);
    await tester.pump(const Duration(milliseconds: 1000));
    expect(_badgeScale(tester), 0);
    await tester.pump(const Duration(milliseconds: 1000));
    expect(_badgeScale(tester), greaterThan(0));
    // Süre dolunca durur; tik 1,0'da kalır, animasyon sürmez.
    await tester.pumpAndSettle();
    expect(_badgeScale(tester), closeTo(1, 1e-6));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Zarf: animasyonları azalt açıkken doğrudan son kare', (
    tester,
  ) async {
    useAndroidScreen(tester); // animasyonlar kapalı
    await tester.pumpWidget(wrap(const Center(child: EnvelopeAnimation())));
    expect(_badgeScale(tester), closeTo(1, 1e-6));
    expect(tester.takeException(), isNull);
  });

  test('Zarf renkleri (tasarım C): açık ve koyu temada belgedeki rollerle', () {
    const l = AppColors.light;
    const d = AppColors.dark;
    // Açık: daire = alt menü aktif hap, gövde = alt menü aktif ikon.
    expect(l.envelopeDisc, l.navPill);
    expect(l.envelopeBody, l.navPillIcon);
    // Koyu: daire = koyu açık mavi vurgu, gövde = sayfa zemini.
    expect(d.envelopeDisc, d.accent);
    expect(d.envelopeBody, d.background);
    // Koyuda zarf zeminden ayırt edilir (daire ≠ gövde).
    expect(d.envelopeDisc, isNot(d.envelopeBody));
    expect(l.envelopeDisc, isNot(l.envelopeBody));
    // Halka dairenin dışında, daireden farklı.
    expect(l.envelopeRing, isNot(l.envelopeDisc));
    expect(d.envelopeRing, isNot(d.envelopeDisc));
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('Zarf: daire ve ince halka çizilir (${mode.name})', (
      tester,
    ) async {
      useAndroidScreen(tester);
      await tester.pumpWidget(
        wrap(const Center(child: EnvelopeAnimation()), theme: mode),
      );
      final colors = mode == ThemeMode.dark ? AppColors.dark : AppColors.light;
      final disc = find
          .descendant(
            of: find.byType(EnvelopeAnimation),
            matching: find.byType(CustomPaint),
          )
          .first;
      expect(
        tester.renderObject(disc),
        paints
          ..circle(color: colors.envelopeDisc)
          ..circle(color: colors.envelopeRing, style: PaintingStyle.stroke),
      );
      // Gövde: belgedeki gövde rengi.
      final body = tester
          .widgetList<DecoratedBox>(
            find.descendant(
              of: find.byType(EnvelopeAnimation),
              matching: find.byType(DecoratedBox),
            ),
          )
          .map((b) => (b.decoration as BoxDecoration).color);
      expect(body, contains(colors.envelopeBody));
      // Daire zarfı çevreler: kutu halka çapında.
      expect(
        tester.getSize(find.byType(EnvelopeAnimation)),
        const Size(
          EnvelopeAnimation.ringDiameter,
          EnvelopeAnimation.ringDiameter,
        ),
      );
    });
  }
}

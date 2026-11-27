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

  test('Zarf renkleri (tasarım B): belgedeki rollerle', () {
    const l = AppColors.light;
    const d = AppColors.dark;
    // Açık: çizgi = alt menü aktif ikon, dolgu = yüzey.
    expect(l.envelopeLine, l.navPillIcon);
    expect(l.envelopeSurface, l.card);
    // Koyu: çizgi = açık mavi vurgu, dolgu = panel/yüzey.
    expect(d.envelopeLine, d.navLogoBg);
    expect(d.envelopeSurface, d.card);
    // Koyuda iç halka dıştan açık, ikisi de çizgiden farklı.
    expect(
      d.envelopeRingInner.computeLuminance(),
      greaterThan(d.envelopeRingOuter.computeLuminance()),
    );
    expect(d.envelopeRingInner, isNot(d.envelopeLine));
    // Zarf koyu zeminden ayırt edilir: çizgi zeminden farklı.
    expect(d.envelopeLine, isNot(d.background));
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('Zarf: iki ince halka, dolgulu daire yok (${mode.name})', (
      tester,
    ) async {
      useAndroidScreen(tester); // azaltılmış: son kare, halkalar statik
      await tester.pumpWidget(
        wrap(const Center(child: EnvelopeAnimation()), theme: mode),
      );
      final colors = mode == ThemeMode.dark ? AppColors.dark : AppColors.light;
      final rings = find
          .descendant(
            of: find.byType(EnvelopeAnimation),
            matching: find.byType(CustomPaint),
          )
          .first;
      expect(
        tester.renderObject(rings),
        paints
          ..circle(color: colors.envelopeRingInner, style: PaintingStyle.stroke)
          ..circle(
            color: colors.envelopeRingOuter,
            style: PaintingStyle.stroke,
          ),
      );
      // Gövde: yüzey dolgulu, 2,5 dp çizgili.
      final body = tester.widget<DecoratedBox>(
        find.byKey(const Key('envelope-body')),
      );
      final deco = body.decoration as BoxDecoration;
      expect(deco.color, colors.envelopeSurface);
      expect(deco.border!.top.color, colors.envelopeLine);
      expect(deco.border!.top.width, EnvelopeAnimation.lineStroke);
      expect(EnvelopeAnimation.lineStroke, 2.5);
      expect(
        tester.getSize(find.byType(EnvelopeAnimation)),
        const Size(
          EnvelopeAnimation.ringOuterDiameter,
          EnvelopeAnimation.ringOuterDiameter,
        ),
      );
    });
  }

  testWidgets('Halkalar içeriden dışarı sırayla belirir', (tester) async {
    useAndroidScreen(tester);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures();
    await tester.pumpWidget(wrap(const Center(child: EnvelopeAnimation())));
    final rings = find
        .descendant(
          of: find.byType(EnvelopeAnimation),
          matching: find.byType(CustomPaint),
        )
        .first;
    // 0,1 sn: yalnızca iç halka.
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      tester.renderObject(rings),
      paints..circle(style: PaintingStyle.stroke),
    );
    expect(
      tester.renderObject(rings),
      isNot(
        paints
          ..circle()
          ..circle(),
      ),
    );
    // 0,5 sn: iki halka da.
    await tester.pump(const Duration(milliseconds: 400));
    expect(
      tester.renderObject(rings),
      paints
        ..circle()
        ..circle(),
    );
    await tester.pumpAndSettle();
    tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
  });
}

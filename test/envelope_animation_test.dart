import 'package:bende_var/core/theme/app_colors.dart';
import 'package:bende_var/core/theme/app_motion.dart';
import 'package:bende_var/core/widgets/envelope_animation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import 'test_helpers.dart';

Finder get _rings => find.byKey(const Key('envelope-rings'));
Finder get _body => find.byKey(const Key('envelope-body'));

double _pulse(WidgetTester tester) => tester
    .widget<Transform>(find.byKey(const Key('envelope-pulse')))
    .transform
    .getMaxScaleOnAxis();

Future<void> _pumpAnimated(WidgetTester tester, {ThemeMode? theme}) async {
  useAndroidScreen(tester);
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures();
  // Test başarısız olsa da ayar her durumda geri alınır.
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  await tester.pumpWidget(
    wrap(
      const Center(child: EnvelopeAnimation()),
      theme: theme ?? ThemeMode.light,
    ),
  );
}

void main() {
  setUpAll(initTestEnv);

  test('Oranlar referans çizimden, ~160 dp', () {
    expect(EnvelopeAnimation.size, 160);
    expect(
      EnvelopeAnimation.refBodyWidth / EnvelopeAnimation.refBodyHeight,
      closeTo(3 / 2, .1),
    );
    expect(EnvelopeAnimation.refRingInner, 72);
    expect(EnvelopeAnimation.refRingOuter, 92);
    // Çizgi kalınlıkları sabit dp (ölçeklenmez).
    expect(EnvelopeAnimation.lineStroke, 3);
    expect(EnvelopeAnimation.ringStroke, 1.5);
    expect(EnvelopeAnimation.flapDepth, .5);
    expect(AppMotion.envelopeSeconds, inInclusiveRange(1.2, 1.5));
  });

  test('Renkler belgedeki rollerle; halkalar yaklaşık istenen tonlar', () {
    const l = AppColors.light;
    const d = AppColors.dark;
    expect(l.envelopeLine, l.navPillIcon);
    expect(l.envelopeSurface, l.card);
    expect(d.envelopeLine, d.navLogoBg);
    expect(d.envelopeSurface, d.card);
    expect(l.envelopeRingInner, const Color(0xFFB8C6DE));
    expect(l.envelopeRingOuter, const Color(0xFFD5DEEE));
    expect(d.envelopeRingInner, const Color(0xFF3A4A85));
    expect(d.envelopeRingOuter, const Color(0xFF2A3560));
    // Açıkta dış halka daha açık, koyuda dış halka daha koyu.
    expect(
      l.envelopeRingOuter.computeLuminance(),
      greaterThan(l.envelopeRingInner.computeLuminance()),
    );
    expect(
      d.envelopeRingOuter.computeLuminance(),
      lessThan(d.envelopeRingInner.computeLuminance()),
    );
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('Son hâl: iki ince halka, kapalı zarf, tik ve mektup yok '
        '(${mode.name})', (tester) async {
      useAndroidScreen(tester); // azaltılmış: son hâl, statik
      await tester.pumpWidget(
        wrap(const Center(child: EnvelopeAnimation()), theme: mode),
      );
      final colors = mode == ThemeMode.dark ? AppColors.dark : AppColors.light;
      expect(
        tester.renderObject(_rings),
        paints
          ..circle(
            color: colors.envelopeRingInner,
            style: PaintingStyle.stroke,
            strokeWidth: EnvelopeAnimation.ringStroke,
          )
          ..circle(
            color: colors.envelopeRingOuter,
            style: PaintingStyle.stroke,
            strokeWidth: EnvelopeAnimation.ringStroke,
          ),
      );
      // Gövde: yüzey dolgu + çizgi; kapak V'si aynı çizgi.
      expect(
        tester.renderObject(_body),
        paints
          ..path(color: colors.envelopeSurface, style: PaintingStyle.fill)
          ..path(
            color: colors.envelopeLine,
            style: PaintingStyle.stroke,
            strokeWidth: EnvelopeAnimation.lineStroke,
          )
          ..path(
            color: colors.envelopeLine,
            style: PaintingStyle.stroke,
            strokeWidth: EnvelopeAnimation.lineStroke,
          ),
      );
      expect(find.byIcon(LucideIcons.check), findsNothing);
      expect(_pulse(tester), closeTo(1, 1e-9));
      // Amblem ~160 dp; yerleşim kutusu önceki gibi 184 dp (dikey yer aynı).
      expect(tester.getSize(_rings), const Size.square(EnvelopeAnimation.size));
      expect(
        tester.getSize(find.byType(EnvelopeAnimation)),
        const Size.square(EnvelopeAnimation.slot),
      );
      expect(EnvelopeAnimation.slot, 184);
    });
  }

  testWidgets('Akış: halkalar içten dışa, gövde, sonra kapak; vurgu ve durur', (
    tester,
  ) async {
    await _pumpAnimated(tester);
    // 0,1 sn: yalnızca iç halka, zarf henüz çizilmedi.
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.renderObject(_rings), paints..circle());
    expect(
      tester.renderObject(_rings),
      isNot(
        paints
          ..circle()
          ..circle(),
      ),
    );
    expect(tester.renderObject(_body), isNot(paints..path()));

    // 0,5 sn: iki halka; gövde çiziliyor (dolgu + kısmi çizgi), kapak yok.
    await tester.pump(const Duration(milliseconds: 400));
    expect(
      tester.renderObject(_rings),
      paints
        ..circle()
        ..circle(),
    );
    expect(
      tester.renderObject(_body),
      paints
        ..path()
        ..path(),
    );
    expect(
      tester.renderObject(_body),
      isNot(
        paints
          ..path()
          ..path()
          ..path(),
      ),
    );

    // 0,95 sn: kapak V'si de çiziliyor.
    await tester.pump(const Duration(milliseconds: 450));
    expect(
      tester.renderObject(_body),
      paints
        ..path()
        ..path()
        ..path(),
    );

    // ~1,22 sn: hafif ölçek vurgusu (1 < s ≤ 1,04).
    await tester.pump(const Duration(milliseconds: 270));
    expect(_pulse(tester), greaterThan(1));
    expect(_pulse(tester), lessThanOrEqualTo(AppMotion.envelopePulseScale));

    // Giriş bitince zarf 1'e döner ve sabit kalır.
    await tester.pump(const Duration(milliseconds: 300));
    expect(_pulse(tester), closeTo(1, 1e-9));
    expect(tester.takeException(), isNull);
    // Halkalar nefes almaya devam ettiği için sayfayı kapat (dispose).
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Giriş bitince halkalar sürekli nefes alır, zarf sabit; '
      'kapanınca durur', (tester) async {
    await _pumpAnimated(tester);
    await tester.pump(const Duration(milliseconds: 1500)); // giriş bitti
    expect(tester.binding.transientCallbackCount, greaterThan(0));

    List<double> radii() {
      final rec = _CircleRecorder();
      tester
          .renderObject<RenderCustomPaint>(_rings)
          .painter!
          .paint(rec, const Size.square(EnvelopeAnimation.size));
      return rec.radii;
    }

    double alpha0() {
      final rec = _CircleRecorder();
      tester
          .renderObject<RenderCustomPaint>(_rings)
          .painter!
          .paint(rec, const Size.square(EnvelopeAnimation.size));
      return rec.alphas.first;
    }

    final r0 = radii();
    final a0 = alpha0();
    await tester.pump(AppMotion.envelopeBreath * .25);
    final r1 = radii();
    final a1 = alpha0();
    // İç halka büyüdü ve soldu; dış halka (faz farkı) ters yönde.
    expect(r1[0], greaterThan(r0[0]));
    expect(a1, lessThan(a0));
    expect(r1[1], lessThan(r0[1]));
    // Ölçek sınırı: en fazla %4.
    const innerMax =
        (EnvelopeAnimation.refRingInner * EnvelopeAnimation.scale -
            EnvelopeAnimation.ringStroke) /
        2 *
        AppMotion.envelopeBreathScale;
    await tester.pump(AppMotion.envelopeBreath * .25);
    expect(radii()[0], lessThanOrEqualTo(innerMax + 1e-6));
    // Zarf sabit.
    expect(_pulse(tester), closeTo(1, 1e-9));

    // Sayfa kapanınca sürekli animasyon durur (sızıntı yok).
    await tester.pumpWidget(const SizedBox());
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('Animasyonları azalt: sürekli animasyon yok, halkalar statik', (
    tester,
  ) async {
    useAndroidScreen(tester); // azaltılmış
    await tester.pumpWidget(wrap(const Center(child: EnvelopeAnimation())));
    await tester.pump();
    expect(tester.binding.transientCallbackCount, 0);
    expect(tester.binding.hasScheduledFrame, isFalse);
    await tester.pump(const Duration(seconds: 3));
    expect(tester.binding.transientCallbackCount, 0);
  });
}

/// drawCircle çağrılarını (yarıçap, opaklık) kaydeden basit tuval.
class _CircleRecorder implements Canvas {
  final radii = <double>[];
  final alphas = <double>[];

  @override
  void drawCircle(Offset c, double radius, Paint paint) {
    radii.add(radius);
    alphas.add(paint.color.a);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

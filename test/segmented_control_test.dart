import 'dart:ui' show Tristate;

import 'package:bende_var/core/theme/app_colors.dart';
import 'package:bende_var/core/theme/app_spacing.dart';
import 'package:bende_var/core/widgets/app_segmented_control.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'test_helpers.dart';

const _labels = ['Açık', 'Okula özel', 'Gizli'];

class _Host extends StatefulWidget {
  const _Host({this.initial = 0});
  final int initial;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late int value = widget.initial;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppSpacing.screen),
    child: AppSegmentedControl<int>(
      value: value,
      onChanged: (v) => setState(() => value = v),
      segments: [
        for (final (i, label) in _labels.indexed)
          AppSegment(value: i, label: label, key: Key('seg-$i')),
      ],
    ),
  );
}

Rect _rect(WidgetTester tester, Finder f) =>
    tester.getTopLeft(f) & tester.getSize(f);

void main() {
  setUpAll(initTestEnv);

  testWidgets('üç segment eşit boyda, en az 48; dolgu kabın içinde', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const _Host()));
    final rects = [
      for (var i = 0; i < 3; i++) _rect(tester, find.byKey(Key('seg-$i'))),
    ];
    for (final r in rects) {
      expect(r.height, greaterThanOrEqualTo(AppSizes.tapTarget));
      expect(r.height, rects.first.height);
      expect(r.width, closeTo(rects.first.width, 0.01));
    }
    // Tek dış kap: segmentlerin hepsi onun içinde.
    final box = _rect(tester, find.byType(AppSegmentedControl<int>));
    for (final r in rects) {
      expect(box.contains(r.topLeft), isTrue);
      expect(box.contains(r.bottomRight - const Offset(1, 1)), isTrue);
    }
    // Seçili dolgu, seçili segmentle aynı boyda ve konumda.
    final ind = _rect(tester, find.byKey(const Key('segment-indicator')));
    expect(ind.height, rects[0].height);
    expect(ind.width, closeTo(rects[0].width, 0.01));
    expect(ind.center.dx, closeTo(rects[0].center.dx, 0.01));
    expect(ind.center.dy, closeTo(rects[0].center.dy, 0.01));
  });

  testWidgets('seçim değişince dolgu kayar, seçili durumu değişir', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(wrap(const _Host()));
    bool selected(int i) =>
        tester
            .getSemantics(find.byKey(Key('seg-$i')))
            .flagsCollection
            .isSelected ==
        Tristate.isTrue;
    expect([for (var i = 0; i < 3; i++) selected(i)], [true, false, false]);

    final start = _rect(tester, find.byKey(const Key('segment-indicator')));
    await tester.tap(find.byKey(const Key('seg-2')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    final mid = _rect(tester, find.byKey(const Key('segment-indicator')));
    final target = _rect(tester, find.byKey(const Key('seg-2')));
    expect(mid.center.dx, greaterThan(start.center.dx));
    expect(mid.center.dx, lessThan(target.center.dx));
    await tester.pumpAndSettle();
    final end = _rect(tester, find.byKey(const Key('segment-indicator')));
    expect(end.center.dx, closeTo(target.center.dx, 0.01));
    expect([for (var i = 0; i < 3; i++) selected(i)], [false, false, true]);
    handle.dispose();
  });

  testWidgets('animasyonları azalt açıkken dolgu anında geçer', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(wrap(const _Host()));
    await tester.tap(find.byKey(const Key('seg-1')));
    await tester.pump();
    final ind = _rect(tester, find.byKey(const Key('segment-indicator')));
    final seg = _rect(tester, find.byKey(const Key('seg-1')));
    expect(ind.center.dx, closeTo(seg.center.dx, 0.01));
  });

  for (final (name, w, scale) in [
    ('412 dp', 412.0, 1.0),
    ('320 dp, büyük yazı', 320.0, 2.0),
  ]) {
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('Okula özel tek satır, taşma yok: $name ${theme.name}', (
        tester,
      ) async {
        tester.view.physicalSize = Size(w * 2, 1200);
        tester.view.devicePixelRatio = 2;
        addTearDown(tester.view.reset);
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(wrap(const _Host(initial: 1), theme: theme));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Her etiket tek satır: yüksekliği tek satırı (≈ yazı boyu × 1,5) geçmez.
        for (final label in _labels) {
          final t = find.text(label);
          final text = tester.widget<Text>(t);
          expect(text.maxLines, 1);
          expect(text.softWrap, isFalse);
          expect(tester.getSize(t).height, lessThan(28 * scale));
        }
        // Etiket kutusu (FittedBox) segmentin dışına taşmaz; sığmayan yazı
        // küçülür, kırılmaz.
        for (var i = 0; i < 3; i++) {
          final seg = _rect(tester, find.byKey(Key('seg-$i')));
          final box = _rect(
            tester,
            find.descendant(
              of: find.byKey(Key('seg-$i')),
              matching: find.byType(FittedBox),
            ),
          );
          expect(box.left, greaterThanOrEqualTo(seg.left - 0.01));
          expect(box.right, lessThanOrEqualTo(seg.right + 0.01));
        }

        // Temaya göre doğru renkler: seçili dolgu infoBg, çerçeve primary.
        final colors = theme == ThemeMode.dark
            ? AppColors.dark
            : AppColors.light;
        final deco =
            tester
                    .widget<DecoratedBox>(
                      find.byKey(const Key('segment-indicator')),
                    )
                    .decoration
                as BoxDecoration;
        expect(deco.color, colors.infoBg);
        expect((deco.border as Border).top.color, colors.primary);
        expect(
          tester.widget<Text>(find.text('Okula özel')).style!.color,
          colors.primary,
        );
        expect(
          tester.widget<Text>(find.text('Açık')).style!.color,
          colors.textSecondary,
        );
      });
    }
  }
}

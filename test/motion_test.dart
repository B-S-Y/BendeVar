import 'package:bende_var/core/theme/app_motion.dart';
import 'package:bende_var/core/theme/app_theme.dart';
import 'package:bende_var/core/widgets/app_buttons.dart';
import 'package:bende_var/core/widgets/app_entrance.dart';
import 'package:bende_var/core/widgets/app_text_field.dart';
import 'package:bende_var/core/widgets/shake_on_error.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'test_helpers.dart';

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: Center(child: child)),
);

double _shakeDx(WidgetTester tester) => tester
    .widget<Transform>(
      find.descendant(
        of: find.byType(ShakeOnError),
        matching: find.byType(Transform),
      ),
    )
    .transform
    .getTranslation()
    .x;

double _scale(WidgetTester tester) => tester
    .widget<AnimatedScale>(
      find.descendant(
        of: find.byType(PrimaryButton),
        matching: find.byType(AnimatedScale),
      ),
    )
    .scale;

void main() {
  setUpAll(initTestEnv);

  testWidgets('D1: sayfa geçişi kayar ve solar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const Scaffold(body: Text('B')),
                ),
              ),
              child: const Text('git'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('git'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    final fades = tester.widgetList<FadeTransition>(
      find.ancestor(of: find.text('B'), matching: find.byType(FadeTransition)),
    );
    expect(fades.any((f) => f.opacity.value < 1), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('D2: düğme basılınca ~0,97 küçülür, bırakınca döner', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(PrimaryButton(label: 'Tamam', onPressed: () {})),
    );
    expect(_scale(tester), 1);
    final g = await tester.startGesture(tester.getCenter(find.text('Tamam')));
    await tester.pump(AppMotion.press * 2);
    expect(_scale(tester), AppMotion.pressScale);
    await g.up();
    await tester.pump(AppMotion.press * 2);
    expect(_scale(tester), 1);
  });

  testWidgets('D2: animasyonlar azaltılınca düğme küçülmez', (tester) async {
    useAndroidScreen(tester);
    await tester.pumpWidget(
      wrap(PrimaryButton(label: 'Tamam', onPressed: () {})),
    );
    final g = await tester.startGesture(tester.getCenter(find.text('Tamam')));
    await tester.pump(AppMotion.press * 2);
    expect(_scale(tester), 1);
    await g.up();
  });

  testWidgets('D3: hata gelince alan titrer, sonra yerine döner', (
    tester,
  ) async {
    Widget field(String? error, int signal) =>
        _host(AppTextField(label: 'E', errorText: error, errorSignal: signal));
    await tester.pumpWidget(field(null, 0));
    await tester.pumpWidget(field('Hata', 1));
    await tester.pump(AppMotion.shake * 0.1);
    expect(_shakeDx(tester).abs(), greaterThan(0));
    await tester.pumpAndSettle();
    expect(_shakeDx(tester), 0);
    // Aynı hata, yeni deneme sayacı: yine titrer.
    await tester.pumpWidget(field('Hata', 2));
    await tester.pump(AppMotion.shake * 0.1);
    expect(_shakeDx(tester).abs(), greaterThan(0));
    await tester.pumpAndSettle();
  });

  testWidgets('D3: animasyonlar azaltılınca alan titremez', (tester) async {
    useAndroidScreen(tester);
    Widget field(String? error) =>
        wrap(AppTextField(label: 'E', errorText: error));
    await tester.pumpWidget(field(null));
    await tester.pumpWidget(field('Hata'));
    await tester.pump(AppMotion.shake * 0.1);
    expect(_shakeDx(tester), 0);
  });

  testWidgets('D5: liste satırları sırayla gelir', (tester) async {
    await tester.pumpWidget(
      _host(
        const Column(
          children: [
            AppEntrance(index: 0, child: Text('bir')),
            AppEntrance(index: 3, child: Text('dört')),
          ],
        ),
      ),
    );
    double op(String t) => tester
        .widget<Opacity>(
          find.ancestor(of: find.text(t), matching: find.byType(Opacity)),
        )
        .opacity;
    await tester.pump();
    await tester.pump(AppMotion.listItem * 0.5);
    expect(op('bir'), greaterThan(op('dört')));
    await tester.pumpAndSettle();
    expect(op('bir'), 1);
    expect(op('dört'), 1);
  });

  testWidgets('D5: animasyonlar azaltılınca satırlar hemen görünür', (
    tester,
  ) async {
    useAndroidScreen(tester);
    await tester.pumpWidget(
      wrap(const AppEntrance(index: 5, child: Text('x'))),
    );
    final o = tester.widget<Opacity>(
      find.ancestor(of: find.text('x'), matching: find.byType(Opacity)),
    );
    expect(o.opacity, 1);
  });
}

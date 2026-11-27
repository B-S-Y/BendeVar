import 'package:bende_var/core/widgets/success_check.dart';
import 'package:bende_var/features/auth/view/signup_done_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'test_helpers.dart';

Future<void> _openDone(WidgetTester tester) async {
  GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/signup/done');
}

double _opacityOf(WidgetTester tester, Key key) => tester
    .widget<Opacity>(
      find.ancestor(of: find.byKey(key), matching: find.byType(Opacity)).first,
    )
    .opacity;

void main() {
  setUpAll(initTestEnv);

  testWidgets('Kayıt tamamlandı: metinler, panel ve Başla → Ana Sayfa', (
    tester,
  ) async {
    await pumpApp(tester); // animasyonlar azaltılmış: son kare
    await signIn(tester);
    await _openDone(tester);
    await tester.pumpAndSettle();

    expect(find.text('Hoş geldin, Elif!'), findsOneWidget);
    expect(
      find.text('Yıldız Teknik Üniversitesi topluluğuna katıldın.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'İhtiyacın topluluğunda. Elinde olanı paylaş, ihtiyacın olanı bul.',
      ),
      findsOneWidget,
    );
    expect(find.byType(SuccessCheck), findsOneWidget);
    // Azaltılmış hareket: son kare doğrudan.
    expect(_opacityOf(tester, const Key('done-title')), 1);
    expect(_opacityOf(tester, const Key('done-subtitle')), 1);
    expect(SuccessCheck.scaleAt(1), 1);

    await tester.tap(find.text('Başla'));
    await tester.pumpAndSettle();
    expect(find.byType(SignupDonePage), findsNothing);
    // Geri tuşu bu ekrana dönmez.
    final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
    expect(router.canPop(), isFalse);
  });

  testWidgets('Kayıt tamamlandı: tik sonra başlık, 0,2 sn sonra alt metin', (
    tester,
  ) async {
    await pumpApp(tester);
    await signIn(tester);
    // Animasyonları aç.
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures();
    await _openDone(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    // Başta ikisi de görünmez.
    expect(_opacityOf(tester, const Key('done-title')), 0);
    expect(_opacityOf(tester, const Key('done-subtitle')), 0);
    // Tik 1,2'ye çıkar.
    await tester.pump(const Duration(milliseconds: 300));
    final peak = tester.widget<Transform>(
      find.descendant(
        of: find.byType(SuccessCheck),
        matching: find.byType(Transform),
      ),
    );
    expect(peak.transform.getMaxScaleOnAxis(), greaterThan(1));

    // Tik bitince (≈0,56 sn) başlık gelir, alt metin ondan geri kalır.
    await tester.pump(const Duration(milliseconds: 500)); // ≈0,85 sn
    final title = _opacityOf(tester, const Key('done-title'));
    final sub = _opacityOf(tester, const Key('done-subtitle'));
    expect(title, greaterThan(0));
    expect(sub, lessThan(title));

    await tester.pump(const Duration(seconds: 2));
    expect(_opacityOf(tester, const Key('done-title')), 1);
    expect(_opacityOf(tester, const Key('done-subtitle')), 1);
    expect(
      tester
          .widget<Transform>(
            find.descendant(
              of: find.byType(SuccessCheck),
              matching: find.byType(Transform),
            ),
          )
          .transform
          .getMaxScaleOnAxis(),
      closeTo(1, 0.001),
    );
    tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
  });

  testWidgets('Kayıt tamamlandı taşmaz: 320×568, büyük yazı', (tester) async {
    await pumpApp(tester);
    await signIn(tester);
    tester.view.physicalSize = const Size(640, 1136);
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _openDone(tester);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

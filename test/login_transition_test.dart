import 'package:bende_var/core/theme/app_motion.dart';
import 'package:bende_var/features/auth/view/auth_stage.dart';
import 'package:bende_var/features/auth/viewmodel/auth_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'test_helpers.dart';

Future<void> _fillAndSubmit(WidgetTester tester) async {
  await tester.tap(find.text('Giriş yap').first);
  await tester.pumpAndSettle();
  await tester.enterText(
    find.byKey(const Key('email-field')),
    'elif@std.yildiz.edu.tr',
  );
  await tester.enterText(find.byKey(const Key('password-field')), 'sifre123');
  await tester.pump();
}

AuthViewModel _auth(WidgetTester tester) => Provider.of<AuthViewModel>(
  tester.element(find.byType(Scaffold).first),
  listen: false,
);

void main() {
  setUpAll(initTestEnv);

  testWidgets('Girişten sonra: giriş solar, Ana Sayfa %96 → %100 büyür', (
    tester,
  ) async {
    await pumpApp(tester);
    await _fillAndSubmit(tester);
    final auth = _auth(tester);
    // Animasyonları aç (azaltılmış hareketi kapat).
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures();
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Giriş yap'));
    await tester.pump(); // istek başladı
    await tester.pump(const Duration(milliseconds: 300)); // sahte gecikme bitti
    expect(auth.fadeToHome, isTrue);

    // Geçişin ortası.
    await tester.pump(AppMotion.loginToHome * 0.4);
    expect(find.textContaining('İlanlar · '), findsOneWidget);
    final scales = tester
        .widgetList<ScaleTransition>(find.byType(ScaleTransition))
        .map((s) => s.scale.value);
    expect(
      scales.any((v) => v >= AppMotion.homeScaleFrom && v < 1),
      isTrue,
      reason: 'Ana Sayfa büyüyerek gelmeli: $scales',
    );
    // Giriş ekranı hâlâ var ama soluyor.
    expect(find.byType(AuthStage), findsOneWidget);
    final fadingOut = tester
        .widgetList<FadeTransition>(
          find.ancestor(
            of: find.byType(AuthStage),
            matching: find.byType(FadeTransition),
          ),
        )
        .any((f) => f.opacity.value < 1);
    expect(fadingOut, isTrue);

    // Bitiş: giriş ekranı gitti, bayrak indi, geri tuşu girişe dönmez.
    await tester.pump(AppMotion.loginToHome);
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(AuthStage), findsNothing);
    expect(auth.fadeToHome, isFalse);
    expect(
      GoRouter.of(tester.element(find.byType(Scaffold).first)).canPop(),
      isFalse,
    );
    await tester.pump(const Duration(seconds: 1));
    tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
  });

  testWidgets('Animasyonları azalt açıkken efekt yok, doğrudan geçer', (
    tester,
  ) async {
    await pumpApp(tester); // azaltılmış hareket
    await _fillAndSubmit(tester);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Giriş yap'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(); // geçiş ~0 sürede biter (azaltılmış hareket)
    expect(find.byType(AuthStage), findsNothing);
    expect(find.textContaining('İlanlar · '), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 50));
    expect(_auth(tester).fadeToHome, isFalse);
    await tester.pump(const Duration(seconds: 1));
  });
}

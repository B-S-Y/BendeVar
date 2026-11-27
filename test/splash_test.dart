import 'package:bende_var/app/di.dart';
import 'package:bende_var/core/theme/app_motion.dart';
import 'package:bende_var/data/mock/mock_repositories.dart';
import 'package:bende_var/data/models/models.dart';
import 'package:bende_var/features/auth/view/auth_stage.dart';
import 'package:bende_var/features/auth/view/splash_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'test_helpers.dart';

const _remembered = {MockAuthRepository.rememberKey: 'elif@std.yildiz.edu.tr'};
const _brand = Key('splash-brand');

/// Oturum kontrolü [delay] sürer (yavaş disk).
class _SlowRestoreAuth extends MockAuthRepository {
  _SlowRestoreAuth(this.delay);
  final Duration delay;

  @override
  Future<AppUser?> restoreSession() async {
    await Future<void>.delayed(delay);
    return super.restoreSession();
  }
}

bool _onHome(WidgetTester tester) =>
    find.textContaining('İlanlar · ').evaluate().isNotEmpty;

void main() {
  setUpAll(initTestEnv);

  testWidgets('Hatırlanan oturum: kısa açılış, sonra solma ile Ana Sayfa', (
    tester,
  ) async {
    await pumpApp(tester, prefsValues: _remembered, animations: true);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(SplashPage), findsOneWidget);
    expect(find.byKey(_brand), findsOneWidget); // oturum var: logo + ad
    expect(_onHome(tester), isFalse);

    // Süre dolmadan Ana Sayfa yok (~0,9 sn).
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.byType(SplashPage), findsOneWidget);
    expect(_onHome(tester), isFalse);

    // ~1,2 sn: geçiş başlar; açılış solarken Ana Sayfa büyüyerek gelir.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 100));
    expect(_onHome(tester), isTrue);
    expect(find.byType(SplashPage), findsOneWidget);
    final scales = tester
        .widgetList<ScaleTransition>(find.byType(ScaleTransition))
        .map((s) => s.scale.value);
    expect(scales.any((v) => v >= AppMotion.homeScaleFrom && v < 1), isTrue);

    await tester.pump(AppMotion.loginToHome);
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(SplashPage), findsNothing);
    expect(
      GoRouter.of(tester.element(find.byType(Scaffold).first)).canPop(),
      isFalse,
    );
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('Oturum yok: bekletmeden Karşılama, logo/ad hiç görünmez', (
    tester,
  ) async {
    await pumpApp(tester, animations: true);
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byKey(_brand), findsNothing);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(SplashPage), findsNothing);
    expect(find.byType(AuthStage), findsOneWidget);
    expect(find.text('Giriş yap'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5)); // tam karşılama animasyonu
  });

  testWidgets('Animasyonları azalt: açılış atlanır, doğrudan Ana Sayfa', (
    tester,
  ) async {
    await pumpApp(tester, prefsValues: _remembered); // azaltılmış hareket
    expect(find.byType(SplashPage), findsNothing);
    expect(find.byKey(_brand), findsNothing);
    expect(_onHome(tester), isTrue);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets(
    'Kontrol 1,2 sn\'den uzun sürerse animasyon bitince hemen geçer',
    (tester) async {
      await pumpApp(
        tester,
        prefsValues: _remembered,
        animations: true,
        deps: AppDependencies(
          auth: _SlowRestoreAuth(const Duration(seconds: 2)),
        ),
      );
      await tester.pump(const Duration(milliseconds: 1500));
      // Kontrol sürüyor: animasyon bitti ama oturum bilinmiyor → logo yok.
      expect(find.byKey(_brand), findsNothing);
      expect(_onHome(tester), isFalse);

      // Kontrol ~2 sn'de bitti: ekstra 1,2 sn beklemeden geçiş başlar.
      await tester.pump(const Duration(milliseconds: 600)); // 2,1 sn
      await tester.pump(const Duration(milliseconds: 300)); // 2,4 sn
      expect(_onHome(tester), isTrue);
      await tester.pump(AppMotion.loginToHome);
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(SplashPage), findsNothing);
      await tester.pump(const Duration(seconds: 1));
    },
  );
}

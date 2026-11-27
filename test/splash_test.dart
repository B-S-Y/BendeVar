import 'package:bende_var/app/di.dart';
import 'package:bende_var/core/theme/app_motion.dart';
import 'package:bende_var/data/mock/mock_repositories.dart';
import 'package:bende_var/data/models/models.dart';
import 'package:bende_var/features/auth/view/auth_burst.dart';
import 'package:bende_var/features/auth/view/auth_motion.dart';
import 'package:bende_var/features/auth/view/auth_stage.dart';
import 'package:bende_var/features/auth/view/splash_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'test_helpers.dart';

const _remembered = {MockAuthRepository.rememberKey: 'elif@std.yildiz.edu.tr'};
const _brand = Key('splash-brand');
const _rings = Key('splash-rings');

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

double _introT(WidgetTester tester) =>
    (tester.widget<CustomPaint>(find.byKey(_rings)).painter! as BurstPainter)
        .intro
        .value;

double _opacity(WidgetTester tester, Key key) {
  final w = tester.widget(find.byKey(key));
  if (w is Opacity) return w.opacity;
  return tester
      .widget<Opacity>(
        find
            .ancestor(of: find.byKey(key), matching: find.byType(Opacity))
            .first,
      )
      .opacity;
}

void main() {
  setUpAll(initTestEnv);

  test('Süre karşılama zaman çizelgesinden: halka 2 bitişi, en az 2 sn', () {
    final seconds =
        AppMotion.splash.inMicroseconds / Duration.microsecondsPerSecond;
    expect(seconds, greaterThanOrEqualTo(2));
    expect(seconds, closeTo(AuthMotion.ring2.$2, 1e-9));
    expect(AppMotion.splashReduced, const Duration(milliseconds: 600));
  });

  testWidgets('Hatırlanan oturum: tam logo girişi (~2,4 sn), sonra solma', (
    tester,
  ) async {
    await pumpApp(tester, prefsValues: _remembered, animations: true);
    // İlk kare: zaman henüz başlamadı.
    expect(find.byType(SplashPage), findsOneWidget);
    await tester.pump(); // ilk kareden sonra başlar
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(_rings), findsOneWidget);
    expect(_introT(tester), greaterThan(0));
    // Karşılamadaki gibi: logo küçükten büyür, ad sonra gelir.
    expect(_opacity(tester, const Key('splash-logo')), greaterThan(0));
    expect(_opacity(tester, _brand), 0);

    // Oturum çoktan geri yüklendi ama 2 sn'de hâlâ açılış.
    await tester.pump(const Duration(milliseconds: 1900));
    expect(find.byType(SplashPage), findsOneWidget);
    expect(_onHome(tester), isFalse);
    expect(_opacity(tester, _brand), 1); // ad 1,52 sn'de tam görünür

    // ~2,4 sn: animasyon bitti → solma + büyüme ile Ana Sayfa.
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pump(const Duration(milliseconds: 100));
    expect(_onHome(tester), isTrue);
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

  testWidgets('Halkalar karşılamadakiyle aynı ressam, parçacıksız, çizilir', (
    tester,
  ) async {
    await pumpApp(tester, prefsValues: _remembered, animations: true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    final painter =
        tester.widget<CustomPaint>(find.byKey(_rings)).painter! as BurstPainter;
    expect(painter.particles, isFalse);
    expect(
      tester.renderObject(find.byKey(_rings)),
      paints..circle(style: PaintingStyle.stroke),
    );
    await tester.pump(const Duration(seconds: 4));
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

  testWidgets(
    'Animasyonları azalt: kısa (~600 ms) ve statik, sonra Ana Sayfa',
    (tester) async {
      await pumpApp(tester, prefsValues: _remembered, settle: false);
      await tester.pump(); // ilk kare
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(SplashPage), findsOneWidget);
      expect(find.byKey(_rings), findsNothing); // statik: halka yok
      expect(_opacity(tester, const Key('splash-logo')), 1); // son kare
      expect(_opacity(tester, _brand), 1);
      expect(_onHome(tester), isFalse);
      await tester.pump(const Duration(milliseconds: 400)); // ~700 ms
      await tester.pumpAndSettle();
      expect(_onHome(tester), isTrue);
      expect(find.byType(SplashPage), findsNothing);
      await tester.pump(const Duration(seconds: 1));
    },
  );

  testWidgets("Kontrol 2,4 sn'den uzun sürerse animasyon bitince hemen geçer", (
    tester,
  ) async {
    await pumpApp(
      tester,
      prefsValues: _remembered,
      animations: true,
      deps: AppDependencies(auth: _SlowRestoreAuth(const Duration(seconds: 3))),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2700));
    // Animasyon bitti ama oturum bilinmiyor → logo yok, bekle.
    expect(find.byKey(_brand), findsNothing);
    expect(_onHome(tester), isFalse);

    // Kontrol ~3 sn'de bitti: ekstra bekleme olmadan geçiş başlar.
    await tester.pump(const Duration(milliseconds: 400)); // 3,1 sn
    await tester.pump(const Duration(milliseconds: 200));
    expect(_onHome(tester), isTrue);
    await tester.pump(AppMotion.loginToHome);
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(SplashPage), findsNothing);
    await tester.pump(const Duration(seconds: 1));
  });
}

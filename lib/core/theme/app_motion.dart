import 'package:material_ui/material_ui.dart';

/// Ortak hareket token'ları: süre, eğri, ölçü. "Animasyonları azalt" açıksa
/// bunlar kullanılmaz ([reduce]).
abstract final class AppMotion {
  /// Düğme basılma efekti.
  static const Duration press = Duration(milliseconds: 100);
  static const double pressScale = 0.97;

  /// Sayfa geçişi (hafif kayma + solma).
  static const Duration page = Duration(milliseconds: 280);
  static const double pageSlide = 0.06;

  /// Giriş başarılı olunca Ana Sayfa'ya geçiş: giriş ekranı solar, Ana Sayfa
  /// %96'dan %100'e büyüyerek belirir.
  static const Duration loginToHome = Duration(milliseconds: 450);
  static const double homeScaleFrom = .96;

  /// Kısa açılış ("Beni hatırla" ile açılan oturum): karşılamadaki logo
  /// girişinin aynısı, gerçek hızda; karşılama zaman çizelgesinin halka 2'nin
  /// bitişine kadarki kısmı (logo 0–1,04 sn, ad 0,96–1,52 sn, halkalar
  /// 0,64–2,40 sn; bkz. AuthMotion). Süre ilk kareden sonra başlar.
  static const Duration splash = Duration(milliseconds: 2400);

  /// "Animasyonları azalt" açıkken kısa, statik açılış.
  static const Duration splashReduced = Duration(milliseconds: 600);

  /// Kayıtta okul kartı: yazma durduktan bu kadar sonra okul aranır (kart
  /// yazarken çıkmaz).
  static const Duration schoolLookupDelay = Duration(milliseconds: 500);

  /// Hatalı alanın sağa sola titremesi.
  static const Duration shake = Duration(milliseconds: 360);
  static const double shakeDistance = 6;
  static const int shakeCycles = 3;

  /// Liste girişleri: her satır sırayla yukarı kayarak gelir.
  static const Duration listItem = Duration(milliseconds: 320);
  static const Duration listStagger = Duration(milliseconds: 45);
  static const int listStaggerMax = 8;
  static const double listSlide = 12;

  /// Başarı tiki (kayıt tamamlandı): ölçek 0 → [successOvershoot] → 1.
  static const Duration check = Duration(milliseconds: 600);
  static const double successPopSeconds = .32;
  static const double successSettleSeconds = .24;
  static const double successOvershoot = 1.2;

  /// "Bağlantıyı gönderdik" amblemi (sade kapalı zarf + iki halka), sn.
  /// Halkalar içeriden dışarı belirir, gövde çizilir, kapak V'si çizilir,
  /// sonda hafif ölçek vurgusu.
  static const double envelopeSeconds = 1.4;
  static const (double, double) envelopeRingInner = (0, .30);
  static const (double, double) envelopeRingOuter = (.15, .45);
  static const (double, double) envelopeBodyDraw = (.25, .80);
  static const (double, double) envelopeFlapDraw = (.80, 1.05);
  static const (double, double) envelopePulse = (1.05, 1.40);
  static const double envelopeRingScaleFrom = .9;
  static const double envelopePulseScale = 1.04;

  /// Giriş bittikten sonra halkaların sürekli "nefes alması": yavaş döngü,
  /// ölçek 1 ↔ [envelopeBreathScale], opaklık en fazla [envelopeBreathFade]
  /// kadar azalır; iki halka arasında [envelopeBreathPhase] (döngü kesri) faz
  /// farkı. Zarf sabit kalır.
  static const Duration envelopeBreath = Duration(milliseconds: 2800);
  static const double envelopeBreathScale = 1.04;
  static const double envelopeBreathFade = .3;
  static const double envelopeBreathPhase = .5;

  /// Kısa ipucunun ekranda kalma süresi ve belirme/kaybolma süresi.
  static const Duration hintVisible = Duration(seconds: 4);
  static const Duration hintFade = Duration(milliseconds: 200);

  /// Sheet içinde bölüm girip çıkması (kurucu işlemleri: davet kodu, açıklama).
  static const Duration sheetContent = Duration(milliseconds: 220);

  static const Curve standard = Curves.easeOutCubic;

  static bool reduce(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);
}

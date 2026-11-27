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

  /// Hatalı alanın sağa sola titremesi.
  static const Duration shake = Duration(milliseconds: 360);
  static const double shakeDistance = 6;
  static const int shakeCycles = 3;

  /// Liste girişleri: her satır sırayla yukarı kayarak gelir.
  static const Duration listItem = Duration(milliseconds: 320);
  static const Duration listStagger = Duration(milliseconds: 45);
  static const int listStaggerMax = 8;
  static const double listSlide = 12;

  /// Başarı tiki.
  static const Duration check = Duration(milliseconds: 600);

  /// Kısa ipucunun ekranda kalma süresi ve belirme/kaybolma süresi.
  static const Duration hintVisible = Duration(seconds: 4);
  static const Duration hintFade = Duration(milliseconds: 200);

  static const Curve standard = Curves.easeOutCubic;

  static bool reduce(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);
}

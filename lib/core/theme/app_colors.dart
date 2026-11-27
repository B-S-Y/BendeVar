import 'package:material_ui/material_ui.dart';

/// Bende Var renk token'ları (docs/STIL_STANDARTLARI.md, "Gece Yarısı").
/// Tek renk kaynağı: `Color(0x...)` ve `Colors.xxx` yalnızca bu dosyada geçer.
/// Widget'lar renge `context.colors` ile erişir; açık/koyu ayrımını tema yapar.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.primaryPressed,
    required this.onPrimary,
    required this.accent,
    required this.background,
    required this.card,
    required this.sheet,
    required this.textPrimary,
    required this.textSecondary,
    required this.silver,
    required this.fieldBorder,
    required this.divider,
    required this.cardBorder,
    required this.disabledBg,
    required this.disabledFg,
    required this.secondaryFg,
    required this.secondaryBorder,
    required this.secondaryPressedBg,
    required this.hero,
    required this.onHero,
    required this.onHeroMuted,
    required this.heroTop,
    required this.heroBlue,
    required this.heroSilver,
    required this.heroDeep,
    required this.envelopeFront,
    required this.appBar,
    required this.onAppBar,
    required this.appBarFieldFill,
    required this.appBarFieldBorder,
    required this.infoFg,
    required this.infoBg,
    required this.successFg,
    required this.successBg,
    required this.warningFg,
    required this.warningBg,
    required this.errorFg,
    required this.errorBg,
    required this.navBg,
    required this.navPill,
    required this.navPillIcon,
    required this.navIcon,
    required this.navLogoBg,
    required this.navLogoFg,
    required this.badge,
    required this.onBadge,
    required this.scrim,
    required this.shadow,
    required this.unreadTint,
  });

  // Birincil düğme ve lacivert alanlar
  final Color primary;
  final Color primaryPressed;
  final Color onPrimary;
  final Color accent; // vurgu mavisi: metin bağlantısı, odak halkası

  // Yüzeyler
  final Color background; // sayfa arka planı
  final Color card; // kart, alan, alt sayfa
  final Color sheet; // karşılama / giriş alt paneli
  final Color textPrimary;
  final Color textSecondary;
  final Color silver; // pasif ikon, süs
  final Color fieldBorder;
  final Color divider;
  final Color cardBorder;

  // Pasif düğme / yer tutucu zemin
  final Color disabledBg;
  final Color disabledFg;

  // İkincil ve tehlikeli düğme
  final Color secondaryFg;
  final Color secondaryBorder;
  final Color secondaryPressedBg;

  // Karşılama / giriş üst zemin
  final Color hero;
  final Color onHero;
  final Color onHeroMuted;
  final Color heroTop; // zemin gradyanının üst ucu (ANIMASYON_1.01.md)
  final Color heroBlue; // halka 1, parçacık, leke
  final Color heroSilver; // halka 2, parçacık
  final Color heroDeep; // parçacık
  final Color envelopeFront; // 1.09 zarfın ön yüzü

  // Üst bar
  final Color appBar;
  final Color onAppBar;
  final Color appBarFieldFill;
  final Color appBarFieldBorder;

  // Durum renkleri
  final Color infoFg;
  final Color infoBg;
  final Color successFg;
  final Color successBg;
  final Color warningFg;
  final Color warningBg;
  final Color errorFg;
  final Color errorBg;

  // Alt menü
  final Color navBg;
  final Color navPill;
  final Color navPillIcon;
  final Color navIcon;
  final Color navLogoBg;
  final Color navLogoFg;
  final Color badge;
  final Color onBadge;

  // Katmanlar
  final Color scrim;
  final Color shadow;
  final Color unreadTint; // okunmamış satır zemini

  static const Color _white = Color(0xFFFFFFFF);

  /// assets/logo.svg içindeki özgün renkler (AppLogo bunları tema rengiyle değiştirir).
  static const Color logoSourceTile = Color(0xFF0D1B4C);
  static const Color logoSourceGlyph = Color(0xFFFFFFFF);

  static const AppColors light = AppColors(
    primary: Color(0xFF0B1D45),
    primaryPressed: Color(0xFF06112B),
    onPrimary: _white,
    accent: Color(0xFF2F5FC4),
    background: Color(0xFFEEF1F6),
    card: _white,
    sheet: Color(0xFFEEF1F6),
    textPrimary: Color(0xFF0B1220),
    textSecondary: Color(0xFF4A5468),
    silver: Color(0xFFA9B2C2),
    fieldBorder: Color(0xFF7D879A),
    divider: Color(0xFFA9B2C2),
    cardBorder: Color(0xFFE1E5EC),
    disabledBg: Color(0xFFE1E5EC),
    disabledFg: Color(0xFF8A93A3),
    secondaryFg: Color(0xFF0B1D45),
    secondaryBorder: Color(0xFF0B1D45),
    secondaryPressedBg: Color(0xFFEEF1F6),
    hero: Color(0xFF0B1D45),
    onHero: _white,
    onHeroMuted: Color(0xFFD5DCEB),
    heroTop: Color(0xFF06112B),
    heroBlue: Color(0xFF5B8CFF),
    heroSilver: Color(0xFFA9B2C2),
    heroDeep: Color(0xFF2F5FC4),
    envelopeFront: Color(0xFF163066),
    appBar: Color(0xFF0B1D45),
    onAppBar: _white,
    appBarFieldFill: Color(0x1AFFFFFF),
    appBarFieldBorder: Color(0x33FFFFFF),
    infoFg: Color(0xFF1B4A8A),
    infoBg: Color(0xFFE3EEFB),
    successFg: Color(0xFF17643A),
    successBg: Color(0xFFDDF3E6),
    warningFg: Color(0xFF7A4300),
    warningBg: Color(0xFFFCEBD3),
    errorFg: Color(0xFFA21C1C),
    errorBg: Color(0xFFFBE1E1),
    navBg: _white,
    navPill: Color(0xFFE3EEFB),
    navPillIcon: Color(0xFF0B1D45),
    navIcon: Color(0xFF4A5468),
    navLogoBg: Color(0xFF0B1D45),
    navLogoFg: _white,
    badge: Color(0xFFB3261E),
    onBadge: _white,
    scrim: Color(0x990B1220),
    shadow: Color(0xFF0B1D45),
    unreadTint: Color(0xFFF3F7FE),
  );

  static const AppColors dark = AppColors(
    primary: Color(0xFF8FB0F0),
    // TODO(koyu-tema): belgede yok, geçici
    primaryPressed: Color(0xFF7699DB),
    onPrimary: Color(0xFF0A1226),
    accent: Color(0xFF5B8CFF),
    background: Color(0xFF0A1226),
    card: Color(0xFF141D35),
    sheet: Color(0xFF141D35),
    textPrimary: Color(0xFFE8ECF4),
    textSecondary: Color(0xFF9AA6BC),
    // TODO(koyu-tema): belgede yok, geçici (pasif ikon / süs)
    silver: Color(0xFF6E7A93),
    fieldBorder: Color(0xFF6E7A93),
    divider: Color(0xFF2A3552),
    cardBorder: Color(0xFF243052),
    disabledBg: Color(0xFF1C2540),
    disabledFg: Color(0xFF6B7691),
    // TODO(koyu-tema): belgede yok, geçici (ikincil düğme yazı + kenar)
    secondaryFg: Color(0xFFE8ECF4),
    secondaryBorder: Color(0xFF8FB0F0),
    // TODO(koyu-tema): belgede yok, geçici
    secondaryPressedBg: Color(0xFF1C2540),
    // TODO(koyu-tema): belgede yok, geçici (karşılama zemini = koyu zemin)
    hero: Color(0xFF0A1226),
    onHero: Color(0xFFE8ECF4),
    onHeroMuted: Color(0xFF9AA6BC),
    // TODO(koyu-tema): belgede yok, geçici (animasyon zemini ve parçacıklar)
    heroTop: Color(0xFF050A18),
    heroBlue: Color(0xFF5B8CFF),
    heroSilver: Color(0xFFA9B2C2),
    heroDeep: Color(0xFF2F5FC4),
    // TODO(koyu-tema): belgede yok, geçici (1.09 zarf ön yüzü)
    envelopeFront: Color(0xFF6F94DB),
    appBar: Color(0xFF141D35),
    onAppBar: Color(0xFFE8ECF4),
    // TODO(koyu-tema): belgede yok, geçici (üst bar içi alan)
    appBarFieldFill: Color(0xFF1C2540),
    appBarFieldBorder: Color(0xFF2A3552),
    infoFg: Color(0xFF9DC1FF),
    infoBg: Color(0xFF13284F),
    successFg: Color(0xFF7FD8A1),
    successBg: Color(0xFF10301F),
    warningFg: Color(0xFFF2C27A),
    warningBg: Color(0xFF3A2A10),
    errorFg: Color(0xFFFF9C9C),
    errorBg: Color(0xFF3D1518),
    navBg: Color(0xFF141D35),
    navPill: Color(0xFF1E3A6B),
    navPillIcon: Color(0xFFE8ECF4),
    navIcon: Color(0xFF9AA6BC),
    navLogoBg: Color(0xFF8FB0F0),
    navLogoFg: Color(0xFF0A1226),
    badge: Color(0xFFB3261E),
    onBadge: Color(0xFFFFFFFF),
    // TODO(koyu-tema): belgede yok, geçici (arka perde)
    scrim: Color(0xB3000000),
    shadow: Color(0xFF000000),
    // TODO(koyu-tema): belgede yok, geçici
    unreadTint: Color(0xFF18233F),
  );

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return t < 0.5 ? this : other;
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}

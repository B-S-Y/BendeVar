/// Boşluk ölçeği (4'lük ızgara). Ek değerler: docs/DESIGN_TOKENS_EK.md
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;

  /// Ekran yan kenar boşluğu (2.01'de 32 px = 16 dp).
  static const double screen = 16;

  // Mockup'tan ölçülen ek boşluklar (4'lük ızgara dışı; DESIGN_TOKENS_EK.md).
  /// Başlık → alt başlık (1.05, 1.07, 1.08, 1.10).
  static const double titleGap = 6;

  /// Şifre alanı → kural metni (1.07, 1.08).
  static const double hintGap = 6;

  /// Durum hapı dikey iç boşluğu (1.09 "Bekleniyor").
  static const double pillPadV = 6;

  /// Sıkı satır aralığı (1.06/1.09 alt bağlantılar, 1.08 şartlar kutusu).
  static const double compactGap = 10;

  /// "Bağlantı gönderildi" dikey yığını (1.06, 1.09).
  static const double sentGap = 14;

  /// Logo → "Bende Var" (şerit), adım noktası → etiket (kayıt adımları).
  static const double brandGap = 7;
}

/// Bileşen ölçüleri.
class AppSizes {
  const AppSizes._();

  static const double buttonHeight = 52;
  static const double buttonSmallHeight = 44;
  static const double fieldHeight = 50;
  static const double tapTarget = 48;
  static const double navHeight = 76;
  static const double navIcon = 26;
  static const double navPillWidth = 60;
  static const double navPillHeight = 44;
  static const double navLogo = 44;
  static const double iconAppBar = 22;

  /// Düğmedeki yükleniyor halkasının çizgi kalınlığı.
  static const double spinnerStroke = 2;

  /// Hata ikonunu metnin ilk satırıyla hizalayan dikey kaydırma.
  static const double errorIconNudge = 1;
  static const double iconRow = 18;
  static const double iconField = 16;
  static const double borderWidth = 1;
  static const double borderStrong = 1.5;
  static const double focusRing = 2;
  static const double thumb = 88;
  static const double avatarSm = 20;
  static const double avatar = 48;
  static const double avatarLg = 72;
  static const double logoWelcome = 104;
  static const double logoSmall = 56;
  static const double sheetHandleWidth = 40;
  static const double sheetHandleHeight = 4;
  static const double photoTile = 80;
  static const double segmentHeight = 44;
  static const double chipHeight = 40;
  static const double statusCircle = 96;
  static const double badge = 18;
  static const double radio = 24;
  static const double radioDot = 12;
  static const double dot = 8;
  static const double headerHeight = 96;
}

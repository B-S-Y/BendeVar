import 'package:material_ui/material_ui.dart';

/// Inter yazı ölçeği (STIL_STANDARTLARI.md). Renk widget'ta verilir.
class AppTypography {
  const AppTypography._();

  static const String fontFamily = 'Inter';

  static TextStyle _s(
    double size,
    double line,
    FontWeight w, {
    double? letterSpacing,
  }) => TextStyle(
    fontFamily: fontFamily,
    fontSize: size,
    height: line / size,
    fontWeight: w,
    letterSpacing: letterSpacing,
  );

  static final TextStyle brand = _s(28, 34, FontWeight.w700);
  static final TextStyle title1 = _s(22, 28, FontWeight.w700);
  static final TextStyle title2 = _s(18, 24, FontWeight.w700);
  static final TextStyle appBar = _s(16, 22, FontWeight.w600);
  static final TextStyle body = _s(15, 22, FontWeight.w400);
  static final TextStyle bodyStrong = _s(15, 22, FontWeight.w600);
  static final TextStyle bodySmall = _s(14, 21, FontWeight.w400);
  static final TextStyle label = _s(13, 18, FontWeight.w600);
  static final TextStyle caption = _s(12, 16, FontWeight.w400);
  static final TextStyle captionStrong = _s(12, 16, FontWeight.w600);
  static final TextStyle section = _s(
    11,
    14,
    FontWeight.w700,
    letterSpacing: 0.6,
  );
  static final TextStyle button = _s(15, 22, FontWeight.w600);
  static final TextStyle buttonSmall = _s(13, 18, FontWeight.w600);
  static final TextStyle link = _s(14, 21, FontWeight.w600);
}

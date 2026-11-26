import 'package:material_ui/material_ui.dart';

/// Köşe yarıçapları. Belge: düğme 12, küçük düğme 10, alan 10. Ek: DESIGN_TOKENS_EK.md
class AppRadius {
  const AppRadius._();

  static const double field = 10;
  static const double button = 12;
  static const double buttonSmall = 10;
  static const double card = 12;
  static const double cardLarge = 16;
  static const double thumb = 12;
  static const double sheet = 24;
  static const double full = 999;

  static BorderRadius get fieldR => BorderRadius.circular(field);
  static BorderRadius get buttonR => BorderRadius.circular(button);
  static BorderRadius get buttonSmallR => BorderRadius.circular(buttonSmall);
  static BorderRadius get cardR => BorderRadius.circular(card);
  static BorderRadius get cardLargeR => BorderRadius.circular(cardLarge);
  static BorderRadius get thumbR => BorderRadius.circular(thumb);
  static BorderRadius get fullR => BorderRadius.circular(full);
  static BorderRadius get sheetR =>
      const BorderRadius.vertical(top: Radius.circular(sheet));
}

import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';

/// Gölge token'ları: yalnızca üstte duran katmanlarda (kartlarda gölge yok).
class AppShadows {
  const AppShadows._();

  static const double elevationSm = 2;
  static const double elevationLg = 8;

  /// shadow-sm: 0 2px 8px, %12 (koyu temada siyah %50).
  static List<BoxShadow> sm(AppColors c, Brightness b) => [
    BoxShadow(
      color: c.shadow.withValues(alpha: b == Brightness.dark ? 0.5 : 0.12),
      offset: const Offset(0, 2),
      blurRadius: 8,
    ),
  ];

  /// shadow-lg: 0 12px 32px, %20 (koyu temada siyah %50).
  static List<BoxShadow> lg(AppColors c, Brightness b) => [
    BoxShadow(
      color: c.shadow.withValues(alpha: b == Brightness.dark ? 0.5 : 0.2),
      offset: const Offset(0, 12),
      blurRadius: 32,
    ),
  ];
}

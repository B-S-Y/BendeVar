import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_shadows.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Açık / koyu ThemeData. Renkleri [AppColors] ThemeExtension'ı taşır.
class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(AppColors.light, Brightness.light);
  static ThemeData get dark => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness b) {
    final scheme = ColorScheme(
      brightness: b,
      primary: c.primary,
      onPrimary: c.onPrimary,
      secondary: c.accent,
      onSecondary: c.onPrimary,
      error: c.errorFg,
      onError: c.errorBg,
      surface: c.card,
      onSurface: c.textPrimary,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: b,
      fontFamily: AppTypography.fontFamily,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      dividerColor: c.divider,
      extensions: [c],
      materialTapTargetSize: MaterialTapTargetSize.padded,
      textTheme: Typography.material2021().black.apply(
        fontFamily: AppTypography.fontFamily,
        bodyColor: c.textPrimary,
        displayColor: c.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.appBar,
        foregroundColor: c.onAppBar,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTypography.appBar.copyWith(color: c.onAppBar),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.card,
        modalBarrierColor: c.scrim,
        elevation: AppShadows.elevationLg,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetR),
        showDragHandle: false,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.primary,
        contentTextStyle: AppTypography.body.copyWith(color: c.onPrimary),
        actionTextColor: c.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonR),
        elevation: AppShadows.elevationSm,
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
      ),
      dividerTheme: DividerThemeData(color: c.divider, space: 1, thickness: 1),
      textSelectionTheme: TextSelectionThemeData(cursorColor: c.accent),
    );
  }
}

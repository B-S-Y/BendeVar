import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'press_scale.dart';

enum _Kind { primary, secondary, danger }

class _AppButton extends StatelessWidget {
  const _AppButton({
    required this.kind,
    required this.label,
    required this.onPressed,
    this.icon,
    this.small = false,
    this.expand = true,
    this.loading = false,
  });

  final _Kind kind;
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool small;
  final bool expand;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = onPressed != null && !loading;
    final height = small ? AppSizes.buttonSmallHeight : AppSizes.buttonHeight;
    final radius = small ? AppRadius.buttonSmallR : AppRadius.buttonR;

    Color bg;
    Color pressedBg;
    Color fg;
    BorderSide side = BorderSide.none;
    switch (kind) {
      case _Kind.primary:
        bg = c.primary;
        pressedBg = c.primaryPressed;
        fg = c.onPrimary;
      case _Kind.secondary:
        bg = c.card;
        pressedBg = c.secondaryPressedBg;
        fg = c.secondaryFg;
        side = BorderSide(
          color: c.secondaryBorder,
          width: AppSizes.borderStrong,
        );
      case _Kind.danger:
        bg = c.card;
        pressedBg = c.errorBg;
        fg = c.errorFg;
        side = BorderSide(color: c.errorFg, width: AppSizes.borderStrong);
    }
    if (!enabled && !loading) {
      bg = c.disabledBg;
      pressedBg = c.disabledBg;
      fg = c.disabledFg;
      side = BorderSide.none;
    }

    final style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(
        Size(expand ? double.infinity : 0, height),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      ),
      elevation: const WidgetStatePropertyAll(0),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: radius, side: side),
      ),
      backgroundColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.pressed) ? pressedBg : bg,
      ),
      foregroundColor: WidgetStatePropertyAll(fg),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      tapTargetSize: MaterialTapTargetSize.padded,
      textStyle: WidgetStatePropertyAll(
        small ? AppTypography.buttonSmall : AppTypography.button,
      ),
    );

    final child = loading
        ? SizedBox(
            width: AppSizes.iconRow,
            height: AppSizes.iconRow,
            child: CircularProgressIndicator(
              strokeWidth: AppSizes.spinnerStroke,
              color: fg,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppSizes.iconRow),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    return PressScale(
      enabled: enabled,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: style,
        child: child,
      ),
    );
  }
}

/// Ekrandaki tek ana eylem.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.small = false,
    this.expand = true,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool small;
  final bool expand;
  final bool loading;

  @override
  Widget build(BuildContext context) => _AppButton(
    kind: _Kind.primary,
    label: label,
    onPressed: onPressed,
    icon: icon,
    small: small,
    expand: expand,
    loading: loading,
  );
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.small = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool small;
  final bool expand;

  @override
  Widget build(BuildContext context) => _AppButton(
    kind: _Kind.secondary,
    label: label,
    onPressed: onPressed,
    icon: icon,
    small: small,
    expand: expand,
  );
}

class DangerButton extends StatelessWidget {
  const DangerButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.small = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool small;
  final bool expand;

  @override
  Widget build(BuildContext context) => _AppButton(
    kind: _Kind.danger,
    label: label,
    onPressed: onPressed,
    icon: icon,
    small: small,
    expand: expand,
  );
}

/// Alt çizgili metin bağlantısı (vurgu mavisi, 14 Semi Bold).
class TextLinkButton extends StatelessWidget {
  const TextLinkButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return TextButton(
      onPressed: onPressed,
      style:
          TextButton.styleFrom(
            minimumSize: const Size(AppSizes.tapTarget, AppSizes.tapTarget),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            tapTargetSize: MaterialTapTargetSize.padded,
            foregroundColor: c.accent,
            overlayColor: Colors.transparent,
          ).copyWith(
            foregroundColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.pressed)
                  ? c.accent.withValues(alpha: kLinkPressedAlpha)
                  : c.accent,
            ),
          ),
      child: Text(
        label,
        style: AppTypography.link.copyWith(
          decoration: TextDecoration.underline,
          decorationColor: c.accent,
        ),
      ),
    );
  }
}

/// 48×48 dokunma alanlı ikon düğmesi.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.color,
    this.size = AppSizes.iconAppBar,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      enabled: onPressed != null,
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        constraints: const BoxConstraints(
          minWidth: AppSizes.tapTarget,
          minHeight: AppSizes.tapTarget,
        ),
        icon: Icon(
          icon,
          size: size,
          color: color ?? context.colors.textPrimary,
        ),
      ),
    );
  }
}

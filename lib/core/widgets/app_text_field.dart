import 'package:material_ui/material_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'shake_on_error.dart';

/// Etiketli giriş alanı: yükseklik 50, köşe 10, kenar `fieldBorder`.
/// Hata = renk + ikon + açıklayıcı cümle.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.onChanged,
    this.errorText,
    this.suffix,
    this.keyboardType,
    this.obscureText = false,
    this.minLines = 1,
    this.maxLines = 1,
    this.textInputAction,
    this.prefixIcon,
    this.onSubmitted,
    this.initialValue,
    this.fieldKey,
    this.errorSignal,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final Widget? suffix;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int minLines;
  final int maxLines;
  final TextInputAction? textInputAction;
  final String? initialValue;
  final Key? fieldKey;

  /// Aynı hata metni tekrar geldiğinde de titremesi için (örn. deneme sayacı).
  final Object? errorSignal;

  @override
  Widget build(BuildContext context) => ShakeOnError(
    trigger: errorText == null ? null : Object.hash(errorText, errorSignal),
    child: _buildField(context),
  );

  Widget _buildField(BuildContext context) {
    final c = context.colors;
    final hasError = errorText != null;

    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: AppRadius.fieldR,
      borderSide: BorderSide(color: color, width: width),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTypography.label.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        TextFormField(
          key: fieldKey,
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          keyboardType: keyboardType,
          obscureText: obscureText,
          minLines: minLines,
          maxLines: obscureText ? 1 : maxLines,
          textInputAction: textInputAction,
          style: AppTypography.body.copyWith(color: c.textPrimary),
          cursorColor: c.accent,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.body.copyWith(color: c.textSecondary),
            filled: true,
            fillColor: c.card,
            isDense: true,
            constraints: minLines == 1
                ? const BoxConstraints(minHeight: AppSizes.fieldHeight)
                : null,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: minLines == 1 ? AppSpacing.md : AppSpacing.lg,
            ),
            prefixIcon: prefixIcon == null
                ? null
                : Icon(
                    prefixIcon,
                    size: AppSizes.iconField,
                    color: c.textSecondary,
                  ),
            suffixIcon: suffix,
            border: border(
              hasError ? c.errorFg : c.fieldBorder,
              AppSizes.borderWidth,
            ),
            enabledBorder: border(
              hasError ? c.errorFg : c.fieldBorder,
              AppSizes.borderWidth,
            ),
            focusedBorder: border(
              hasError ? c.errorFg : c.accent,
              AppSizes.focusRing,
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(
                  LucideIcons.circleAlert,
                  size: AppSizes.iconField,
                  color: c.errorFg,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  errorText!,
                  style: AppTypography.label.copyWith(color: c.errorFg),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

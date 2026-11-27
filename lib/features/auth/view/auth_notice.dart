import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';

/// Giriş hata/uyarı kutusu (1.03c çok fazla deneme, 1.04 doğrulanmamış hesap).
class AuthNotice extends StatelessWidget {
  const AuthNotice({
    super.key,
    required this.icon,
    required this.message,
    this.warning = false,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;

  /// true: sarı uyarı renkleri, false: kırmızı hata renkleri.
  final bool warning;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = warning ? c.warningFg : c.errorFg;
    final bg = warning ? c.warningBg : c.errorBg;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.cardR),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: AppSizes.iconRow, color: fg),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.bodySmall.copyWith(color: fg),
                ),
              ),
            ],
          ),
          if (actionLabel != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextLinkButton(label: actionLabel!, onPressed: onAction),
            ),
        ],
      ),
    );
  }
}

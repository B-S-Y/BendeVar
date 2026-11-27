import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../l10n/app_localizations.dart';

/// Ayarlar ailesi (1.15, 1.18, 1.19, 1.19a/b, 1.20) ortak sayfa iskeleti:
/// koyu üst bar (geri + başlık) ve kaydırılabilir gövde.
class SettingsScaffold extends StatelessWidget {
  const SettingsScaffold({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final top = MediaQuery.paddingOf(context).top;
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: c.appBar,
            padding: EdgeInsets.only(
              top: top,
              left: AppSpacing.xs,
              right: AppSpacing.xs,
            ),
            height: top + AppSizes.tapTarget + AppSpacing.md,
            child: Row(
              children: [
                AppIconButton(
                  icon: LucideIcons.arrowLeft,
                  tooltip: l.back,
                  color: c.onAppBar,
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/profile');
                    }
                  },
                ),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.title1.copyWith(color: c.onAppBar),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Kart satırı: ikon, başlık, isteğe bağlı açıklama ve sağda [trailing]
/// (varsayılan: ok).
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.label,
    this.description,
    this.onTap,
    this.trailing,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final String? description;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = destructive ? c.errorFg : c.textPrimary;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Material(
        color: c.card,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardLargeR,
          side: BorderSide(color: c.cardBorder),
        ),
        child: InkWell(
          borderRadius: AppRadius.cardLargeR,
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: AppSizes.buttonHeight),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Icon(icon, size: AppSizes.iconAppBar, color: fg),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTypography.bodyStrong.copyWith(color: fg),
                      ),
                      if (description != null)
                        Text(
                          description!,
                          style: AppTypography.caption.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                trailing ??
                    (onTap == null
                        ? const SizedBox.shrink()
                        : Icon(
                            LucideIcons.chevronRight,
                            size: AppSizes.iconAppBar,
                            color: c.textSecondary,
                          )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

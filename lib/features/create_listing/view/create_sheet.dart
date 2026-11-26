import 'package:material_ui/material_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/sheets.dart';
import '../../../data/models/models.dart';
import '../../../l10n/app_localizations.dart';

/// 3.01 · Bende var / İhtiyacım var paneli. Seçilen türü döndürür.
/// [context], alt menünün üstünde kalması için dal Navigator'ının altında olmalı.
Future<ListingKind?> showCreateSheet(BuildContext context) {
  return showModalBottomSheet<ListingKind>(
    context: context,
    useRootNavigator: false,
    isScrollControlled: true,
    builder: (_) => const _CreateSheet(),
  );
}

class _CreateSheet extends StatelessWidget {
  const _CreateSheet();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        0,
        AppSpacing.screen,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SheetHandle(),
          Align(
            alignment: Alignment.centerRight,
            child: AppIconButton(
              icon: LucideIcons.x,
              tooltip: l.close,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _Option(
            icon: LucideIcons.package,
            title: l.createIlanTitle,
            subtitle: l.createIlanSubtitle,
            onTap: () => Navigator.pop(context, ListingKind.ilan),
          ),
          const SizedBox(height: AppSpacing.md),
          _Option(
            icon: LucideIcons.search,
            title: l.createNeedTitle,
            subtitle: l.createNeedSubtitle,
            onTap: () => Navigator.pop(context, ListingKind.ihtiyac),
          ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.card,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardLargeR,
        side: BorderSide(color: c.divider, width: AppSizes.borderWidth),
      ),
      child: InkWell(
        borderRadius: AppRadius.cardLargeR,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md + AppSpacing.xs),
          child: Row(
            children: [
              Container(
                width: AppSizes.avatar,
                height: AppSizes.avatar,
                decoration: BoxDecoration(
                  color: c.infoBg,
                  borderRadius: AppRadius.fieldR,
                ),
                child: Icon(
                  icon,
                  size: AppSizes.iconAppBar + 2,
                  color: c.infoFg,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.title2.copyWith(
                        color: c.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                size: AppSizes.iconAppBar,
                color: c.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

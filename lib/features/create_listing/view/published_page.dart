import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/small_widgets.dart';
import '../../../data/models/models.dart';
import '../../../l10n/app_localizations.dart';

/// 3.07 · İlan yayınlandı (ihtiyaç için de).
class PublishedPage extends StatelessWidget {
  const PublishedPage({super.key, required this.id, required this.kind});

  final String id;
  final ListingKind kind;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final isIlan = kind == ListingKind.ilan;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxxl,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: AppSizes.statusCircle,
                      height: AppSizes.statusCircle,
                      decoration: BoxDecoration(
                        color: c.successBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.check,
                        size: AppSizes.avatar - AppSpacing.sm,
                        color: c.successFg,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      isIlan ? l.publishedTitleListing : l.publishedTitleNeed,
                      textAlign: TextAlign.center,
                      style: AppTypography.title1.copyWith(
                        color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      isIlan ? l.publishedBodyListing : l.publishedBodyNeed,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    StatusPill(
                      label: l.statusPublishedShort,
                      fg: c.successFg,
                      bg: c.successBg,
                      icon: LucideIcons.check,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.lg,
              AppSpacing.screen,
              AppSpacing.md + MediaQuery.paddingOf(context).bottom,
            ),
            decoration: BoxDecoration(
              color: c.card,
              border: Border(top: BorderSide(color: c.divider)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PrimaryButton(
                  label: l.view,
                  onPressed: () {
                    context.go('/home');
                    context.push('/listing/$id');
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                SecondaryButton(
                  label: l.backToHome,
                  onPressed: () => context.go('/home'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

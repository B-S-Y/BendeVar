import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/star_field.dart';
import '../../../l10n/app_localizations.dart';

/// 1.01 · Karşılama
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: c.hero,
      body: Stack(
        children: [
          const Positioned.fill(child: StarField()),
          Column(
            children: [
              Expanded(
                child: SafeArea(
                  bottom: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AppLogo(size: AppSizes.logoWelcome),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          l.brandName,
                          style: AppTypography.brand.copyWith(color: c.onHero),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l.slogan,
                          style: AppTypography.body.copyWith(
                            color: c.onHeroMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screen + AppSpacing.xs,
                  AppSpacing.xxxl,
                  AppSpacing.screen + AppSpacing.xs,
                  AppSpacing.xxxl + MediaQuery.paddingOf(context).bottom,
                ),
                decoration: BoxDecoration(
                  color: c.sheet,
                  borderRadius: AppRadius.sheetR,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l.welcomeTitle,
                      style: AppTypography.title1.copyWith(
                        color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l.welcomeSubtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    PrimaryButton(
                      label: l.login,
                      onPressed: () => context.push('/login'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SecondaryButton(
                      label: l.signup,
                      onPressed: () => context.push('/coming-soon'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

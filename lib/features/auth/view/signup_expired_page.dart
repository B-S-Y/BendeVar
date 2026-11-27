import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../l10n/app_localizations.dart';
import '../viewmodel/auth_view_model.dart';
import 'auth_shell.dart';
import 'signup_stepper.dart';

/// 1.12 · Bağlantının süresi doldu.
class SignupExpiredPage extends StatelessWidget {
  const SignupExpiredPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final vm = context.read<AuthViewModel>();

    return AuthShell(
      title: l.signup,
      onBack: () => context.go('/signup'),
      step: const SignupStepper(step: 2),
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(
            label: l.sendNewLink,
            onPressed: () async {
              await vm.resendLink();
              if (context.mounted) context.go('/signup/sent');
            },
          ),
          TextLinkButton(
            label: l.fixEmail,
            onPressed: () => context.go('/signup'),
          ),
        ],
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl + AppSpacing.xs,
            vertical: AppSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppSizes.statusCircle,
                height: AppSizes.statusCircle,
                decoration: BoxDecoration(
                  color: c.warningBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.clock,
                  size: AppSizes.statusCircle / 2,
                  color: c.warningFg,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                l.expiredTitle,
                textAlign: TextAlign.center,
                style: AppTypography.title1.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l.expiredBody,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(color: c.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

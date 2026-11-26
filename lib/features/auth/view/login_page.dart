import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/star_field.dart';
import '../../../l10n/app_localizations.dart';
import '../viewmodel/auth_view_model.dart';

/// 1.02 · Giriş yap
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final vm = context.watch<AuthViewModel>();

    final emailError = switch (vm.emailError) {
      EmailError.empty => l.errorEmailEmpty,
      EmailError.notEdu => l.errorEmailNotEdu,
      null => null,
    };
    final passwordError = vm.passwordError == null
        ? null
        : l.errorPasswordEmpty;

    Future<void> submit() async {
      final ok = await vm.signIn();
      if (ok && context.mounted) context.go('/home');
    }

    return Scaffold(
      backgroundColor: c.hero,
      body: Stack(
        children: [
          const Positioned.fill(child: StarField()),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.lg),
                const AppLogo(size: AppSizes.logoSmall),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l.brandName,
                  style: AppTypography.title2.copyWith(color: c.onHero),
                ),
                const SizedBox(height: AppSpacing.xl),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: c.sheet,
                      borderRadius: AppRadius.sheetR,
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.sm,
                            AppSpacing.lg,
                            AppSpacing.screen,
                            0,
                          ),
                          child: Row(
                            children: [
                              AppIconButton(
                                icon: LucideIcons.arrowLeft,
                                tooltip: l.back,
                                onPressed: () => context.pop(),
                              ),
                              Text(
                                l.login,
                                style: AppTypography.appBar.copyWith(
                                  color: c.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.screen + AppSpacing.xs,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: AppSpacing.xl),
                                Text(
                                  l.loginTitle,
                                  style: AppTypography.title1.copyWith(
                                    color: c.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  l.loginSubtitle,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: c.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                AppTextField(
                                  fieldKey: const Key('email-field'),
                                  label: l.emailLabel,
                                  hint: l.emailHint,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  onChanged: vm.setEmail,
                                  errorText: emailError,
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                AppTextField(
                                  fieldKey: const Key('password-field'),
                                  label: l.passwordLabel,
                                  hint: l.passwordHint,
                                  obscureText: vm.obscure,
                                  textInputAction: TextInputAction.done,
                                  onChanged: vm.setPassword,
                                  onSubmitted: (_) =>
                                      vm.canSubmit ? submit() : null,
                                  errorText: passwordError,
                                  suffix: IconButton(
                                    onPressed: vm.toggleObscure,
                                    tooltip: vm.obscure
                                        ? l.showPassword
                                        : l.hidePassword,
                                    icon: Icon(
                                      vm.obscure
                                          ? LucideIcons.eye
                                          : LucideIcons.eyeOff,
                                      size: AppSizes.iconAppBar,
                                      color: c.textSecondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextLinkButton(
                                    label: l.forgotPassword,
                                    onPressed: () =>
                                        context.push('/coming-soon'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.screen + AppSpacing.xs,
                            AppSpacing.sm,
                            AppSpacing.screen + AppSpacing.xs,
                            AppSpacing.sm +
                                MediaQuery.paddingOf(context).bottom,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PrimaryButton(
                                label: l.login,
                                loading: vm.loading,
                                onPressed: vm.canSubmit ? submit : null,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      l.noAccount,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: c.textSecondary,
                                      ),
                                    ),
                                  ),
                                  TextLinkButton(
                                    label: l.signup,
                                    onPressed: () =>
                                        context.push('/coming-soon'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

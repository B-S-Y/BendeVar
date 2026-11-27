import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_checkbox.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/institution_email_field.dart';
import '../../../l10n/app_localizations.dart';
import '../../../data/repositories/repositories.dart';
import '../viewmodel/auth_view_model.dart';
import 'auth_motion.dart';
import 'auth_notice.dart';

const double _formSide = AppSpacing.screen + AppSpacing.xs;

/// 1.02 üst satır: geri oku + "Giriş yap".
class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm + AppSpacing.xs,
        AppSpacing.screen,
        0,
      ),
      child: SizedBox(
        height: AuthMotion.headerRow,
        child: Row(
          children: [
            AppIconButton(
              icon: LucideIcons.arrowLeft,
              tooltip: l.back,
              onPressed: onBack,
            ),
            Text(
              l.login,
              style: AppTypography.appBar.copyWith(color: c.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

/// 1.02 gövde: başlık, e-posta, şifre, "Şifremi unuttum".
class LoginBody extends StatefulWidget {
  const LoginBody({super.key});

  @override
  State<LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
  final ScrollController _scroll = ScrollController();
  AuthFailure? _lastFailure;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Hata kutusu açılınca form en üste döner; başlık yarım kesik kalmaz.
  void _revealTop(AuthFailure? failure) {
    if (failure == _lastFailure) return;
    _lastFailure = failure;
    if (failure == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients || _scroll.offset == 0) return;
      if (AppMotion.reduce(context)) {
        _scroll.jumpTo(0);
      } else {
        _scroll.animateTo(
          0,
          duration: AppMotion.page,
          curve: AppMotion.standard,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final vm = context.watch<AuthViewModel>();
    _revealTop(vm.failure);

    final emailError = vm.failure == AuthFailure.accountNotFound
        ? l.errorAccountNotFound
        : switch (vm.emailError) {
            EmailError.empty => l.errorEmailEmpty,
            EmailError.notEdu => l.errorEmailNotEdu,
            null => null,
          };
    final passwordError = vm.failure == AuthFailure.wrongPassword
        ? l.errorPasswordWrong
        : vm.passwordError == null
        ? null
        : l.errorPasswordEmpty;

    Future<void> submit() async {
      final ok = await vm.signIn();
      if (ok && context.mounted) context.go('/home');
    }

    return SingleChildScrollView(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(horizontal: _formSide),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Text(
            l.loginTitle,
            style: AppTypography.title1.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l.loginSubtitle,
            style: AppTypography.bodySmall.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          InstitutionEmailField(
            fieldKey: const Key('email-field'),
            textInputAction: TextInputAction.next,
            onChanged: vm.setEmail,
            errorText: emailError,
            errorSignal: vm.errorSeq,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppTextField(
            fieldKey: const Key('password-field'),
            label: l.passwordLabel,
            hint: l.passwordHint,
            obscureText: vm.obscure,
            textInputAction: TextInputAction.done,
            onChanged: vm.setPassword,
            onSubmitted: (_) => vm.canSubmit ? submit() : null,
            errorText: passwordError,
            errorSignal: vm.errorSeq,
            suffix: IconButton(
              onPressed: vm.toggleObscure,
              tooltip: vm.obscure ? l.showPassword : l.hidePassword,
              icon: Icon(
                vm.obscure ? LucideIcons.eye : LucideIcons.eyeOff,
                size: AppSizes.iconAppBar,
                color: c.textSecondary,
              ),
            ),
          ),
          AppCheckbox(
            checkboxKey: const Key('remember-checkbox'),
            value: vm.remember,
            onChanged: vm.setRemember,
            label: l.rememberMe,
          ),
          if (vm.failure == AuthFailure.tooManyAttempts) ...[
            const SizedBox(height: AppSpacing.lg),
            AuthNotice(
              icon: LucideIcons.circleAlert,
              message: l.errorTooManyAttempts,
            ),
          ],
          if (vm.failure == AuthFailure.notVerified) ...[
            const SizedBox(height: AppSpacing.lg),
            AuthNotice(
              icon: LucideIcons.mail,
              warning: true,
              message: l.errorNotVerified,
              actionLabel: l.resendVerification,
              onAction: () async {
                final messenger = ScaffoldMessenger.of(context);
                await vm.resendVerification();
                messenger.showSnackBar(
                  SnackBar(content: Text(l.verificationSent)),
                );
              },
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: TextLinkButton(
              label: l.forgotPassword,
              onPressed: () => context.push('/forgot'),
            ),
          ),
        ],
      ),
    );
  }
}

/// 1.02 alt: "Giriş yap" düğmesi ve "Hesabın yok mu? Kayıt ol".
class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key, required this.onSignup});

  /// "Kayıt ol": aynı panelde kayıt formuna geçer.
  final VoidCallback onSignup;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final vm = context.watch<AuthViewModel>();

    Future<void> submit() async {
      final ok = await vm.signIn();
      if (ok && context.mounted) context.go('/home');
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        _formSide,
        AppSpacing.sm,
        _formSide,
        AppSpacing.sm + MediaQuery.paddingOf(context).bottom,
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
              TextLinkButton(label: l.signup, onPressed: onSignup),
            ],
          ),
        ],
      ),
    );
  }
}

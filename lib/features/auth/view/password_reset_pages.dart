import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/envelope_animation.dart';
import '../../../core/widgets/institution_email_field.dart';
import '../../../data/repositories/repositories.dart';
import '../../../l10n/app_localizations.dart';
import '../viewmodel/auth_view_model.dart';
import 'auth_shell.dart';

const EdgeInsets _bodyPadding = EdgeInsets.fromLTRB(
  AppSpacing.xl,
  AppSpacing.xxl,
  AppSpacing.xl,
  AppSpacing.lg,
);

/// 1.05 · Şifremi unuttum: kurum e-postası → bağlantı gönder.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late final InstitutionEmailController _email;

  @override
  void initState() {
    super.initState();
    final vm = context.read<AuthViewModel>()..startReset();
    _email = InstitutionEmailController(text: vm.resetEmail);
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final vm = context.read<AuthViewModel>();
    final ok = await vm.sendReset();
    if (ok && mounted) context.push('/forgot/sent');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final vm = context.watch<AuthViewModel>();
    final error = switch (vm.resetEmailError) {
      EmailError.empty => l.errorEmailEmpty,
      EmailError.notEdu => l.errorEmailNotEdu,
      null => null,
    };

    return AuthShell(
      title: l.forgotPassword,
      onBack: backOr(context, '/login'),
      footer: PrimaryButton(
        label: l.sendResetLink,
        loading: vm.resetLoading,
        onPressed: _send,
      ),
      child: SingleChildScrollView(
        padding: _bodyPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.forgotTitle,
              style: AppTypography.title1.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: AppSpacing.titleGap),
            Text(
              l.forgotSubtitle,
              style: AppTypography.bodySmall.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            InstitutionEmailField(
              fieldKey: const Key('reset-email-field'),
              controller: _email,
              textInputAction: TextInputAction.done,
              onChanged: vm.setResetEmail,
              onSubmitted: (_) => _send(),
              errorText: error,
            ),
          ],
        ),
      ),
    );
  }
}

/// 1.06 · Bağlantı gönderildi. Öne dönünce ve "Bağlantıya tıkladım" ile
/// kontrol edilir; tıklandıysa 1.07'ye geçer.
class ResetSentPage extends StatefulWidget {
  const ResetSentPage({super.key});

  @override
  State<ResetSentPage> createState() => _ResetSentPageState();
}

class _ResetSentPageState extends State<ResetSentPage>
    with WidgetsBindingObserver {
  Timer? _tick;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tick?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check(manual: false);
  }

  Future<void> _check({required bool manual}) async {
    if (_checking) return;
    _checking = true;
    final vm = context.read<AuthViewModel>();
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final status = await vm.checkReset();
    _checking = false;
    if (!mounted) return;
    switch (status) {
      case VerificationStatus.verified:
        context.go('/forgot/new');
      case VerificationStatus.expired:
        messenger.showSnackBar(SnackBar(content: Text(l.resetExpired)));
      case VerificationStatus.pending:
        if (manual) {
          messenger.showSnackBar(SnackBar(content: Text(l.notVerifiedYet)));
        }
    }
  }

  Future<void> _resend() async {
    final vm = context.read<AuthViewModel>();
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await vm.resendReset();
    messenger.showSnackBar(SnackBar(content: Text(l.linkResent)));
  }

  static String _mmss(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final vm = context.watch<AuthViewModel>();
    final remaining = vm.resetResendRemaining();

    return AuthShell(
      title: l.forgotPassword,
      onBack: backOr(context, '/forgot'),
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(
            label: l.openMailApp,
            onPressed: () => context.push('/coming-soon'),
          ),
          const SizedBox(height: AppSpacing.compactGap),
          SecondaryButton(
            label: l.clickedLink,
            onPressed: () => _check(manual: true),
          ),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextLinkButton(
                label: remaining > 0
                    ? l.resendIn(_mmss(remaining))
                    : l.resendLink,
                onPressed: remaining > 0 ? null : _resend,
              ),
              TextButton.icon(
                onPressed: backOr(context, '/forgot'),
                icon: Icon(
                  LucideIcons.arrowLeft,
                  size: AppSizes.iconRow,
                  color: c.textPrimary,
                ),
                label: Text(
                  l.fixEmail,
                  style: AppTypography.link.copyWith(color: c.textPrimary),
                ),
              ),
            ],
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
              const EnvelopeAnimation(),
              const SizedBox(height: AppSpacing.sentGap),
              Text(
                l.sentTitle,
                textAlign: TextAlign.center,
                style: AppTypography.title1.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: AppSpacing.sentGap),
              Text(
                vm.resetEmail,
                textAlign: TextAlign.center,
                style: AppTypography.bodyStrong.copyWith(
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sentGap),
              Text(
                l.resetSentInstruction,
                textAlign: TextAlign.center,
                style: AppTypography.label.copyWith(
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  color: c.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 1.07 · Yeni şifre belirle.
class ResetNewPasswordPage extends StatelessWidget {
  const ResetNewPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final vm = context.watch<AuthViewModel>();

    final error = vm.newPasswordError == null ? null : l.errorPasswordWeak;
    final mismatch = vm.passwordMismatch ? l.errorPasswordMismatch : null;

    Future<void> save() async {
      final messenger = ScaffoldMessenger.of(context);
      final ok = await vm.savePassword();
      if (!ok || !context.mounted) return;
      vm.resetPasswordFlow();
      messenger.showSnackBar(SnackBar(content: Text(l.passwordUpdated)));
      context.go('/login');
    }

    // Her alanın kendi göz ikonu var; ikisi birbirinden bağımsız çalışır.
    Widget eye({required bool hidden, required VoidCallback onToggle}) =>
        IconButton(
          onPressed: onToggle,
          tooltip: hidden ? l.showPassword : l.hidePassword,
          icon: Icon(
            hidden ? LucideIcons.eye : LucideIcons.eyeOff,
            size: AppSizes.iconAppBar,
            color: c.textSecondary,
          ),
        );

    return AuthShell(
      title: l.forgotPassword,
      footer: PrimaryButton(
        label: l.savePassword,
        loading: vm.savingPassword,
        onPressed: save,
      ),
      child: SingleChildScrollView(
        padding: _bodyPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.newPasswordTitle,
              style: AppTypography.title1.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              fieldKey: const Key('new-password-field'),
              label: l.newPasswordLabel,
              hint: l.newPasswordHint,
              obscureText: vm.newObscure,
              textInputAction: TextInputAction.next,
              onChanged: vm.setNewPassword,
              errorText: error,
              errorSignal: vm.newErrorSeq,
              suffix: eye(hidden: vm.newObscure, onToggle: vm.toggleNewObscure),
            ),
            if (error == null) ...[
              const SizedBox(height: AppSpacing.hintGap),
              Text(
                l.signupPasswordRule,
                style: AppTypography.label.copyWith(
                  fontWeight: FontWeight.w400,
                  color: c.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              fieldKey: const Key('confirm-password-field'),
              label: l.confirmPasswordLabel,
              hint: l.confirmPasswordHint,
              obscureText: vm.confirmObscure,
              textInputAction: TextInputAction.done,
              onChanged: vm.setConfirmPassword,
              onSubmitted: (_) => save(),
              errorText: mismatch,
              errorSignal: vm.newErrorSeq,
              suffix: eye(
                hidden: vm.confirmObscure,
                onToggle: vm.toggleConfirmObscure,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

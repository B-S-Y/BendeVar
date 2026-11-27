import 'package:flutter/gestures.dart';
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
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/institution_email_field.dart';
import '../../../data/repositories/repositories.dart';
import '../../../l10n/app_localizations.dart';
import '../viewmodel/auth_view_model.dart';
import 'auth_motion.dart';

const double _formSide = AppSpacing.xl;

/// 1.08 üst satır: kapat (X) + "Kayıt ol".
class SignupHeader extends StatelessWidget {
  const SignupHeader({super.key, required this.onExit});

  final VoidCallback onExit;

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
              icon: LucideIcons.x,
              tooltip: l.signupExit,
              onPressed: onExit,
            ),
            Text(
              l.signup,
              style: AppTypography.appBar.copyWith(color: c.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

/// 1.08 gövde: e-posta, okul kartı, şifre, şartlar.
class SignupBody extends StatefulWidget {
  const SignupBody({super.key, required this.emailController});

  /// Ortak kurum e-postası denetleyicisi (sahne tutar; Türkçe karakter ve
  /// büyük harf düzeltmesi içinde).
  final InstitutionEmailController emailController;

  @override
  State<SignupBody> createState() => _SignupBodyState();
}

class _SignupBodyState extends State<SignupBody> {
  final FocusNode _emailFocus = FocusNode();
  bool _hadFocus = false;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(_onFocus);
  }

  /// Alan odağı kaybedince bilinmeyen okulun "ilk kayıtla açılacak" notu gelir.
  void _onFocus() {
    if (_emailFocus.hasFocus) {
      _hadFocus = true;
    } else if (_hadFocus) {
      context.read<AuthViewModel>().signupEmailBlurred();
    }
  }

  @override
  void dispose() {
    _emailFocus.removeListener(_onFocus);
    _emailFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emailController = widget.emailController;
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final vm = context.watch<AuthViewModel>();

    final emailError = vm.signupFailure == AuthFailure.emailInUse
        ? l.errorEmailInUse
        : switch (vm.signupEmailError) {
            EmailError.empty => l.errorEmailEmpty,
            EmailError.notEdu => l.errorEmailNotEdu, // 1.08a
            null => null,
          };
    final passwordError = switch (vm.signupPasswordError) {
      NewPasswordError.empty || NewPasswordError.weak => l.errorPasswordWeak,
      null => null,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        _formSide,
        AppSpacing.xl + AppSpacing.xs / 2,
        _formSide,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.signupTitle,
            style: AppTypography.title1.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: AppSpacing.lg),
          InstitutionEmailField(
            fieldKey: const Key('signup-email-field'),
            controller: emailController,
            focusNode: _emailFocus,
            textInputAction: TextInputAction.next,
            onChanged: vm.setSignupEmail,
            errorText: emailError,
            errorSignal: vm.signupErrorSeq,
          ),
          if (vm.showSchoolCard) ...[
            const SizedBox(height: AppSpacing.sm),
            _SchoolCard(
              name:
                  vm.schoolCommunity?.name ??
                  _capitalize(Validators.schoolId(vm.signupEmail) ?? ''),
              exists: vm.schoolCommunity != null,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            fieldKey: const Key('signup-password-field'),
            label: l.passwordLabel,
            hint: l.signupPasswordHint,
            obscureText: vm.signupObscure,
            textInputAction: TextInputAction.done,
            onChanged: vm.setSignupPassword,
            errorText: passwordError,
            errorSignal: vm.signupErrorSeq,
            suffix: IconButton(
              onPressed: vm.toggleSignupObscure,
              tooltip: vm.signupObscure ? l.showPassword : l.hidePassword,
              icon: Icon(
                vm.signupObscure ? LucideIcons.eye : LucideIcons.eyeOff,
                size: AppSizes.iconAppBar,
                color: c.textSecondary,
              ),
            ),
          ),
          if (passwordError == null) ...[
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
          _TermsRow(
            accepted: vm.termsAccepted,
            error: vm.termsError,
            onChanged: vm.setTermsAccepted,
          ),
        ],
      ),
    );
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _SchoolCard extends StatelessWidget {
  const _SchoolCard({required this.name, required this.exists});

  final String name;
  final bool exists;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadius.fieldR,
        border: Border.all(color: c.silver, width: AppSizes.borderWidth),
      ),
      child: Row(
        children: [
          Container(
            width: AppSizes.avatar - AppSpacing.lg,
            height: AppSizes.avatar - AppSpacing.lg,
            decoration: BoxDecoration(
              color: c.infoBg,
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
            child: Icon(
              LucideIcons.graduationCap,
              size: AppSizes.iconRow,
              color: c.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.compactGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
                Text(
                  exists ? l.signupJoinCommunity : l.signupNewCommunity,
                  style: AppTypography.caption.copyWith(color: c.textSecondary),
                ),
              ],
            ),
          ),
          Icon(LucideIcons.check, size: AppSizes.iconRow, color: c.textPrimary),
        ],
      ),
    );
  }
}

/// "Kullanım şartlarını ve gizlilik politikasını okudum, kabul ediyorum."
class _TermsRow extends StatefulWidget {
  const _TermsRow({
    required this.accepted,
    required this.error,
    required this.onChanged,
  });

  final bool accepted;
  final bool error;
  final ValueChanged<bool> onChanged;

  @override
  State<_TermsRow> createState() => _TermsRowState();
}

class _TermsRowState extends State<_TermsRow> {
  late final TapGestureRecognizer _terms = TapGestureRecognizer()
    ..onTap = () => context.push('/legal/terms');
  late final TapGestureRecognizer _privacy = TapGestureRecognizer()
    ..onTap = () => context.push('/legal/privacy');

  @override
  void dispose() {
    _terms.dispose();
    _privacy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final base = AppTypography.bodySmall.copyWith(color: c.textSecondary);
    final link = base.copyWith(
      fontWeight: FontWeight.w600,
      color: c.accent,
      decoration: TextDecoration.underline,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: AppSizes.tapTarget,
              height: AppSizes.tapTarget,
              child: Checkbox(
                key: const Key('terms-checkbox'),
                value: widget.accepted,
                activeColor: c.primary,
                checkColor: c.onPrimary,
                side: BorderSide(
                  color: widget.error ? c.errorFg : c.textSecondary,
                  width: AppSizes.borderStrong,
                ),
                onChanged: (v) => widget.onChanged(v ?? false),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: Text.rich(
                  TextSpan(
                    style: base,
                    children: [
                      TextSpan(text: l.termsLead),
                      TextSpan(
                        text: l.termsLink,
                        style: link,
                        recognizer: _terms,
                      ),
                      TextSpan(text: l.termsMid),
                      TextSpan(
                        text: l.privacyLink,
                        style: link,
                        recognizer: _privacy,
                      ),
                      TextSpan(text: l.termsTail),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (widget.error)
          Padding(
            padding: const EdgeInsets.only(left: AppSizes.tapTarget),
            child: Row(
              children: [
                Icon(
                  LucideIcons.circleAlert,
                  size: AppSizes.iconField,
                  color: c.errorFg,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l.errorTermsRequired,
                    style: AppTypography.label.copyWith(color: c.errorFg),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// 1.08 alt: "Kayıt ol" düğmesi ve "Hesabın var mı? Giriş yap".
class SignupFooter extends StatelessWidget {
  const SignupFooter({super.key, required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final vm = context.watch<AuthViewModel>();

    Future<void> submit() async {
      final ok = await vm.signUp();
      if (ok && context.mounted) context.push('/signup/sent');
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
            label: l.signup,
            loading: vm.signupLoading,
            onPressed: submit,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  l.haveAccount,
                  style: AppTypography.bodySmall.copyWith(
                    color: c.textSecondary,
                  ),
                ),
              ),
              TextLinkButton(label: l.login, onPressed: onLogin),
            ],
          ),
        ],
      ),
    );
  }
}

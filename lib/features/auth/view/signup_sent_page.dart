import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/envelope_animation.dart';
import '../../../data/repositories/repositories.dart';
import '../../../l10n/app_localizations.dart';
import '../viewmodel/auth_view_model.dart';
import 'auth_shell.dart';
import 'signup_stepper.dart';

/// 1.09 · Bağlantı gönderildi. Uygulama öne dönünce doğrulamayı kendisi
/// kontrol eder; yedek olarak "Bağlantıya tıkladım" düğmesi.
class SignupSentPage extends StatefulWidget {
  const SignupSentPage({super.key});

  @override
  State<SignupSentPage> createState() => _SignupSentPageState();
}

class _SignupSentPageState extends State<SignupSentPage>
    with WidgetsBindingObserver {
  Timer? _tick;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // "Tekrar gönder (0:45)" geri sayımı.
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
    final status = await vm.checkVerification();
    _checking = false;
    if (!mounted) return;
    switch (status) {
      case VerificationStatus.verified:
        context.go('/signup/name');
      case VerificationStatus.expired:
        context.go('/signup/expired');
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
    await vm.resendLink();
    messenger.showSnackBar(SnackBar(content: Text(l.linkResent)));
  }

  static String _mmss(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final vm = context.watch<AuthViewModel>();
    final remaining = vm.resendRemaining();

    return AuthShell(
      title: l.signup,
      onBack: backOr(context, '/signup'),
      step: const SignupStepper(step: 2),
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(
            label: l.openMailApp,
            onPressed: () => context.push('/coming-soon'),
          ),
          const SizedBox(height: AppSpacing.md - 2),
          SecondaryButton(
            label: l.clickedLink,
            onPressed: () => _check(manual: true),
          ),
          // Büyük yazıda iki bağlantı alt alta geçer (taşma olmaz).
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
                onPressed: backOr(context, '/signup'),
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
              const SizedBox(height: AppSpacing.md + 2),
              Text(
                l.sentTitle,
                textAlign: TextAlign.center,
                style: AppTypography.title1.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: AppSpacing.md + 2),
              Text(
                l.sentSubtitle,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: AppSpacing.md + 2),
              Text(
                vm.signupEmail,
                textAlign: TextAlign.center,
                style: AppTypography.bodyStrong.copyWith(
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md + 2),
              Text(
                l.sentInstruction,
                textAlign: TextAlign.center,
                style: AppTypography.label.copyWith(
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  color: c.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md + 2),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm - 2,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: c.silver),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: AppSizes.dot,
                      height: AppSizes.dot,
                      decoration: BoxDecoration(
                        color: c.textSecondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      l.sentWaiting,
                      style: AppTypography.caption.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

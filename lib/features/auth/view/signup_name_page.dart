import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../l10n/app_localizations.dart';
import '../viewmodel/auth_view_model.dart';
import 'auth_shell.dart';
import 'signup_stepper.dart';

/// 1.10 · Adın ne? Ad Soyad e-postadan çıkarılıp hazır gelir, düzenlenebilir.
class SignupNamePage extends StatefulWidget {
  const SignupNamePage({super.key});

  @override
  State<SignupNamePage> createState() => _SignupNamePageState();
}

class _SignupNamePageState extends State<SignupNamePage> {
  late final TextEditingController _name = TextEditingController(
    text: context.read<AuthViewModel>().suggestedName,
  );
  bool _showError = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final vm = context.read<AuthViewModel>();
    if (Validators.requiredText(_name.text) != null) {
      setState(() => _showError = true);
      return;
    }
    final ok = await vm.completeSignUp(_name.text);
    if (ok && mounted) {
      vm.resetSignup();
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final loading = context.select<AuthViewModel, bool>((v) => v.completing);

    return AuthShell(
      title: l.signup,
      step: const SignupStepper(step: 3),
      footer: PrimaryButton(
        label: l.finish,
        loading: loading,
        onPressed: _finish,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.xxl,
          AppSpacing.xl,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.nameTitle,
              style: AppTypography.title1.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: AppSpacing.xs + 2),
            Text(
              l.nameSubtitle,
              style: AppTypography.bodySmall.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              fieldKey: const Key('name-field'),
              controller: _name,
              label: l.nameLabel,
              hint: l.nameHint,
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() => _showError = false),
              onSubmitted: (_) => _finish(),
              errorText: _showError ? l.errorNameEmpty : null,
            ),
          ],
        ),
      ),
    );
  }
}

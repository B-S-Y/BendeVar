import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';
import 'auth_shell.dart';

enum LegalKind { terms, privacy }

/// 1.10a / 1.10b (kayıt sırasında) ve 1.19a / 1.19b (Ayarlar'dan):
/// kullanım şartları ve gizlilik politikası.
class LegalPage extends StatelessWidget {
  const LegalPage({super.key, required this.kind});

  final LegalKind kind;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final terms = kind == LegalKind.terms;
    return AuthShell(
      title: terms ? l.legalTermsTitle : l.legalPrivacyTitle,
      onBack: backOr(context, '/welcome'),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.xxl + MediaQuery.paddingOf(context).bottom,
        ),
        child: Text(
          terms ? l.legalTermsBody : l.legalPrivacyBody,
          style: AppTypography.body.copyWith(height: 1.5, color: c.textPrimary),
        ),
      ),
    );
  }
}

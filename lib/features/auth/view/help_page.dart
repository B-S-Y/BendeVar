import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';
import 'settings_widgets.dart';

/// Yardım ve destek (Ayarlar → Gizlilik ve destek). Başlık, kısa açıklama,
/// 3 soru-cevap ve iletişim e-postası. Figma'da yok (DEVIATIONS.md).
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final faqs = [
      (l.helpQ1, l.helpA1),
      (l.helpQ2, l.helpA2),
      (l.helpQ3, l.helpA3),
    ];
    return SettingsScaffold(
      title: l.helpSupport,
      child: ListView(
        padding: settingsListPadding(context),
        children: [
          Text(
            l.helpIntro,
            style: AppTypography.body.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final (i, (q, a)) in faqs.indexed)
            _FaqTile(key: Key('faq-$i'), question: q, answer: a),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            l.helpContact,
            style: AppTypography.bodyStrong.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          SelectableText(
            l.helpContactEmail,
            key: const Key('help-email'),
            style: AppTypography.body.copyWith(color: c.accent),
          ),
        ],
      ),
    );
  }
}

/// Soru-cevap satırı: kart içinde ExpansionTile.
class _FaqTile extends StatelessWidget {
  const _FaqTile({super.key, required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Material(
        color: c.card,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardLargeR,
          side: BorderSide(color: c.cardBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          // Açılırken ExpansionTile'ın kendi ayırıcı çizgileri görünmesin.
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            // "Animasyonları azalt" açıksa açılıp kapanma animasyonsuz.
            expansionAnimationStyle: AppMotion.reduce(context)
                ? AnimationStyle.noAnimation
                : null,
            tilePadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            iconColor: c.textSecondary,
            collapsedIconColor: c.textSecondary,
            title: Text(
              question,
              style: AppTypography.bodyStrong.copyWith(color: c.textPrimary),
            ),
            children: [
              Text(
                answer,
                style: AppTypography.body.copyWith(color: c.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

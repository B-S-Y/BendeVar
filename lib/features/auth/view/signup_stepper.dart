import 'package:material_ui/material_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';

/// Kayıt adımları: 1 Hesap, 2 Doğrulama, 3 Adın (1.08 / 1.09 / 1.10).
class SignupStepper extends StatelessWidget {
  const SignupStepper({super.key, required this.step});

  /// 1, 2 veya 3.
  final int step;

  static const double _dot = 22;
  static const double _ring = 4;
  static const double _line = 2;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final labels = [l.stepAccount, l.stepVerify, l.stepName];
    return Semantics(
      label: '${labels[step - 1]} ($step/3)',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xs / 2,
            AppSpacing.xl,
            0,
          ),
          child: Row(
            children: [
              for (var i = 1; i <= 3; i++) ...[
                _Step(index: i, label: labels[i - 1], step: step),
                if (i < 3)
                  Expanded(
                    child: Container(
                      height: _line,
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: i < step
                            ? context.colors.primary
                            : context.colors.silver,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.index, required this.label, required this.step});

  final int index;
  final String label;
  final int step;

  /// Bu yazı ölçeğinin üstünde pasif adımların etiketi gizlenir.
  static const double _maxScale = 1.15;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final done = index < step;
    final current = index == step;
    return Row(
      children: [
        Container(
          width: SignupStepper._dot,
          height: SignupStepper._dot,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: done || current ? c.primary : null,
            borderRadius: AppRadius.fullR,
            border: done || current
                ? null
                : Border.all(color: c.silver, width: AppSizesStep.border),
            boxShadow: current
                ? [
                    BoxShadow(
                      color: c.infoBg,
                      spreadRadius: SignupStepper._ring,
                    ),
                  ]
                : null,
          ),
          child: done
              ? Icon(
                  LucideIcons.check,
                  size: AppSizesStep.check,
                  color: c.onPrimary,
                )
              : Text(
                  '$index',
                  style: AppTypography.captionStrong.copyWith(
                    color: current ? c.onPrimary : c.textSecondary,
                  ),
                ),
        ),
        // Büyük yazı boyutunda yalnızca geçerli adımın etiketi (taşma olmasın).
        if (current ||
            MediaQuery.textScalerOf(context).scale(1) <= _maxScale) ...[
          const SizedBox(width: AppSpacing.sm - 1),
          Text(
            label,
            style: AppTypography.label.copyWith(
              fontWeight: current ? FontWeight.w700 : FontWeight.w500,
              color: current || done ? c.textPrimary : c.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Adım göstergesi ölçüleri (1.08 mockup'ı).
class AppSizesStep {
  const AppSizesStep._();
  static const double border = 1.5;
  static const double check = 12;
}

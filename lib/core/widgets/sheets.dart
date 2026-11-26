import 'package:material_ui/material_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../app/locale_controller.dart';
import '../../app/theme_controller.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_buttons.dart';
import 'small_widgets.dart';

/// Alt sayfa tutamacı.
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: AppSizes.sheetHandleWidth,
      height: AppSizes.sheetHandleHeight,
      margin: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.silver,
        borderRadius: AppRadius.fullR,
      ),
    ),
  );
}

/// Onay penceresi (alt sayfa). Birincil düğme "Vazgeç"; ikinci sırada eylem.
/// Onaylanırsa `true` döner.
Future<bool> showConfirmSheet(
  BuildContext context, {
  required String title,
  required List<String> messages,
  required String cancelLabel,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (ctx) {
      final c = ctx.colors;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            0,
            AppSpacing.screen,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SheetHandle(),
              Text(
                title,
                style: AppTypography.title2.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final m in messages) ...[
                Text(
                  m,
                  style: AppTypography.body.copyWith(color: c.textSecondary),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              const SizedBox(height: AppSpacing.xs),
              PrimaryButton(
                label: cancelLabel,
                onPressed: () => Navigator.pop(ctx, false),
              ),
              const SizedBox(height: AppSpacing.md),
              destructive
                  ? DangerButton(
                      label: confirmLabel,
                      onPressed: () => Navigator.pop(ctx, true),
                    )
                  : SecondaryButton(
                      label: confirmLabel,
                      onPressed: () => Navigator.pop(ctx, true),
                    ),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}

/// Tema ve dil seçici (Profil'den açılır; ileride Ayarlar'a taşınabilir).
Future<void> showThemeLanguageSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => const ThemeLanguageSheet(),
  );
}

class ThemeLanguageSheet extends StatelessWidget {
  const ThemeLanguageSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final theme = context.watch<ThemeController>();
    final locale = context.watch<LocaleController>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          0,
          AppSpacing.screen,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SheetHandle(),
            Text(
              l.sheetTitle,
              style: AppTypography.title2.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: AppSpacing.lg),
            _Heading(icon: LucideIcons.sunMoon, text: l.themeHeading),
            _Option(
              label: l.themeSystem,
              selected: theme.mode == ThemeMode.system,
              onTap: () => theme.setMode(ThemeMode.system),
            ),
            _Option(
              label: l.themeLight,
              selected: theme.mode == ThemeMode.light,
              onTap: () => theme.setMode(ThemeMode.light),
            ),
            _Option(
              label: l.themeDark,
              selected: theme.mode == ThemeMode.dark,
              onTap: () => theme.setMode(ThemeMode.dark),
            ),
            const SizedBox(height: AppSpacing.lg),
            _Heading(icon: LucideIcons.globe, text: l.languageHeading),
            _Option(
              label: l.languageSystem,
              selected: locale.choice == LocaleChoice.system,
              onTap: () => locale.setChoice(LocaleChoice.system),
            ),
            _Option(
              label: l.languageTr,
              selected: locale.choice == LocaleChoice.tr,
              onTap: () => locale.setChoice(LocaleChoice.tr),
            ),
            _Option(
              label: l.languageEn,
              selected: locale.choice == LocaleChoice.en,
              onTap: () => locale.setChoice(LocaleChoice.en),
            ),
            const SizedBox(height: AppSpacing.lg),
            SecondaryButton(
              label: l.close,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: AppSizes.iconRow, color: c.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          SectionLabel(text),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.buttonSmallR,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.tapTarget),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style:
                      (selected ? AppTypography.bodyStrong : AppTypography.body)
                          .copyWith(color: c.textPrimary),
                ),
              ),
              if (selected)
                Icon(
                  LucideIcons.check,
                  size: AppSizes.iconAppBar,
                  color: c.accent,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

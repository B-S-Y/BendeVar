import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_buttons.dart';

/// MVP'de olmayan hedefler için yer tutucu sayfa.
class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key, this.title});

  final String? title;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: AppIconButton(
          icon: LucideIcons.arrowLeft,
          tooltip: l.back,
          color: c.onAppBar,
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: Text(title ?? l.comingSoonTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.clock, size: AppSpacing.huge, color: c.silver),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l.comingSoonTitle,
                style: AppTypography.title1.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l.comingSoonBody,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xxl),
              SecondaryButton(
                label: l.back,
                onPressed: () =>
                    context.canPop() ? context.pop() : context.go('/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Basit SnackBar yardımcısı: "Yakında" mesajı.
void showComingSoonSnack(BuildContext context) {
  final l = AppLocalizations.of(context);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(l.comingSoonSnack)));
}

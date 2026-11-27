import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_entrance.dart';
import '../../../l10n/app_localizations.dart';

/// Ayarlar ailesi (1.15, 1.18, 1.19, 1.19a/b, 1.20) ortak sayfa iskeleti:
/// koyu üst bar (geri + başlık) ve kaydırılabilir gövde.
class SettingsScaffold extends StatelessWidget {
  const SettingsScaffold({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  /// Üst bar başlığı için yazı ölçeği sınırı (büyük yazı / ekran boyutu).
  static const double maxTitleTextScale = 1.2;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final top = MediaQuery.paddingOf(context).top;
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: c.appBar,
            padding: EdgeInsets.only(
              top: top,
              left: AppSpacing.xs,
              right: AppSpacing.xs,
            ),
            height: top + AppSizes.tapTarget + AppSpacing.md,
            child: Row(
              children: [
                AppIconButton(
                  icon: LucideIcons.arrowLeft,
                  tooltip: l.back,
                  color: c.onAppBar,
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/profile');
                    }
                  },
                ),
                Expanded(
                  // Başlık tek satır; çok büyük yazıda üst bar taşmasın diye
                  // yazı ölçeği en fazla [maxTitleTextScale] (Ayarlar'ın tüm alt
                  // sayfalarına uygulanır).
                  child: MediaQuery.withClampedTextScaling(
                    maxScaleFactor: maxTitleTextScale,
                    child: Text(
                      title,
                      key: const Key('settings-title'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title1.copyWith(color: c.onAppBar),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Kart satırı: ikon, başlık, isteğe bağlı açıklama ve sağda [trailing]
/// (varsayılan: ok).
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.label,
    this.description,
    this.onTap,
    this.trailing,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final String? description;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = destructive ? c.errorFg : c.textPrimary;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Material(
        color: c.card,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardLargeR,
          side: BorderSide(color: c.cardBorder),
        ),
        child: InkWell(
          borderRadius: AppRadius.cardLargeR,
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: AppSizes.buttonHeight),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Icon(icon, size: AppSizes.iconAppBar, color: fg),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTypography.bodyStrong.copyWith(color: fg),
                      ),
                      if (description != null)
                        Text(
                          description!,
                          style: AppTypography.caption.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                trailing ??
                    (onTap == null
                        ? const SizedBox.shrink()
                        : Icon(
                            LucideIcons.chevronRight,
                            size: AppSizes.iconAppBar,
                            color: c.textSecondary,
                          )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Satırları sırayla yukarı kayarak gelecek şekilde sarar.
List<Widget> staggerRows(List<Widget> rows) => [
  for (final (i, r) in rows.indexed) AppEntrance(index: i, child: r),
];

/// Liste sayfası kenar boşluğu; alttaki sistem çubuğu payı eklenir (son satır
/// gezinme çubuğunun altında kalmasın).
EdgeInsets settingsListPadding(BuildContext context) => EdgeInsets.fromLTRB(
  AppSpacing.screen,
  AppSpacing.sm,
  AppSpacing.screen,
  AppSpacing.xxl + MediaQuery.paddingOf(context).bottom,
);

/// Yükleniyor göstergesi.
class SettingsLoading extends StatelessWidget {
  const SettingsLoading({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppSpacing.xxl),
    child: Center(
      child: CircularProgressIndicator(
        key: const Key('settings-loading'),
        color: context.colors.primary,
      ),
    ),
  );
}

/// Yüklenemedi: kısa açıklama + "Tekrar dene".
class SettingsError extends StatelessWidget {
  const SettingsError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l.loadFailed,
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          SecondaryButton(
            key: const Key('retry'),
            label: l.retry,
            expand: false,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

/// İşlem başarısız: kısa SnackBar + "Tekrar dene".
void showActionFailed(
  ScaffoldMessengerState messenger,
  AppLocalizations l,
  VoidCallback retry,
) {
  messenger.showSnackBar(
    SnackBar(
      content: Text(l.actionFailed),
      action: SnackBarAction(label: l.retry, onPressed: retry),
    ),
  );
}

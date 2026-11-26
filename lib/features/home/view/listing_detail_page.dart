import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/labels.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/coming_soon_page.dart';
import '../../../core/widgets/small_widgets.dart';
import '../../../data/models/models.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/viewmodel/auth_view_model.dart';
import '../viewmodel/home_view_model.dart';

/// 2.14 · İlan detayı (ihtiyaç için de aynı sayfa).
class ListingDetailPage extends StatelessWidget {
  const ListingDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final vm = context.watch<HomeViewModel>();
    final item = vm.byId(id);
    final locale = Localizations.localeOf(context).languageCode;

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.detailTitleListing)),
        body: Center(child: Text(l.emptyResults)),
      );
    }

    final isIlan = item.kind == ListingKind.ilan;
    final communityName =
        context.read<AuthViewModel>().user?.community.name ??
        item.communityShort;
    final rows = <(String, String)>[
      (l.rowCategory, Labels.category(l, item.category)),
      if (item.condition != null)
        (l.rowCondition, Labels.condition(l, item.condition!)),
      (l.rowMode, Labels.mode(l, item.mode)),
      (l.rowPrice, Labels.price(l, item, locale)),
      if (item.availableFrom != null && item.availableTo != null)
        (
          isIlan ? l.rowAvailable : l.rowNeededWhen,
          '${Formatters.dayMonth(item.availableFrom!, locale)}–${Formatters.dayMonth(item.availableTo!, locale)}',
        ),
      if (item.urgency != null)
        (l.rowUrgency, Labels.urgency(l, item.urgency!)),
      (l.rowCommunity, item.communityShort),
    ];

    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: c.card,
              border: Border(bottom: BorderSide(color: c.divider)),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top,
              left: AppSpacing.xs,
              right: AppSpacing.xs,
            ),
            height:
                MediaQuery.paddingOf(context).top +
                AppSizes.tapTarget +
                AppSpacing.sm,
            child: Row(
              children: [
                AppIconButton(
                  icon: LucideIcons.arrowLeft,
                  tooltip: l.back,
                  onPressed: () => context.pop(),
                ),
                Expanded(
                  child: Text(
                    isIlan ? l.detailTitleListing : l.detailTitleNeed,
                    style: AppTypography.appBar.copyWith(color: c.textPrimary),
                  ),
                ),
                IconButton(
                  onPressed: () => vm.toggleFavorite(item.id),
                  tooltip: item.isFavorite ? l.favoriteRemove : l.favoriteAdd,
                  icon: FavoriteIcon(
                    filled: item.isFavorite,
                    color: c.textPrimary,
                    size: AppSizes.iconAppBar,
                  ),
                ),
                AppIconButton(
                  icon: LucideIcons.share,
                  tooltip: l.share,
                  onPressed: () => showComingSoonSnack(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.screen),
              children: [
                Container(
                  height: AppSizes.thumb * 2 + AppSpacing.md,
                  decoration: BoxDecoration(
                    color: c.disabledBg,
                    borderRadius: AppRadius.cardLargeR,
                  ),
                  child: Icon(
                    isIlan ? LucideIcons.package : LucideIcons.search,
                    size: AppSizes.avatarLg - AppSpacing.sm,
                    color: c.silver,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    ListingKindBadge(kind: item.kind, large: true),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs + 2,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: AppRadius.fullR,
                        border: Border.all(color: c.fieldBorder),
                      ),
                      child: Text(
                        l.statusPublished,
                        style: AppTypography.captionStrong.copyWith(
                          letterSpacing: 0.4,
                          color: c.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  item.title,
                  style: AppTypography.title1.copyWith(color: c.textPrimary),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    const AppAvatar(size: AppSizes.avatar / 2 + AppSpacing.xs),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        '${item.ownerName} · $communityName · ${Formatters.relative(l, item.postedAt, DateTime.now())}',
                        style: AppTypography.bodySmall.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                for (final (k, v) in rows)
                  Container(
                    constraints: const BoxConstraints(
                      minHeight: AppSizes.tapTarget,
                    ),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: c.cardBorder)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            k,
                            style: AppTypography.body.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                        ),
                        Text(
                          v,
                          style: AppTypography.bodyStrong.copyWith(
                            color: c.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    item.description,
                    style: AppTypography.body.copyWith(color: c.textPrimary),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.md,
              AppSpacing.screen,
              AppSpacing.md + MediaQuery.paddingOf(context).bottom,
            ),
            decoration: BoxDecoration(
              color: c.card,
              border: Border(top: BorderSide(color: c.divider)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SecondaryButton(
                    label: item.isFavorite ? l.favorited : l.favorite,
                    onPressed: () => vm.toggleFavorite(item.id),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  flex: 3,
                  child: PrimaryButton(
                    label: isIlan
                        ? (item.mode == ListingMode.lend
                              ? l.actionBorrow
                              : l.actionBuy)
                        : l.respondHaveIt,
                    onPressed: () => showComingSoonSnack(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

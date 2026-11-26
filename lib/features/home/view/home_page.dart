import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/labels.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/coming_soon_page.dart';
import '../../../core/widgets/listing_card.dart';
import '../../../core/widgets/small_widgets.dart';
import '../../../data/models/models.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/viewmodel/auth_view_model.dart';
import '../viewmodel/home_view_model.dart';

/// 2.01 · Ana Sayfa
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final vm = context.watch<HomeViewModel>();
    final items = vm.visible;
    final isIlan = vm.kind == ListingKind.ilan;

    return Column(
      children: [
        _Header(vm: vm),
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppSpacing.lg,
                  AppSpacing.screen,
                  0,
                ),
                sliver: SliverList.list(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            fieldKey: const Key('search-field'),
                            hint: l.searchHint,
                            prefixIcon: LucideIcons.search,
                            onChanged: vm.setQuery,
                            suffix: AppIconButton(
                              icon: LucideIcons.mic,
                              tooltip: l.voiceSearch,
                              size: AppSizes.iconRow + 2,
                              onPressed: () => showComingSoonSnack(context),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _FilterButton(
                          tooltip: l.filters,
                          onTap: () => showComingSoonSnack(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppSegmented<ListingKind>(
                      value: vm.kind,
                      onChanged: vm.setKind,
                      items: [
                        SegmentItem(
                          value: ListingKind.ilan,
                          label: l.tabListings(vm.countOf(ListingKind.ilan)),
                        ),
                        SegmentItem(
                          value: ListingKind.ihtiyac,
                          label: l.tabNeeds(vm.countOf(ListingKind.ihtiyac)),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      height: AppSizes.tapTarget,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: ListingCategory.values.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: AppSpacing.sm),
                        itemBuilder: (_, i) {
                          final cat = ListingCategory.values[i];
                          return CategoryChip(
                            label: Labels.category(l, cat),
                            selected: vm.category == cat,
                            onTap: () => vm.setCategory(cat),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isIlan
                                ? l.countListings(items.length)
                                : l.countNeeds(items.length),
                            style: AppTypography.bodySmall.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: vm.toggleSort,
                          icon: Icon(
                            LucideIcons.arrowUpDown,
                            size: AppSizes.iconRow,
                            color: c.textPrimary,
                          ),
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                vm.sort == ListingSort.newest
                                    ? l.sortNewest
                                    : l.sortOldest,
                                style: AppTypography.label.copyWith(
                                  color: c.textPrimary,
                                ),
                              ),
                              Icon(
                                LucideIcons.chevronDown,
                                size: AppSizes.iconRow,
                                color: c.textPrimary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _Empty(
                    text: vm.onlyFavorites ? l.emptyFavorites : l.emptyResults,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    0,
                    AppSpacing.screen,
                    AppSpacing.xxl,
                  ),
                  sliver: SliverList.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (_, i) {
                      final item = items[i];
                      return ListingCard(
                        key: ValueKey(item.id),
                        listing: item,
                        onTap: () => context.push('/listing/${item.id}'),
                        onFavorite: () => vm.toggleFavorite(item.id),
                        onRespond: item.kind == ListingKind.ihtiyac
                            ? () => showComingSoonSnack(context)
                            : null,
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.vm});
  final HomeViewModel vm;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final community = context.watch<AuthViewModel>().user?.community.name ?? '';
    return Container(
      color: c.appBar,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screen,
        MediaQuery.paddingOf(context).top + AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              button: true,
              child: InkWell(
                borderRadius: AppRadius.buttonR,
                onTap: () => showComingSoonSnack(context),
                child: Container(
                  height: AppSizes.tapTarget + AppSpacing.xs,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: c.appBarFieldFill,
                    borderRadius: AppRadius.buttonR,
                    border: Border.all(color: c.appBarFieldBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.mapPin,
                        size: AppSizes.iconAppBar,
                        color: c.onAppBar,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.communityLabel.toUpperCase(),
                              style: AppTypography.caption.copyWith(
                                color: c.onAppBar.withValues(alpha: 0.7),
                                height: 1.1,
                              ),
                            ),
                            Text(
                              community,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.label.copyWith(
                                color: c.onAppBar,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        LucideIcons.chevronDown,
                        size: AppSizes.iconAppBar,
                        color: c.onAppBar,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: vm.toggleOnlyFavorites,
            tooltip: vm.onlyFavorites ? l.showAll : l.showFavorites,
            constraints: const BoxConstraints(
              minWidth: AppSizes.tapTarget,
              minHeight: AppSizes.tapTarget,
            ),
            icon: FavoriteIcon(
              filled: vm.onlyFavorites,
              color: c.onAppBar,
              size: AppSizes.iconAppBar + 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.tooltip, required this.onTap});
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: c.card,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.fieldR,
          side: BorderSide(color: c.fieldBorder),
        ),
        child: InkWell(
          borderRadius: AppRadius.fieldR,
          onTap: onTap,
          child: SizedBox(
            width: AppSizes.fieldHeight,
            height: AppSizes.fieldHeight,
            child: Icon(
              LucideIcons.slidersHorizontal,
              size: AppSizes.iconAppBar,
              color: c.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.search, size: AppSizes.avatar, color: c.silver),
          const SizedBox(height: AppSpacing.md),
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}

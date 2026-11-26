import 'package:material_ui/material_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/models/models.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../utils/formatters.dart';
import '../utils/labels.dart';
import 'app_buttons.dart';
import 'small_widgets.dart';

/// Ana sayfa kartı (Emine · Bileşenler v6). İhtiyaç kartında "Bende Var" düğmesi.
class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
    required this.onFavorite,
    this.onRespond,
  });

  final Listing listing;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback? onRespond;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final isNeed = listing.kind == ListingKind.ihtiyac;

    final thumb = isNeed
        ? DashedBox(
            size: AppSizes.thumb,
            child: Icon(LucideIcons.search, size: 32, color: c.textPrimary),
          )
        : Container(
            width: AppSizes.thumb,
            height: AppSizes.thumb,
            decoration: BoxDecoration(
              color: c.disabledBg,
              borderRadius: AppRadius.thumbR,
            ),
            child: Icon(LucideIcons.package, size: 32, color: c.silver),
          );

    final owner = Row(
      children: [
        const AppAvatar(size: AppSizes.avatarSm),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            '${listing.ownerName} · ${Formatters.relative(l, listing.postedAt, DateTime.now())}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(color: c.textSecondary),
          ),
        ),
      ],
    );

    return Semantics(
      container: true,
      child: Material(
        color: c.card,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardR,
          side: BorderSide(color: c.cardBorder),
        ),
        child: InkWell(
          borderRadius: AppRadius.cardR,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    thumb,
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              right: AppSpacing.xxxl,
                            ),
                            child: Text(
                              listing.title,
                              style: AppTypography.appBar.copyWith(
                                color: c.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            Labels.meta(l, listing, locale),
                            style: AppTypography.bodySmall.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          if (isNeed && onRespond != null)
                            Row(
                              children: [
                                Expanded(child: owner),
                                const SizedBox(width: AppSpacing.sm),
                                SecondaryButton(
                                  label: l.respondHaveIt,
                                  small: true,
                                  expand: false,
                                  onPressed: onRespond,
                                ),
                              ],
                            )
                          else
                            owner,
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: -AppSpacing.sm,
                  right: -AppSpacing.sm,
                  child: IconButton(
                    onPressed: onFavorite,
                    tooltip: listing.isFavorite
                        ? l.favoriteRemove
                        : l.favoriteAdd,
                    constraints: const BoxConstraints(
                      minWidth: AppSizes.tapTarget,
                      minHeight: AppSizes.tapTarget,
                    ),
                    icon: FavoriteIcon(
                      filled: listing.isFavorite,
                      color: c.textPrimary,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

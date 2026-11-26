import 'package:material_ui/material_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_logo.dart';

/// Alt menü (STIL_STANDARTLARI "Alt menü"): sadece ikon, etiket yok.
/// Sıra: Ana sayfa, Mesajlar, ortada logo (ilan ver), Bildirimler, Profil.
/// Sekme indeksleri 0..3 (Ana sayfa, Mesajlar, Bildirimler, Profil);
/// [selectedIndex] `null` ise (logo paneli açıkken) hiçbir sekme mavi olmaz.
class BendeVarBottomNav extends StatelessWidget {
  const BendeVarBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    required this.onLogoTap,
    this.notificationBadge = 0,
  });

  final int? selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogoTap;
  final int notificationBadge;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      height: AppSizes.navHeight + bottomInset,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: c.navBg,
        border: Border(
          top: BorderSide(color: c.divider.withValues(alpha: 0.6)),
        ),
      ),
      child: Row(
        children: [
          _NavItem(
            icon: LucideIcons.house,
            tooltip: l.navHome,
            selected: selectedIndex == 0,
            onTap: () => onSelect(0),
          ),
          _NavItem(
            icon: LucideIcons.messageCircle,
            tooltip: l.navMessages,
            selected: selectedIndex == 1,
            onTap: () => onSelect(1),
          ),
          Expanded(
            child: Center(
              child: Semantics(
                button: true,
                label: l.navCreate,
                child: GestureDetector(
                  key: const Key('nav-logo'),
                  behavior: HitTestBehavior.opaque,
                  onTap: onLogoTap,
                  child: SizedBox(
                    width: AppSizes.tapTarget,
                    height: AppSizes.tapTarget,
                    child: Center(
                      child: AppLogo(
                        size: AppSizes.navLogo,
                        tile: c.navLogoBg,
                        glyph: c.navLogoFg,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          _NavItem(
            icon: LucideIcons.bell,
            tooltip: l.navNotifications,
            selected: selectedIndex == 2,
            onTap: () => onSelect(2),
            badge: notificationBadge,
          ),
          _NavItem(
            icon: LucideIcons.user,
            tooltip: l.navProfile,
            selected: selectedIndex == 3,
            onTap: () => onSelect(3),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.onTap,
    this.badge = 0,
  });

  final IconData icon;
  final String tooltip;
  final bool selected;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: tooltip,
        child: InkResponse(
          onTap: onTap,
          radius: AppSizes.tapTarget / 2 + AppSpacing.sm,
          child: Center(
            child: Container(
              width: AppSizes.navPillWidth,
              height: AppSizes.navPillHeight,
              decoration: BoxDecoration(
                color: selected ? c.navPill : Colors.transparent,
                borderRadius: AppRadius.fullR,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Icon(
                    icon,
                    size: AppSizes.navIcon,
                    color: selected ? c.navPillIcon : c.navIcon,
                  ),
                  if (badge > 0)
                    Positioned(
                      top: 0,
                      right: AppSpacing.sm,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: AppSizes.badge,
                          minHeight: AppSizes.badge,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: c.badge,
                          shape: BoxShape.rectangle,
                          borderRadius: AppRadius.fullR,
                        ),
                        child: Text(
                          '$badge',
                          style: AppTypography.captionStrong.copyWith(
                            color: c.onBadge,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/coming_soon_page.dart';
import '../../../core/widgets/sheets.dart';
import '../../../data/models/models.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/viewmodel/auth_view_model.dart';
import '../viewmodel/profile_view_models.dart';

/// 5.01 · Profilim
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final auth = context.watch<AuthViewModel>();
    final vm = context.watch<ProfileViewModel>();
    final user = auth.user;
    if (user == null) return const SizedBox.shrink();

    Future<void> logout() async {
      final ok = await showConfirmSheet(
        context,
        title: l.logoutTitle,
        messages: [l.logoutLine1, l.logoutLine2, l.logoutLine3],
        cancelLabel: l.cancel,
        confirmLabel: l.logout,
      );
      if (ok && context.mounted) {
        await auth.signOut();
        if (context.mounted) context.go('/welcome');
      }
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          decoration: BoxDecoration(
            color: c.appBar,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(AppRadius.sheet),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screen,
            MediaQuery.paddingOf(context).top + AppSpacing.sm,
            AppSpacing.screen,
            AppSpacing.screen,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l.profileTitle,
                      style: AppTypography.title1.copyWith(color: c.onAppBar),
                    ),
                  ),
                  AppIconButton(
                    icon: LucideIcons.settings,
                    tooltip: l.settings,
                    color: c.onAppBar,
                    onPressed: () => context.push('/settings'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Container(
                    width: AppSizes.avatarLg * 2 / 1.5,
                    height: AppSizes.avatarLg * 2 / 1.5,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: c.disabledBg,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      user.initials,
                      style: AppTypography.brand.copyWith(color: c.textPrimary),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                user.displayName,
                                style: AppTypography.title1.copyWith(
                                  color: c.onAppBar,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Icon(
                              LucideIcons.badgeCheck,
                              size: AppSizes.iconAppBar + 2,
                              color: c.accent,
                            ),
                          ],
                        ),
                        Text(
                          '${user.department} · ${user.community.shortName}',
                          style: AppTypography.bodySmall.copyWith(
                            color: c.onAppBar.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                user.bio,
                style: AppTypography.bodySmall.copyWith(
                  color: c.onAppBar.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Material(
                color: c.disabledBg,
                shape: const StadiumBorder(),
                child: InkWell(
                  customBorder: const StadiumBorder(),
                  onTap: () => showComingSoonSnack(context),
                  child: SizedBox(
                    height: AppSizes.buttonHeight - AppSpacing.sm,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.pencil,
                          size: AppSizes.iconRow,
                          color: c.textPrimary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          l.edit,
                          style: AppTypography.button.copyWith(
                            color: c.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Stat(
                    value: Formatters.decimal(user.rating, locale),
                    label: l.statRating,
                    star: true,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _Stat(
                    value: '${user.transactions}',
                    label: l.statTransactions,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _Stat(
                    value: Formatters.percent(user.onTimeRate, locale),
                    label: l.statOnTime,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l.sectionPending,
                style: AppTypography.title2.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final p in vm.pending)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _PendingCard(item: p),
                ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l.loansTitle,
                      style: AppTypography.title2.copyWith(
                        color: c.textPrimary,
                      ),
                    ),
                  ),
                  AppIconButton(
                    icon: LucideIcons.arrowRight,
                    tooltip: l.loansTitle,
                    onPressed: () => context.push('/loans'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _LoanTile(
                      icon: LucideIcons.arrowDownLeft,
                      label: l.borrowed,
                      count: vm.borrowedCount,
                      onTap: () => context.push('/loans'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _LoanTile(
                      icon: LucideIcons.arrowUpRight,
                      label: l.lent,
                      count: vm.lentCount,
                      onTap: () => context.push('/loans?dir=lent'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _MenuRow(
                icon: LucideIcons.listChecks,
                label: l.myListingsAndNeeds,
                onTap: () => context.push('/coming-soon'),
              ),
              _MenuRow(
                icon: LucideIcons.sunMoon,
                label: l.themeAndLanguage,
                onTap: () => showThemeLanguageSheet(context),
              ),
              _MenuRow(
                icon: LucideIcons.logOut,
                label: l.logout,
                onTap: logout,
                destructive: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.star = false});
  final String value;
  final String label;
  final bool star;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: AppRadius.cardLargeR,
          border: Border.all(color: c.cardBorder),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: AppTypography.title1.copyWith(color: c.textPrimary),
                ),
                if (star) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    LucideIcons.star,
                    size: AppSizes.iconRow,
                    color: c.warningFg,
                  ),
                ],
              ],
            ),
            Text(
              label,
              style: AppTypography.caption.copyWith(color: c.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({required this.item});
  final PendingItem item;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final (fg, bg, icon, title, sub) = switch (item.kind) {
      PendingKind.newResponses => (
        c.infoFg,
        c.infoBg,
        LucideIcons.inbox,
        l.pendingNewResponses(item.count),
        item.itemTitle,
      ),
      PendingKind.overdue => (
        c.errorFg,
        c.errorBg,
        LucideIcons.calendarX,
        l.daysLate(1),
        item.itemTitle,
      ),
      PendingKind.handover => (
        c.warningFg,
        c.warningBg,
        LucideIcons.qrCode,
        l.pendingHandover,
        '${item.itemTitle} · ${Formatters.weekdayLong(item.when!, locale)}',
      ),
    };
    return Material(
      color: bg,
      borderRadius: AppRadius.cardLargeR,
      child: InkWell(
        borderRadius: AppRadius.cardLargeR,
        onTap: () => context.push('/loans'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(icon, size: AppSizes.iconAppBar + 2, color: fg),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyStrong.copyWith(color: fg),
                    ),
                    Text(
                      sub,
                      style: AppTypography.bodySmall.copyWith(color: fg),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                size: AppSizes.iconAppBar,
                color: fg,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoanTile extends StatelessWidget {
  const _LoanTile({
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.card,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardLargeR,
        side: BorderSide(color: c.cardBorder),
      ),
      child: InkWell(
        borderRadius: AppRadius.cardLargeR,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: AppSizes.avatar + AppSpacing.sm,
                height: AppSizes.avatar + AppSpacing.sm,
                decoration: BoxDecoration(
                  color: c.disabledBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: AppSizes.iconAppBar,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                label,
                style: AppTypography.title2.copyWith(color: c.textPrimary),
              ),
              Text(
                '$count',
                style: AppTypography.body.copyWith(color: c.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
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
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Icon(icon, size: AppSizes.iconAppBar, color: fg),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.bodyStrong.copyWith(color: fg),
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  size: AppSizes.iconAppBar,
                  color: c.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

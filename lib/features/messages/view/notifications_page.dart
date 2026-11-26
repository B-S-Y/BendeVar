import 'package:material_ui/material_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/coming_soon_page.dart';
import '../../../core/widgets/small_widgets.dart';
import '../../../data/models/models.dart';
import '../../../l10n/app_localizations.dart';
import '../viewmodel/messages_view_models.dart';

/// 4.07 · Bildirimler
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final vm = context.watch<NotificationsViewModel>();
    final now = DateTime.now();
    final returns = vm.returns;
    final today = vm.today(now);
    final week = vm.thisWeek(now);

    return Column(
      children: [
        Container(
          color: c.appBar,
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screen,
            MediaQuery.paddingOf(context).top + AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l.notificationsTitle,
                  style: AppTypography.title1.copyWith(color: c.onAppBar),
                ),
              ),
              TextButton(
                onPressed: vm.unreadCount == 0 ? null : vm.markAllRead,
                style: TextButton.styleFrom(
                  minimumSize: const Size(
                    AppSizes.tapTarget,
                    AppSizes.tapTarget,
                  ),
                  foregroundColor: c.onAppBar,
                ),
                child: Text(
                  l.markAllRead,
                  style: AppTypography.bodyStrong.copyWith(
                    color: vm.unreadCount == 0
                        ? c.onAppBar.withValues(alpha: 0.5)
                        : c.onAppBar,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
            children: [
              if (returns.isNotEmpty) ...[
                _Section(l.sectionUpcomingReturns),
                for (final n in returns)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screen,
                      0,
                      AppSpacing.screen,
                      AppSpacing.md,
                    ),
                    child: _ReturnCard(item: n),
                  ),
              ],
              if (today.isNotEmpty) ...[
                _Section(l.sectionToday),
                for (final n in today) _Row(item: n, vm: vm),
              ],
              if (week.isNotEmpty) ...[
                _Section(l.sectionThisWeek),
                for (final n in week) _Row(item: n, vm: vm),
              ],
              if (returns.isEmpty && today.isEmpty && week.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxxl),
                  child: Text(
                    l.emptyNotifications,
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(color: c.textSecondary),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.screen,
      AppSpacing.lg,
      AppSpacing.screen,
      AppSpacing.sm,
    ),
    child: SectionLabel(text),
  );
}

class _ReturnCard extends StatelessWidget {
  const _ReturnCard({required this.item});
  final AppNotification item;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final overdue = item.type == NotificationType.overdue;
    final fg = overdue ? c.errorFg : c.warningFg;
    final bg = overdue ? c.errorBg : c.warningBg;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.cardLargeR,
        border: Border(
          left: BorderSide(color: fg, width: AppSpacing.xs),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md + AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                overdue ? LucideIcons.circleAlert : LucideIcons.clock,
                size: AppSizes.iconAppBar,
                color: fg,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  item.itemTitle,
                  style: AppTypography.title2.copyWith(color: fg),
                ),
              ),
              Text(
                overdue ? l.daysLate(item.daysLate) : l.tomorrow,
                style: AppTypography.label.copyWith(color: fg),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            overdue
                ? l.notifOverdueBody(item.peerName)
                : l.notifDueSoonBody(item.peerName),
            style: AppTypography.bodySmall.copyWith(color: fg),
          ),
          const SizedBox(height: AppSpacing.sm),
          Material(
            color: overdue ? fg : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.buttonSmallR,
              side: overdue
                  ? BorderSide.none
                  : BorderSide(color: fg, width: AppSizes.borderStrong),
            ),
            child: InkWell(
              borderRadius: AppRadius.buttonSmallR,
              onTap: () => showComingSoonSnack(context),
              child: Container(
                height: AppSizes.buttonSmallHeight,
                constraints: const BoxConstraints(minWidth: AppSizes.tapTarget),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      overdue ? l.actionReturned : l.actionMessage,
                      style: AppTypography.buttonSmall.copyWith(
                        color: overdue ? c.card : fg,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.item, required this.vm});
  final AppNotification item;
  final NotificationsViewModel vm;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    final (badgeIcon, badgeBg) = switch (item.type) {
      NotificationType.response => (LucideIcons.archive, c.accent),
      NotificationType.message => (LucideIcons.messageSquare, c.primary),
      _ => (LucideIcons.check, c.successFg),
    };
    final rest = switch (item.type) {
      NotificationType.response => l.notifResponseRest(item.itemTitle),
      NotificationType.message => l.notifMessageRest(item.messageText),
      _ => l.notifAcceptedRest(item.itemTitle),
    };

    return Material(
      color: item.isRead ? c.card : c.unreadTint,
      child: InkWell(
        onTap: () => vm.markRead(item.id),
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: c.cardBorder)),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screen,
            vertical: AppSpacing.md + AppSpacing.xs,
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AppAvatar(
                    initials: item.peerInitials,
                    tone: item.peerTone,
                    size: AppSizes.avatar - AppSpacing.sm,
                  ),
                  Positioned(
                    right: -AppSpacing.xs,
                    bottom: -AppSpacing.xs,
                    child: Container(
                      width: AppSizes.badge + AppSpacing.xs,
                      height: AppSizes.badge + AppSpacing.xs,
                      decoration: BoxDecoration(
                        color: badgeBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.card, width: 2),
                      ),
                      child: Icon(
                        badgeIcon,
                        size: AppSizes.iconField - 4,
                        color: c.card,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: item.peerName,
                            style: AppTypography.bodyStrong.copyWith(
                              color: c.textPrimary,
                            ),
                          ),
                          TextSpan(
                            text: ' $rest',
                            style: AppTypography.body.copyWith(
                              color: c.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      Formatters.chatTime(
                        l,
                        item.createdAt,
                        DateTime.now(),
                        locale,
                      ),
                      style: AppTypography.caption.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!item.isRead)
                Container(
                  width: AppSizes.dot,
                  height: AppSizes.dot,
                  margin: const EdgeInsets.only(left: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: c.accent,
                    shape: BoxShape.circle,
                  ),
                )
              else
                const SizedBox(width: AppSizes.dot),
            ],
          ),
        ),
      ),
    );
  }
}

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
import '../../../core/widgets/small_widgets.dart';
import '../../../data/models/models.dart';
import '../../../l10n/app_localizations.dart';
import '../viewmodel/profile_view_models.dart';

/// 5.07 · Ödünçlerim · Aldıklarım / Verdiklerim
class LoansPage extends StatelessWidget {
  const LoansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final vm = context.watch<LoansViewModel>();

    return Scaffold(
      body: Column(
        children: [
          Container(
            color: c.appBar,
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top,
              left: AppSpacing.xs,
              right: AppSpacing.xs,
            ),
            height:
                MediaQuery.paddingOf(context).top +
                AppSizes.tapTarget +
                AppSpacing.md,
            child: Row(
              children: [
                AppIconButton(
                  icon: LucideIcons.arrowLeft,
                  tooltip: l.back,
                  color: c.onAppBar,
                  onPressed: () => context.pop(),
                ),
                Expanded(
                  child: Text(
                    l.loansTitle,
                    style: AppTypography.title1.copyWith(color: c.onAppBar),
                  ),
                ),
                AppIconButton(
                  icon: LucideIcons.qrCode,
                  tooltip: l.qrScan,
                  color: c.onAppBar,
                  onPressed: () => showComingSoonSnack(context),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _Tab(
                label: l.borrowed,
                selected: vm.direction == LoanDirection.borrowed,
                onTap: () => vm.setDirection(LoanDirection.borrowed),
              ),
              _Tab(
                label: l.lent,
                selected: vm.direction == LoanDirection.lent,
                onTap: () => vm.setDirection(LoanDirection.lent),
              ),
            ],
          ),
          Divider(height: 1, color: c.cardBorder),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screen),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: AppSpacing.sm,
                children: [
                  CategoryChip(
                    label: l.filterAll,
                    selected: vm.filter == LoanFilter.all,
                    showCheck: true,
                    onTap: () => vm.setFilter(LoanFilter.all),
                  ),
                  CategoryChip(
                    label: l.filterActive,
                    selected: vm.filter == LoanFilter.active,
                    showCheck: true,
                    onTap: () => vm.setFilter(LoanFilter.active),
                  ),
                  CategoryChip(
                    label: l.filterPast,
                    selected: vm.filter == LoanFilter.past,
                    showCheck: true,
                    onTap: () => vm.setFilter(LoanFilter.past),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: vm.loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screen,
                      0,
                      AppSpacing.screen,
                      AppSpacing.xxl,
                    ),
                    itemCount: vm.visible.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (_, i) => _LoanCard(loan: vm.visible[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
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
    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: AppSizes.tapTarget + AppSpacing.xs,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: selected ? c.primary : Colors.transparent,
                  width: AppSpacing.xs,
                ),
              ),
            ),
            child: Text(
              label,
              style: AppTypography.bodyStrong.copyWith(
                color: selected ? c.textPrimary : c.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoanCard extends StatelessWidget {
  const _LoanCard({required this.loan});
  final Loan loan;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    final (statusLabel, fg, bg) = switch (loan.status) {
      LoanStatus.overdue => (l.daysLate(loan.daysLate), c.errorFg, c.errorBg),
      LoanStatus.onLoan => (l.statusOnLoan, c.successFg, c.successBg),
      LoanStatus.awaitingHandover => (
        l.statusAwaiting,
        c.warningFg,
        c.warningBg,
      ),
      LoanStatus.returned => (l.statusReturned, c.infoFg, c.infoBg),
    };
    final borrowed = loan.direction == LoanDirection.borrowed;
    final (actionLabel, actionIcon) = switch (loan.status) {
      LoanStatus.overdue when borrowed => (l.actionReturn, LucideIcons.qrCode),
      LoanStatus.onLoan when borrowed => (
        l.actionEarlyReturn,
        LucideIcons.undo2,
      ),
      LoanStatus.awaitingHandover when borrowed => (
        l.actionScanQr,
        LucideIcons.qrCode,
      ),
      LoanStatus.awaitingHandover => (l.actionShowQr, LucideIcons.qrCode),
      LoanStatus.returned => (null, null),
      _ => (l.actionScanQr, LucideIcons.qrCode),
    };
    final soft = loan.status == LoanStatus.onLoan && borrowed;
    final dateText = loan.status == LoanStatus.awaitingHandover
        ? '${Formatters.weekdayLong(loan.date, locale)} ${Formatters.time(loan.date, locale)}'
        : Formatters.dayMonth(loan.date, locale);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: AppRadius.cardLargeR,
        border: loan.status == LoanStatus.overdue
            ? Border.all(color: c.errorFg, width: AppSizes.borderWidth)
            : Border.all(color: c.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppSizes.avatarLg - AppSpacing.sm,
                height: AppSizes.avatarLg - AppSpacing.sm,
                decoration: BoxDecoration(
                  color: c.disabledBg,
                  borderRadius: AppRadius.cardLargeR,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loan.title,
                      style: AppTypography.title2.copyWith(
                        color: c.textPrimary,
                      ),
                    ),
                    Text(
                      loan.peerName,
                      style: AppTypography.body.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              StatusPill(label: statusLabel, fg: fg, bg: bg),
              const SizedBox(width: AppSpacing.md),
              Icon(
                LucideIcons.calendarCheck,
                size: AppSizes.iconAppBar,
                color: c.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                dateText,
                style: AppTypography.body.copyWith(color: c.textSecondary),
              ),
            ],
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => showComingSoonSnack(context),
                  tooltip: l.sendMessage,
                  style: IconButton.styleFrom(
                    backgroundColor: c.disabledBg,
                    fixedSize: const Size(
                      AppSizes.tapTarget,
                      AppSizes.tapTarget,
                    ),
                  ),
                  icon: Icon(
                    LucideIcons.messageSquareText,
                    size: AppSizes.iconAppBar,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                soft
                    ? _SoftButton(
                        label: actionLabel,
                        icon: actionIcon!,
                        onTap: () => showComingSoonSnack(context),
                      )
                    : PrimaryButton(
                        label: actionLabel,
                        icon: actionIcon,
                        small: true,
                        expand: false,
                        onPressed: () => showComingSoonSnack(context),
                      ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SoftButton extends StatelessWidget {
  const _SoftButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.disabledBg,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          height: AppSizes.tapTarget,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: AppSizes.iconRow, color: c.textPrimary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: AppTypography.buttonSmall.copyWith(color: c.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

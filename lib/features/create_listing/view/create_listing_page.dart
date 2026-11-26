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
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/coming_soon_page.dart';
import '../../../core/widgets/small_widgets.dart';
import '../../../data/models/models.dart';
import '../../../l10n/app_localizations.dart';
import '../viewmodel/create_listing_view_model.dart';

/// 3.02 · İlan: tek sayfa form ve 3.11 · İhtiyaç: tek sayfa form.
class CreateListingPage extends StatelessWidget {
  const CreateListingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final vm = context.watch<CreateListingViewModel>();
    final isIlan = vm.isIlan;
    final locale = Localizations.localeOf(context).languageCode;

    Future<void> publish() async {
      final listing = await vm.publish();
      if (listing != null && context.mounted) {
        context.pushReplacement('/published/${listing.id}');
      }
    }

    Future<void> pick(bool isFrom) async {
      final now = DateTime.now();
      final initial = (isFrom ? vm.from : vm.to) ?? now;
      final picked = await showDatePicker(
        context: context,
        initialDate: initial.isBefore(now) ? now : initial,
        firstDate: DateTime(now.year, now.month, now.day),
        lastDate: DateTime(now.year + 2),
      );
      if (picked == null) return;
      isFrom ? vm.setFrom(picked) : vm.setTo(picked);
    }

    return Scaffold(
      body: Column(
        children: [
          Container(
            color: c.card,
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top,
              left: AppSpacing.xs,
            ),
            height:
                MediaQuery.paddingOf(context).top +
                AppSizes.tapTarget +
                AppSpacing.sm,
            child: Row(
              children: [
                AppIconButton(
                  icon: LucideIcons.x,
                  tooltip: l.close,
                  onPressed: () => context.pop(),
                ),
                Text(
                  isIlan ? l.newListingTitle : l.newNeedTitle,
                  style: AppTypography.appBar.copyWith(color: c.textPrimary),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.screen),
              children: [
                _FormCard(
                  title: l.sectionItem,
                  children: [
                    if (isIlan) ...[
                      _Label(l.fieldPhotos),
                      Row(
                        children: [
                          _PhotoTile(
                            dashed: true,
                            onTap: () => showComingSoonSnack(context),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.camera,
                                  size: AppSizes.iconAppBar + 2,
                                  color: c.textPrimary,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  l.photoAdd,
                                  style: AppTypography.label.copyWith(
                                    color: c.infoFg,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _PhotoTile(
                            fill: c.infoBg,
                            onTap: () => showComingSoonSnack(context),
                            child: Icon(
                              LucideIcons.image,
                              size: AppSizes.iconAppBar + 2,
                              color: c.primary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _PhotoTile(
                            fill: c.disabledBg,
                            onTap: () => showComingSoonSnack(context),
                            child: Icon(
                              LucideIcons.plus,
                              size: AppSizes.iconAppBar + 2,
                              color: c.silver,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    AppTextField(
                      fieldKey: const Key('title-field'),
                      label: l.fieldTitle,
                      onChanged: vm.setTitle,
                      errorText: vm.titleError == null ? null : l.errorRequired,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _Label(l.fieldCategory),
                    _Grid(
                      children: [
                        for (final cat in ListingCategory.values)
                          CategoryChip(
                            label: Labels.category(l, cat),
                            selected: vm.category == cat,
                            expand: true,
                            onTap: () => vm.setCategory(cat),
                          ),
                      ],
                    ),
                    if (vm.categoryError) _Error(l.errorChoose),
                    if (isIlan) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _Label(l.fieldCondition),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final cond in ListingCondition.values)
                            CategoryChip(
                              label: Labels.condition(l, cond),
                              selected: vm.condition == cond,
                              onTap: () => vm.setCondition(cond),
                            ),
                        ],
                      ),
                      if (vm.conditionError) _Error(l.errorChoose),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      fieldKey: const Key('description-field'),
                      label: l.fieldDescription,
                      minLines: 3,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      onChanged: vm.setDescription,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _FormCard(
                  title: l.sectionTerms,
                  children: [
                    _Label(isIlan ? l.fieldAvailability : l.fieldNeededWhen),
                    Row(
                      children: [
                        Expanded(
                          child: _DateField(
                            key: const Key('date-from'),
                            text: vm.from == null
                                ? l.datePick
                                : Formatters.dayMonth(vm.from!, locale),
                            filled: vm.from != null,
                            onTap: () => pick(true),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _DateField(
                            key: const Key('date-to'),
                            text: vm.to == null
                                ? l.datePick
                                : Formatters.dayMonth(vm.to!, locale),
                            filled: vm.to != null,
                            onTap: () => pick(false),
                          ),
                        ),
                      ],
                    ),
                    if (vm.datesError) _Error(l.errorDates),
                    if (isIlan) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _Label(l.fieldMode),
                      Wrap(
                        spacing: AppSpacing.sm,
                        children: [
                          for (final m in ListingMode.values)
                            CategoryChip(
                              label: Labels.mode(l, m),
                              selected: vm.mode == m,
                              onTap: () => vm.setMode(m),
                            ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: AppSpacing.lg),
                      _Label(l.fieldUrgency),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final u in Urgency.values)
                            CategoryChip(
                              label: Labels.urgency(l, u),
                              selected: vm.urgency == u,
                              onTap: () => vm.setUrgency(u),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    _Label(l.fieldPrice),
                    AppSegmented<bool>(
                      value: vm.paid,
                      onChanged: vm.setPaid,
                      items: [
                        SegmentItem(value: false, label: l.priceFree),
                        SegmentItem(value: true, label: l.pricePaid),
                      ],
                    ),
                    if (vm.paid) ...[
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppTextField(
                              fieldKey: const Key('price-field'),
                              hint: l.priceHint,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              onChanged: vm.setPriceText,
                              errorText: vm.priceError ? l.errorPrice : null,
                            ),
                          ),
                          if (!isIlan) ...[
                            const SizedBox(width: AppSpacing.sm),
                            CategoryChip(
                              label: l.priceDaily,
                              selected: vm.priceUnit == PriceUnit.daily,
                              onTap: () => vm.setPriceUnit(PriceUnit.daily),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            CategoryChip(
                              label: l.priceTotal,
                              selected: vm.priceUnit == PriceUnit.total,
                              onTap: () => vm.setPriceUnit(PriceUnit.total),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
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
            child: PrimaryButton(
              label: l.publish,
              loading: vm.saving,
              onPressed: publish,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: AppRadius.cardLargeR,
        border: Border.all(color: c.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.title2.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Text(
      text,
      style: AppTypography.label.copyWith(color: context.colors.textPrimary),
    ),
  );
}

class _Error extends StatelessWidget {
  const _Error(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            LucideIcons.circleAlert,
            size: AppSizes.iconField,
            color: c.errorFg,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTypography.label.copyWith(color: c.errorFg),
            ),
          ),
        ],
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < children.length; i += 2) ...[
          Row(
            children: [
              Expanded(child: children[i]),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: i + 1 < children.length
                    ? children[i + 1]
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          if (i + 2 < children.length) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.child,
    required this.onTap,
    this.dashed = false,
    this.fill,
  });

  final Widget child;
  final VoidCallback onTap;
  final bool dashed;
  final Color? fill;

  @override
  Widget build(BuildContext context) {
    final inner = dashed
        ? DashedBox(size: AppSizes.photoTile, child: child)
        : Container(
            width: AppSizes.photoTile,
            height: AppSizes.photoTile,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: AppRadius.thumbR,
            ),
            child: Center(child: child),
          );
    return InkWell(borderRadius: AppRadius.thumbR, onTap: onTap, child: inner);
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    super.key,
    required this.text,
    required this.filled,
    required this.onTap,
  });

  final String text;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.card,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.fieldR,
        side: BorderSide(color: c.fieldBorder),
      ),
      child: InkWell(
        borderRadius: AppRadius.fieldR,
        onTap: onTap,
        child: Container(
          height: AppSizes.fieldHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body.copyWith(
                    color: filled ? c.textPrimary : c.textSecondary,
                  ),
                ),
              ),
              Icon(
                LucideIcons.calendar,
                size: AppSizes.iconAppBar,
                color: c.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

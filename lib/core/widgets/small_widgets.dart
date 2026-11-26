import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/models/models.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Seçilebilir hap: kategori, ürün durumu, aciliyet.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.expand = false,
    this.showCheck = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool expand;
  final bool showCheck;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = selected ? c.onPrimary : c.textPrimary;
    final chip = Material(
      color: selected ? c.primary : c.card,
      shape: StadiumBorder(
        side: selected
            ? BorderSide.none
            : BorderSide(color: c.divider, width: AppSizes.borderStrong),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.tapTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showCheck && selected) ...[
                  Icon(LucideIcons.check, size: AppSizes.iconRow, color: fg),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyStrong.copyWith(color: fg),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return Semantics(
      selected: selected,
      button: true,
      child: expand ? SizedBox(width: double.infinity, child: chip) : chip,
    );
  }
}

/// İLAN / İHTİYAÇ etiketi (liste, sohbet başlığı, detay).
class ListingKindBadge extends StatelessWidget {
  const ListingKindBadge({super.key, required this.kind, this.large = false});

  final ListingKind kind;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final isIlan = kind == ListingKind.ilan;
    final text = large
        ? (isIlan ? l.badgeIlanLarge : l.badgeNeedLarge)
        : (isIlan ? l.badgeIlan : l.badgeNeed);
    final style = AppTypography.captionStrong.copyWith(
      letterSpacing: 0.4,
      color: large && isIlan ? c.onPrimary : c.infoFg,
    );
    final BoxDecoration deco;
    if (large && isIlan) {
      deco = BoxDecoration(color: c.primary, borderRadius: AppRadius.fullR);
    } else if (isIlan) {
      deco = BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.buttonSmall / 2),
        border: Border.all(color: c.infoFg, width: AppSizes.borderStrong),
      );
    } else {
      deco = BoxDecoration(
        color: c.infoBg,
        borderRadius: BorderRadius.circular(
          large ? AppRadius.full : AppRadius.buttonSmall / 2,
        ),
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? AppSpacing.md : AppSpacing.sm,
        vertical: large ? AppSpacing.xs + 2 : 1,
      ),
      decoration: deco,
      child: Text(text, style: style),
    );
  }
}

/// Durum etiketi (Yayında, Ödünçte, Gecikti ...).
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.fg,
    required this.bg,
    this.icon,
  });

  final String label;
  final Color fg;
  final Color bg;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.fullR),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppSizes.iconField, color: fg),
            const SizedBox(width: AppSpacing.xs + 2),
          ],
          Text(label, style: AppTypography.label.copyWith(color: fg)),
        ],
      ),
    );
  }
}

/// Baş harfli yuvarlak avatar; ton temadan.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.initials,
    this.tone,
    this.size = AppSizes.avatar,
  });

  final String? initials;
  final AvatarTone? tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (fg, bg) = switch (tone) {
      AvatarTone.info => (c.infoFg, c.infoBg),
      AvatarTone.error => (c.errorFg, c.errorBg),
      AvatarTone.success => (c.successFg, c.successBg),
      AvatarTone.warning => (c.warningFg, c.warningBg),
      null => (c.textSecondary, c.disabledBg),
    };
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: initials == null
          ? null
          : Text(
              initials!,
              style:
                  (size >= AppSizes.avatar
                          ? AppTypography.bodyStrong
                          : AppTypography.captionStrong)
                      .copyWith(color: fg),
            ),
    );
  }
}

/// Segment kontrolü: Tümü/Okunmamış, İlanlar/İhtiyaçlar, Ücretsiz/Ücretli.
class SegmentItem<T> {
  const SegmentItem({required this.value, required this.label, this.count});
  final T value;
  final String label;
  final int? count;
}

class AppSegmented<T> extends StatelessWidget {
  const AppSegmented({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.bordered = false,
  });

  final List<SegmentItem<T>> items;
  final T value;
  final ValueChanged<T> onChanged;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: bordered ? c.card : c.disabledBg,
        borderRadius: AppRadius.cardR,
        border: bordered ? Border.all(color: c.cardBorder) : null,
      ),
      child: Row(
        children: [
          for (final item in items)
            Expanded(
              child: _SegmentCell(
                label: item.label,
                count: item.count,
                selected: item.value == value,
                onTap: () => onChanged(item.value),
              ),
            ),
        ],
      ),
    );
  }
}

class _SegmentCell extends StatelessWidget {
  const _SegmentCell({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = selected ? c.onPrimary : c.textSecondary;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? c.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.buttonSmall),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.buttonSmall),
          onTap: onTap,
          child: SizedBox(
            height: AppSizes.segmentHeight,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTypography.bodyStrong.copyWith(
                      color: selected ? fg : c.textPrimary,
                    ),
                  ),
                  if (count != null && !selected) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: c.disabledBg,
                        borderRadius: AppRadius.fullR,
                      ),
                      child: Text(
                        '$count',
                        style: AppTypography.captionStrong.copyWith(
                          color: c.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Lucide kalp (dolu / boş). Lucide'de dolu varyant olmadığı için aynı yol
/// `fill` ile çizilir; ikon seti karışmaz.
class FavoriteIcon extends StatelessWidget {
  const FavoriteIcon({
    super.key,
    required this.filled,
    required this.color,
    this.size = 24,
  });

  final bool filled;
  final Color color;
  final double size;

  static const String _path =
      'M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z';

  @override
  Widget build(BuildContext context) {
    final hex =
        '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
    final svg =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" '
        'fill="${filled ? hex : 'none'}" stroke="$hex" stroke-width="2" '
        'stroke-linecap="round" stroke-linejoin="round"><path d="$_path"/></svg>';
    return SvgPicture.string(svg, width: size, height: size);
  }
}

/// "GİZLİLİK" gibi bölüm etiketi.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: AppTypography.section.copyWith(color: context.colors.textSecondary),
  );
}

/// Kesikli çerçeveli kutu (ihtiyaç görseli, "Ekle" kutusu).
class DashedBox extends StatelessWidget {
  const DashedBox({
    super.key,
    required this.child,
    this.size,
    this.radius = AppRadius.thumb,
  });

  final Widget child;
  final double? size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return CustomPaint(
      painter: _DashedPainter(color: c.divider, radius: radius),
      child: SizedBox(
        width: size,
        height: size,
        child: Center(child: child),
      ),
    );
  }
}

class _DashedPainter extends CustomPainter {
  _DashedPainter({required this.color, required this.radius});
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 4), paint);
        d += 8;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedPainter old) =>
      old.color != color || old.radius != radius;
}

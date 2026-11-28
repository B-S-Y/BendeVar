import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// [AppSegmentedControl] seçeneği.
class AppSegment<T> {
  const AppSegment({required this.value, required this.label, this.key});

  final T value;
  final String label;

  /// Segmentin dokunma alanına verilen anahtar (test için).
  final Key? key;
}

/// Tek kaplı segment kontrolü: yuvarlak köşeli tek dış çerçeve, içinde eşit
/// genişlikte segmentler. Seçili olan kabın iç boşluğunun içinde açık mavi
/// dolgu + lacivert çerçeve + lacivert yazıyla görünür ve seçim değişince
/// yumuşakça kayar ("animasyonları azalt" açıkken anında). Diğerleri dolgusuz,
/// ikincil yazı renginde. Yazı tek satırdır; sığmazsa küçülür (büyük yazı
/// ayarında da kırılmaz). Segment yüksekliği dokunma alanıdır (48).
class AppSegmentedControl<T> extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.segments,
    required this.value,
    required this.onChanged,
  }) : assert(segments.length > 1);

  final List<AppSegment<T>> segments;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final n = segments.length;
    final selected = segments.indexWhere((s) => s.value == value);
    final outer = AppRadius.buttonR;
    final inner = BorderRadius.circular(AppRadius.button - AppSpacing.xs);
    final duration = AppMotion.reduce(context)
        ? Duration.zero
        : AppMotion.segment;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: outer,
        border: Border.all(color: c.secondaryBorder),
      ),
      child: SizedBox(
        height: AppSizes.tapTarget,
        child: Stack(
          children: [
            if (selected >= 0)
              AnimatedAlign(
                duration: duration,
                curve: AppMotion.standard,
                alignment: Alignment(-1 + 2 * selected / (n - 1), 0),
                child: FractionallySizedBox(
                  widthFactor: 1 / n,
                  heightFactor: 1,
                  child: DecoratedBox(
                    key: const Key('segment-indicator'),
                    decoration: BoxDecoration(
                      color: c.infoBg,
                      borderRadius: inner,
                      border: Border.all(
                        color: c.primary,
                        width: AppSizes.borderStrong,
                      ),
                    ),
                  ),
                ),
              ),
            Row(
              children: [
                for (final s in segments)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: s.value == value,
                      label: s.label,
                      excludeSemantics: true,
                      child: InkWell(
                        key: s.key,
                        borderRadius: inner,
                        onTap: () => onChanged(s.value),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                s.label,
                                maxLines: 1,
                                softWrap: false,
                                style: AppTypography.bodyStrong.copyWith(
                                  color: s.value == value
                                      ? c.primary
                                      : c.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'envelope_animation.dart';

/// Başarı tiki: mavi daire, içinde beyaz tik; ölçek 0 → 1,2 → 1.
/// 1.09 zarfındaki rozetle aynı zamanlama ve eğri (`EnvelopeAnimation`
/// sabitleri). [animation] 0..1; [totalSeconds] kadar sürede oynayacak
/// şekilde sürülür.
class SuccessCheck extends StatelessWidget {
  const SuccessCheck({super.key, required this.animation});

  final Animation<double> animation;

  /// Tik animasyonunun toplam süresi (sn): açılma + yerleşme.
  static final double totalSeconds =
      (EnvelopeAnimation.badgePop.$2 - EnvelopeAnimation.badgePop.$1) +
      (EnvelopeAnimation.badgeSettle.$2 - EnvelopeAnimation.badgeSettle.$1);

  /// Daire içindeki tik ikonunun daireye oranı.
  static const double iconRatio = .5;

  static double scaleAt(double t) {
    final popLen =
        EnvelopeAnimation.badgePop.$2 - EnvelopeAnimation.badgePop.$1;
    final settleLen =
        EnvelopeAnimation.badgeSettle.$2 - EnvelopeAnimation.badgeSettle.$1;
    final s = t.clamp(0.0, 1.0) * totalSeconds;
    if (s < popLen) {
      return EnvelopeAnimation.badgeOvershoot *
          Curves.ease.transform(s / popLen);
    }
    final k = Curves.ease.transform(((s - popLen) / settleLen).clamp(0.0, 1.0));
    return EnvelopeAnimation.badgeOvershoot +
        (1 - EnvelopeAnimation.badgeOvershoot) * k;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) => Transform.scale(
          scale: scaleAt(animation.value),
          child: Container(
            width: AppSizes.statusCircle,
            height: AppSizes.statusCircle,
            decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
            child: Icon(
              LucideIcons.check,
              size: AppSizes.statusCircle * iconRatio,
              color: c.onBadge,
            ),
          ),
        ),
      ),
    );
  }
}

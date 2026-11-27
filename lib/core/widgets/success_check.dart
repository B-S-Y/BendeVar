import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';

/// Başarı tiki: mavi daire, içinde beyaz tik; ölçek 0 → 1,2 → 1.
/// Zamanlama ve eğri `AppMotion.success*` token'larında (eski 1.09 rozetiyle
/// aynı). [animation] 0..1; [totalSeconds] kadar sürede oynayacak şekilde
/// sürülür.
class SuccessCheck extends StatelessWidget {
  const SuccessCheck({super.key, required this.animation});

  final Animation<double> animation;

  /// Tik animasyonunun toplam süresi (sn): açılma + yerleşme.
  static const double totalSeconds =
      AppMotion.successPopSeconds + AppMotion.successSettleSeconds;

  /// Daire içindeki tik ikonunun daireye oranı.
  static const double iconRatio = .5;

  static double scaleAt(double t) {
    const popLen = AppMotion.successPopSeconds;
    const settleLen = AppMotion.successSettleSeconds;
    final s = t.clamp(0.0, 1.0) * totalSeconds;
    if (s < popLen) {
      return AppMotion.successOvershoot * Curves.ease.transform(s / popLen);
    }
    final k = Curves.ease.transform(((s - popLen) / settleLen).clamp(0.0, 1.0));
    return AppMotion.successOvershoot + (1 - AppMotion.successOvershoot) * k;
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

import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Radyo işareti (1.16d "Kim görebilir?", 1.18 "Ne zaman hatırlatalım?").
/// Seçili: lacivert halka + dolu nokta; seçili değil: gri halka. Dokunma
/// davranışı çevreleyen satırdadır.
class AppRadioDot extends StatelessWidget {
  const AppRadioDot({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: AppSizes.radio,
      height: AppSizes.radio,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? c.primary : c.silver,
          width: selected ? AppSizes.focusRing : AppSizes.borderStrong,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: AppSizes.radioDot,
              height: AppSizes.radioDot,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.primary,
              ),
            )
          : null,
    );
  }
}

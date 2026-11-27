import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Ortak onay kutusu: 48 dp dokunma alanı, yanında etiket. Etikete de
/// dokunulabilir.
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.checkboxKey,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;
  final Key? checkboxKey;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: AppSizes.tapTarget,
            height: AppSizes.tapTarget,
            child: Checkbox(
              key: checkboxKey,
              value: value,
              activeColor: c.primary,
              checkColor: c.onPrimary,
              side: BorderSide(
                color: c.textSecondary,
                width: AppSizes.borderStrong,
              ),
              onChanged: (v) => onChanged(v ?? false),
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Text(
                label,
                style: AppTypography.bodySmall.copyWith(color: c.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

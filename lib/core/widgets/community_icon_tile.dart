import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../utils/community_icons.dart';

/// Topluluk simgesi: açık mavi kare üstünde lacivert Lucide simgesi
/// (1.16 satırları, 1.16e başlığı).
class CommunityIconTile extends StatelessWidget {
  const CommunityIconTile({super.key, required this.iconKey});

  final String iconKey;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: AppSizes.avatar,
      height: AppSizes.avatar,
      decoration: BoxDecoration(color: c.infoBg, borderRadius: AppRadius.cardR),
      alignment: Alignment.center,
      child: Icon(
        communityIcon(iconKey),
        size: AppSizes.iconAppBar,
        color: c.primary,
      ),
    );
  }
}

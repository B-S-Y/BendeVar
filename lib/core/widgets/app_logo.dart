import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';

/// assets/logo.svg'yi çizer; zemin ve simge renklerini temadan alır.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, required this.size, this.tile, this.glyph});

  final double size;

  /// Verilmezse karşılama zemini üzerindeki varsayılan: `hero` zemin, `onHero` simge.
  final Color? tile;
  final Color? glyph;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SvgPicture.asset(
      'assets/logo.svg',
      width: size,
      height: size,
      colorMapper: _LogoColorMapper(tile ?? c.hero, glyph ?? c.onHero),
      excludeFromSemantics: true,
    );
  }
}

class _LogoColorMapper extends ColorMapper {
  const _LogoColorMapper(this.tile, this.glyph);

  final Color tile;
  final Color glyph;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    if (color == AppColors.logoSourceTile) return tile;
    if (color == AppColors.logoSourceGlyph) return glyph;
    return color;
  }
}

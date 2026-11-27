import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import 'auth_motion.dart';
import 'auth_stars.dart';

/// Karşılama/giriş zemini: gradyan + bulanık lekeler + 130 yanıp sönen yıldız.
/// [ambient] 0..1 arası sürekli döner (süre: AuthMotion.ambientPeriod).
/// null ise (animasyonları azalt) her şey durağan çizilir.
class AuthBackdrop extends StatelessWidget {
  const AuthBackdrop({super.key, required this.ambient});

  final Animation<double>? ambient;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return RepaintBoundary(
      child: CustomPaint(
        painter: _BackdropPainter(
          top: c.heroTop,
          bottom: c.hero,
          star: c.onHero,
          blobA: c.heroBlue,
          blobB: c.heroDeep,
          ambient: ambient,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  _BackdropPainter({
    required this.top,
    required this.bottom,
    required this.star,
    required this.blobA,
    required this.blobB,
    required this.ambient,
  }) : super(repaint: ambient);

  final Color top;
  final Color bottom;
  final Color star;
  final Color blobA;
  final Color blobB;
  final Animation<double>? ambient;

  // border-radius: yatay(tl,tr,br,bl) / dikey(tl,tr,br,bl) yüzdeleri.
  static const _shapeA = [.42, .58, .63, .37, .41, .44, .56, .59];
  static const _shapeB = [.58, .42, .35, .65, .55, .38, .62, .45];
  static const _shapeC = [.38, .62, .52, .48, .62, .57, .43, .38];

  /// CSS "alternate + ease-in-out": 0..1..0 üçgen dalga, her yönde easeInOut.
  static double _alternate(double seconds, double period) {
    final p = (seconds / period) % 2;
    final u = p <= 1 ? p : 2 - p;
    return Curves.easeInOut.transform(u);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final seconds = (ambient?.value ?? 0) * AuthMotion.ambientSeconds;
    final rect = Offset.zero & size;

    // Gradyan: üst %0 → alt %60 ve aşağısı.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          rect.topCenter,
          rect.bottomCenter,
          [top, bottom, bottom],
          [0, .6, 1],
        ),
    );

    _blob(
      canvas,
      size,
      seconds,
      color: blobA,
      center: Offset(size.width * .15, size.height * .22),
      box: const Size(260, 240),
    );
    _blob(
      canvas,
      size,
      seconds,
      color: blobB,
      center: Offset(size.width * .85, size.height * .62),
      box: const Size(300, 280),
    );

    final sx = size.width / kStarSpaceWidth;
    final sy = size.height / kStarSpaceHeight;
    for (final s in kAuthStars) {
      final p = (((seconds + s.delay) / s.duration) % 1 + 1) % 1;
      final o = p < .5
          ? lerpD(
              1,
              AuthMotion.starMinOpacity,
              Curves.easeInOut.transform(p / .5),
            )
          : lerpD(
              AuthMotion.starMinOpacity,
              1,
              Curves.easeInOut.transform((p - .5) / .5),
            );
      canvas.drawCircle(
        Offset(s.x * sx, s.y * sy),
        s.r,
        Paint()..color = star.withValues(alpha: o),
      );
    }
  }

  void _blob(
    Canvas canvas,
    Size size,
    double seconds, {
    required Color color,
    required Offset center,
    required Size box,
  }) {
    final m = _alternate(seconds, AuthMotion.blobMorphSeconds);
    final f = _alternate(seconds, AuthMotion.blobFloatSeconds);
    // 0% → 50% → 100% anahtar kareleri (A → B → C), alternate ile gidip gelir.
    final shape = m < .5
        ? _mix(_shapeA, _shapeB, m / .5)
        : _mix(_shapeB, _shapeC, (m - .5) / .5);
    final shifted =
        center + Offset(AuthMotion.blobDx * f, AuthMotion.blobDy * f);
    final r = Rect.fromCenter(
      center: Offset.zero,
      width: box.width,
      height: box.height,
    );
    Radius rad(int h, int v) =>
        Radius.elliptical(r.width * shape[h], r.height * shape[v]);
    final rrect = RRect.fromRectAndCorners(
      r,
      topLeft: rad(0, 4),
      topRight: rad(1, 5),
      bottomRight: rad(2, 6),
      bottomLeft: rad(3, 7),
    );
    canvas
      ..save()
      ..translate(shifted.dx, shifted.dy)
      ..rotate(AuthMotion.blobRotation * math.pi / 180 * f)
      ..drawRRect(
        rrect,
        Paint()
          ..color = color.withValues(alpha: AuthMotion.blobAlpha)
          ..maskFilter = const MaskFilter.blur(
            BlurStyle.normal,
            AuthMotion.blobBlur,
          ),
      )
      ..restore();
  }

  static List<double> _mix(List<double> a, List<double> b, double t) => [
    for (var i = 0; i < a.length; i++) lerpD(a[i], b[i], t),
  ];

  @override
  bool shouldRepaint(_BackdropPainter old) =>
      old.top != top ||
      old.bottom != bottom ||
      old.star != star ||
      old.ambient != ambient;
}

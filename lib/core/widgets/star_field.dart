import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

/// Karşılama / giriş zemini süsü: sabit konumlu küçük yıldızlar.
/// [reveal] verilirse yıldızlar 0→1 arasında sırayla belirir.
class StarField extends StatelessWidget {
  const StarField({super.key, this.reveal});

  final Animation<double>? reveal;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: CustomPaint(
      painter: _StarPainter(context.colors.onHero, reveal),
      size: Size.infinite,
    ),
  );
}

class _StarPainter extends CustomPainter {
  _StarPainter(this.color, this.reveal) : super(repaint: reveal);
  final Color color;
  final Animation<double>? reveal;

  // (x, y, yarıçap) oranları.
  static const List<(double, double, double)> _stars = [
    (0.08, 0.04, 1.0),
    (0.79, 0.08, 1.5),
    (0.45, 0.12, 1.2),
    (0.73, 0.13, 1.0),
    (0.85, 0.12, 1.0),
    (0.12, 0.23, 1.2),
    (0.62, 0.20, 1.2),
    (0.35, 0.18, 1.0),
    (0.84, 0.27, 1.8),
    (0.30, 0.28, 1.5),
    (0.19, 0.38, 1.0),
    (0.80, 0.36, 1.5),
    (0.08, 0.50, 1.2),
    (0.32, 0.50, 1.5),
    (0.79, 0.57, 1.5),
    (0.90, 0.58, 1.8),
    (0.21, 0.62, 1.5),
    (0.12, 0.63, 1.2),
  ];

  /// Her yıldızın belirme penceresinin genişliği (toplam sürenin oranı).
  static const double _window = 0.3;

  @override
  void paint(Canvas canvas, Size size) {
    final t = reveal?.value ?? 1.0;
    for (var i = 0; i < _stars.length; i++) {
      final (x, y, r) = _stars[i];
      final start = (1 - _window) * i / _stars.length;
      final a = ((t - start) / _window).clamp(0.0, 1.0);
      if (a == 0) continue;
      final paint = Paint()..color = color.withValues(alpha: 0.85 * a);
      canvas.drawCircle(Offset(size.width * x, size.height * y), r, paint);
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) =>
      old.color != color || old.reveal != reveal;
}

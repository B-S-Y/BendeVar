import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import 'auth_motion.dart';

enum _Tone { white, blue, silver, deep }

/// Parçacık: (x, y, çap, renk). Kaynak: ANIMASYON_1.01.md "Parçacıklar".
const List<(double, double, double, _Tone)> _particles = [
  (95, 0, 6, _Tone.white),
  (84, 81, 4, _Tone.blue),
  (43, 132, 8, _Tone.silver),
  (-42, 85, 5, _Tone.deep),
  (-95, 69, 6, _Tone.white),
  (-138, -19, 4, _Tone.blue),
  (-77, -56, 8, _Tone.silver),
  (-20, -115, 5, _Tone.deep),
  (43, -132, 6, _Tone.white),
  (84, -45, 4, _Tone.blue),
];

/// Logo merkezinden açılan 2 halka ve 10 parçacık (1.01 açılışı).
class BurstPainter extends CustomPainter {
  BurstPainter({
    required this.intro,
    required this.mode,
    required this.center,
    required this.shift,
    required this.colors,
    this.particles = true,
  }) : super(repaint: Listenable.merge([intro, mode]));

  /// false ise yalnızca halkalar çizilir (kısa açılış).
  final bool particles;

  final Animation<double> intro;
  final Animation<double> mode;

  /// Logo grubu kayma payı hesaba katılmadan, açılış başındaki merkez.
  final Offset center;

  /// Logo grubunun açılış sonunda yukarı kayma miktarı.
  final double shift;
  final AppColors colors;

  static const double _total = AuthMotion.introSeconds;

  @override
  void paint(Canvas canvas, Size size) {
    final t = intro.value;
    final modeFade =
        1 - span(mode.value, AuthMotion.modeSeconds, (0, AuthMotion.burstOut));
    if (modeFade <= 0) return;

    // Halkalar ve parçacıklar, logo grubuyla birlikte yukarı kayar.
    final lift = shift * span(t, _total, AuthMotion.group, AuthMotion.slide);
    final origin = center.translate(0, -lift);

    _ring(
      canvas,
      origin,
      t,
      AuthMotion.ring1,
      AuthMotion.ring1Stroke,
      colors.heroBlue,
      modeFade,
    );
    _ring(
      canvas,
      origin,
      t,
      AuthMotion.ring2,
      AuthMotion.ring2Stroke,
      colors.heroSilver,
      modeFade,
    );

    if (!particles) return;
    final fly = span(t, _total, AuthMotion.particleFly, AuthMotion.burst);
    final drift = span(t, _total, AuthMotion.particleDrift, AuthMotion.burst);
    if (t <= AuthMotion.particleFly.$1 / _total) return;
    final fadeIn = span(t, _total, (
      AuthMotion.particleFly.$1,
      AuthMotion.particleFly.$1 + .08,
    ));
    for (final (x, y, d, tone) in _particles) {
      final k = lerpD(1, AuthMotion.particleDriftFactor, drift);
      final pos = origin.translate(x * fly * k, y * fly * k);
      var scale = lerpD(AuthMotion.particleScaleFrom, 1, fly);
      scale = lerpD(scale, AuthMotion.particleScaleEnd, drift);
      final opacity =
          fadeIn *
          lerpD(1, AuthMotion.particleOpacity, fly) *
          (1 - drift) *
          modeFade;
      if (opacity <= 0) continue;
      final color = switch (tone) {
        _Tone.white => colors.onHero,
        _Tone.blue => colors.heroBlue,
        _Tone.silver => colors.heroSilver,
        _Tone.deep => colors.heroDeep,
      };
      canvas.drawCircle(
        pos,
        d / 2 * scale,
        Paint()..color = color.withValues(alpha: opacity.clamp(0, 1)),
      );
    }
  }

  void _ring(
    Canvas canvas,
    Offset origin,
    double t,
    (double, double, double, double) spec,
    double stroke,
    Color color,
    double modeFade,
  ) {
    final (start, end, scaleEnd, startOpacity) = spec;
    final p = span(t, _total, (start, end), AuthMotion.easeOut);
    if (t <= start / _total) return;
    final fadeIn = span(t, _total, (start, start + .08));
    final scale = lerpD(AuthMotion.ringScaleFrom, scaleEnd, p);
    final opacity = fadeIn * lerpD(startOpacity, 0, p) * modeFade;
    if (opacity <= 0) return;
    canvas.drawCircle(
      origin,
      AuthMotion.ringDiameter / 2 * scale,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke * scale
        ..color = color.withValues(alpha: opacity.clamp(0, 1)),
    );
  }

  @override
  bool shouldRepaint(BurstPainter old) =>
      old.center != center ||
      old.shift != shift ||
      old.colors != colors ||
      old.particles != particles;
}

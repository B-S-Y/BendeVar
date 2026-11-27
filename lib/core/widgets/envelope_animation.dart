import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';

/// 1.09 / 1.06 "Bağlantıyı gönderdik" amblemi: sade, çizgili, kapalı zarf ve
/// arkasında iki ince eş merkezli halka (dolgu yok). Mektup ve onay tiki yok.
///
/// Akış ([AppMotion] `envelope*`): halkalar içeriden dışarı belirir (opaklık +
/// ölçek 0,9 → 1), zarf gövdesi çizilir gibi belirir, ardından kapak V'si
/// çizilir, sonda çok hafif ölçek vurgusu (1 → 1,04 → 1) ve durur.
/// Giriş bitince iki halka ayrı bir sürekli controller ile hafifçe "nefes
/// alır" (ölçek + opaklık, faz farklı); zarf sabit kalır.
/// "Animasyonları azalt" açıksa doğrudan son hâl, halkalar statik.
///
/// Oranlar referans çizimden (birim): gövde 52×36, köşe 6; kapak V'si gövde
/// yüksekliğinin %50'sine iner; iç halka 72, dış halka 92. Boyutlar [size]'a
/// orantılı ölçeklenir; çizgi kalınlıkları sabit dp ([lineStroke],
/// [ringStroke]).
class EnvelopeAnimation extends StatefulWidget {
  const EnvelopeAnimation({super.key});

  /// Amblem boyutu (dış halka çapı), dp.
  static const double size = 160;

  /// Ekrandaki yer: önceki amblemin kutusu (184 dp). Amblem bunun ortasında
  /// durur; böylece sayfadaki dikey yerleşim değişmez.
  static const double slot = 184;

  // Referans çizim birimleri.
  static const double refRingOuter = 92;
  static const double refRingInner = 72;
  static const double refBodyWidth = 52;
  static const double refBodyHeight = 36;
  static const double refBodyRadius = 6;

  /// Çizgi kalınlıkları sabit dp (ölçeklenmez): zarf gövdesi ve kapak V'si.
  static const double lineStroke = 3;

  /// Halka çizgisi, dp.
  static const double ringStroke = 1.5;

  /// Kapak V'sinin alt ucu: gövde yüksekliğinin bu oranı.
  static const double flapDepth = .5;

  /// Referans birimden dp'ye çarpan.
  static const double scale = size / refRingOuter;

  /// [range] (sn) aralığının zaman çizelgesindeki 0..1 ilerlemesi.
  static double progressOf(
    double t,
    (double, double) range, [
    Curve curve = Curves.linear,
  ]) => Interval(
    range.$1 / AppMotion.envelopeSeconds,
    range.$2 / AppMotion.envelopeSeconds,
    curve: curve,
  ).transform(t);

  /// Sondaki ölçek vurgusu: 1 → [AppMotion.envelopePulseScale] → 1.
  static double pulseAt(double t) {
    final p = progressOf(t, AppMotion.envelopePulse);
    final up = p < .5 ? p * 2 : (1 - p) * 2;
    return 1 +
        (AppMotion.envelopePulseScale - 1) *
            Curves.easeInOut.transform(up.clamp(0.0, 1.0));
  }

  @override
  State<EnvelopeAnimation> createState() => _EnvelopeAnimationState();
}

class _EnvelopeAnimationState extends State<EnvelopeAnimation>
    with TickerProviderStateMixin {
  /// Giriş animasyonu (tek controller + Interval'lar).
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: Duration(
      milliseconds: (AppMotion.envelopeSeconds * 1000).round(),
    ),
  );

  /// Giriş bittikten sonra halkaların sürekli nefes alması (ayrı controller).
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: AppMotion.envelopeBreath,
  );
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted && !_reduce) {
        _breath.repeat();
      }
    });
  }

  bool _reduce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduce = AppMotion.reduce(context);
    // Ayar sonradan açılırsa nefes durur (halkalar statik).
    if (_reduce && _breath.isAnimating) {
      _breath
        ..stop()
        ..value = 0;
    }
    if (_started) return;
    _started = true;
    if (_reduce) {
      _ctrl.value = 1;
    } else {
      _ctrl.forward();
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: EnvelopeAnimation.slot,
        child: Center(
          child: SizedBox.square(
            dimension: EnvelopeAnimation.size,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    key: const Key('envelope-rings'),
                    painter: _RingsPainter(
                      progress: _ctrl,
                      breath: _breath,
                      inner: c.envelopeRingInner,
                      outer: c.envelopeRingOuter,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _ctrl,
                    builder: (context, child) => Transform.scale(
                      key: const Key('envelope-pulse'),
                      scale: EnvelopeAnimation.pulseAt(_ctrl.value),
                      child: child,
                    ),
                    child: CustomPaint(
                      key: const Key('envelope-body'),
                      painter: _EnvelopePainter(
                        progress: _ctrl,
                        line: c.envelopeLine,
                        surface: c.envelopeSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// İki ince eş merkezli halka; içeriden dışarı sırayla belirir.
class _RingsPainter extends CustomPainter {
  _RingsPainter({
    required this.progress,
    required this.breath,
    required this.inner,
    required this.outer,
  }) : super(repaint: Listenable.merge([progress, breath]));

  final Animation<double> progress;

  /// Sürekli nefes döngüsü (0..1, tekrar eder); durmuşsa 0 → etkisiz.
  final Animation<double> breath;

  /// Nefes dalgası 0..1 (yumuşak: kosinüs), [phase] döngü kesri kadar kaydırılmış.
  double _wave(double phase) {
    if (breath.value == 0 && !breath.isAnimating) return 0;
    return (1 - math.cos(2 * math.pi * (breath.value + phase))) / 2;
  }

  final Color inner;
  final Color outer;

  void _ring(
    Canvas canvas,
    Offset center,
    double refDiameter,
    Color color,
    (double, double) range,
    double wave,
  ) {
    final p = EnvelopeAnimation.progressOf(
      progress.value,
      range,
      Curves.easeOut,
    );
    if (p <= 0) return;
    const stroke = EnvelopeAnimation.ringStroke;
    final k =
        (AppMotion.envelopeRingScaleFrom +
            (1 - AppMotion.envelopeRingScaleFrom) * p) *
        (1 + (AppMotion.envelopeBreathScale - 1) * wave);
    final fade = 1 - AppMotion.envelopeBreathFade * wave;
    canvas.drawCircle(
      center,
      (refDiameter * EnvelopeAnimation.scale - stroke) / 2 * k,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = color.withValues(alpha: color.a * p * fade),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    _ring(
      canvas,
      center,
      EnvelopeAnimation.refRingInner,
      inner,
      AppMotion.envelopeRingInner,
      _wave(0),
    );
    _ring(
      canvas,
      center,
      EnvelopeAnimation.refRingOuter,
      outer,
      AppMotion.envelopeRingOuter,
      _wave(AppMotion.envelopeBreathPhase),
    );
  }

  @override
  bool shouldRepaint(_RingsPainter old) =>
      old.inner != inner ||
      old.outer != outer ||
      old.progress != progress ||
      old.breath != breath;
}

/// Kapalı zarf: yuvarlatılmış gövde (yüzey dolgulu) ve üst köşelerden
/// ortaya inen kapak V'si; ikisi de çizilir gibi belirir.
class _EnvelopePainter extends CustomPainter {
  _EnvelopePainter({
    required this.progress,
    required this.line,
    required this.surface,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final Color line;
  final Color surface;

  /// [path]'in baştan [fraction] kadarını döndürür (çizilir gibi belirme).
  static Path _partial(Path path, double fraction) {
    if (fraction >= 1) return path;
    final out = Path();
    if (fraction <= 0) return out;
    for (final PathMetric m in path.computeMetrics()) {
      out.addPath(m.extractPath(0, m.length * fraction), Offset.zero);
    }
    return out;
  }

  @override
  void paint(Canvas canvas, Size size) {
    const k = EnvelopeAnimation.scale;
    const w = EnvelopeAnimation.refBodyWidth * k;
    const h = EnvelopeAnimation.refBodyHeight * k;
    final rect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: w,
      height: h,
    );
    final t = progress.value;
    final bodyP = EnvelopeAnimation.progressOf(
      t,
      AppMotion.envelopeBodyDraw,
      Curves.easeInOut,
    );
    final flapP = EnvelopeAnimation.progressOf(
      t,
      AppMotion.envelopeFlapDraw,
      Curves.easeInOut,
    );
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = EnvelopeAnimation.lineStroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = line;

    final body = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          rect,
          const Radius.circular(EnvelopeAnimation.refBodyRadius * k),
        ),
      );
    if (bodyP > 0) {
      // Dolgu, gövde çizildikçe belirir.
      canvas.drawPath(
        body,
        Paint()..color = surface.withValues(alpha: surface.a * bodyP),
      );
      canvas.drawPath(_partial(body, bodyP), stroke);
    }
    if (flapP > 0) {
      // Uçlar yuvarlak köşe yayının üzerinde (45°): köşeden dışarı taşmaz.
      const inset = EnvelopeAnimation.refBodyRadius * k * (1 - math.sqrt1_2);
      final flap = Path()
        ..moveTo(rect.left + inset, rect.top + inset)
        ..lineTo(rect.center.dx, rect.top + h * EnvelopeAnimation.flapDepth)
        ..lineTo(rect.right - inset, rect.top + inset);
      canvas.drawPath(_partial(flap, flapP), stroke);
    }
  }

  @override
  bool shouldRepaint(_EnvelopePainter old) =>
      old.line != line || old.surface != surface || old.progress != progress;
}

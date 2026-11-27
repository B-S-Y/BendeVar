import 'package:material_ui/material_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';

/// 1.09 / 1.06 "Bağlantı gönderildi" amblemi (tasarım "B": çizgili zarf,
/// halkalı). Arkada iki ince eş merkezli halka (dolgu yok), önde yüzey dolgulu
/// ve çizgili zarf. Akış: halkalar içeriden dışarı belirir, kapak açılır,
/// mektup çıkar, onay rozeti belirir. Bir kez oynar, son karede durur.
/// "Animasyonları azalt" açıksa doğrudan son kare (halkalar statik).
/// Kaynak: design/ANIMASYON_1.01.md (1.09 akışı).
class EnvelopeAnimation extends StatefulWidget {
  const EnvelopeAnimation({super.key});

  // Ölçüler (dp), mockup: .env 150×120 (zarfın kendi kutusu).
  static const double width = 150;
  static const double height = 120;

  // Halkalar (yalnızca çizgi).
  static const double ringInnerDiameter = 152;
  static const double ringOuterDiameter = 184;
  static const double ringStroke = 1.5;
  static const double ringScaleFrom = .9;

  /// Zarf, kapak ve mektup çizgi kalınlığı.
  static const double lineStroke = 2.5;
  static const double bodyLeft = 15;
  static const double bodyTop = 50;
  static const double bodyWidth = 120;
  static const double bodyHeight = 70;
  static const double bodyRadius = 10;
  static const double flapHeight = 46;
  static const double letterLeft = 30;
  static const double letterTop = 34;
  static const double letterWidth = 90;
  static const double letterHeight = 70;
  static const double letterRadius = 8;
  static const double letterStart = 16; // aşağıda başlar
  static const double letterEnd = -26; // yukarıda kalır
  static const double badgeSize = 22;
  static const double badgeRight = 12;
  static const double badgeTop = 10;
  static const double badgeIcon = 12;
  static const double lineLeft = 14;
  static const double lineHeight = 6;

  /// Mektup satırları: (üst, genişlik).
  static const List<(double, double)> lines = [(14, 40), (28, 56), (42, 48)];

  // Zaman çizelgesi (sn). Zarf akışı önceki tasarımla aynı.
  static const double totalSeconds = 2.08;
  static const (double, double) ringInnerIn = (0, .30);
  static const (double, double) ringOuterIn = (.15, .45);
  static const (double, double) flap = (.32, .88);
  static const double flapBehindAt = .62; // katman sırası ~0,6 sn'de değişir
  static const (double, double) letter = (.8, 1.52);
  static const (double, double) badgePop = (1.52, 1.84);
  static const (double, double) badgeSettle = (1.84, 2.08);
  static const double badgeOvershoot = 1.2;
  static const Curve letterCurve = Cubic(.3, .8, .3, 1);

  /// Zaman çizelgesinde [range] (sn) aralığının 0..1 ilerlemesi.
  static double progressOf(
    double t,
    (double, double) range, [
    Curve curve = Curves.linear,
  ]) => Interval(
    range.$1 / totalSeconds,
    range.$2 / totalSeconds,
    curve: curve,
  ).transform(t);

  @override
  State<EnvelopeAnimation> createState() => _EnvelopeAnimationState();
}

class _EnvelopeAnimationState extends State<EnvelopeAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: Duration(
      milliseconds: (EnvelopeAnimation.totalSeconds * 1000).round(),
    ),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _ctrl.value = 1;
    } else {
      _ctrl.forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Zarf kutusu, gövde merkezi halkaların merkezine gelecek şekilde oturur.
    const box = EnvelopeAnimation.ringOuterDiameter;
    const left =
        box / 2 -
        (EnvelopeAnimation.bodyLeft + EnvelopeAnimation.bodyWidth / 2);
    const top =
        box / 2 -
        (EnvelopeAnimation.bodyTop + EnvelopeAnimation.bodyHeight / 2);
    return ExcludeSemantics(
      child: SizedBox(
        width: box,
        height: box,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _RingsPainter(
                  progress: _ctrl,
                  inner: c.envelopeRingInner,
                  outer: c.envelopeRingOuter,
                ),
              ),
            ),
            Positioned(
              left: left,
              top: top,
              width: EnvelopeAnimation.width,
              height: EnvelopeAnimation.height,
              child: _envelope(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Zarf (gövde, kapak, mektup, ön yüz); animasyon akışı değişmedi.
  Widget _envelope(BuildContext context) {
    final c = context.colors;
    final surface = c.envelopeSurface;
    final line = c.envelopeLine;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value;
        final seconds = t * EnvelopeAnimation.totalSeconds;
        final flapP = EnvelopeAnimation.progressOf(
          t,
          EnvelopeAnimation.flap,
          Curves.ease,
        );
        final letterP = EnvelopeAnimation.progressOf(
          t,
          EnvelopeAnimation.letter,
          EnvelopeAnimation.letterCurve,
        );
        final badgeScale = seconds < EnvelopeAnimation.badgePop.$2
            ? _lerp(
                0,
                EnvelopeAnimation.badgeOvershoot,
                EnvelopeAnimation.progressOf(
                  t,
                  EnvelopeAnimation.badgePop,
                  Curves.ease,
                ),
              )
            : _lerp(
                EnvelopeAnimation.badgeOvershoot,
                1,
                EnvelopeAnimation.progressOf(
                  t,
                  EnvelopeAnimation.badgeSettle,
                  Curves.ease,
                ),
              );

        final flapWidget = Positioned(
          left: EnvelopeAnimation.bodyLeft,
          top: EnvelopeAnimation.bodyTop,
          width: EnvelopeAnimation.bodyWidth,
          height: EnvelopeAnimation.flapHeight,
          child: Transform(
            alignment: Alignment.topCenter,
            // Dikey ölçek 1 → −1 (menteşe: zarfın üst kenarı).
            transform: Matrix4.diagonal3Values(1, 1 - 2 * flapP, 1),
            child: CustomPaint(painter: _FlapPainter(surface, line)),
          ),
        );
        // Açılırken (≈0,6 sn'den sonra) kapak mektubun arkasına geçer.
        final flapBehind = seconds >= EnvelopeAnimation.flapBehindAt;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: EnvelopeAnimation.bodyLeft,
              top: EnvelopeAnimation.bodyTop,
              width: EnvelopeAnimation.bodyWidth,
              height: EnvelopeAnimation.bodyHeight,
              child: DecoratedBox(
                key: const Key('envelope-body'),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(
                    EnvelopeAnimation.bodyRadius,
                  ),
                  border: Border.all(
                    color: line,
                    width: EnvelopeAnimation.lineStroke,
                  ),
                ),
              ),
            ),
            if (flapBehind) flapWidget,
            Positioned(
              left: EnvelopeAnimation.letterLeft,
              top: EnvelopeAnimation.letterTop,
              width: EnvelopeAnimation.letterWidth,
              height: EnvelopeAnimation.letterHeight,
              child: Transform.translate(
                offset: Offset(
                  0,
                  _lerp(
                    EnvelopeAnimation.letterStart,
                    EnvelopeAnimation.letterEnd,
                    letterP,
                  ),
                ),
                child: _Letter(badgeScale: badgeScale),
              ),
            ),
            Positioned(
              left: EnvelopeAnimation.bodyLeft,
              top: EnvelopeAnimation.bodyTop,
              width: EnvelopeAnimation.bodyWidth,
              height: EnvelopeAnimation.bodyHeight,
              child: CustomPaint(painter: _FrontPainter(surface, line)),
            ),
            if (!flapBehind) flapWidget,
          ],
        );
      },
    );
  }
}

/// Mektup: yüzey dolgulu, çizgili; satırlar ince; köşede onay rozeti.
class _Letter extends StatelessWidget {
  const _Letter({required this.badgeScale});

  final double badgeScale;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.envelopeSurface,
        borderRadius: BorderRadius.circular(EnvelopeAnimation.letterRadius),
        border: Border.all(
          color: c.envelopeLine,
          width: EnvelopeAnimation.lineStroke,
        ),
      ),
      child: Stack(
        children: [
          for (final (top, width) in EnvelopeAnimation.lines)
            Positioned(
              left: EnvelopeAnimation.lineLeft,
              top: top,
              width: width,
              height: EnvelopeAnimation.lineHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: c.envelopeRingInner,
                  borderRadius: BorderRadius.circular(
                    EnvelopeAnimation.lineHeight / 2,
                  ),
                ),
              ),
            ),
          Positioned(
            right: EnvelopeAnimation.badgeRight,
            top: EnvelopeAnimation.badgeTop,
            width: EnvelopeAnimation.badgeSize,
            height: EnvelopeAnimation.badgeSize,
            child: Transform.scale(
              scale: badgeScale,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: c.accent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.check,
                  size: EnvelopeAnimation.badgeIcon,
                  color: c.onBadge,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// İki ince eş merkezli halka (dolgu yok); içeriden dışarı sırayla belirir
/// (opaklık + hafif ölçek).
class _RingsPainter extends CustomPainter {
  _RingsPainter({
    required this.progress,
    required this.inner,
    required this.outer,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final Color inner;
  final Color outer;

  void _ring(
    Canvas canvas,
    Offset center,
    double diameter,
    Color color,
    (double, double) range,
  ) {
    final p = EnvelopeAnimation.progressOf(
      progress.value,
      range,
      Curves.easeOut,
    );
    if (p <= 0) return;
    final scale =
        EnvelopeAnimation.ringScaleFrom +
        (1 - EnvelopeAnimation.ringScaleFrom) * p;
    canvas.drawCircle(
      center,
      (diameter - EnvelopeAnimation.ringStroke) / 2 * scale,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = EnvelopeAnimation.ringStroke
        ..color = color.withValues(alpha: color.a * p),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    _ring(
      canvas,
      center,
      EnvelopeAnimation.ringInnerDiameter,
      inner,
      EnvelopeAnimation.ringInnerIn,
    );
    _ring(
      canvas,
      center,
      EnvelopeAnimation.ringOuterDiameter,
      outer,
      EnvelopeAnimation.ringOuterIn,
    );
  }

  @override
  bool shouldRepaint(_RingsPainter old) =>
      old.inner != inner || old.outer != outer || old.progress != progress;
}

/// Ön yüz (120×70 uzayı): M0 22 L60 50 L120 22 L120 60 Q120 70 110 70
/// L10 70 Q0 70 0 60 Z. Yüzey dolgulu; kenarı ve cep V'si zarf çizgisiyle.
class _FrontPainter extends CustomPainter {
  _FrontPainter(this.fill, this.line);
  final Color fill;
  final Color line;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 120;
    final sy = size.height / 70;
    final path = Path()
      ..moveTo(0, 22 * sy)
      ..lineTo(60 * sx, 50 * sy)
      ..lineTo(120 * sx, 22 * sy)
      ..lineTo(120 * sx, 60 * sy)
      ..quadraticBezierTo(120 * sx, 70 * sy, 110 * sx, 70 * sy)
      ..lineTo(10 * sx, 70 * sy)
      ..quadraticBezierTo(0, 70 * sy, 0, 60 * sy)
      ..close();
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = EnvelopeAnimation.lineStroke
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..color = line,
    );
  }

  @override
  bool shouldRepaint(_FrontPainter old) => old.fill != fill || old.line != line;
}

/// Kapak (120×46 uzayı): üst kenardan ortaya inen V. Yüzey dolgulu, çizgili.
class _FlapPainter extends CustomPainter {
  _FlapPainter(this.fill, this.line);
  final Color fill;
  final Color line;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 120;
    final sy = size.height / 46;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(120 * sx, 0)
      ..lineTo(60 * sx, 46 * sy)
      ..close();
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = EnvelopeAnimation.lineStroke
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..color = line,
    );
  }

  @override
  bool shouldRepaint(_FlapPainter old) => old.fill != fill || old.line != line;
}

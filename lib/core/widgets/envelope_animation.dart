import 'package:material_ui/material_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';

/// 1.09 "Bağlantı gönderildi" zarfı: kapak açılır, mektup çıkar, tik belirir.
/// Bir kez oynar ve açık zarf + tik halinde durur. "Animasyonları azalt"
/// açıksa doğrudan son kareyi gösterir. Kaynak: design/ANIMASYON_1.01.md (1.09).
class EnvelopeAnimation extends StatefulWidget {
  const EnvelopeAnimation({super.key});

  // Ölçüler (dp), mockup: .env 150×120 (zarfın kendi kutusu).
  static const double width = 150;
  static const double height = 120;

  // Tasarım C: zarfın arkasında daire, dışında ince halka.
  static const double discDiameter = 176;
  static const double ringDiameter = 188;
  static const double ringStroke = 1.5;

  /// Kapak ve ön yüz kenar çizgisi (daire renginde) kalınlığı.
  static const double creaseStroke = 2;
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
  static const double letterShadowAlpha = .12;
  static const double letterShadowBlur = 8;
  static const double letterShadowDy = 2;
  static const double badgeSize = 22;
  static const double badgeRight = 12;
  static const double badgeTop = 10;
  static const double badgeIcon = 12;
  static const double lineLeft = 14;
  static const double lineHeight = 6;

  /// Mektup satırları: (üst, genişlik).
  static const List<(double, double)> lines = [(14, 40), (28, 56), (42, 48)];

  // Zaman çizelgesi (sn).
  static const double totalSeconds = 2.08;
  static const (double, double) flap = (.32, .88);
  static const double flapBehindAt = .62; // katman sırası ~0,6 sn'de değişir
  static const (double, double) letter = (.8, 1.52);
  static const (double, double) badgePop = (1.52, 1.84);
  static const (double, double) badgeSettle = (1.84, 2.08);
  static const double badgeOvershoot = 1.2;
  static const Curve letterCurve = Cubic(.3, .8, .3, 1);

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

  static double _p(
    double t,
    (double, double) r, [
    Curve curve = Curves.linear,
  ]) => Interval(
    r.$1 / EnvelopeAnimation.totalSeconds,
    r.$2 / EnvelopeAnimation.totalSeconds,
    curve: curve,
  ).transform(t);

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Zarf kutusu, gövde merkezi dairenin merkezine gelecek şekilde oturur.
    const box = EnvelopeAnimation.ringDiameter;
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
                painter: _DiscPainter(c.envelopeDisc, c.envelopeRing),
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
    return SizedBox(
      width: EnvelopeAnimation.width,
      height: EnvelopeAnimation.height,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = _ctrl.value;
          final seconds = t * EnvelopeAnimation.totalSeconds;
          final flapP = _p(t, EnvelopeAnimation.flap, Curves.ease);
          final letterP = _p(
            t,
            EnvelopeAnimation.letter,
            EnvelopeAnimation.letterCurve,
          );
          final badgeScale = seconds < EnvelopeAnimation.badgePop.$2
              ? _lerp(
                  0,
                  EnvelopeAnimation.badgeOvershoot,
                  _p(t, EnvelopeAnimation.badgePop, Curves.ease),
                )
              : _lerp(
                  EnvelopeAnimation.badgeOvershoot,
                  1,
                  _p(t, EnvelopeAnimation.badgeSettle, Curves.ease),
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
              child: CustomPaint(
                painter: _FlapPainter(c.envelopeBody, c.envelopeDisc),
              ),
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
                  decoration: BoxDecoration(
                    color: c.envelopeBody,
                    borderRadius: BorderRadius.circular(
                      EnvelopeAnimation.bodyRadius,
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
                child: CustomPaint(
                  painter: _FrontPainter(c.envelopeBody, c.envelopeDisc),
                ),
              ),
              if (!flapBehind) flapWidget,
            ],
          );
        },
      ),
    );
  }
}

class _Letter extends StatelessWidget {
  const _Letter({required this.badgeScale});

  final double badgeScale;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(EnvelopeAnimation.letterRadius),
        boxShadow: [
          BoxShadow(
            color: c.shadow.withValues(
              alpha: EnvelopeAnimation.letterShadowAlpha,
            ),
            blurRadius: EnvelopeAnimation.letterShadowBlur,
            offset: const Offset(0, EnvelopeAnimation.letterShadowDy),
          ),
        ],
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
                  color: c.infoBg,
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

/// Daire + dışında ince halka (zarfın arka planı).
class _DiscPainter extends CustomPainter {
  _DiscPainter(this.disc, this.ring);
  final Color disc;
  final Color ring;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    canvas.drawCircle(
      center,
      EnvelopeAnimation.discDiameter / 2,
      Paint()..color = disc,
    );
    canvas.drawCircle(
      center,
      EnvelopeAnimation.ringDiameter / 2 - EnvelopeAnimation.ringStroke / 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = EnvelopeAnimation.ringStroke
        ..color = ring,
    );
  }

  @override
  bool shouldRepaint(_DiscPainter old) => old.disc != disc || old.ring != ring;
}

/// Ön yüz (120×70 uzayı): M0 22 L60 50 L120 22 L120 60 Q120 70 110 70
/// L10 70 Q0 70 0 60 Z. Gövde renginde; V kenarı daire renginde çizgi.
class _FrontPainter extends CustomPainter {
  _FrontPainter(this.color, this.crease);
  final Color color;
  final Color crease;

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
    canvas.drawPath(path, Paint()..color = color);
    final edge = Path()
      ..moveTo(0, 22 * sy)
      ..lineTo(60 * sx, 50 * sy)
      ..lineTo(120 * sx, 22 * sy);
    canvas.drawPath(
      edge,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = EnvelopeAnimation.creaseStroke
        ..strokeJoin = StrokeJoin.round
        ..color = crease,
    );
  }

  @override
  bool shouldRepaint(_FrontPainter old) =>
      old.color != color || old.crease != crease;
}

/// Kapak (120×46 uzayı): M0 10 Q0 0 10 0 L110 0 Q120 0 120 10 L60 46 Z.
/// Gövde renginde; alt kenarları daire renginde çizgi.
class _FlapPainter extends CustomPainter {
  _FlapPainter(this.color, this.crease);
  final Color color;
  final Color crease;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 120;
    final sy = size.height / 46;
    final path = Path()
      ..moveTo(0, 10 * sy)
      ..quadraticBezierTo(0, 0, 10 * sx, 0)
      ..lineTo(110 * sx, 0)
      ..quadraticBezierTo(120 * sx, 0, 120 * sx, 10 * sy)
      ..lineTo(60 * sx, 46 * sy)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    final edge = Path()
      ..moveTo(0, 10 * sy)
      ..lineTo(60 * sx, 46 * sy)
      ..lineTo(120 * sx, 10 * sy);
    canvas.drawPath(
      edge,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = EnvelopeAnimation.creaseStroke
        ..strokeJoin = StrokeJoin.round
        ..color = crease,
    );
  }

  @override
  bool shouldRepaint(_FlapPainter old) =>
      old.color != color || old.crease != crease;
}

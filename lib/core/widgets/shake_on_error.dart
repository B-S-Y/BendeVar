import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/app_motion.dart';

/// [trigger] değişip null olmayınca çocuk hafifçe sağa sola titrer.
/// İlk kurulumda (hata zaten varsa) titremez.
class ShakeOnError extends StatefulWidget {
  const ShakeOnError({super.key, required this.trigger, required this.child});

  final Object? trigger;
  final Widget child;

  @override
  State<ShakeOnError> createState() => _ShakeOnErrorState();
}

class _ShakeOnErrorState extends State<ShakeOnError>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: AppMotion.shake,
  );

  @override
  void didUpdateWidget(ShakeOnError old) {
    super.didUpdateWidget(old);
    if (widget.trigger != null &&
        widget.trigger != old.trigger &&
        !AppMotion.reduce(context)) {
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    child: widget.child,
    builder: (context, child) {
      final t = _c.value;
      final dx =
          math.sin(t * math.pi * 2 * AppMotion.shakeCycles) *
          (1 - t) *
          AppMotion.shakeDistance;
      return Transform.translate(offset: Offset(dx, 0), child: child);
    },
  );
}

import 'package:material_ui/material_ui.dart';

import '../theme/app_motion.dart';

/// Basılınca hafifçe küçülür (ortak düğme efekti). Dokunuşu engellemez:
/// yalnızca işaretçiyi dinler.
class PressScale extends StatefulWidget {
  const PressScale({super.key, required this.child, this.enabled = true});

  final Widget child;
  final bool enabled;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final animate = widget.enabled && !AppMotion.reduce(context);
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: animate && _down ? AppMotion.pressScale : 1,
        duration: animate ? AppMotion.press : Duration.zero,
        curve: AppMotion.standard,
        child: widget.child,
      ),
    );
  }
}

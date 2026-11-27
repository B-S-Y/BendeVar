import 'package:material_ui/material_ui.dart';

import '../theme/app_motion.dart';

/// Liste girişi: satır, sırasına göre gecikmeyle hafifçe yukarı kayarak ve
/// solarak gelir. Bir kez oynar; "animasyonları azalt" açıksa hemen görünür.
class AppEntrance extends StatefulWidget {
  const AppEntrance({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<AppEntrance> createState() => _AppEntranceState();
}

class _AppEntranceState extends State<AppEntrance>
    with SingleTickerProviderStateMixin {
  late final Duration _delay =
      AppMotion.listStagger *
      (widget.index < AppMotion.listStaggerMax
          ? widget.index
          : AppMotion.listStaggerMax);
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: _delay + AppMotion.listItem,
  );
  late final CurvedAnimation _t = CurvedAnimation(
    parent: _c,
    curve: Interval(
      _delay.inMicroseconds / (_delay + AppMotion.listItem).inMicroseconds,
      1,
      curve: AppMotion.standard,
    ),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (AppMotion.reduce(context)) {
      _c.value = 1;
    } else {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _t.dispose();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _t,
    child: widget.child,
    builder: (context, child) => Opacity(
      opacity: _t.value,
      child: Transform.translate(
        offset: Offset(0, (1 - _t.value) * AppMotion.listSlide),
        child: child,
      ),
    ),
  );
}

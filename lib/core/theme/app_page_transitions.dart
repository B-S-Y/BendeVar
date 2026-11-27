import 'package:material_ui/material_ui.dart';

import 'app_motion.dart';

/// Tek ortak sayfa geçişi: hafif yana kayma + solma. Tema üzerinden tüm
/// rotalara (go_router sayfaları dahil) uygulanır. "Animasyonları azalt"
/// açıksa geçiş animasyonsuzdur.
class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  @override
  Duration get transitionDuration => AppMotion.page;

  @override
  Duration get reverseTransitionDuration => AppMotion.page;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (AppMotion.reduce(context)) return child;
    final curved = animation.drive(CurveTween(curve: AppMotion.standard));
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: curved.drive(
          Tween<Offset>(
            begin: const Offset(AppMotion.pageSlide, 0),
            end: Offset.zero,
          ),
        ),
        child: child,
      ),
    );
  }
}

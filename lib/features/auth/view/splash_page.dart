import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../l10n/app_localizations.dart';
import '../viewmodel/auth_view_model.dart';
import 'auth_backdrop.dart';
import 'auth_burst.dart';
import 'auth_motion.dart';

/// Açılış kapısı. Oturum kontrolü (shared_preferences) burada yapılır:
/// - oturum yok → hemen Karşılama (tam açılış animasyonu orada oynar);
/// - oturum var (Beni hatırla) → karşılamadaki logo girişinin aynısı
///   ([AppMotion.splash]: logo büyür, halkalar açılır, "Bende Var" belirir),
///   bitince giriş sonrası geçişle (solma + büyüme) Ana Sayfa;
/// - "animasyonları azalt" açıksa kısa ([AppMotion.splashReduced]) ve statik.
/// Süre ilk kare çizildikten sonra başlar; oturum geri yükleme daha önce
/// bitse de animasyon tamamlanmadan Ana Sayfa'ya geçilmez. Kontrol uzun
/// sürerse animasyon bitince, kontrol biter bitmez geçilir.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  /// Karşılama zaman çizelgesinin ilk [AppMotion.splash]'ı (gerçek hızda).
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: AppMotion.splash,
  );

  /// Animasyonlar azaltılmışken kısa statik bekleme. `preserve`: sistem
  /// "animasyonları kapat" ayarında süre sıfıra indirilmesin.
  late final AnimationController _hold = AnimationController(
    vsync: this,
    duration: AppMotion.splashReduced,
    animationBehavior: AnimationBehavior.preserve,
  );

  /// [_ctrl] 0..1 → karşılama açılışının kesri (BurstPainter ile aynı ölçek).
  late final Animation<double> _introT = Tween<double>(
    begin: 0,
    end:
        AppMotion.splash.inMicroseconds /
        Duration.microsecondsPerSecond /
        AuthMotion.introSeconds,
  ).animate(_ctrl);

  late final AuthViewModel _auth = context.read<AuthViewModel>();
  bool _started = false;
  bool _reduce = false;
  bool _left = false;

  static const double _total = AuthMotion.introSeconds;

  @override
  void initState() {
    super.initState();
    _auth.addListener(_decide);
    void onDone(AnimationStatus s) {
      if (s == AnimationStatus.completed) _decide();
    }

    _ctrl.addStatusListener(onDone);
    _hold.addStatusListener(onDone);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _reduce = AppMotion.reduce(context);
    // Süre ilk kare çizildikten sonra başlar (öncesinde geçen zaman sayılmaz).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      (_reduce ? _hold : _ctrl).forward();
      _decide();
    });
  }

  @override
  void dispose() {
    _auth.removeListener(_decide);
    _ctrl.dispose();
    _hold.dispose();
    super.dispose();
  }

  void _decide() {
    if (_left || !mounted || !_auth.restored) return;
    if (!_auth.isSignedIn) {
      // Oturum yok: bekletme, Karşılama'ya geç.
      _left = true;
      context.go('/welcome');
      return;
    }
    if (_reduce) {
      if (!_hold.isCompleted) return; // kısa statik açılış
      _left = true;
      context.go('/home');
      return;
    }
    if (!_ctrl.isCompleted) return; // açılış animasyonu tamamlansın
    _left = true;
    _auth.requestFadeToHome(); // giriş sonrası geçişin aynısı
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final show = context.select<AuthViewModel, bool>(
      (a) => a.restored && a.isSignedIn,
    );

    return Scaffold(
      backgroundColor: c.hero,
      body: Stack(
        children: [
          // Karşılama ile aynı zemin (yıldızlar durağan: kısa açılış).
          const Positioned.fill(child: AuthBackdrop(ambient: null)),
          if (show)
            Center(
              child: AnimatedBuilder(
                animation: _introT,
                builder: (context, _) {
                  // Azaltılmış: son kare (logo 1, ad görünür, halka yok).
                  final t = _reduce ? 1.0 : _introT.value;
                  // Karşılamadaki logo girişinin aynısı (AuthStage).
                  final popP = span(
                    t,
                    _total,
                    AuthMotion.logoPop,
                    AuthMotion.pop,
                  );
                  final settleP = span(
                    t,
                    _total,
                    AuthMotion.logoSettle,
                    AuthMotion.pop,
                  );
                  final logoScale = t < AuthMotion.logoSettle.$1 / _total
                      ? lerpD(
                          AuthMotion.logoFrom,
                          AuthMotion.logoOvershoot,
                          popP,
                        )
                      : lerpD(AuthMotion.logoOvershoot, 1, settleP);
                  final logoOpacity = popP.clamp(0.0, 1.0);
                  final nameP = span(
                    t,
                    _total,
                    AuthMotion.name,
                    AuthMotion.ease,
                  );
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox.square(
                        dimension: AuthMotion.logoSize,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            if (!_reduce)
                              // Karşılamadaki logo halkaları (parçacıksız).
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: CustomPaint(
                                    key: const Key('splash-rings'),
                                    painter: BurstPainter(
                                      intro: _introT,
                                      mode:
                                          const AlwaysStoppedAnimation<double>(
                                            0,
                                          ),
                                      shift: 0,
                                      center: const Offset(
                                        AuthMotion.logoSize / 2,
                                        AuthMotion.logoSize / 2,
                                      ),
                                      colors: c,
                                      particles: false,
                                    ),
                                  ),
                                ),
                              ),
                            Opacity(
                              key: const Key('splash-logo'),
                              opacity: logoOpacity,
                              child: Transform.scale(
                                scale: logoScale,
                                child: const AppLogo(
                                  size: AuthMotion.logoSize,
                                  tile: AppColors.logoSourceTile,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AuthMotion.nameGap),
                      Opacity(
                        opacity: nameP,
                        child: Text(
                          l.brandName,
                          key: const Key('splash-brand'),
                          style: AppTypography.brandHero.copyWith(
                            color: c.onHero,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../l10n/app_localizations.dart';
import '../viewmodel/auth_view_model.dart';
import 'auth_backdrop.dart';
import 'auth_motion.dart';

/// Açılış kapısı. Oturum kontrolü (shared_preferences) burada, animasyon
/// süresi içinde yapılır:
/// - oturum yok → hemen Karşılama (tam açılış animasyonu orada oynar);
/// - oturum var (Beni hatırla) → ~1,2 sn kısa açılış (logo büyür, "Bende Var"),
///   sonra giriş sonrası geçişle (solma + büyüme) Ana Sayfa;
/// - "animasyonları azalt" açıksa açılış atlanır, doğrudan Ana Sayfa.
/// Kontrol 1,2 sn'den uzun sürerse animasyon bitince hemen geçilir.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: AppMotion.splash,
  );
  late final AuthViewModel _auth = context.read<AuthViewModel>();
  // Bir kez kurulur, dispose'da bırakılır.
  late final CurvedAnimation _logoT = CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(
      0,
      AppMotion.splashLogoEnd,
      curve: AppMotion.standard,
    ),
  );
  late final CurvedAnimation _textT = CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(
      AppMotion.splashTextStart,
      AppMotion.splashTextEnd,
      curve: AppMotion.standard,
    ),
  );
  bool _animated = false;
  bool _left = false;

  @override
  void initState() {
    super.initState();
    _auth.addListener(_decide);
    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) _decide();
    });
    // İlk kareden sonra: kontrol bitmişse hemen karar ver.
    WidgetsBinding.instance.addPostFrameCallback((_) => _decide());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Animasyon sayaç olarak sayfa açılır açılmaz başlar (kontrol süresi bu
    // 1,2 sn'nin içinde geçer); logo yalnızca oturum varsa görünür.
    if (!_animated && !AppMotion.reduce(context)) {
      _animated = true;
      _ctrl.forward();
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_decide);
    _logoT.dispose();
    _textT.dispose();
    _ctrl.dispose();
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
    if (AppMotion.reduce(context)) {
      _left = true;
      context.go('/home');
      return;
    }
    if (_ctrl.status != AnimationStatus.completed) return; // süre dolsun
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

    final logoT = _logoT;
    final textT = _textT;

    return Scaffold(
      backgroundColor: c.hero,
      body: Stack(
        children: [
          // Karşılama ile aynı zemin (yıldızlar durağan: kısa açılış).
          const Positioned.fill(child: AuthBackdrop(ambient: null)),
          if (show)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: logoT,
                    builder: (context, child) => Opacity(
                      opacity: logoT.value,
                      child: Transform.scale(
                        scale:
                            AppMotion.splashLogoFrom +
                            (1 - AppMotion.splashLogoFrom) * logoT.value,
                        child: child,
                      ),
                    ),
                    child: const AppLogo(
                      size: AuthMotion.logoSize,
                      tile: AppColors.logoSourceTile,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AnimatedBuilder(
                    animation: textT,
                    builder: (context, child) =>
                        Opacity(opacity: textT.value, child: child),
                    child: Text(
                      l.brandName,
                      key: const Key('splash-brand'),
                      style: AppTypography.title1.copyWith(color: c.onHero),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

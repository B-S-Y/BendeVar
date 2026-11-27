import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/success_check.dart';
import '../../../l10n/app_localizations.dart';
import '../viewmodel/auth_view_model.dart';
import 'auth_backdrop.dart';
import 'auth_motion.dart';

/// 1.11 sonrası "Kayıt tamamlandı" zamanlaması (sn). Tik bitince başlık,
/// 0,2 sn sonra alt metin gelir; her biri 0,5 sn sürer.
abstract final class DoneMotion {
  static final double check = SuccessCheck.totalSeconds;
  static final double titleStart = check;
  static const double textGap = .2;
  static const double itemLength = .5;
  static final double subtitleStart = titleStart + textGap;
  static final double total = subtitleStart + itemLength;
}

/// Kayıt tamamlandı: yıldızlı koyu zemin, tik, karşılama metni ve altta
/// "Başla" panelı. Ad adımından (1.10) sonra, Ana Sayfa'dan önce gösterilir.
class SignupDonePage extends StatefulWidget {
  const SignupDonePage({super.key});

  @override
  State<SignupDonePage> createState() => _SignupDonePageState();
}

class _SignupDonePageState extends State<SignupDonePage>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: (DoneMotion.total * 1000).round()),
  );
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: AuthMotion.ambientPeriod,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _ambient.stop();
      _ctrl.value = 1; // son kare doğrudan
    } else {
      if (!_ambient.isAnimating) _ambient.repeat();
      if (!_started) _ctrl.forward();
    }
    _started = true;
  }

  @override
  void dispose() {
    _checkT.dispose();
    _titleT.dispose();
    _subtitleT.dispose();
    _ctrl.dispose();
    _ambient.dispose();
    super.dispose();
  }

  CurvedAnimation _slice(double start, double length, Curve curve) =>
      CurvedAnimation(
        parent: _ctrl,
        curve: Interval(
          start / DoneMotion.total,
          (start + length) / DoneMotion.total,
          curve: curve,
        ),
      );

  // Bir kez kurulur, dispose'da bırakılır (her build'de yeniden değil).
  late final CurvedAnimation _checkT = _slice(
    0,
    DoneMotion.check,
    Curves.linear,
  );
  late final CurvedAnimation _titleT = _slice(
    DoneMotion.titleStart,
    DoneMotion.itemLength,
    AppMotion.standard,
  );
  late final CurvedAnimation _subtitleT = _slice(
    DoneMotion.subtitleStart,
    DoneMotion.itemLength,
    AppMotion.standard,
  );

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final user = context
        .select<AuthViewModel, ({String name, String community})>(
          (v) => (
            name: (v.user?.displayName ?? '').split(' ').first,
            community: v.user?.community.name ?? '',
          ),
        );
    final bottom = MediaQuery.paddingOf(context).bottom;

    Widget rise(Animation<double> a, Widget child) => AnimatedBuilder(
      animation: a,
      child: child,
      builder: (context, child) => Opacity(
        opacity: a.value,
        child: Transform.translate(
          offset: Offset(0, (1 - a.value) * AppMotion.listSlide),
          child: child,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: c.hero,
      body: Stack(
        children: [
          Positioned.fill(
            child: AuthBackdrop(
              ambient: reduceMotion(context) ? null : _ambient,
            ),
          ),
          Column(
            children: [
              Expanded(
                child: SafeArea(
                  bottom: false,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxl,
                        vertical: AppSpacing.xxl,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SuccessCheck(animation: _checkT),
                          const SizedBox(height: AppSpacing.xxl),
                          rise(
                            _titleT,
                            Text(
                              l.doneTitle(user.name),
                              key: const Key('done-title'),
                              textAlign: TextAlign.center,
                              style: AppTypography.title1.copyWith(
                                color: c.onHero,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          rise(
                            _subtitleT,
                            Text(
                              l.doneSubtitle(user.community),
                              key: const Key('done-subtitle'),
                              textAlign: TextAlign.center,
                              style: AppTypography.body.copyWith(
                                color: c.onHeroMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xxl,
                  AppSpacing.xl,
                  AppSpacing.xl + bottom,
                ),
                decoration: BoxDecoration(
                  color: c.sheet,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AuthMotion.panelRadius),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l.doneSlogan,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyStrong.copyWith(
                        color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    PrimaryButton(
                      key: const Key('done-start'),
                      label: l.doneStart,
                      // go: yığın temizlenir, geri tuşu bu ekrana dönmez.
                      onPressed: () => context.go('/home'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

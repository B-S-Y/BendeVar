import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/institution_email_field.dart';
import '../../../l10n/app_localizations.dart';
import 'auth_backdrop.dart';
import 'auth_burst.dart';
import 'auth_motion.dart';
import '../viewmodel/auth_view_model.dart';
import 'login_form.dart';
import 'signup_form.dart';
import 'signup_stepper.dart';

enum AuthMode { home, login, signup }

/// 1.01 Karşılama + 1.02 Giriş: yıldızlı üst şerit ve alt panel tek sahnede.
/// "Giriş yap"a basınca aynı panel büyüyüp forma dönüşür (ANIMASYON_1.01.md).
class AuthStage extends StatefulWidget {
  const AuthStage({super.key, this.initialMode = AuthMode.home});

  /// [AuthMode.login] / [AuthMode.signup] ile açılırsa açılış animasyonu atlanır.
  final AuthMode initialMode;

  @override
  State<AuthStage> createState() => _AuthStageState();
}

class _AuthStageState extends State<AuthStage> with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: AuthMotion.intro,
  );
  late final AnimationController _mode = AnimationController(
    vsync: this,
    duration: AuthMotion.modeDuration,
  );
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: AuthMotion.ambientPeriod,
  );

  bool _loginOpen = false;

  /// Panel açıkken gösterilen form (giriş / kayıt).
  AuthMode _form = AuthMode.login;
  late final InstitutionEmailController _signupEmail;
  Ticker? _introTicker;
  Timer? _introDelay;

  static const double _total = AuthMotion.introSeconds;

  @override
  void initState() {
    super.initState();
    _signupEmail = InstitutionEmailController(
      text: context.read<AuthViewModel>().signupEmail,
    );
    if (widget.initialMode != AuthMode.home) {
      _form = widget.initialMode;
      _intro.value = 1;
      _mode.value = 1;
      _loginOpen = true;
    } else {
      // Açılış, ilk gerçek kare çizildikten ve sistemin uygulama penceresi
      // açma animasyonu bittikten sonra başlar (soğuk açılışta ilk kareler
      // ağır; animasyon o sırada oynayıp kaçmasın).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _introDelay = Timer(AuthMotion.introStartDelay, _startIntro);
      });
    }
  }

  /// "Animasyonları azalt" kararı burada, başlangıç oturduktan sonra okunur
  /// (ilk karedeki geçici değere güvenilmez).
  void _startIntro() {
    if (!mounted) return;
    if (reduceMotion(context)) {
      _intro.value = 1;
      return;
    }
    // İlk karede "azalt" geçici olarak true görünmüş olabilir: baştan oyna.
    _intro.value = 0;
    Duration last = Duration.zero;
    _introTicker = createTicker((elapsed) {
      // Kare atlaması animasyonu yutmasın: tek karede en fazla 50 ms ilerler.
      final dt = elapsed - last;
      last = elapsed;
      final step = dt > AuthMotion.maxFrameStep ? AuthMotion.maxFrameStep : dt;
      final v =
          _intro.value + step.inMicroseconds / AuthMotion.intro.inMicroseconds;
      if (v >= 1) {
        _intro.value = 1;
        _introTicker?.stop();
      } else {
        _intro.value = v;
      }
    })..start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // "Azalt" açıksa son kare hemen gösterilir (başlangıç kararı _startIntro'da
    // yeniden doğrulanır).
    if (reduceMotion(context) && _introTicker == null) _intro.value = 1;
    // Sürekli yıldız/leke animasyonu ayar değişince canlı izlenir.
    if (reduceMotion(context)) {
      _ambient.stop();
    } else if (!_ambient.isAnimating) {
      _ambient.repeat();
    }
  }

  @override
  void dispose() {
    _signupEmail.dispose();
    _introDelay?.cancel();
    _introTicker?.dispose();
    _intro.dispose();
    _mode.dispose();
    _ambient.dispose();
    super.dispose();
  }

  void _openForm(AuthMode form) {
    setState(() {
      _form = form;
      _loginOpen = true;
    });
    if (reduceMotion(context)) {
      _mode.value = 1;
    } else {
      _mode.forward();
    }
  }

  void _closeLogin() {
    FocusScope.of(context).unfocus();
    setState(() => _loginOpen = false);
    if (reduceMotion(context)) {
      _mode.value = 0;
    } else {
      _mode.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final size = MediaQuery.sizeOf(context);
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final groupTop =
        AuthMotion.groupTop * size.height / AuthMotion.designHeight;
    final reduce = reduceMotion(context);

    // Logo, durum çubuğu/çentik altında kalsın: kayma miktarları buna göre.
    final minTop = MediaQuery.paddingOf(context).top + AuthMotion.logoTopGap;
    final homeShift = (groupTop - minTop).clamp(0.0, AuthMotion.groupShift);
    final finalTop = math.max(minTop, groupTop - 2 * AuthMotion.groupShift);
    final modeShift = math.max(0.0, groupTop - homeShift - finalTop);

    return PopScope(
      canPop: !_loginOpen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _closeLogin();
      },
      child: Scaffold(
        backgroundColor: c.hero,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Positioned.fill(
              child: AuthBackdrop(ambient: reduce ? null : _ambient),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: BurstPainter(
                    intro: _intro,
                    mode: _mode,
                    shift: homeShift,
                    center: Offset(
                      size.width / 2,
                      groupTop + AuthMotion.logoSize / 2,
                    ),
                    colors: c,
                  ),
                ),
              ),
            ),
            _buildGroup(context, size, groupTop, homeShift, modeShift),
            _buildPanel(context, size, keyboard),
          ],
        ),
      ),
    );
  }

  /// Logo + ad + slogan.
  Widget _buildGroup(
    BuildContext context,
    Size size,
    double groupTop,
    double homeShift,
    double modeShift,
  ) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final ox = size.width / 2;

    return Positioned(
      top: groupTop,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: Listenable.merge([_intro, _mode]),
          builder: (context, _) {
            final t = _intro.value;
            final m = _mode.value;

            // Logo: 0→0,64 ölçek .2→1,15; 0,64→1,04 ölçek 1,15→1.
            final popP = span(t, _total, AuthMotion.logoPop, AuthMotion.pop);
            final settleP = span(
              t,
              _total,
              AuthMotion.logoSettle,
              AuthMotion.pop,
            );
            final logoScale = t < AuthMotion.logoSettle.$1 / _total
                ? lerpD(AuthMotion.logoFrom, AuthMotion.logoOvershoot, popP)
                : lerpD(AuthMotion.logoOvershoot, 1, settleP);
            final logoOpacity = popP.clamp(0.0, 1.0);

            final nameP = span(t, _total, AuthMotion.name, AuthMotion.ease);
            final sloganP = span(t, _total, AuthMotion.slogan, AuthMotion.ease);
            final sloganOut =
                1 - span(m, AuthMotion.modeSeconds, (0, AuthMotion.sloganOut));

            final shift = span(t, _total, AuthMotion.group, AuthMotion.slide);
            final mv = -homeShift * shift;
            final grow = span(m, AuthMotion.modeSeconds, (
              0,
              AuthMotion.modeMove,
            ), AuthMotion.expand);
            final scale = lerpD(1, AuthMotion.miniScale, grow);
            // Ölçek, grubun yukarı kaymış hâlinin üst-ortasında (mockup: 195,180).
            final oy = -homeShift;

            final matrix = Matrix4.identity()
              ..translateByDouble(0, -modeShift * grow, 0, 1)
              ..translateByDouble(ox, oy, 0, 1)
              ..scaleByDouble(scale, scale, 1, 1)
              ..translateByDouble(-ox, -oy, 0, 1)
              ..translateByDouble(0, mv, 0, 1);

            return Transform(
              transform: matrix,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Opacity(
                    opacity: logoOpacity,
                    child: Transform.scale(
                      scale: logoScale,
                      alignment: const Alignment(0, .2),
                      child: const AppLogo(
                        size: AuthMotion.logoSize,
                        tile: AppColors.logoSourceTile,
                      ),
                    ),
                  ),
                  const SizedBox(height: AuthMotion.nameGap),
                  Opacity(
                    opacity: nameP,
                    child: Transform.translate(
                      offset: Offset(0, AuthMotion.nameRise * (1 - nameP)),
                      child: Text(
                        l.brandName,
                        style: AppTypography.brandHero.copyWith(
                          color: c.onHero,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AuthMotion.sloganGap),
                  Opacity(
                    opacity: sloganP * sloganOut,
                    child: Text(
                      l.slogan,
                      style: AppTypography.body.copyWith(color: c.onHeroMuted),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPanel(BuildContext context, Size size, double keyboard) {
    final c = context.colors;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final homeHeight = _homeHeight(context, size.width, bottomInset);
    // Açık panel, ekrana sığdığı kadar büyür ama ana panelden küçük olmaz.
    final openHeight = math.max(
      homeHeight,
      math.min(
        AuthMotion.panelOpen,
        size.height -
            keyboard -
            math.max(
              AuthMotion.panelTopReserve,
              MediaQuery.paddingOf(context).top +
                  AuthMotion.logoTopGap +
                  AuthMotion.miniGroupHeight +
                  AuthMotion.miniGroupGap,
            ),
      ),
    );

    return Positioned(
      left: 0,
      right: 0,
      bottom: keyboard,
      child: AnimatedBuilder(
        animation: Listenable.merge([_intro, _mode]),
        builder: (context, _) {
          final t = _intro.value;
          final m = _mode.value;
          final rise = span(t, _total, AuthMotion.panel, AuthMotion.slide);
          final grow = span(m, AuthMotion.modeSeconds, (
            0,
            AuthMotion.modeMove,
          ), AuthMotion.expand);
          final height = lerpD(homeHeight, openHeight, grow);

          return FractionalTranslation(
            translation: Offset(0, 1 - rise),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: c.sheet,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AuthMotion.panelRadius),
                ),
              ),
              child: Stack(
                children: [
                  if (m < 1) _homeContent(context, t, m, bottomInset),
                  if (m > 0) _loginContent(context, m),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Ana panelin yüksekliği: içerik (yazı boyutuna göre ölçülür) ve alt sistem
  /// çubuğu payı. Belgedeki 330, bunların altına inmez.
  double _homeHeight(BuildContext context, double width, double bottomInset) {
    final l = AppLocalizations.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    final textWidth = width - 2 * AuthMotion.homePadSide;

    double measure(String text, TextStyle style) {
      final tp = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: Directionality.of(context),
        textScaler: scaler,
      )..layout(maxWidth: textWidth);
      final h = tp.height;
      tp.dispose();
      return h;
    }

    final content =
        AuthMotion.homePadTop +
        measure(l.welcomeTitle, AppTypography.welcomeHeading) +
        _headingGap +
        measure(l.welcomeSubtitle, AppTypography.bodySmall) +
        AppSpacing.xl +
        AppSizes.buttonHeight +
        AppSpacing.md +
        AppSizes.buttonHeight +
        AuthMotion.homePadBottom;
    return math.max(AuthMotion.panelHome, content) + bottomInset;
  }

  static const double _headingGap = AppSpacing.sm - AppSpacing.xs / 2;

  /// Panelin ilk içeriği: başlık, açıklama, 2 düğme.
  Widget _homeContent(
    BuildContext context,
    double t,
    double m,
    double bottomInset,
  ) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final inP = span(t, _total, AuthMotion.panelContent, AuthMotion.ease);
    final outO =
        1 - span(m, AuthMotion.modeSeconds, (0, AuthMotion.oldContentOpacity));
    final outMove = span(m, AuthMotion.modeSeconds, (
      0,
      AuthMotion.oldContentMove,
    ));
    final dy =
        AuthMotion.contentRise * (1 - inP) -
        AuthMotion.oldContentLift * outMove;

    return Positioned(
      left: AuthMotion.homePadSide,
      right: AuthMotion.homePadSide,
      top: AuthMotion.homePadTop,
      child: IgnorePointer(
        ignoring: inP < 1 || m > 0,
        child: Opacity(
          opacity: inP * outO,
          child: Transform.translate(
            offset: Offset(0, dy),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l.welcomeTitle,
                  style: AppTypography.welcomeHeading.copyWith(
                    color: c.primary,
                  ),
                ),
                const SizedBox(height: _headingGap),
                Text(
                  l.welcomeSubtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: c.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: l.login,
                  onPressed: () => _openForm(AuthMode.login),
                ),
                const SizedBox(height: AppSpacing.md),
                SecondaryButton(
                  label: l.signup,
                  onPressed: () => _openForm(AuthMode.signup),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _switchForm(AuthMode form) {
    FocusScope.of(context).unfocus();
    setState(() => _form = form);
  }

  /// Giriş / kayıt formu: öğeler sırayla (0,25 / 0,30 / 0,36 sn gecikmeyle) gelir.
  Widget _loginContent(BuildContext context, double m) {
    double fade(int i) => delayed(
      m,
      AuthMotion.modeSeconds,
      AuthMotion.itemDelays[i],
      AuthMotion.formFade,
    );
    double rise(int i) =>
        AuthMotion.itemRise *
        (1 -
            delayed(
              m,
              AuthMotion.modeSeconds,
              AuthMotion.itemDelays[i],
              AuthMotion.formMove,
              AuthMotion.ease,
            ));

    Widget item(int i, Widget child) => Opacity(
      opacity: fade(i),
      child: Transform.translate(offset: Offset(0, rise(i)), child: child),
    );

    final wrapperFade = delayed(
      m,
      AuthMotion.modeSeconds,
      AuthMotion.itemDelays[0],
      AuthMotion.formFade,
    );
    final wrapperRise =
        AuthMotion.formRise *
        (1 -
            delayed(
              m,
              AuthMotion.modeSeconds,
              AuthMotion.itemDelays[0],
              AuthMotion.formMove,
              AuthMotion.expand,
            ));

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: wrapperFade < 1,
        child: Opacity(
          opacity: wrapperFade,
          child: Transform.translate(
            offset: Offset(0, wrapperRise),
            child: AnimatedSwitcher(
              duration: reduceMotion(context)
                  ? Duration.zero
                  : AuthMotion.formSwitch,
              child: KeyedSubtree(
                key: ValueKey(_form),
                child: Column(
                  children: _form == AuthMode.signup
                      ? [
                          item(0, SignupHeader(onExit: _closeLogin)),
                          item(1, const SignupStepper(step: 1)),
                          Expanded(
                            child: item(
                              2,
                              SignupBody(emailController: _signupEmail),
                            ),
                          ),
                          item(
                            3,
                            SignupFooter(
                              onLogin: () => _switchForm(AuthMode.login),
                            ),
                          ),
                        ]
                      : [
                          item(0, LoginHeader(onBack: _closeLogin)),
                          Expanded(child: item(1, const LoginBody())),
                          item(
                            2,
                            LoginFooter(
                              onSignup: () => _switchForm(AuthMode.signup),
                            ),
                          ),
                        ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

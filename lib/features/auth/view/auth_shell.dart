import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../l10n/app_localizations.dart';
import 'auth_backdrop.dart';
import 'auth_motion.dart';

/// Yıldızlı üst şerit + alt panel düzeni (1.09, 1.10, 1.12, 1.10a/b).
/// Aynı düzen karşılama/giriş/kayıt sahnesinde ([AuthStage]) de kullanılır.
class AuthShell extends StatefulWidget {
  const AuthShell({
    super.key,
    required this.title,
    required this.child,
    this.onBack,
    this.backTooltip,
    this.backIcon = LucideIcons.arrowLeft,
    this.footer,
    this.step,
  });

  /// Panel üst satırındaki başlık ("Kayıt ol", "Kullanım şartları"...).
  final String title;
  final VoidCallback? onBack;
  final String? backTooltip;
  final IconData backIcon;

  /// Başlık satırının altında, kaydırılabilir gövde.
  final Widget child;

  /// Altta sabit duran alan (düğmeler).
  final Widget? footer;

  /// Kayıt adım göstergesi (1–3); null ise gösterilmez.
  final Widget? step;

  @override
  State<AuthShell> createState() => _AuthShellState();
}

class _AuthShellState extends State<AuthShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: AuthMotion.ambientPeriod,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _ambient.stop();
    } else if (!_ambient.isAnimating) {
      _ambient.repeat();
    }
  }

  @override
  void dispose() {
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final top = MediaQuery.paddingOf(context).top;
    final logoTop = top + AuthMotion.logoTopGap > AuthMotion.logoSmallTop
        ? top + AuthMotion.logoTopGap
        : AuthMotion.logoSmallTop;

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
              SizedBox(height: logoTop),
              const AppLogo(
                size: AuthMotion.logoSmall,
                tile: AppColors.logoSourceTile,
              ),
              const SizedBox(height: AppSpacing.sm - 1),
              Text(
                l.brandName,
                style: AppTypography.title2.copyWith(color: c.onHero),
              ),
              const SizedBox(height: AuthMotion.shellGap),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: c.sheet,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AuthMotion.panelRadius),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.sm,
                          AppSpacing.sm + AppSpacing.xs,
                          AppSpacing.screen,
                          0,
                        ),
                        child: SizedBox(
                          height: AuthMotion.headerRow,
                          child: Row(
                            children: [
                              if (widget.onBack != null)
                                AppIconButton(
                                  icon: widget.backIcon,
                                  tooltip: widget.backTooltip ?? l.back,
                                  onPressed: widget.onBack,
                                )
                              else
                                const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: Text(
                                  widget.title,
                                  style: AppTypography.appBar.copyWith(
                                    color: c.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ?widget.step,
                      Expanded(child: widget.child),
                      if (widget.footer != null)
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.xl,
                            AppSpacing.lg,
                            AppSpacing.xl,
                            AppSpacing.xxl +
                                MediaQuery.paddingOf(context).bottom,
                          ),
                          child: widget.footer,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Geri düğmesi için ortak davranış: yığında sayfa varsa pop, yoksa [fallback].
VoidCallback backOr(BuildContext context, String fallback) => () {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(fallback);
  }
};

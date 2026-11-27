import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_spacing.dart';

/// 1.01 açılış animasyonu ve giriş/kayıt geçişi sabitleri.
/// Kaynak: design/ANIMASYON_1.01.md (mockup 8 sn döngüsünün saniyeye çevrilmiş hâli).
class AuthMotion {
  const AuthMotion._();

  // ── Açılış (tek controller, bir kez) ──
  static const double introSeconds =
      3.52; // belge: ≈3,5 (son öğe 3,52 sn'de biter)
  static const Duration intro = Duration(milliseconds: 3520);

  /// İlk kareden sonra açılışı başlatmadan önce beklenen süre.
  static const Duration introStartDelay = Duration(milliseconds: 250);

  /// Tek karede animasyonun ilerleyebileceği en çok süre (kare atlamasına karşı).
  static const Duration maxFrameStep = Duration(milliseconds: 50);

  // Eğriler (CSS cubic-bezier karşılıkları)
  static const Curve pop = Cubic(.3, 1.6, .5, 1);
  static const Curve burst = Cubic(.15, .7, .3, 1);
  static const Curve slide = Cubic(.6, 0, .2, 1);
  static const Curve expand = Cubic(.3, .8, .2, 1);
  static const Curve ease = Curves.ease; // CSS "ease"
  static const Curve easeOut = Curves.easeOut;

  // Logo
  static const (double, double) logoPop = (0, .64);
  static const (double, double) logoSettle = (.64, 1.04);
  static const double logoFrom = .2;
  static const double logoOvershoot = 1.15;

  // Halkalar: (başlar, biter, ölçek sonu, başlangıç opaklığı)
  static const (double, double, double, double) ring1 = (.64, 1.92, 2.3, .85);
  static const (double, double, double, double) ring2 = (.88, 2.40, 3.0, .5);
  static const double ringScaleFrom = .6;
  static const double ring1Stroke = 2;
  static const double ring2Stroke = 1.5;
  static const double ringDiameter = 140;

  // Parçacıklar
  static const (double, double) particleFly = (.64, 1.92);
  static const (double, double) particleDrift = (1.92, 2.56);
  static const double particleScaleFrom = .4;
  static const double particleScaleEnd = .6;
  static const double particleOpacity = .9;
  static const double particleDriftFactor = 1.15;

  // Metinler
  static const (double, double) name = (.96, 1.52);
  static const (double, double) slogan = (1.52, 2.00);
  static const double nameRise = 10;

  // Yukarı kayma ve panel
  static const (double, double) group = (2.08, 2.88);
  static const (double, double) panel = (2.16, 3.04);
  static const (double, double) panelContent = (2.88, 3.52);
  static const double groupShift = 150;
  static const double contentRise = 8;

  // ── Yerleşim (412×917 tasarım uzayı, dp) ──
  static const double designHeight = 917;
  static const double groupTop = 330;
  static const double panelHome = 330;
  static const double panelOpen = 700;
  static const double panelRadius = 28;
  static const double logoSize = 104;
  static const double nameGap = 14;

  /// Karşılama paneli: slogan ile düğmeler arası (eski alt satır + iki boşluk
  /// yerine tek boşluk, 4'lük ızgara).
  static const double sloganButtonGap = AppSpacing.xxxl;
  static const double sloganGap = 8;
  static const double miniScale = .5;
  static const double homePadTop = 30;
  static const double homePadSide = 20;
  static const double homePadBottom = 34;
  static const double headerRow = 56;

  /// Giriş ↔ kayıt formu değişirken geçiş süresi.
  static const Duration formSwitch = Duration(milliseconds: 250);

  /// 1.09/1.10/1.12/yasal sayfalar: küçük logo ve panel yerleşimi.
  static const double logoSmall = 56;
  static const double logoSmallTop = 30;
  static const double shellGap = 28;

  /// Açık panelin üstünde logo grubuna bırakılan en az boşluk.
  static const double panelTopReserve = 130;

  /// Logonun durum çubuğu/çentik altında bırakacağı boşluk.
  static const double logoTopGap = 12;

  /// Küçültülmüş logo + ad bloğunun yüksekliği ve panelle arasındaki boşluk.
  static const double miniGroupHeight = 80;
  static const double miniGroupGap = 8;

  // ── Giriş/kayıt geçişi (ikinci controller, 1 sn: gecikmeler dahil) ──
  static const Duration modeDuration = Duration(milliseconds: 1000);
  static const double modeSeconds = 1.0;
  static const double modeMove = .5; // panel + logo büyüme/küçülme süresi
  static const double sloganOut = .2;
  static const double burstOut = .3;
  static const double oldContentOpacity = .2;
  static const double oldContentMove = .3;
  static const double oldContentLift = 10;
  static const double formFade = .3;
  static const double formMove = .4;
  static const double formRise = 16;
  static const double itemRise = 12;

  /// Formun öğeleri için sıralı gecikmeler (sn).
  static const List<double> itemDelays = [.25, .30, .36, .42, .48, .54];

  // ── Sürekli (yıldız, leke) ──
  static const Duration ambientPeriod = Duration(seconds: 3600);
  static const double ambientSeconds = 3600;
  static const double starMinOpacity = .15;
  static const double blobMorphSeconds = 12;
  static const double blobFloatSeconds = 10;
  static const double blobDx = 16;
  static const double blobDy = -20;
  static const double blobRotation = 22;
  static const double blobBlur = 36;
  static const double blobAlpha = .12;
}

/// Saniye cinsinden [a]–[b] aralığının, eğriyle 0..1'e çevrilmiş ilerlemesi.
/// [t] controller değeri (0..1), [total] controller'ın toplam saniyesi.
double span(double t, double total, (double, double) range, [Curve? curve]) {
  final i = Interval(
    range.$1 / total,
    range.$2 / total,
    curve: curve ?? Curves.linear,
  );
  return i.transform(t);
}

/// Gecikmeli (saniye) öğe ilerlemesi: [delay] sonra [dur] sürer.
double delayed(
  double t,
  double total,
  double delay,
  double dur, [
  Curve curve = Curves.linear,
]) => span(t, total, (delay, delay + dur), curve);

/// Telefonun "animasyonları azalt" ayarı açık mı?
bool reduceMotion(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context);

double lerpD(double a, double b, double t) => a + (b - a) * t;

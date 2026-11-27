import 'package:bende_var/app/app.dart';
import 'package:bende_var/app/di.dart';
import 'package:bende_var/app/locale_controller.dart';
import 'package:bende_var/app/theme_controller.dart';
import 'package:bende_var/core/theme/app_theme.dart';
import 'package:bende_var/l10n/app_localizations.dart';
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 412×917 dp Android ekranı.
void useAndroidScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(824, 1834);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  // Sürekli animasyonlar (yıldız/leke) pumpAndSettle'ı bekletmesin.
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
}

Future<void> initTestEnv() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  // Cihazdaki gibi Inter ölçüleriyle test için yazı tipini yükle.
  final loader = FontLoader('Inter');
  for (final f in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    loader.addFont(rootBundle.load('assets/fonts/Inter-$f.ttf'));
  }
  await loader.load();
}

/// Tam uygulamayı verilen tema ve dille açar.
Future<void> pumpApp(
  WidgetTester tester, {
  ThemeMode theme = ThemeMode.light,
  Locale locale = const Locale('tr'),
  Map<String, Object> prefsValues = const {},
  AppDependencies? deps,
  bool animations = false,
}) async {
  useAndroidScreen(tester);
  SharedPreferences.setMockInitialValues(prefsValues);
  final prefs = await SharedPreferences.getInstance();
  final themeCtrl = ThemeController(prefs);
  final localeCtrl = LocaleController(prefs);
  await themeCtrl.setMode(theme);
  await localeCtrl.setChoice(
    locale.languageCode == 'en' ? LocaleChoice.en : LocaleChoice.tr,
  );
  final appDeps = deps ?? AppDependencies();
  if (animations) {
    // Gerçek cihaz gibi: animasyonlar açık.
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures();
  }
  await tester.pumpWidget(
    BendeVarApp(
      deps: appDeps,
      themeController: themeCtrl,
      localeController: localeCtrl,
    ),
  );
  // Animasyonlar açıksa sürekli animasyon (yıldızlar) settle'ı bekletir.
  if (animations) {
    await tester.pump();
  } else {
    await tester.pumpAndSettle();
  }
}

/// Tek bir widget'ı tema + dil ile sarar.
Widget wrap(
  Widget child, {
  ThemeMode theme = ThemeMode.light,
  Locale locale = const Locale('tr'),
}) {
  return MaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: theme,
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    home: Scaffold(body: child),
  );
}

Future<void> signIn(WidgetTester tester) async {
  await tester.tap(find.text('Giriş yap').first);
  await tester.pumpAndSettle();
  await tester.enterText(
    find.byKey(const Key('email-field')),
    'elif@std.yildiz.edu.tr',
  );
  await tester.enterText(find.byKey(const Key('password-field')), 'sifre123');
  await tester.pump();
  await tester.tap(find.widgetWithText(ElevatedButton, 'Giriş yap'));
  await tester.pumpAndSettle();
}

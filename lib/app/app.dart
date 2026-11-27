import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/viewmodel/auth_view_model.dart';
import '../features/auth/viewmodel/community_view_model.dart';
import '../features/auth/viewmodel/settings_view_model.dart';
import '../features/home/viewmodel/home_view_model.dart';
import '../features/messages/viewmodel/messages_view_models.dart';
import '../features/profile/viewmodel/profile_view_models.dart';
import '../l10n/app_localizations.dart';
import 'di.dart';
import 'locale_controller.dart';
import 'router.dart';
import 'theme_controller.dart';

class BendeVarApp extends StatefulWidget {
  const BendeVarApp({
    super.key,
    required this.deps,
    required this.themeController,
    required this.localeController,
  });

  final AppDependencies deps;
  final ThemeController themeController;
  final LocaleController localeController;

  @override
  State<BendeVarApp> createState() => _BendeVarAppState();
}

class _BendeVarAppState extends State<BendeVarApp> {
  late final AuthViewModel _auth = AuthViewModel(
    widget.deps.auth,
    communities: widget.deps.communities,
  );
  late final HomeViewModel _home = HomeViewModel(widget.deps.listings);
  late final MessagesViewModel _messages = MessagesViewModel(widget.deps.chats);
  late final NotificationsViewModel _notifications = NotificationsViewModel(
    widget.deps.notifications,
  );
  late final ProfileViewModel _profile = ProfileViewModel(widget.deps.users);
  late final SettingsViewModel _settings = SettingsViewModel(
    widget.deps.settings,
  );
  late final CommunityViewModel _communities = CommunityViewModel(
    widget.deps.communities,
  );
  late final GoRouter _router = buildRouter(widget.deps, _auth);

  @override
  void dispose() {
    _router.dispose();
    _auth.dispose();
    _home.dispose();
    _messages.dispose();
    _notifications.dispose();
    _profile.dispose();
    _settings.dispose();
    _communities.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.themeController),
        ChangeNotifierProvider.value(value: widget.localeController),
        ChangeNotifierProvider.value(value: _auth),
        ChangeNotifierProvider.value(value: _home),
        ChangeNotifierProvider.value(value: _messages),
        ChangeNotifierProvider.value(value: _notifications),
        ChangeNotifierProvider.value(value: _profile),
        ChangeNotifierProvider.value(value: _settings),
        ChangeNotifierProvider.value(value: _communities),
      ],
      child: Consumer2<ThemeController, LocaleController>(
        builder: (context, theme, locale, _) => MaterialApp.router(
          onGenerateTitle: (ctx) => AppLocalizations.of(ctx).brandName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: theme.mode,
          locale: locale.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          // Varsayılan Türkçe; cihaz dili İngilizceyse İngilizce.
          localeResolutionCallback: (device, supported) =>
              device?.languageCode == 'en'
              ? const Locale('en')
              : const Locale('tr'),
          routerConfig: _router,
        ),
      ),
    );
  }
}

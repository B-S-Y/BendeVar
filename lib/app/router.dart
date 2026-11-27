import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_motion.dart';
import '../core/theme/app_page_transitions.dart';
import '../core/widgets/coming_soon_page.dart';
import '../data/models/models.dart';
import '../features/auth/view/legal_page.dart';
import '../features/auth/view/login_page.dart';
import '../features/auth/view/password_reset_pages.dart';
import '../features/auth/view/community_pages.dart';
import '../features/auth/view/settings_pages.dart';
import '../features/auth/view/signup_done_page.dart';
import '../features/auth/view/splash_page.dart';
import '../features/auth/view/signup_expired_page.dart';
import '../features/auth/view/signup_name_page.dart';
import '../features/auth/view/signup_page.dart';
import '../features/auth/view/signup_sent_page.dart';
import '../features/auth/view/welcome_page.dart';
import '../features/auth/viewmodel/auth_view_model.dart';
import '../features/create_listing/view/create_listing_page.dart';
import '../features/create_listing/view/published_page.dart';
import '../features/create_listing/viewmodel/create_listing_view_model.dart';
import '../features/home/view/home_page.dart';
import '../features/home/view/listing_detail_page.dart';
import '../features/home/viewmodel/home_view_model.dart';
import '../features/messages/view/chat_page.dart';
import '../features/messages/view/messages_page.dart';
import '../features/messages/view/notifications_page.dart';
import '../features/messages/viewmodel/messages_view_models.dart';
import '../features/profile/view/loans_page.dart';
import '../features/profile/view/profile_page.dart';
import '../features/profile/viewmodel/profile_view_models.dart';
import 'app_shell.dart';
import 'di.dart';

const Set<String> _publicRoutes = {
  '/splash',
  '/welcome',
  '/login',
  '/signup',
  '/signup/sent',
  '/signup/name',
  '/signup/expired',
  '/forgot',
  '/forgot/sent',
  '/forgot/new',
  '/legal/terms',
  '/legal/privacy',
  '/coming-soon',
};

/// Giriş ekranı sayfası: giriş başarılı olunca (Ana Sayfa'ya geçerken) solar.
/// Diğer zamanlarda ortak sayfa geçişi.
Page<void> _authEntryPage(
  GoRouterState state,
  Widget child,
  AuthViewModel auth,
) => CustomTransitionPage<void>(
  key: state.pageKey,
  child: child,
  transitionDuration: AppMotion.page,
  reverseTransitionDuration: AppMotion.page,
  transitionsBuilder: (context, animation, secondary, child) {
    final base = AppMotion.reduce(context)
        ? child
        : AppPageTransitionsBuilder.slideFade(animation, child);
    if (!auth.fadeToHome || AppMotion.reduce(context)) return base;
    return AppPageTransitionsBuilder.fadeOut(secondary, base);
  },
);

/// Ana Sayfa (alt menü iskeleti): girişten sonra %96 → %100 büyüyerek ve
/// belirginleşerek gelir; "animasyonları azalt" açıksa doğrudan geçer.
Page<void> _shellPage(GoRouterState state, Widget child, AuthViewModel auth) {
  var played = false;
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: auth.fadeToHome
        ? AppMotion.loginToHome
        : AppMotion.page,
    reverseTransitionDuration: AppMotion.page,
    transitionsBuilder: (context, animation, secondary, child) {
      final reduce = AppMotion.reduce(context);
      // İlk kare "completed" görünür (henüz başlamadı); geçiş gerçekten
      // oynadıktan sonra ya da hiç oynamayacaksa (azaltılmış hareket) biter.
      if (animation.status == AnimationStatus.forward) played = true;
      if (auth.fadeToHome &&
          (reduce ||
              (played && animation.status == AnimationStatus.completed))) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => auth.endFadeToHome(),
        );
      }
      if (reduce) return child;
      return auth.fadeToHome
          ? AppPageTransitionsBuilder.scaleFade(animation, child)
          : AppPageTransitionsBuilder.slideFade(animation, child);
    },
  );
}

/// Oturum açıkken anlamsız olan giriş öncesi sayfalar → Ana Sayfa.
/// (`/signup/name` ve `/signup/done` dahil değil: kayıt orada tamamlanıp oturum
/// açılır; `/splash` kendi kararını verir; yasal metinler herkese açık.)
const Set<String> _preLoginRoutes = {
  '/welcome',
  '/login',
  '/signup',
  '/signup/sent',
  '/signup/expired',
  '/forgot',
  '/forgot/sent',
  '/forgot/new',
};

/// Uygulama yönlendirmesi. Giriş yoksa Karşılama'ya yönlenir.
GoRouter buildRouter(AppDependencies deps, AuthViewModel auth) {
  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  final branchKeys = List.generate(
    4,
    (i) => GlobalKey<NavigatorState>(debugLabel: 'branch$i'),
  );

  return GoRouter(
    navigatorKey: rootKey,
    // Açılış kapısı: oturum kontrolü + (varsa) kısa açılış, sonra Ana Sayfa;
    // oturum yoksa Karşılama.
    initialLocation: '/splash',
    refreshListenable: auth,
    redirect: (context, state) {
      final path = state.uri.path;
      final isPublic = _publicRoutes.contains(path);
      if (!auth.isSignedIn && !isPublic) return '/welcome';
      if (auth.isSignedIn && _preLoginRoutes.contains(path)) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (_, state) =>
            _authEntryPage(state, const SplashPage(), auth),
      ),
      GoRoute(
        path: '/welcome',
        pageBuilder: (_, state) =>
            _authEntryPage(state, const WelcomePage(), auth),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (_, state) =>
            _authEntryPage(state, const LoginPage(), auth),
      ),
      GoRoute(path: '/signup', builder: (_, _) => const SignupPage()),
      GoRoute(path: '/signup/sent', builder: (_, _) => const SignupSentPage()),
      GoRoute(path: '/signup/name', builder: (_, _) => const SignupNamePage()),
      GoRoute(path: '/signup/done', builder: (_, _) => const SignupDonePage()),
      GoRoute(
        path: '/signup/expired',
        builder: (_, _) => const SignupExpiredPage(),
      ),
      GoRoute(path: '/forgot', builder: (_, _) => const ForgotPasswordPage()),
      GoRoute(path: '/forgot/sent', builder: (_, _) => const ResetSentPage()),
      GoRoute(
        path: '/forgot/new',
        builder: (_, _) => const ResetNewPasswordPage(),
      ),
      GoRoute(
        path: '/legal/terms',
        builder: (_, _) => const LegalPage(kind: LegalKind.terms),
      ),
      GoRoute(
        path: '/legal/privacy',
        builder: (_, _) => const LegalPage(kind: LegalKind.privacy),
      ),
      GoRoute(path: '/coming-soon', builder: (_, _) => const ComingSoonPage()),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: rootKey,
        builder: (_, _) => const SettingsPage(),
      ),
      GoRoute(
        path: '/settings/notifications',
        parentNavigatorKey: rootKey,
        builder: (_, _) => const NotificationSettingsPage(),
      ),
      GoRoute(
        path: '/settings/privacy',
        parentNavigatorKey: rootKey,
        builder: (_, _) => const PrivacySupportPage(),
      ),
      GoRoute(
        path: '/settings/terms',
        parentNavigatorKey: rootKey,
        builder: (_, _) =>
            const LegalPage(kind: LegalKind.terms, inSettings: true),
      ),
      GoRoute(
        path: '/settings/privacy-policy',
        parentNavigatorKey: rootKey,
        builder: (_, _) =>
            const LegalPage(kind: LegalKind.privacy, inSettings: true),
      ),
      GoRoute(
        path: '/communities',
        parentNavigatorKey: rootKey,
        builder: (_, _) => const CommunitiesPage(),
      ),
      GoRoute(
        path: '/communities/create',
        parentNavigatorKey: rootKey,
        builder: (_, _) => const CreateCommunityPage(),
      ),
      GoRoute(
        path: '/settings/blocked',
        parentNavigatorKey: rootKey,
        builder: (_, _) => const BlockedAccountsPage(),
      ),
      StatefulShellRoute.indexedStack(
        pageBuilder: (context, state, shell) => _shellPage(
          state,
          AppShell(shell: shell, branchKeys: branchKeys),
          auth,
        ),
        branches: [
          StatefulShellBranch(
            navigatorKey: branchKeys[0],
            routes: [
              GoRoute(path: '/home', builder: (_, _) => const HomePage()),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: branchKeys[1],
            routes: [
              GoRoute(
                path: '/messages',
                builder: (_, _) => const MessagesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: branchKeys[2],
            routes: [
              GoRoute(
                path: '/notifications',
                builder: (_, _) => const NotificationsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: branchKeys[3],
            routes: [
              GoRoute(path: '/profile', builder: (_, _) => const ProfilePage()),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/listing/:id',
        parentNavigatorKey: rootKey,
        builder: (_, state) =>
            ListingDetailPage(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/create/:kind',
        parentNavigatorKey: rootKey,
        builder: (context, state) {
          final kind = state.pathParameters['kind'] == 'ihtiyac'
              ? ListingKind.ihtiyac
              : ListingKind.ilan;
          return ChangeNotifierProvider(
            create: (_) => CreateListingViewModel(
              kind: kind,
              repo: deps.listings,
              ownerName: auth.user?.shortName ?? '',
            ),
            child: const CreateListingPage(),
          );
        },
      ),
      GoRoute(
        path: '/published/:id',
        parentNavigatorKey: rootKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final kind =
              context.read<HomeViewModel>().byId(id)?.kind ?? ListingKind.ilan;
          return PublishedPage(id: id, kind: kind);
        },
      ),
      GoRoute(
        path: '/chat/:id',
        parentNavigatorKey: rootKey,
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => ChatViewModel(deps.chats, state.pathParameters['id']!),
          child: const ChatPage(),
        ),
      ),
      GoRoute(
        path: '/loans',
        parentNavigatorKey: rootKey,
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => LoansViewModel(
            deps.users,
            initial: state.uri.queryParameters['dir'] == 'lent'
                ? LoanDirection.lent
                : LoanDirection.borrowed,
          ),
          child: const LoansPage(),
        ),
      ),
    ],
  );
}

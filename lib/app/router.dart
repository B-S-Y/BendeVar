import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/widgets/coming_soon_page.dart';
import '../data/models/models.dart';
import '../features/auth/view/login_page.dart';
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

const Set<String> _publicRoutes = {'/welcome', '/login', '/coming-soon'};

/// Uygulama yönlendirmesi. Giriş yoksa Karşılama'ya yönlenir.
GoRouter buildRouter(AppDependencies deps, AuthViewModel auth) {
  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  final branchKeys = List.generate(
    4,
    (i) => GlobalKey<NavigatorState>(debugLabel: 'branch$i'),
  );

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/home',
    refreshListenable: auth,
    redirect: (context, state) {
      final path = state.uri.path;
      final isPublic = _publicRoutes.contains(path);
      if (!auth.isSignedIn && !isPublic) return '/welcome';
      if (auth.isSignedIn && (path == '/welcome' || path == '/login')) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/welcome', builder: (_, _) => const WelcomePage()),
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/coming-soon', builder: (_, _) => const ComingSoonPage()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) =>
            AppShell(shell: shell, branchKeys: branchKeys),
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

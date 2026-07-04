import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/auth/user_entity.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/recover_password_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/auth/splash_page.dart';
import '../../presentation/pages/stories/create_story_page.dart';
import '../../presentation/pages/stories/home_page.dart';
import '../../presentation/pages/stories/join_story_page.dart';
import '../../presentation/pages/stories/story_detail_page.dart';
import '../../presentation/providers/auth/auth_provider.dart';

part 'app_router.g.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String recoverPassword = '/recover-password';
  static const String home = '/home';
  static const String createStory = '/create-story';
  static const String joinStory = '/join-story';

  static const String _storyCategoriesPattern = '/story/:id/categories';
  static const String _storyHistoryPattern = '/story/:id/history';
  static const String _storyAlbumPattern = '/story/:id/album';
  static const String _storyRoulettePattern = '/story/:id/roulette';

  static String storyCategories(String id) => '/story/$id/categories';
  static String storyHistory(String id) => '/story/$id/history';
  static String storyAlbum(String id) => '/story/$id/album';
  static String storyRoulette(String id) => '/story/$id/roulette';
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refreshNotifier = _RouterRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.value != null;
      final isSplash = state.matchedLocation == AppRoutes.splash;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.recoverPassword;

      if (authState.isLoading) {
        return isSplash ? null : AppRoutes.splash;
      }
      if (!isLoggedIn) {
        // Splash doubles as the logged-out "Bienvenida" welcome screen, so
        // it's allowed alongside the other auth routes.
        return (isAuthRoute || isSplash) ? null : AppRoutes.login;
      }
      if (isSplash || isAuthRoute) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.recoverPassword,
        name: 'recoverPassword',
        builder: (context, state) => const RecoverPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.createStory,
        name: 'createStory',
        builder: (context, state) => const CreateStoryPage(),
      ),
      GoRoute(
        path: AppRoutes.joinStory,
        name: 'joinStory',
        builder: (context, state) => const JoinStoryPage(),
      ),
      GoRoute(
        path: AppRoutes._storyCategoriesPattern,
        name: 'storyCategories',
        builder: (context, state) => StoryDetailPage(
          storyId: state.pathParameters['id']!,
          tabIndex: 0,
        ),
      ),
      GoRoute(
        path: AppRoutes._storyHistoryPattern,
        name: 'storyHistory',
        builder: (context, state) => StoryDetailPage(
          storyId: state.pathParameters['id']!,
          tabIndex: 1,
        ),
      ),
      GoRoute(
        path: AppRoutes._storyAlbumPattern,
        name: 'storyAlbum',
        builder: (context, state) => StoryDetailPage(
          storyId: state.pathParameters['id']!,
          tabIndex: 2,
        ),
      ),
      GoRoute(
        path: AppRoutes._storyRoulettePattern,
        name: 'storyRoulette',
        builder: (context, state) => StoryDetailPage(
          storyId: state.pathParameters['id']!,
          tabIndex: 3,
        ),
      ),
    ],
  );
}

/// Bridges [authProvider] to a [Listenable] so [GoRouter]
/// re-evaluates its `redirect` callback exactly when the session state
/// the redirect itself reads (via `ref.read`) actually changes.
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    _subscription = ref.listen<AsyncValue<UserEntity?>>(
      authProvider,
      (_, _) => notifyListeners(),
    );
  }

  late final ProviderSubscription<AsyncValue<UserEntity?>> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

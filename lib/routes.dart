import 'package:fe_tucknpike/services/auth_service.dart';
import 'package:fe_tucknpike/views/coaches/gymnasts_page.dart';
import 'package:fe_tucknpike/views/gymnasts/trainings_page.dart';
import 'package:fe_tucknpike/views/login_page.dart';
import 'package:fe_tucknpike/views/profile_page.dart';
import 'package:fe_tucknpike/views/registration_page.dart';
import 'package:fe_tucknpike/views/role_based_shell.dart';
import 'package:go_router/go_router.dart';

/// The main application router.
final GoRouter router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final loggedIn = AuthService().isLoggedIn;
    final loggingIn =
        state.uri.toString() == '/login' || state.uri.toString() == '/register';

    // If at root '/', determine destination based on logged in state.
    if (state.uri.toString() == '/') {
      return loggedIn ? '/gymnasts' : '/login';
    }

    // If not logged in and not going to login/register, redirect to /login.
    if (!loggedIn && !loggingIn) return '/login';

    // If logged in but trying to visit login/register, send them to default page.
    if (loggedIn && loggingIn) return '/gymnasts';

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegistrationPage(),
    ),
    // Shell route for authenticated pages.
    ShellRoute(
      builder: (context, state, child) => RoleBasedShell(child: child),
      routes: [
        GoRoute(
          path: '/gymnasts',
          builder: (context, state) => const GymnastsPage(),
        ),
        GoRoute(
          path: '/trainings',
          builder: (context, state) => const TrainingsPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),
  ],
);

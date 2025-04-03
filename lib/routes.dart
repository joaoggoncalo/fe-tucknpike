import 'package:fe_tucknpike/services/auth_service.dart';
import 'package:fe_tucknpike/views/coaches/gymnasts_page.dart';
import 'package:fe_tucknpike/views/gymnasts/trainings_page.dart';
import 'package:fe_tucknpike/views/login_page.dart';
import 'package:fe_tucknpike/views/profile_page.dart';
import 'package:fe_tucknpike/views/registration_page.dart';
import 'package:fe_tucknpike/views/role_based_shell.dart';
import 'package:go_router/go_router.dart';

/// This file contains the routing logic for the application
/// using the GoRouter package.
final GoRouter router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final loggedIn = AuthService().isLoggedIn;
    final loggingIn =
        state.uri.toString() == '/login' || state.uri.toString() == '/register';

    if (loggedIn) {
      final role = AuthService().userRole;

      if (state.uri.toString() == '/' || loggingIn) {
        return role == 'gymnast' ? '/trainings' : '/gymnasts';
      }
    }

    // If not logged in and not heading toward login/register, force login.
    if (!loggedIn && !loggingIn) return '/login';

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

import 'package:fe_tucknpike/services/auth_service.dart';
import 'package:fe_tucknpike/views/home_page.dart';
import 'package:fe_tucknpike/views/login_page.dart';
import 'package:fe_tucknpike/views/registration_page.dart';
import 'package:go_router/go_router.dart';

/// The main router for the application.
final GoRouter router = GoRouter(
  initialLocation: '/login',
  // Redirect logic to protect routes.
  redirect: (context, state) {
    final loggedIn = AuthService().isLoggedIn;
    final loggingIn =
        state.uri.toString() == '/login' || state.uri.toString() == '/register';

    // If the user is not logged in and is trying to access a protected route,
    // redirect to login.
    if (!loggedIn && !loggingIn) return '/login';

    // If the user is logged in and tries to access login or registration,
    // send them to home.
    if (loggedIn && loggingIn) return '/home';

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
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
  ],
);

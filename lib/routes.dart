// File: lib/routes.dart
import 'package:fe_tucknpike/models/trainings.dart';
import 'package:fe_tucknpike/services/auth_service.dart';
import 'package:fe_tucknpike/views/coaches/gymnasts_page.dart';
import 'package:fe_tucknpike/views/coaches/select_gymnast_page.dart';
import 'package:fe_tucknpike/views/create_training_page.dart';
import 'package:fe_tucknpike/views/gymnasts/trainings_page.dart';
import 'package:fe_tucknpike/views/login_page.dart';
import 'package:fe_tucknpike/views/profile_page.dart';
import 'package:fe_tucknpike/views/registration_page.dart';
import 'package:fe_tucknpike/views/role_based_shell.dart';
import 'package:fe_tucknpike/views/training_detail_page.dart';
import 'package:go_router/go_router.dart';

/// A [GoRouter] instance that manages the app's routing.
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
          path: '/trainings/:trainingId',
          builder: (context, state) {
            final training = state.extra! as Training;
            final fromProfile = state.uri.queryParameters['from'] == 'profile';
            return TrainingDetailPage(
              training: training,
              fromProfile: fromProfile,
            );
          },
        ),
        GoRoute(
          path: '/create-training',
          builder: (context, state) {
            final selectedGymnast = state.extra as Map<String, dynamic>?;
            return CreateTrainingPage(selectedGymnast: selectedGymnast);
          },
        ),
        GoRoute(
          path: '/select-gymnast',
          builder: (context, state) => const SelectGymnastPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),
  ],
);

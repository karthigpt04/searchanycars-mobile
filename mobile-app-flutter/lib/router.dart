import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/compare_screen.dart';
import 'screens/wishlist_screen.dart';
import 'screens/splus_screen.dart';
import 'screens/splus_new_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/car_detail_screen.dart';
import 'screens/main_shell.dart';
import 'screens/my_bookings_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/book_test_drive_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
// Shell navigator keys are managed by StatefulShellRoute

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/compare',
              builder: (context, state) => const CompareScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/splus',
              builder: (context, state) => const SplusScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/splus-new',
              builder: (context, state) => const SplusNewScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/wishlist',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const WishlistScreen(),
    ),
    GoRoute(
      path: '/my-bookings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const MyBookingsScreen(),
    ),
    GoRoute(
      path: '/car/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final carId = int.parse(state.pathParameters['id']!);
        return CarDetailScreen(carId: carId);
      },
    ),
    GoRoute(
      path: '/settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/book-test-drive/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final carId = int.parse(state.pathParameters['id']!);
        return BookTestDriveScreen(carId: carId);
      },
    ),
    GoRoute(
      path: '/login',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const RegisterScreen(),
    ),
  ],
);

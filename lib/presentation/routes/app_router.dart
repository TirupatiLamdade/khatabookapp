import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/processing_screen.dart';
import '../screens/shop/shop_setup_screen.dart';
import '../screens/dashboard/home_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/welcome',
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/processing',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>? ?? {};
          return ProcessingScreen(prefilledData: extra);
        },
      ),
      GoRoute(
        path: '/shop-setup',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>? ?? {};
          return ShopManageScreen(
            prefilledEmail: extra['email'] ?? '',
            prefilledPhone: extra['phone'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:login_setup/presentation/screens/auth/opensplach_screen.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/processing_screen.dart';
import '../screens/shop/shop_setup_screen.dart';
import '../screens/dashboard/home_screen.dart';


class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    
    refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
    
    redirect: (BuildContext context, GoRouterState state) {
      final user = FirebaseAuth.instance.currentUser;
      final location = state.matchedLocation;

      final isPublicOrGatekeeper = location == '/splash' || 
                                   location == '/welcome' || 
                                   location == '/login' || 
                                   location == '/processing' ||
                                   location == '/shop-setup';

      // 1️⃣ जर युझर लॉग इन नसेल आणि Home सारख्या प्रिव्हेट स्क्रीनवर जात असेल
      if (user == null && !isPublicOrGatekeeper) {
        return '/welcome';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
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
          final rawExtra = state.extra as Map<String, dynamic>? ?? {};
          final Map<String, String> safeExtra = rawExtra.map(
            (key, value) => MapEntry(key, value.toString()),
          );
          return ProcessingScreen(prefilledData: safeExtra);
        },
      ),
      GoRoute(
        path: '/shop-setup',
        builder: (context, state) {
          final rawExtra = state.extra as Map<String, dynamic>? ?? {};
          return ShopManageScreen(
            prefilledEmail: rawExtra['email']?.toString() ?? '',
            prefilledPhone: rawExtra['phone']?.toString() ?? '',
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

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (_) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.cancel(); super.dispose();
  }
}
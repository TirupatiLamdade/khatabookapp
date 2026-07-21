// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:login_setup/presentation/screens/auth/opensplach_screen.dart';
// import '../screens/auth/welcome_screen.dart';
// import '../screens/auth/login_screen.dart';
// import '../screens/auth/processing_screen.dart';
// import '../screens/shop/shop_setup_screen.dart';
// import '../screens/dashboard/home_screen.dart';

// class AppRouter {
//   static final router = GoRouter(
//     initialLocation: '/splash',
    
//     // 🔄 Listen to Firebase Auth state changes automatically
//     refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
    
//     // 🛡️ Global Auth Guard Redirect Logic
//     redirect: (BuildContext context, GoRouterState state) {
//       final user = FirebaseAuth.instance.currentUser;
//       final isLoggingIn = state.matchedLocation == '/login' || 
//                           state.matchedLocation == '/welcome' || 
//                           state.matchedLocation == '/splash';

//       // 1. If user is logged in & tries to go to Splash/Welcome/Login -> Send to /home
//       if (user != null && isLoggingIn) {
//         return '/home';
//       }

//       // 2. If user is NOT logged in & tries to access protected routes -> Send to /welcome
//       if (user == null && !isLoggingIn) {
//         return '/welcome';
//       }

//       return null; // No redirect needed
//     },

//     routes: [
//       GoRoute(
//         path: '/splash',
//         builder: (context, state) => const SplashScreen(),
//       ),
//       GoRoute(
//         path: '/welcome',
//         builder: (context, state) => const WelcomeScreen(),
//       ),
//       GoRoute(
//         path: '/login',
//         builder: (context, state) => const LoginScreen(),
//       ),
//       GoRoute(
//         path: '/processing',
//         builder: (context, state) {
//           final extra = state.extra as Map<String, String>? ?? {};
//           return ProcessingScreen(prefilledData: extra);
//         },
//       ),
//       GoRoute(
//         path: '/shop-setup',
//         builder: (context, state) {
//           final extra = state.extra as Map<String, String>? ?? {};
//           return ShopManageScreen(
//             prefilledEmail: extra['email'] ?? '',
//             prefilledPhone: extra['phone'] ?? '',
//           );
//         },
//       ),
//       GoRoute(
//         path: '/home',
//         builder: (context, state) => const HomeScreen(),
//       ),
//     ],
//   );
// }

// // ⚡ Helper Stream to Listenable conversion for GoRouter
// class GoRouterRefreshStream extends ChangeNotifier {
//   GoRouterRefreshStream(Stream<dynamic> stream) {
//     notifyListeners();
//     stream.listen((_) => notifyListeners());
//   }
// }
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

      // 🛡️ Public/Gatekeeper राऊट्स जिथे Auto-Redirect पूर्णपणे बंद ठेवला आहे
      final isPublicOrGatekeeper = location == '/splash' || 
                                   location == '/welcome' || 
                                   location == '/login' || 
                                   location == '/processing' ||
                                   location == '/shop-setup';

      // 1️⃣ युझर लॉग इन नाही आणि Protected Screen वर जाण्याचा प्रयत्न करतोय
      if (user == null && !isPublicOrGatekeeper) {
        return '/welcome';
      }

      // 2️⃣ टीप: /login स्क्रीनवर असताना युझरला मध्येच /home वर वळवणे बंद केले आहे,
      // जेणेकरून OTP व्हॅरीफाय झाल्यावर New Password व Multi-Account Selection दिसेल.

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
    _subscription.cancel();
    super.dispose();
  }
}


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

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// // Screens Import (Clean Architecture Path)
// import '../screens/auth/opensplach_screen.dart';
// import '../screens/auth/welcome_screen.dart';
// import '../screens/auth/login_screen.dart';
// import '../screens/auth/processing_screen.dart';
// import '../screens/auth/pin_lock_screen.dart';
// import '../screens/shop/shop_setup_screen.dart';
// import '../screens/dashboard/home_screen.dart';
// import '../screens/profile/profile_screen.dart';
// import '../screens/setting/setting_screen.dart';

// class AppRouter {
//   static final GoRouter router = GoRouter(
//     initialLocation: '/splash',
    
//     refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
    
//     redirect: (BuildContext context, GoRouterState state) async {
//       final user = FirebaseAuth.instance.currentUser;
//       final location = state.matchedLocation;

//       final isPublicOrGatekeeper = location == '/splash' || 
//                                    location == '/welcome' || 
//                                    location == '/login' || 
//                                    location == '/processing' ||
//                                    location == '/shop-setup' ||
//                                    location == '/pin-lock';

//       // 1️⃣ जर युझर लॉग इन नसेल आणि प्रिव्हेट स्क्रीनवर जात असेल तर Welcome कडे पाठवणे
//       if (user == null && !isPublicOrGatekeeper) {
//         return '/welcome';
//       }

//       // 2️⃣ युझर ऑटो-लॉगिन / री-लॉगिन झाला असेल आणि /home वर चालला असेल तर Lock Check करणे
//       if (user != null && location == '/home') {
//         try {
//           final userDoc = await FirebaseFirestore.instance
//               .collection('users')
//               .doc(user.uid)
//               .get();

//           if (userDoc.exists && userDoc.data() != null) {
//             final data = userDoc.data()!;
//             final bool isPinEnabled = data['isPinEnabled'] ?? false;
//             final bool isBiometricEnabled = data['isBiometricEnabled'] ?? false;

//             // जर युझरने PIN किंवा Biometric Security चालू ठेवली असेल, तर आधी Lock Screen कडे वळवणे
//             if (isPinEnabled || isBiometricEnabled) {
//               return '/pin-lock';
//             }
//           }
//         } catch (e) {
//           debugPrint("Router Security Check Error: $e");
//         }
//       }

//       return null;
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
//           final rawExtra = state.extra as Map<String, dynamic>? ?? {};
//           final Map<String, String> safeExtra = rawExtra.map(
//             (key, value) => MapEntry(key, value.toString()),
//           );
//           return ProcessingScreen(prefilledData: safeExtra);
//         },
//       ),
//       GoRoute(
//         path: '/shop-setup',
//         builder: (context, state) {
//           final rawExtra = state.extra as Map<String, dynamic>? ?? {};
//           return ShopManageScreen(
//             prefilledEmail: rawExtra['email']?.toString() ?? '',
//             prefilledPhone: rawExtra['phone']?.toString() ?? '',
//           );
//         },
//       ),
//       GoRoute(
//         path: '/pin-lock',
//         builder: (context, state) {
//           final extra = state.extra as Map<String, dynamic>? ?? {};
//           return PinLockScreen(
//             isDeleteMode: extra['isDeleteMode'] ?? false,
//           );
//         },
//       ),
//       GoRoute(
//         path: '/home',
//         builder: (context, state) => const HomeScreen(),
//       ),
//       GoRoute(
//         path: '/profile',
//         builder: (context, state) => const ProfileScreen(),
//       ),
//       GoRoute(
//         path: '/settings',
//         builder: (context, state) => const SettingsControlPanel(isDark: true, textColor: Colors.black, cardBgColor: Colors.white12, borderColor: Colors.white70,),
//       ),
//     ],
//   );
// }

// class GoRouterRefreshStream extends ChangeNotifier {
//   late final StreamSubscription<dynamic> _subscription;

//   GoRouterRefreshStream(Stream<dynamic> stream) {
//     notifyListeners();
//     _subscription = stream.asBroadcastStream().listen(
//       (_) => notifyListeners(),
//     );
//   }

//   @override
//   void dispose() {
//     _subscription.cancel();
//     super.dispose();
//   }
// }
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_setup/presentation/screens/setting/setting_screen.dart';

// Screens & Views Imports
import '../screens/auth/welcome_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/pin_lock_screen.dart';
import '../screens/dashboard/home_screen.dart';
import '../screens/customer/customer_list_screen.dart';
import '../screens/customer/ledger_screen.dart';
import '../screens/customer/recycle_bin_screen.dart';
import '../screens/customer/scanner_view.dart';
import '../screens/shop/shop_manage_screen.dart';


class AppRouter {
  // 🧭 गो-राउटरची मुख्य कॉन्फिगरेशन पाईपलाईन (Main GoRouter Instance)
  static final GoRouter router = GoRouter(
    initialLocation: '/welcome',
    debugLogDiagnostics: true, // डेव्हलपमेंट दरम्यान लॉग्स तपासण्यासाठी

    // 🛡️ SECURITY GUARD REDIRECT: युझर लॉग-इन आहे की नाही यावर लक्ष ठेवणारी सुरक्षा भिंत
    redirect: (BuildContext context, GoRouterState state) {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final bool isLoggedIn = auth.currentUser != null;
      
      // युझर सध्या कोणत्या पाथवर जाण्याचा प्रयत्न करत आहे
      final String currentPath = state.matchedLocation;
      final bool isAuthenticationRoute = currentPath == '/login' || currentPath == '/welcome' || currentPath == '/pin_lock';

      // नियम १: युझर लॉग-इन नसेल आणि आतल्या पेजेसवर जाण्याचा प्रयत्न करेल, तर त्याला सरळ लॉगिनवर पाठवा
      if (!isLoggedIn && !isAuthenticationRoute) {
        return '/login';
      }

      // नियम २: युझर आधीच लॉग-इन असेल आणि पुन्हा लॉगिन/वेलकम पेजवर जाण्याचा प्रयत्न करेल, तर त्याला थेट होमवर पाठवा
      if (isLoggedIn && (currentPath == '/login' || currentPath == '/welcome')) {
        return '/home';
      }

      return null; // सर्व काही सुरक्षित असल्यास नियोजित मार्गावर जाऊ द्या
    },

    routes: <RouteBase>[
      // १. स्वागत स्क्रीन (Welcome Screen)
      GoRoute(
        path: '/welcome',
        builder: (BuildContext context, GoRouterState state) => const WelcomeScreen(),
      ),

      // २. मुख्य लॉगिन गेटवे (Authentication Screen)
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) => const LoginScreen(),
      ),

      // ३. सुरक्षा पिन लॉक स्क्रीन (PIN Lock Gate)
      GoRoute(
        path: '/pin_lock',
        builder: (BuildContext context, GoRouterState state) {
          final extraMap = state.extra as Map<String, dynamic>? ?? {};
          final bool setupMode = extraMap['isSettingPin'] as bool? ?? false;
          return PinLockScreen(isSettingPin: setupMode);
        },
      ),

      // ४. मुख्य डॅशबोर्ड स्क्रीन (Home Dashboard Layout with Bottom Nav)
      GoRoute(
        path: '/home',
        builder: (BuildContext context, GoRouterState state) => const HomeScreen(),
      ),

      // ५. मल्टी-शॉप व्यवस्थापन स्क्रीन (Shop Workspaces Manager)
      GoRoute(
        path: '/shops',
        builder: (BuildContext context, GoRouterState state) => const ShopManageScreen(currentUserId: 'active_auth_uid'),
      ),

      // ६. ग्राहकांची सूची स्क्रीन (Filtered Client Directory Grid)
      GoRoute(
        path: '/customers/:shopId',
        builder: (BuildContext context, GoRouterState state) {
          final shopId = state.pathParameters['shopId']!;
          return CustomerListScreen(
            shopId: shopId,
            currentUserId: FirebaseAuth.instance.currentUser?.uid ?? 'guest_uid',
          );
        },
      ),

      // ७. मुख्य लेजर बुक स्क्रीन (Transaction Ledger View Book)
      GoRoute(
        path: '/ledger/:customerId/:shopId/:ownerId',
        builder: (BuildContext context, GoRouterState state) {
          return LedgerScreen(
            customerId: state.pathParameters['customerId']!,
            shopId: state.pathParameters['shopId']!,
            ownerId: state.pathParameters['ownerId']!,
          );
        },
      ),

      // ८. कचरापेटी स्क्रीन (Soft-deleted Data View)
      GoRoute(
        path: '/recycle_bin',
        builder: (BuildContext context, GoRouterState state) => const RecycleBinScreen(),
      ),

      // ९. बारकोड / क्यूआर कॅमेरा स्कॅनर (Camera Scanner Screen)
      GoRoute(
        path: '/scanner',
        builder: (BuildContext context, GoRouterState state) => const ScannerView(),
      ),

      // १०. ॲप्लिकेशन सेटिंग्स स्क्रीन (Master Configuration Hub)
      GoRoute(
        path: '/settings',
        builder: (BuildContext context, GoRouterState state) => const SettingsScreen(),
      ),
    ],
    
    // ⚠️ एरर हँडलिंग पान (Route Not Found Error Page)
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Navigation Pipeline Interrupted: ${state.error}'),
      ),
    ),
  );
}
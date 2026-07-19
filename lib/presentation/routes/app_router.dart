import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/home_screen.dart';
import '../screens/customer/customer_list_screen.dart';
import '../screens/customer/ledger_screen.dart';
import '../../../data/models/customer_model.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/customers',
        // 💡 फिक्स: जुने पॅरामीटर्स काढून क्लीन कन्स्ट्रक्टर कॉल केला
        builder: (context, state) => const CustomerListScreen(),
      ),
      GoRoute(
        path: '/ledger',
        builder: (context, state) {
          final customer = state.extra as CustomerModel;
          return LedgerScreen(customer: customer);
        },
      ),
    ],
  );
}


// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'presentation/routes/app_router.dart';
// import 'firebase_options.dart';
// import 'core/providers/global_provider_hub.dart';

// void main() async {
//   // 1. Ensure Flutter engine bindings are initialized properly
//   WidgetsFlutterBinding.ensureInitialized();

//   // 2. Initialize Firebase using the provided multi-platform credentials
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   // 3. Initialize Hive local storage for quick access caching (theme/offline flags)
//   await Hive.initFlutter();
//   await Hive.openBox('settings_box');

//   // 4. Run the root application wrapped in the ProviderScope for global state management
//   runApp(
//     const ProviderScope(
//       child: KhatabookSmartEngineApp(),
//     ),
//   );
// }

// class KhatabookSmartEngineApp extends ConsumerWidget {
//   const KhatabookSmartEngineApp({super.key}); // 👈 इथे Key चा 'k' small केला आहे

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Listens to the dynamic theme mode provider managed from settings
//     final currentThemeMode = ref.watch(themeModeProvider);

//     return MaterialApp.router(
//       title: 'Khatabook',
//       debugShowCheckedModeBanner: false,
      
//       // 🌟 Eye-safe Professional Light Theme
//       theme: ThemeData(
//         useMaterial3: true,
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color(0xFF1E3A8A),
//           brightness: Brightness.light,
//           surface: const Color(0xFFF8FAFC),
//         ),
//         scaffoldBackgroundColor: const Color(0xFFF8FAFC),
//         cardTheme: const CardThemeData(
//           color: Colors.white,
//           elevation: 0,
//         ),
//       ),
      
//       // 🌙 Eye-safe Professional Dark Theme
//       darkTheme: ThemeData(
//         useMaterial3: true,
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color(0xFF3B82F6),
//           brightness: Brightness.dark,
//           surface: const Color(0xFF1E293B),
//         ),
//         scaffoldBackgroundColor: const Color(0xFF0F172A),
//       ),
      
//       // Binds the router configuration and reactive system theme setup
//       themeMode: currentThemeMode,
//       routerConfig: AppRouter.router,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'presentation/routes/app_router.dart';
import 'firebase_options.dart';
import 'core/providers/global_provider_hub.dart';

void main() async {
  // 1. Ensure Flutter engine bindings are initialized properly
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase using the provided multi-platform credentials
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Initialize Hive local storage for quick access caching (theme/offline flags)
  await Hive.initFlutter();
  await Hive.openBox('settings_box');

  // 4. Run the root application wrapped in the ProviderScope for global state management
  runApp(
    const ProviderScope(
      child: KhatabookSmartEngineApp(),
    ),
  );
}

class KhatabookSmartEngineApp extends ConsumerWidget {
  const KhatabookSmartEngineApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listens to the dynamic theme mode provider managed from settings
    final currentThemeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Khatabook',
      debugShowCheckedModeBanner: false,
      
      // 🌟 Eye-safe Professional Light Theme
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
          brightness: Brightness.light,
          surface: const Color(0xFFF8FAFC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 0,
        ),
      ),
      
      // 🌙 Eye-safe Professional Dark Theme
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
          brightness: Brightness.dark,
          surface: const Color(0xFF1E293B),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      
      // Binds the router configuration and reactive system theme setup
      themeMode: currentThemeMode,
      routerConfig: AppRouter.router,
    );
  }
}
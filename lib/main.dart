import 'package:flutter/material.dart';
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
  const KhatabookSmartEngineApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listens to the dynamic theme mode provider managed from settings
    final currentThemeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Khatabook Smart Engine',
      debugShowCheckedModeBanner: false,
      
      // 🌟 Eye-safe Professional Light Theme (Prevents strain during prolonged viewing)
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A), // Clean Premium Deep Navy Blue
          brightness: Brightness.light,
          surface: const Color(0xFFF8FAFC),    // Ultra-soft off-white surface tint
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
        ),
      ),
      
      // 🌙 Eye-safe Professional Dark Theme (Soft slate tones instead of pure pitch black)
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6), // Eye-friendly radiant indigo
          brightness: Brightness.dark,
          surface: const Color(0xFF1E293B),    // Muted deep slate gray
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Dark slate void background
      ),
      
      // Binds the router configuration and reactive system theme setup
      themeMode: currentThemeMode,
      routerConfig: AppRouter.router,
    );
  }
}
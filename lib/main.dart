import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'presentation/routes/app_router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  await Hive.openBox('settings_box');

  runApp(
    const ProviderScope(
      child: KhatabookSmartEngineApp(),
    ),
  );
}

class KhatabookSmartEngineApp extends StatelessWidget {
  const KhatabookSmartEngineApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Khatabook Smart Engine',
      debugShowCheckedModeBanner: false,
      
      // 💡 फिक्स: एरर देणारे AppTheme बदलून सरळ इन-लाइन थीम दिली आहे
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      
      routerConfig: AppRouter.router,
    );
  }
}
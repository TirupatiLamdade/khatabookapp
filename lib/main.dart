import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Core Registries Imports
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'core/services/fcm_push_service.dart';
import 'core/utils/connection_matcher.dart';
import 'data/local/sync_orchestrator_worker.dart';

import 'presentation/routes/app_router.dart';

void main() async {
  // 1. सुनिश्चित करें कि फ़्लटर का बाइंडिंग लेयर पूरी तरह इनिशियलाइज़ हो गया है
  WidgetsFlutterBinding.ensureInitialized();

  // 2. फ़ायरबेस क्लाउड इंफ्रास्ट्रक्चर को बूटस्ट्रैप करें
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. हाइव ऑफलाइन-फर्स्ट लोकल डेटाबेस को इनिशियलाइज़ करें
  await Hive.initFlutter();

  // 4. ऐप के सभी आवश्यक डेटा स्टोरेज बॉक्सेस (Hive Boxes) को खोलें
  await Hive.openBox(AppConfig.customerBoxName);
  await Hive.openBox(AppConfig.transactionBoxName);
  await Hive.openBox(AppConfig.auditBoxName);
  await Hive.openBox(AppConfig.syncQueueBoxName);
  await Hive.openBox(AppConfig.settingsBoxName);
  await Hive.openBox(AppConfig.recycleBinBoxName);

  // 5. सिस्टम पुश नोटिफिकेशन्स और क्लाउड मेसेजिंग (FCM) को सक्रिय करें
  //final NotificationService notificationService = NotificationService();
  //await notificationService.initNotificationChannel();
  
  final FcmPushService fcmPushService = FcmPushService();
  await fcmPushService.initializeCloudMessaging();

  // 6. बैकग्राउंड सिड्यूलर वर्कर को चालू करें (दर 30 सेकंड में ऑटो-सिंक)
  SyncOrchestratorWorker.startPeriodicSyncWorker();

  // 7. ऐप को रिवरपॉड (ProviderScope) के साथ रन करें
  runApp(
    const ProviderScope(
      child: KhatabookSmartApp(),
    ),
  );
}

class KhatabookSmartApp extends ConsumerWidget {
  const KhatabookSmartApp({super.key});

  @override
  // 🛠️ FIX 1: तिसरा नको असलेला dynamic पॅरामीटर काढून टाकला आहे
  Widget build(BuildContext context, WidgetRef ref) {
    // थीम स्टेट को मॉनिटर करें (Light / Dark / AMOLED)
    final themeModeOption = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return ConnectionMatcher(
      child: MaterialApp.router(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        
        // थीम कॉन्फिगरेशन
        theme: themeNotifier.getThemeData(),
        // 🛠️ FIX 2: ThemeModeMode काढून फ्लटरचा डीफॉल्ट ThemeMode वापरला आहे
        themeMode: themeModeOption == ThemeModeOption.light 
            ? ThemeMode.light 
            : ThemeMode.dark,

        // गो-राउटर नेविगेशन पाइपलाइन मैपिंग
        routerConfig: AppRouter.router,
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart'; 

// import 'notifiiotn.dart'; 

// void main() async {
//   // Flutter bindings इनिशियलाइज करणे गरजेचे आहे
//   WidgetsFlutterBinding.ensureInitialized();

//   // Firebase इनिशियलाइज करा (Android आणि Web दोन्हीसाठी)
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   // पुश नोटिफिकेशन सर्व्हिस सुरू करा
//   await NotificationService().initNotifications();

//   runApp(const MyApp());
// }

// // 🟢 हा MyApp क्लास खाली जोडल्यामुळे तुमची एरर निघून जाईल
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Khatabook Smart',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         useMaterial3: true,
//       ),
//       // तुमच्या होम स्क्रीनचे नाव (उदा. LoginScreen किंवा HomeScreen)
//       home: const Scaffold(
//         body: Center(
//           child: Text(
//             'Khatabook Smart मध्ये आपले स्वागत आहे!',
//             style: TextStyle(fontSize: 20),
//           ),
//         ),
//       ),
//     );
//   }
// }
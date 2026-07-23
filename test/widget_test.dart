import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:login_setup/core/config/app_config.dart' show AppConfig;
import 'package:login_setup/main.dart' show KhatabookSmartApp, KhatabookSmartEngineApp;

void main() {
  // टेस्ट शुरू होने से पहले आवश्यक हाइव बॉक्स मॉक सेटअप
  setUpAll(() async {
    // टेस्ट एनवायरनमेंट के लिए हाइव को इनिशियलाइज़ करें
    await Hive.initFlutter();
    
    // सभी आवश्यक बॉक्स खोलें ताकि विजेट रेंडर होते समय क्रैश न हो
    await Hive.openBox(AppConfig.customerBoxName);
    await Hive.openBox(AppConfig.transactionBoxName);
    await Hive.openBox(AppConfig.auditBoxName);
    await Hive.openBox(AppConfig.syncQueueBoxName);
    await Hive.openBox(AppConfig.settingsBoxName);
  });

  testWidgets('Khatabook Smart App Init Smoke Test', (WidgetTester tester) async {
    // Riverpod Scope के साथ हमारे मुख्य ऐप को बिल्ड करें
    await tester.pumpWidget(
      const ProviderScope(
        child: KhatabookSmartEngineApp(),
      ),
    );

    // एक फ्रेम ट्रिगर करें ताकि यूआई रेंडर हो जाए
    await tester.pump();

    // पुष्टि करें कि ऐप का नाम (Title) स्क्रीन पर दिखाई दे रहा है या नहीं
    expect(find.text(AppConfig.appName), findsWidgets);
  });
}
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: 'AIzaSyDSvxTCE16t-dvPn5FldxtidIAkJxjOvYs',
        appId: '1:21224449328:web:cf83d80abf2a4163f154f5',
        messagingSenderId: '21224449328',
        projectId: 'loginsetup-6f413',
        authDomain: 'loginsetup-6f413.firebaseapp.com',
        storageBucket: 'loginsetup-6f413.firebasestorage.app',
        measurementId: 'G-22DS0MNRZ7',
      );
      
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
          apiKey:
              'AIzaSyDFLroWXRMGMcw5uP79lFTTo0sNyjQwNYc', // ही की तुमच्या google-services.json मधून घेतली जाईल
          appId:
              '1:21224449328:android:com.example.login_setup', // तुमच्या Android ॲपचा ID
          messagingSenderId: '21224449328',
          projectId: 'loginsetup-6f413',
        );
      case TargetPlatform.iOS:
        return const FirebaseOptions(
          apiKey:
              'AIzaSyAQ6Sn27c1oH4cN9XWEj-2Udzc4hsZhxyE', // ही की तुमच्या GoogleService-Info.plist मध्ये असेल
          appId:
              '1:21224449328:ios:com.example.loginSetup', // तुमच्या iOS ॲपचा ID
          messagingSenderId: '21224449328',
          projectId: 'loginsetup-6f413',
          iosBundleId: 'com.example.loginSetup',
        );
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }
}
//flutter run -d chrome --web-port=58900

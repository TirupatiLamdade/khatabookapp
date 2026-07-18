import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  // काय डिव्हाइसवर बायोमेट्रिक हार्डवेअर उपलब्ध आहे?
  Future<bool> isHardwareAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (_) {
      return false;
    }
  }

  // फिंगरप्रिंट किंवा फेस आयडी ऑथेंटिकेशन ट्रिगर करा
  Future<bool> authenticateUser({required String reasonMessage}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reasonMessage,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (_) {
      return false;
    }
  }
}
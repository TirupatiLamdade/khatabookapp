import 'package:flutter/services.dart';

class PrivacyMaskService {
  static const MethodChannel _channel = MethodChannel('com.example.khatabook_smart/privacy_mask');

  static Future<void> enableSecureSurfaceMask() async {
    try {
      await _channel.invokeMethod('enableSecureMask');
    } on PlatformException catch (_) {
      // प्लॅटफॉर्म वेब असल्यास हे स्किप होईल
    }
  }

  static Future<void> disableSecureSurfaceMask() async {
    try {
      await _channel.invokeMethod('disableSecureMask');
    } on PlatformException catch (_) {
      // प्लॅटफॉर्म वेब असल्यास हे स्किप होईल
    }
  }
}
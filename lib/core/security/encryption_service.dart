import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/adapters.dart';

class EncryptionService {
  static const _storage = FlutterSecureStorage();

  // AES कूटबद्धीकरणासाठी सुरक्षित की जनरेट किंवा फेच करा
  static Future<Uint8List> getSecureEncryptionKey() async {
    final containsKey = await _storage.containsKey(key: 'secure_hive_key');
    if (!containsKey) {
      final key = Hive.generateSecureKey();
      await _storage.write(key: 'secure_hive_key', value: base64Url.encode(key));
    }
    final keyString = await _storage.read(key: 'secure_hive_key');
    return base64Url.decode(keyString!);
  }

  // बायोमेट्रिक पिनचा SHA-256 सिक्योर हॅश तयार करा
  static String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
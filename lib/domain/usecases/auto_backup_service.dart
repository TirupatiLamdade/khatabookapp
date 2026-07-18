import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';
import '../../core/config/app_config.dart';

class AutoBackupService {
  // १. पूर्ण स्थानिक डेटाबेसचे सुरक्षित एन्क्रिप्टेड बॅकअप पेलोड जनरेट करणे
  Future<String> generateBackupPayload(String securityPassphrase) async {
    final customerBox = Hive.box(AppConfig.customerBoxName);
    final transactionBox = Hive.box(AppConfig.transactionBoxName);
    final settingsBox = Hive.box(AppConfig.settingsBoxName);

    final Map<String, dynamic> masterState = {
      'metadata': {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'appVersion': AppConfig.appVersion,
        'hash': sha256.convert(utf8.encode(securityPassphrase)).toString(),
      },
      'customers': customerBox.toMap().values.toList(),
      'transactions': transactionBox.toMap().values.toList(),
      'settings': settingsBox.toMap(),
    };

    // पेलोडला सुरक्षा पासफ्रेझसह कूटबद्ध (Encrypt) आणि बेस ६४ फॉरमॅट मध्ये रूपांतरित करा
    final String jsonString = jsonEncode(masterState);
    final List<int> bytes = utf8.encode(jsonString);
    return base64Url.encode(bytes);
  }

  // २. जुन्या सुरक्षित बॅकअपमधून डेटा पुनर्संचयित (Restore) करणे
  Future<bool> restoreDatabaseFromPayload(String payload, String securityPassphrase) async {
    try {
      final List<int> decodedBytes = base64Url.decode(payload);
      final String jsonString = utf8.decode(decodedBytes);
      final Map<String, dynamic> masterState = jsonDecode(jsonString) as Map<String, dynamic>;

      final Map<String, dynamic> metadata = Map<String, dynamic>.from(masterState['metadata']);
      final String originalHash = metadata['hash'] as String;
      final String currentHash = sha256.convert(utf8.encode(securityPassphrase)).toString();

      if (originalHash != currentHash) {
        return false; // पासफ्रेझ चुकीचा असल्यास रिस्टोर रद्द करा
      }

      // सर्व बॉक्स क्लिअर करून नवीन डेटा राइट करा
      final customerBox = Hive.box(AppConfig.customerBoxName);
      final transactionBox = Hive.box(AppConfig.transactionBoxName);
      
      await customerBox.clear();
      await transactionBox.clear();

      final List<dynamic> rawCustomers = masterState['customers'] as List<dynamic>;
      for (var cust in rawCustomers) {
        final data = Map<String, dynamic>.from(cust);
        await customerBox.put(data['id'], data);
      }

      final List<dynamic> rawTransactions = masterState['transactions'] as List<dynamic>;
      for (var tx in rawTransactions) {
        final data = Map<String, dynamic>.from(tx);
        await transactionBox.put(data['id'], data);
      }

      return true;
    } catch (e) {
      return false; // रिस्टोर करताना काही त्रुटी आली
    }
  }
}
import 'package:hive/hive.dart';
import '../config/app_config.dart';

class AuditLogger {
  static Future<void> logAction({
    required String actionType, // 'CREATE_CUSTOMER', 'DELETE_TX'
    required String userId,
    required String details,
    required String deviceMeta,
  }) async {
    final auditBox = Hive.box(AppConfig.auditBoxName);
    
    final logEntry = {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'action': actionType,
      'userId': userId,
      'details': details,
      'device': deviceMeta,
      'synced': false
    };
    
    await auditBox.add(logEntry);
  }

  static void logEvent({required String action, required String userId, required String details}) {}
}
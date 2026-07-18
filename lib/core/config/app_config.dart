class AppConfig {
  static const String appName = 'Khatabook Smart';
  static const String appVersion = '1.0.0+1';
  
  static const int pinLength = 4;
  static const Duration autoLockTimeout = Duration(minutes: 5);
  
  static const String customerBoxName = 'customers_box';
  static const String transactionBoxName = 'transactions_box';
  static const String auditBoxName = 'audit_logs_box';
  static const String syncQueueBoxName = 'pending_sync_queue';
  static const String settingsBoxName = 'app_settings_box';

  static const int maxSyncRetries = 3;
  static const Duration syncInterval = Duration(seconds: 30);

  // 🛠️ FIX: null ऐवजी वास्तविक हायव्ह बॉक्सचे नाव स्ट्रिंग स्वरूपात दिले आहे
  static String get recycleBinBoxName => 'recycle_bin_box';
}
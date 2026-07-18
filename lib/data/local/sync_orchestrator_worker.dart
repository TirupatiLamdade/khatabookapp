import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../../core/config/app_config.dart';
import 'sync_queue.dart';

class SyncOrchestratorWorker {
  // १. सिंगलटन पॅटर्न (Singleton Worker Architecture)
  static final SyncOrchestratorWorker _instance = SyncOrchestratorWorker._internal();
  factory SyncOrchestratorWorker() => _instance;
  SyncOrchestratorWorker._internal();

  static Timer? _syncTimer;
  static final SyncQueueManager _syncQueueManager = SyncQueueManager();
  static final Connectivity _connectivity = Connectivity();

  // २. बॅकग्राउंड पीरिऑडिक वर्कर सुरू करा (Start 30s Interval Sync Worker)
  static void startPeriodicSyncWorker() {
    if (_syncTimer != null && _syncTimer!.isActive) return;

    debugPrint("Background Scheduler: Initializing periodic synchronization pipeline...");
    _syncTimer = Timer.periodic(AppConfig.syncInterval, (timer) async {
      await _executeOrchestratedSync();
    });
  }

  // ३. पीरिऑडिक वर्कर तात्पुरता थांबवा (Stop Background Sync Worker)
  static void stopSyncWorker() {
    if (_syncTimer != null) {
      debugPrint("Background Scheduler: Deactivating active sync intervals.");
      _syncTimer!.cancel();
      _syncTimer = null;
    }
  }

  // 🔄 ४. सिंकिंग प्रक्रिया प्रत्यक्ष राबवणे (Orchestrated Cloud Sync Execution)
  static Future<void> _executeOrchestratedSync() async {
    try {
      // डिव्हाइस नेटवर्कशी जोडलेले आहे का ते तपासा
      final List<ConnectivityResult> connectionState = await _connectivity.checkConnectivity();
      final bool isOnline = !connectionState.contains(ConnectivityResult.none);

      if (!isOnline) {
        debugPrint("Sync Orchestrator: Device is offline. Bypassing cloud upload pass.");
        return;
      }

      debugPrint("Sync Orchestrator: Device is online. Processing pending local storage queue...");
      
      // प्रलंबित कतार व्यवस्थापक कॉल (Sync Queue Trigger)
      await _syncQueueManager.triggerProcessSync();
      
      debugPrint("Sync Orchestrator: All items in local queue resolved with Cloud Firestore.");
    } catch (e) {
      debugPrint("Sync Orchestrator: Exception caught during sync execution cycle -> $e");
    }
  }
}

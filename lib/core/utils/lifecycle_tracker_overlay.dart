import 'package:flutter/material.dart';
import '../security/privacy_mask_service.dart';
import '../../data/local/sync_orchestrator_worker.dart';

class LifecycleTrackerOverlay extends StatefulWidget {
  final Widget child;

  const LifecycleTrackerOverlay({super.key, required this.child});

  @override
  State<LifecycleTrackerOverlay> createState() => _LifecycleTrackerOverlayState();
}

// REMOVED "with AppLifecycleListener" from this line
class _LifecycleTrackerOverlayState extends State<LifecycleTrackerOverlay> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    // Start background sync worker when the app wakes up
    SyncOrchestratorWorker.startPeriodicSyncWorker();

    _listener = AppLifecycleListener(
      onStateChange: _handleLifecycleStateChange,
    );
  }

  void _handleLifecycleStateChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // Hide sensitive account ledgers from recent task switcher view
        PrivacyMaskService.enableSecureSurfaceMask();
        SyncOrchestratorWorker.stopSyncWorker();
        break;
      case AppLifecycleState.resumed:
        // Clear privacy filter overlay and resume database synchronization worker
        PrivacyMaskService.disableSecureSurfaceMask();
        SyncOrchestratorWorker.startPeriodicSyncWorker();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _listener.dispose();
    SyncOrchestratorWorker.stopSyncWorker();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
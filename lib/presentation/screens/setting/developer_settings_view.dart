
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DeveloperSettingsView extends StatefulWidget {
  const DeveloperSettingsView({Key? key}) : super(key: key);

  @override
  State<DeveloperSettingsView> createState() => _DeveloperSettingsViewState();
}

class _DeveloperSettingsViewState extends State<DeveloperSettingsView> {
  final ScrollController _scrollController = ScrollController();

  bool _enableDebugLogs = true;
  bool _isClearingCache = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 🔝 स्क्रीनच्या सर्वात वर (Top) मेसेज दाखवण्यासाठी कस्टम फंक्शन
  void _showTopNotification(String message, {bool isError = false}) {
    if (!mounted) return;
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  // 🚀 स्क्रीन स्मूथली खालून वर (Bottom to Top Rocket Scroll) नेण्याचे फंक्शन
  void _scrollToTopRocket() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 700),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  // Local Hive Storage clear करणे
  Future<void> _clearAllHiveCache() async {
    setState(() => _isClearingCache = true);
    try {
      if (Hive.isBoxOpen('settings_box')) {
        await Hive.box('settings_box').clear();
      }

      if (mounted) {
        _showTopNotification('Local Hive cache cleared successfully!');
        _scrollToTopRocket(); // 🚀 कृती पूर्ण झाल्यावर वर स्क्रोल होईल
      }
    } catch (e) {
      if (mounted) {
        _showTopNotification('Failed to clear local cache: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isClearingCache = false);
    }
  }

  // Confirmation dialog
  void _showClearConfirmationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 10),
            Text(
              'Clear Local Cache?',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'This action will wipe temporary offline cache stored on this device. Do you wish to continue?',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(ctx);
              _clearAllHiveCache();
            },
            child: const Text('Clear', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktopOrWeb = screenWidth > 800;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Developer Settings', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: borderColor, width: 1)),
        actions: [
          IconButton(
            tooltip: 'Scroll to Top',
            icon: const Icon(Icons.rocket_launch_rounded, color: Color(0xFF38BDF8)),
            onPressed: _scrollToTopRocket,
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: isDesktopOrWeb ? 750 : double.infinity),
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isDesktopOrWeb ? 32.0 : 16.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Warning Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade900.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade700.withOpacity(0.5)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_rounded, color: Colors.amber, size: 22),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Warning: These settings are intended for testing and debugging. Modifications here may impact local app performance.',
                          style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'STORAGE AND DATA MANAGEMENT',
                  style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
                ),
                const SizedBox(height: 12),

                // Cache Purge Card
                Container(
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.cleaning_services_rounded, color: Colors.redAccent, size: 22),
                    ),
                    title: const Text('Clear Local Hive Cache', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Purge all offline cached ledger data on this device', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _isClearingCache ? null : _showClearConfirmationDialog,
                      child: _isClearingCache
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Clear', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'SYSTEM & DEBUGGING CONTROLS',
                  style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
                ),
                const SizedBox(height: 12),

                // Verbose Logging Toggle
                Container(
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: SwitchListTile(
                    activeColor: const Color(0xFF38BDF8),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFF38BDF8).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.bug_report_rounded, color: Color(0xFF38BDF8), size: 22),
                    ),
                    title: const Text('Verbose Debug Logging', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Output detailed operation logs to application console', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    value: _enableDebugLogs,
                    onChanged: (val) {
                      setState(() => _enableDebugLogs = val);
                      _showTopNotification(val ? 'Verbose Logging Enabled' : 'Verbose Logging Disabled');
                      _scrollToTopRocket();
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // System Diagnostics Card
                Container(
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.memory_rounded, color: Colors.green, size: 22),
                    ),
                    title: const Text('System Diagnostics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 6),
                        Text('• Version: v1.0.0+1 (Production Engine)', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                        Text('• Database Engine: Firebase Firestore', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                        Text('• Cache Engine: Hive Local Storage', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                        Text('• Cross-Platform Support: iOS, Android, Web & Desktop', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // 🚀 Bottom Rocket Button
                Center(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: _scrollToTopRocket,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.rocket_launch_rounded, color: Color(0xFF38BDF8), size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Back to Top',
                            style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
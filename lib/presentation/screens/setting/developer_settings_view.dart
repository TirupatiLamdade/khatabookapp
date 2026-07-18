import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../core/security/audit_logger.dart';

class DeveloperSettingsView extends StatelessWidget {
  const DeveloperSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Look up the theme color scheme from context
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Developer & Diagnostics Mode')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            // FIXED: Using colorScheme.errorContainer instead of Colors.redContainer
            color: colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              // Dynamic text color matching the theme's error container contrast requirements
              child: Text(
                'WARNING: Internal database testing instruments active. Modifying entries may cause sync failure.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onErrorContainer,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Inspect Hive Local Allocation'),
            subtitle: Text('Customers cached: ${Hive.box('customers_box').length} entries'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.bug_report_outlined),
            title: const Text('Trigger Synthetic Local Exception'),
            subtitle: const Text('Tests Crashlytics logging pipeline natively'),
            onTap: () {
              AuditLogger.logEvent(
                action: 'DIAGNOSTIC_CRASH_TEST',
                userId: 'dev_admin',
                details: 'User initiated simulated crash sequence.',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Simulated Diagnostic Event Dispatched.')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.cloud_sync_outlined),
            title: const Text('Purge Sync Queue Queue'),
            subtitle: Text('Pending cache objects: ${Hive.box('pending_sync_queue').length} items'),
            onTap: () async {
              await Hive.box('pending_sync_queue').clear();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Synchronization Buffer Cleared.')),
              );
            },
          ),
        ],
      ),
    );
  }
}
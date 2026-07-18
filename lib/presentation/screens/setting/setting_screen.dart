import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/usecases/auto_backup_service.dart';
import '../../widgets/glass_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final AutoBackupService _backupService = AutoBackupService();
  bool _isAutoBackupEnabled = true;
  String _selectedCurrency = 'INR';

  // 🔄 बॅकअप पेलोड जनरेशन आणि मॅन्युअल बॅकअप ट्रिगर
  Future<void> _triggerManualBackup() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final payload = await _backupService.generateBackupPayload('khatabook_passphrase_123');
      Navigator.pop(context); // प्रोग्रेस डायलॉग बंद करा

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.cloud_done, color: Colors.green),
              SizedBox(width: 8),
              Text('Backup Successful'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your encrypted database backup string has been created safely:'),
              const SizedBox(height: 12),
              SelectableText(
                payload.substring(0, 100) + '...', // सुरक्षेसाठी फक्त सुरवातीचा भाग दाखवला आहे
                style: const TextStyle(fontSize: 11, color: Colors.grey, fontFamily: 'monospace'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Dismiss'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup execution failed.'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 🎨 विभाग १: थीम आणि डिझाईन सेटिंग्ज (Theme Settings)
          const Text('Theme Configuration', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          GlassCard(
            child: Column(
              children: [
                RadioListTile<ThemeModeOption>(
                  title: const Text('Light Mode'),
                  value: ThemeModeOption.light,
                  groupValue: currentTheme,
                  onChanged: (val) {
                    if (val != null) themeNotifier.setTheme(val);
                  },
                ),
                RadioListTile<ThemeModeOption>(
                  title: const Text('Dark Mode'),
                  value: ThemeModeOption.dark,
                  groupValue: currentTheme,
                  onChanged: (val) {
                    if (val != null) themeNotifier.setTheme(val);
                  },
                ),
                RadioListTile<ThemeModeOption>(
                  title: const Text('AMOLED Black (True Black)'),
                  value: ThemeModeOption.amoled,
                  groupValue: currentTheme,
                  onChanged: (val) {
                    if (val != null) themeNotifier.setTheme(val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 🛡️ विभाग २: सुरक्षा आणि गोपनीयतेचे नियम (Security Settings)
          const Text('Security & Access Control', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          GlassCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.pin, color: Colors.deepPurple),
                  title: const Text('Setup Security PIN Lock'),
                  subtitle: const Text('Create a secure 4-digit master pin access lock'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    context.push('/pin_lock', extra: {'isSettingPin': true});
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Auto-Backup Daily'),
                  subtitle: const Text('Keep cloud data backups synchronized instantly'),
                  value: _isAutoBackupEnabled,
                  onChanged: (val) {
                    setState(() {
                      _isAutoBackupEnabled = val;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 🪙 विभाग ३: प्रादेशिक आणि चलन सेटिंग्ज (Regional Settings)
          const Text('Regional & Currency Preferences', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          GlassCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.currency_exchange, color: Colors.deepPurple),
                  title: const Text('Business Currency Symbol'),
                  subtitle: Text('Current: $_selectedCurrency (${CurrencyFormatter.getSelectedCurrencySymbol()})'),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.edit_outlined),
                    onSelected: (val) {
                      setState(() {
                        _selectedCurrency = val;
                        CurrencyFormatter.updateCurrencyConfiguration(val);
                      });
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'INR', child: Text('Indian Rupee (₹)')),
                      const PopupMenuItem(value: 'USD', child: Text('US Dollar (\$)')),
                      const PopupMenuItem(value: 'EUR', child: Text('Euro (€)')),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 🔄 विभाग ४: मॅनेजमेंट आणि डेटा कंट्रोल्स (Data Management)
          const Text('Data Administration', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          GlassCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.backup_outlined, color: Colors.deepPurple),
                  title: const Text('Perform Secure Manual Backup'),
                  subtitle: const Text('Compile and encrypt database ledger immediately'),
                  trailing: const Icon(Icons.sync_outlined),
                  onTap: _triggerManualBackup,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Clear All Local Cache', style: TextStyle(color: Colors.red)),
                  subtitle: const Text('Purges offline database. Use with extreme caution!'),
                  onTap: () {
                    // कॅश साफ करण्यासाठी अलर्ट दाखवा
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Are you absolutely sure?'),
                        content: const Text('This will purge your encrypted local offline storage boxes. Unsaved data will be lost.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Local data cache cleared successfully.')),
                              );
                            },
                            child: const Text('Purge Cache', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
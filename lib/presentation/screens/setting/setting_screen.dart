import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/global_provider_hub.dart';

class SettingScreen extends ConsumerWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeShopId = ref.watch(activeShopIdProvider) ?? "No Shop Active";
    final currentThemeMode = ref.watch(themeModeProvider);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: isDesktop ? 650 : double.infinity),
            padding: const EdgeInsets.all(24.0),
            child: ListView(
              children: [
                const Text(
                  'Application Settings',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Active Tenant Display Card
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: const Icon(Icons.storefront, color: Color(0xFF1E3A8A)),
                    title: const Text('Active Store Context Identifier', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    subtitle: Text(activeShopId, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 28),

                const Text('Interface Customization', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                const Divider(),
                const SizedBox(height: 8),

                // 🌓 Dynamic Theme Selector Action Row
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('Appearance Mode'),
                  subtitle: Text(_getThemeModeName(currentThemeMode)),
                  trailing: DropdownButton<ThemeMode>(
                    value: currentThemeMode,
                    underline: const SizedBox(),
                    onChanged: (ThemeMode? newMode) {
                      if (newMode != null) {
                        ref.read(themeModeProvider.notifier).state = newMode;
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: ThemeMode.light, child: Text('Light Mode')),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark Mode')),
                      DropdownMenuItem(value: ThemeMode.system, child: Text('System Default')),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(activeShopIdProvider.notifier).state = null;
                    context.go('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red.shade700,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.logout_outlined),
                  label: const Text('Log Out Safely', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return "Light Theme Active";
      case ThemeMode.dark:
        return "Dark Theme Active";
      case ThemeMode.system:
        return "Following Device Preferences";
    }
  }
}
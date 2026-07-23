// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import '../../../core/providers/global_provider_hub.dart';

// class SettingScreen extends ConsumerWidget {
//   const SettingScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final activeShopId = ref.watch(activeShopIdProvider) ?? "No Shop Active";
//     final currentThemeMode = ref.watch(themeModeProvider);
//     final isDesktop = MediaQuery.of(context).size.width > 900;

//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: Container(
//             constraints: BoxConstraints(maxWidth: isDesktop ? 650 : double.infinity),
//             padding: const EdgeInsets.all(24.0),
//             child: ListView(
//               children: [
//                 const Text(
//                   'Application Settings',
//                   style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 24),

//                 // Active Tenant Display Card
//                 Card(
//                   elevation: 0,
//                   color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                   child: ListTile(
//                     leading: const Icon(Icons.storefront, color: Color(0xFF1E3A8A)),
//                     title: const Text('Active Store Context Identifier', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
//                     subtitle: Text(activeShopId, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                   ),
//                 ),
//                 const SizedBox(height: 28),

//                 const Text('Interface Customization', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
//                 const Divider(),
//                 const SizedBox(height: 8),

//                 // 🌓 Dynamic Theme Selector Action Row
//                 ListTile(
//                   leading: const Icon(Icons.palette_outlined),
//                   title: const Text('Appearance Mode'),
//                   subtitle: Text(_getThemeModeName(currentThemeMode)),
//                   trailing: DropdownButton<ThemeMode>(
//                     value: currentThemeMode,
//                     underline: const SizedBox(),
//                     onChanged: (ThemeMode? newMode) {
//                       if (newMode != null) {
//                         ref.read(themeModeProvider.notifier).state = newMode;
//                       }
//                     },
//                     items: const [
//                       DropdownMenuItem(value: ThemeMode.light, child: Text('Light Mode')),
//                       DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark Mode')),
//                       DropdownMenuItem(value: ThemeMode.system, child: Text('System Default')),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 32),
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     ref.read(activeShopIdProvider.notifier).state = null;
//                     context.go('/login');
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red.shade50,
//                     foregroundColor: Colors.red.shade700,
//                     elevation: 0,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   icon: const Icon(Icons.logout_outlined),
//                   label: const Text('Log Out Safely', style: TextStyle(fontWeight: FontWeight.bold)),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   String _getThemeModeName(ThemeMode mode) {
//     switch (mode) {
//       case ThemeMode.light:
//         return "Light Theme Active";
//       case ThemeMode.dark:
//         return "Dark Theme Active";
//       case ThemeMode.system:
//         return "Following Device Preferences";
//     }
//   }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/global_provider_hub.dart';

class SettingsControlPanel extends ConsumerWidget {
  final bool isDark;
  final Color textColor;
  final Color cardBgColor;
  final Color borderColor;

  const SettingsControlPanel({
    Key? key,
    required this.isDark,
    required this.textColor,
    required this.cardBgColor,
    required this.borderColor,
  }) : super(key: key);

  Future<void> _performLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      context.go('/splash');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeModeProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'SYSTEM THEME CONFIGURATION CANVAS',
          style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700, letterSpacing: 1.0, fontSize: 11),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: cardBgColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: borderColor, width: 1.5)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ThemeMode>(
              value: currentTheme,
              dropdownColor: cardBgColor,
              icon: const Icon(Icons.palette_rounded, color: Color(0xFF38BDF8)),
              isExpanded: true,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 14),
              onChanged: (ThemeMode? val) {
                if (val != null) ref.read(themeModeProvider.notifier).state = val;
              },
              items: [
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Activate Dark Slate System Profile', style: TextStyle(color: textColor, fontWeight: FontWeight.w900))),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Activate Light Clean System Profile', style: TextStyle(color: textColor, fontWeight: FontWeight.w900))),
                DropdownMenuItem(value: ThemeMode.system, child: Text('Synchronize Local Operating System Theme', style: TextStyle(color: textColor, fontWeight: FontWeight.w900))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 36),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: cardBgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor, width: 1.5)),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Logout Session', style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Terminates current session and redirects to initial splash.', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _performLogout(context),
                icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
                label: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
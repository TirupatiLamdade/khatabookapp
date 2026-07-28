
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:go_router/go_router.dart';
// import 'package:login_setup/presentation/screens/auth/forgot_password_helper.dart';
// import 'package:login_setup/presentation/screens/setting/historybook_view.dart';
// import 'package:login_setup/presentation/screens/setting/saved_reports_screen.dart';

// import '../../../core/providers/global_provider_hub.dart';
// import '../../widgets/customer_dialogs.dart';
// import 'developer_settings_view.dart';

// class SettingsControlPanel extends ConsumerStatefulWidget {
//   final bool isDark;
//   final Color textColor;
//   final Color cardBgColor;
//   final Color borderColor;

//   const SettingsControlPanel({
//     Key? key,
//     required this.isDark,
//     required this.textColor,
//     required this.cardBgColor,
//     required this.borderColor,
//   }) : super(key: key);

//   @override
//   ConsumerState<SettingsControlPanel> createState() => _SettingsControlPanelState();
// }

// class _SettingsControlPanelState extends ConsumerState<SettingsControlPanel> {
//   final _backupEmailController = TextEditingController();

//   bool _isAutoBackupEnabled = false;
//   bool _isRestoring = false;
//   bool _isDeleting = false;
//   bool _isBackingUp = false;

//   @override
//   void initState() {
//     super.initState();
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null && user.email != null) {
//       _backupEmailController.text = user.email!;
//     }
//   }

//   @override
//   void dispose() {
//     _backupEmailController.dispose();
//     super.dispose();
//   }

//   // 🚪 Perform Actual Firebase Logout
//   Future<void> _performLogout(BuildContext context) async {
//     await FirebaseAuth.instance.signOut();
//     if (context.mounted) {
//       context.go('/splash');
//     }
//   }

//   // 🟢 🚪 RESPONSIVE LOGOUT CONFIRMATION POP-UP DIALOG (Left: Cancel, Right: Exit)
//   void _showLogoutConfirmationDialog(BuildContext context) {
//     final bool isDark = widget.isDark;
//     final Color dialogBg = isDark ? const Color(0xFF0F172A) : Colors.white;
//     final Color titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
//     final Color subTextColor = isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600;

//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (dialogCtx) {
//         return AlertDialog(
//           backgroundColor: dialogBg,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//             side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
//           ),
//           title: Row(
//             children: [
//               const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 24),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Text(
//                   'Exit / Logout Session',
//                   style: TextStyle(color: titleColor, fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ],
//           ),
//           content: Text(
//             'Are you sure you want to exit and logout from current screen session?',
//             style: TextStyle(color: subTextColor, fontSize: 13, height: 1.4),
//           ),
//           actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           actions: [
//             Row(
//               children: [
//                 // ⬅️ Left Side: Cancel Button
//                 Expanded(
//                   child: OutlinedButton(
//                     style: OutlinedButton.styleFrom(
//                       side: BorderSide(color: isDark ? const Color(0xFF334155) : Colors.grey.shade300),
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                     ),
//                     onPressed: () => Navigator.of(dialogCtx).pop(),
//                     child: Text('Cancel', style: TextStyle(color: subTextColor, fontWeight: FontWeight.bold)),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 // ➡️ Right Side: Exit / Logout Button
//                 Expanded(
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFEF4444),
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                     ),
//                     onPressed: () {
//                       Navigator.of(dialogCtx).pop();
//                       _performLogout(context);
//                     },
//                     child: const Text('Exit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ☁️ ALL PLATFORM SAFE CLOUD BACKUP
//   Future<void> _startBackupProcessWithProgressWindow() async {
//     final email = _backupEmailController.text.trim();
//     if (email.isEmpty || !email.contains('@')) {
//       CustomerDialogs.showTopNotification(context, 'Please enter a valid email address!', isError: true);
//       return;
//     }

//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) return;

//     if (_isBackingUp) return;
//     setState(() => _isBackingUp = true);

//     try {
//       final customersSnap = await FirebaseFirestore.instance
//           .collection('customers')
//           .where('operatorUid', isEqualTo: currentUser.uid)
//           .get();

//       final txSnap = await FirebaseFirestore.instance
//           .collection('transactions')
//           .where('operatorUid', isEqualTo: currentUser.uid)
//           .get();

//       final historySnap = await FirebaseFirestore.instance
//           .collection('deleted_products_history')
//           .where('operatorUid', isEqualTo: currentUser.uid)
//           .get();

//       final totalCustomers = customersSnap.docs.length;
//       final totalTx = txSnap.docs.length;
//       final totalHistory = historySnap.docs.length;

//       if (totalCustomers == 0 && totalTx == 0 && totalHistory == 0) {
//         if (mounted) {
//           setState(() => _isBackingUp = false);
//           CustomerDialogs.showTopNotification(
//             context,
//             'No local records found to backup! Add data first.',
//             isError: true,
//           );
//         }
//         return;
//       }

//       final customersList = customersSnap.docs.map((d) {
//         var data = d.data();
//         data['docId'] = d.id;
//         return data;
//       }).toList();

//       final txList = txSnap.docs.map((d) => d.data()).toList();
//       final historyList = historySnap.docs.map((d) => d.data()).toList();

//       final backupRef = FirebaseFirestore.instance.collection('cloud_user_backups').doc(currentUser.uid);
//       await backupRef.set({
//         'backupEmail': email,
//         'operatorUid': currentUser.uid,
//         'isAutoBackupActive': _isAutoBackupEnabled,
//         'updatedAt': FieldValue.serverTimestamp(),
//         'customers': customersList,
//         'transactions': txList,
//         'deletedProductsHistory': historyList,
//       }, SetOptions(merge: true));

//       if (mounted) {
//         setState(() => _isBackingUp = false);
//         CustomerDialogs.showTopNotification(
//           context,
//           'Cloud Backup Complete! $totalCustomers Accounts & $totalTx Records saved to $email',
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isBackingUp = false);
//         CustomerDialogs.showTopNotification(context, 'Cloud sync failed!', isError: true);
//       }
//     }
//   }

//   // Restore Security Modal Dialog
//   void _openRestoreSecurityModal() {
//     final emailController = TextEditingController(text: _backupEmailController.text);
//     final passwordController = TextEditingController();
//     final formKey = GlobalKey<FormState>();
//     bool isAuthenticating = false;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogCtx) {
//         return StatefulBuilder(
//           builder: (context, setModalState) {
//             return AlertDialog(
//               backgroundColor: const Color(0xFF0F172A),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF10B981))),
//               title: const Row(
//                 children: [
//                   Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 22),
//                   SizedBox(width: 8),
//                   Expanded(
//                     child: Text('Restore Account Security', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
//                   ),
//                 ],
//               ),
//               content: SingleChildScrollView(
//                 child: Form(
//                   key: formKey,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text('Enter registered username/email and password to verify:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
//                       const SizedBox(height: 14),
//                       TextFormField(
//                         controller: emailController,
//                         style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                         decoration: const InputDecoration(
//                           labelText: 'Registered Username / Email *',
//                           labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
//                           focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF10B981))),
//                         ),
//                         validator: (v) => (v == null || !v.contains('@')) ? 'Please enter a valid email' : null,
//                       ),
//                       const SizedBox(height: 10),
//                       TextFormField(
//                         controller: passwordController,
//                         obscureText: true,
//                         style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                         decoration: const InputDecoration(
//                           labelText: 'Account Password *',
//                           labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
//                           focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF10B981))),
//                         ),
//                         validator: (v) => (v == null || v.length < 6) ? 'Please enter password' : null,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: isAuthenticating
//                       ? null
//                       : () {
//                           if (Navigator.of(dialogCtx, rootNavigator: true).canPop()) {
//                             Navigator.of(dialogCtx, rootNavigator: true).pop();
//                           }
//                         },
//                   child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
//                 ),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
//                   onPressed: isAuthenticating
//                       ? null
//                       : () async {
//                           if (formKey.currentState!.validate()) {
//                             setModalState(() => isAuthenticating = true);
//                             try {
//                               AuthCredential cred = EmailAuthProvider.credential(
//                                 email: emailController.text.trim(),
//                                 password: passwordController.text.trim(),
//                               );
//                               await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(cred);

//                               if (dialogCtx.mounted && Navigator.of(dialogCtx, rootNavigator: true).canPop()) {
//                                 Navigator.of(dialogCtx, rootNavigator: true).pop();
//                               }
//                               _executeSmartReplaceRestore();
//                             } catch (e) {
//                               setModalState(() => isAuthenticating = false);
//                               if (mounted) {
//                                 CustomerDialogs.showTopNotification(context, 'Invalid Username or Password!', isError: true);
//                               }
//                             }
//                           }
//                         },
//                   child: isAuthenticating
//                       ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                       : const Text('Verify & Restore', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   // Restore Execution Logic
//   Future<void> _executeSmartReplaceRestore() async {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) return;

//     setState(() => _isRestoring = true);
//     try {
//       final backupDoc = await FirebaseFirestore.instance.collection('cloud_user_backups').doc(currentUser.uid).get();

//       if (!backupDoc.exists || backupDoc.data() == null) {
//         if (mounted) {
//           setState(() => _isRestoring = false);
//           CustomerDialogs.showTopNotification(context, 'No Cloud Backup record found! Please backup first.', isError: true);
//         }
//         return;
//       }

//       final backupData = backupDoc.data()!;
      
//       final List customers = (backupData['customers'] is List) ? backupData['customers'] : [];
//       final List transactions = (backupData['transactions'] is List) ? backupData['transactions'] : [];
//       final List history = (backupData['deletedProductsHistory'] is List) ? backupData['deletedProductsHistory'] : [];

//       if (customers.isEmpty && transactions.isEmpty && history.isEmpty) {
//         if (mounted) {
//           setState(() => _isRestoring = false);
//           CustomerDialogs.showTopNotification(context, 'Your Cloud Backup is currently empty!', isError: true);
//         }
//         return;
//       }

//       final existingCustSnap = await FirebaseFirestore.instance
//           .collection('customers')
//           .where('operatorUid', isEqualTo: currentUser.uid)
//           .get();

//       Map<String, String> existingNameToIdMap = {};
//       for (var doc in existingCustSnap.docs) {
//         final name = (doc.data()['name'] ?? '').toString().trim().toLowerCase();
//         if (name.isNotEmpty) {
//           existingNameToIdMap[name] = doc.id;
//         }
//       }

//       for (var c in customers) {
//         if (c is Map) {
//           final Map<String, dynamic> cMap = Map<String, dynamic>.from(c);
//           final String cName = (cMap['name'] ?? '').toString().trim().toLowerCase();

//           if (existingNameToIdMap.containsKey(cName)) {
//             String existingDocId = existingNameToIdMap[cName]!;
//             await FirebaseFirestore.instance.collection('customers').doc(existingDocId).set(cMap, SetOptions(merge: true));
//           } else {
//             await FirebaseFirestore.instance.collection('customers').add(cMap);
//           }
//         }
//       }

//       for (var t in transactions) {
//         if (t is Map) {
//           final Map<String, dynamic> tMap = Map<String, dynamic>.from(t);
//           await FirebaseFirestore.instance.collection('transactions').add(tMap);
//         }
//       }

//       for (var h in history) {
//         if (h is Map) {
//           final Map<String, dynamic> hMap = Map<String, dynamic>.from(h);
//           await FirebaseFirestore.instance.collection('deleted_products_history').add(hMap);
//         }
//       }

//       if (mounted) {
//         setState(() => _isRestoring = false);
//         CustomerDialogs.showTopNotification(
//           context,
//           'Data Restored Successfully! Synced ${customers.length} Accounts & Records.',
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isRestoring = false);
//         CustomerDialogs.showTopNotification(context, 'Restore operation failed!', isError: true);
//       }
//     }
//   }

//   // Security Modal for Data Purge
//   void _openDataPurgeSecurityModal({required bool purgeCloudBackupToo}) {
//     final emailController = TextEditingController(text: _backupEmailController.text);
//     final passwordController = TextEditingController();
//     final formKey = GlobalKey<FormState>();
//     bool isAuthenticating = false;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogCtx) {
//         return StatefulBuilder(
//           builder: (context, setModalState) {
//             return AlertDialog(
//               backgroundColor: const Color(0xFF0F172A),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//                 side: BorderSide(color: purgeCloudBackupToo ? Colors.redAccent : Colors.orangeAccent, width: 1.5),
//               ),
//               title: Row(
//                 children: [
//                   Icon(
//                     purgeCloudBackupToo ? Icons.delete_forever_rounded : Icons.cleaning_services_rounded,
//                     color: purgeCloudBackupToo ? Colors.redAccent : Colors.orangeAccent,
//                     size: 22,
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       purgeCloudBackupToo ? 'Hard Delete All Data' : 'Purge Live Data (Keep Backup)',
//                       style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ],
//               ),
//               content: SingleChildScrollView(
//                 child: Form(
//                   key: formKey,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         purgeCloudBackupToo
//                             ? 'WARNING: This will permanently delete ALL live account data AND your cloud backup. Enter username and password to proceed.'
//                             : 'This will purge all live app records. Data stored in your cloud backup will be preserved. Enter credentials to proceed.',
//                         style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.3),
//                       ),
//                       const SizedBox(height: 14),
//                       TextFormField(
//                         controller: emailController,
//                         style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                         decoration: const InputDecoration(
//                           labelText: 'Registered Username / Email *',
//                           labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
//                           focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
//                         ),
//                         validator: (v) => (v == null || !v.contains('@')) ? 'Please enter a valid email' : null,
//                       ),
//                       const SizedBox(height: 10),
//                       TextFormField(
//                         controller: passwordController,
//                         obscureText: true,
//                         style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                         decoration: const InputDecoration(
//                           labelText: 'Account Password *',
//                           labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
//                           focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
//                         ),
//                         validator: (v) => (v == null || v.length < 6) ? 'Please enter password' : null,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: isAuthenticating
//                       ? null
//                       : () {
//                           if (Navigator.of(dialogCtx, rootNavigator: true).canPop()) {
//                             Navigator.of(dialogCtx, rootNavigator: true).pop();
//                           }
//                         },
//                   child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
//                 ),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(backgroundColor: purgeCloudBackupToo ? Colors.red : Colors.orange.shade800),
//                   onPressed: isAuthenticating
//                       ? null
//                       : () async {
//                           if (formKey.currentState!.validate()) {
//                             setModalState(() => isAuthenticating = true);
//                             try {
//                               AuthCredential cred = EmailAuthProvider.credential(
//                                 email: emailController.text.trim(),
//                                 password: passwordController.text.trim(),
//                               );
//                               final authResult = await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(cred);

//                               if (authResult?.user != null && authResult!.user!.email != null) {
//                                 await FirebaseAuth.instance.sendPasswordResetEmail(email: authResult.user!.email!);
//                               }

//                               if (dialogCtx.mounted && Navigator.of(dialogCtx, rootNavigator: true).canPop()) {
//                                 Navigator.of(dialogCtx, rootNavigator: true).pop();
//                               }
//                               _startDirectPurgeExecution(purgeCloudBackupToo: purgeCloudBackupToo);
//                             } catch (e) {
//                               setModalState(() => isAuthenticating = false);
//                               if (mounted) {
//                                 CustomerDialogs.showTopNotification(context, 'Authentication Failed! Incorrect Credentials.', isError: true);
//                               }
//                             }
//                           }
//                         },
//                   child: isAuthenticating
//                       ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                       : Text(
//                           purgeCloudBackupToo ? 'Confirm Hard Purge' : 'Confirm Purge',
//                           style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                         ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   // Safe Direct Purge Execution
//   Future<void> _startDirectPurgeExecution({required bool purgeCloudBackupToo}) async {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) return;

//     if (_isDeleting) return;
//     setState(() => _isDeleting = true);

//     try {
//       final custSnap = await FirebaseFirestore.instance.collection('customers').where('operatorUid', isEqualTo: currentUser.uid).get();
//       final txSnap = await FirebaseFirestore.instance.collection('transactions').where('operatorUid', isEqualTo: currentUser.uid).get();
//       final histSnap = await FirebaseFirestore.instance.collection('deleted_products_history').where('operatorUid', isEqualTo: currentUser.uid).get();

//       for (var doc in custSnap.docs) {
//         await doc.reference.delete();
//       }

//       for (var doc in txSnap.docs) {
//         await doc.reference.delete();
//       }

//       for (var doc in histSnap.docs) {
//         await doc.reference.delete();
//       }

//       if (purgeCloudBackupToo) {
//         await FirebaseFirestore.instance.collection('cloud_user_backups').doc(currentUser.uid).delete();
//       }

//       if (mounted) {
//         setState(() => _isDeleting = false);
//         CustomerDialogs.showTopNotification(
//           context,
//           purgeCloudBackupToo
//               ? 'All data & cloud backups purged successfully!'
//               : 'Live data purged! Cloud backup retained.',
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isDeleting = false);
//         CustomerDialogs.showTopNotification(context, 'Data purge operation failed!', isError: true);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentTheme = ref.watch(themeModeProvider);
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isDesktopOrWeb = kIsWeb || screenWidth > 800;

//     return Center(
//       child: Container(
//         constraints: BoxConstraints(maxWidth: isDesktopOrWeb ? 750 : double.infinity),
//         child: ListView(
//           physics: const BouncingScrollPhysics(),
//           padding: EdgeInsets.symmetric(
//             horizontal: isDesktopOrWeb ? 32.0 : 16.0,
//             vertical: 20.0,
//           ).copyWith(bottom: 120.0),
//           children: [
//             Text(
//               'SYSTEM THEME CONFIGURATION CANVAS',
//               style: TextStyle(
//                 fontWeight: FontWeight.w900,
//                 color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade700,
//                 letterSpacing: 1.0,
//                 fontSize: 11,
//               ),
//             ),
//             const SizedBox(height: 14),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//               decoration: BoxDecoration(
//                 color: widget.cardBgColor,
//                 borderRadius: BorderRadius.circular(14),
//                 border: Border.all(color: widget.borderColor, width: 1.5),
//               ),
//               child: DropdownButtonHideUnderline(
//                 child: DropdownButton<ThemeMode>(
//                   value: currentTheme,
//                   dropdownColor: widget.cardBgColor,
//                   icon: const Icon(Icons.palette_rounded, color: Color(0xFF38BDF8)),
//                   isExpanded: true,
//                   style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w900, fontSize: 13),
//                   onChanged: (ThemeMode? val) {
//                     if (val != null) {
//                       ref.read(themeModeProvider.notifier).state = val;
//                     }
//                   },
//                   items: [
//                     DropdownMenuItem(value: ThemeMode.dark, child: Text('Activate Dark Slate System Profile', style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w900))),
//                     DropdownMenuItem(value: ThemeMode.light, child: Text('Activate Light Clean System Profile', style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w900))),
//                     DropdownMenuItem(value: ThemeMode.system, child: Text('Synchronize Local Operating System Theme', style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w900))),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),

//             // REAL CLOUD BACKUP & SMART RECOVERY DESK
//             Text(
//               'REAL CLOUD BACKUP & SMART RECOVERY DESK',
//               style: TextStyle(
//                 fontWeight: FontWeight.w900,
//                 color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade700,
//                 letterSpacing: 1.0,
//                 fontSize: 11,
//               ),
//             ),
//             const SizedBox(height: 14),
//             Container(
//               padding: const EdgeInsets.all(18),
//               decoration: BoxDecoration(
//                 color: widget.cardBgColor,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: widget.borderColor, width: 1.5),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF38BDF8).withOpacity(0.15),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: const Icon(Icons.cloud_sync_rounded, color: Color(0xFF38BDF8), size: 22),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Cloud Sync & Auto Backup', style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w900, fontSize: 15)),
//                             const SizedBox(height: 2),
//                             Text(
//                               'Store data safely on cloud. Accounts with matching names will be merged/replaced on restore.',
//                               style: TextStyle(color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.bold),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),

//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: widget.isDark ? Colors.black : const Color(0xFFF1F5F9),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           children: [
//                             Icon(Icons.autorenew_rounded, color: _isAutoBackupEnabled ? const Color(0xFF10B981) : Colors.grey, size: 20),
//                             const SizedBox(width: 10),
//                             Text(
//                               'Auto Cloud Sync',
//                               style: TextStyle(color: widget.textColor, fontWeight: FontWeight.bold, fontSize: 13),
//                             ),
//                           ],
//                         ),
//                         Switch(
//                           value: _isAutoBackupEnabled,
//                           activeColor: const Color(0xFF10B981),
//                           onChanged: (val) {
//                             setState(() => _isAutoBackupEnabled = val);
//                             CustomerDialogs.showTopNotification(
//                               context,
//                               val ? 'Auto Cloud Sync Activated!' : 'Auto Sync Deactivated! Manual backup mode enabled.',
//                             );
//                           },
//                         )
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 14),

//                   TextField(
//                     controller: _backupEmailController,
//                     style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w900, fontSize: 13),
//                     decoration: InputDecoration(
//                       labelText: 'Primary Cloud Backup Email *',
//                       labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
//                       prefixIcon: const Icon(Icons.mark_email_read_rounded, color: Color(0xFF38BDF8), size: 18),
//                       suffixIcon: const Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 20),
//                       filled: true,
//                       fillColor: widget.isDark ? Colors.black : const Color(0xFFF1F5F9),
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
//                     ),
//                   ),
//                   const SizedBox(height: 16),

//                   // Responsive Buttons
//                   LayoutBuilder(
//                     builder: (context, constraints) {
//                       bool isSmallScreen = constraints.maxWidth < 360;
//                       return Flex(
//                         direction: isSmallScreen ? Axis.vertical : Axis.horizontal,
//                         children: [
//                           Expanded(
//                             flex: isSmallScreen ? 0 : 1,
//                             child: SizedBox(
//                               width: isSmallScreen ? double.infinity : null,
//                               height: 44,
//                               child: ElevatedButton.icon(
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: _isAutoBackupEnabled ? const Color(0xFF0066CC) : Colors.grey.shade700,
//                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                                 ),
//                                 onPressed: (_isAutoBackupEnabled && !_isBackingUp) ? _startBackupProcessWithProgressWindow : null,
//                                 icon: _isBackingUp 
//                                     ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                                     : const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 18),
//                                 label: Text(_isBackingUp ? 'Backing Up...' : 'Cloud Backup', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: isSmallScreen ? 0 : 12, height: isSmallScreen ? 10 : 0),
//                           Expanded(
//                             flex: isSmallScreen ? 0 : 1,
//                             child: SizedBox(
//                               width: isSmallScreen ? double.infinity : null,
//                               height: 44,
//                               child: ElevatedButton.icon(
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color(0xFF10B981),
//                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                                 ),
//                                 onPressed: _isRestoring ? null : _openRestoreSecurityModal,
//                                 icon: _isRestoring
//                                     ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                                     : const Icon(Icons.cloud_download_rounded, color: Colors.white, size: 18),
//                                 label: const Text('Restore Data', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
//                               ),
//                             ),
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),

//             // ACCOUNT DATA PURGE DESK
//             Text(
//               'ACCOUNT DATA PURGE DESK',
//               style: TextStyle(
//                 fontWeight: FontWeight.w900,
//                 color: Colors.red.shade400,
//                 letterSpacing: 1.0,
//                 fontSize: 11,
//               ),
//             ),
//             const SizedBox(height: 14),
//             Container(
//               padding: const EdgeInsets.all(18),
//               decoration: BoxDecoration(
//                 color: widget.cardBgColor,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: Colors.red.shade900.withOpacity(0.5), width: 1.5),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Data Erasure Controls',
//                     style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
//                   ),
//                   const SizedBox(height: 4),
//                   const Text(
//                     'Requires username & password verification. Verification details sent to backup email.',
//                     style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 16),
//                   LayoutBuilder(
//                     builder: (context, constraints) {
//                       bool isSmallScreen = constraints.maxWidth < 360;
//                       return Flex(
//                         direction: isSmallScreen ? Axis.vertical : Axis.horizontal,
//                         children: [
//                           Expanded(
//                             flex: isSmallScreen ? 0 : 1,
//                             child: SizedBox(
//                               width: isSmallScreen ? double.infinity : null,
//                               child: OutlinedButton.icon(
//                                 style: OutlinedButton.styleFrom(
//                                   foregroundColor: Colors.orangeAccent,
//                                   side: const BorderSide(color: Colors.orangeAccent),
//                                   padding: const EdgeInsets.symmetric(vertical: 12),
//                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                                 ),
//                                 onPressed: _isDeleting ? null : () => _openDataPurgeSecurityModal(purgeCloudBackupToo: false),
//                                 icon: const Icon(Icons.cleaning_services_rounded, size: 16),
//                                 label: const Text('Purge Live Data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: isSmallScreen ? 0 : 12, height: isSmallScreen ? 10 : 0),
//                           Expanded(
//                             flex: isSmallScreen ? 0 : 1,
//                             child: SizedBox(
//                               width: isSmallScreen ? double.infinity : null,
//                               child: ElevatedButton.icon(
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.red.shade800,
//                                   padding: const EdgeInsets.symmetric(vertical: 12),
//                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                                 ),
//                                 onPressed: _isDeleting ? null : () => _openDataPurgeSecurityModal(purgeCloudBackupToo: true),
//                                 icon: const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 16),
//                                 label: const Text('Hard Purge All', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
//                               ),
//                             ),
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),

//             // HISTORYBOOK ACCESS TILE
//             Container(
//               decoration: BoxDecoration(
//                 color: widget.cardBgColor,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: widget.borderColor, width: 1.5),
//               ),
//               child: ListTile(
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//                 leading: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.blue.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: const Icon(Icons.menu_book_rounded, color: Color(0xFF38BDF8), size: 22),
//                 ),
//                 title: Text(
//                   'Global Cloud Historybook',
//                   style: TextStyle(fontWeight: FontWeight.w900, color: widget.textColor, fontSize: 14),
//                 ),
//                 subtitle: const Text(
//                   'View pushed customer archives with daily, weekly & monthly filters',
//                   style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
//                 ),
//                 trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const HistorybookView(),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 16),

//             // 📄 SAVED PDF REPORTS TILE
//             Container(
//               decoration: BoxDecoration(
//                 color: widget.cardBgColor,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: widget.borderColor, width: 1.5),
//               ),
//               child: ListTile(
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//                 leading: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.red.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFEF4444), size: 22),
//                 ),
//                 title: Text(
//                   'Saved PDF Reports',
//                   style: TextStyle(fontWeight: FontWeight.w900, color: widget.textColor, fontSize: 14),
//                 ),
//                 subtitle: const Text(
//                   'Manage exported reports (Share, Download, Delete)',
//                   style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
//                 ),
//                 trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => SavedReportsScreen(),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 16),

//             // FORGOT / RESET PASSWORD
//             Container(
//               decoration: BoxDecoration(
//                 color: widget.cardBgColor,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: widget.borderColor, width: 1.5),
//               ),
//               child: ListTile(
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//                 leading: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.orange.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: const Icon(Icons.lock_reset_rounded, color: Colors.orangeAccent, size: 22),
//                 ),
//                 title: Text(
//                   'Forgot / Reset Password',
//                   style: TextStyle(fontWeight: FontWeight.w900, color: widget.textColor, fontSize: 14),
//                 ),
//                 subtitle: const Text(
//                   'Reset password via Mobile OTP or Email Link',
//                   style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
//                 ),
//                 trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
//                 onTap: () {
//                   ForgotPasswordHelper.showForgotPasswordDialog(context);
//                 },
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Developer Settings Option Card
//             Container(
//               decoration: BoxDecoration(
//                 color: widget.cardBgColor,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: widget.borderColor, width: 1.5),
//               ),
//               child: ListTile(
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//                 leading: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.purple.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: const Icon(Icons.developer_mode_rounded, color: Colors.purpleAccent, size: 22),
//                 ),
//                 title: Text(
//                   'Developer Settings',
//                   style: TextStyle(fontWeight: FontWeight.w900, color: widget.textColor, fontSize: 14),
//                 ),
//                 subtitle: const Text(
//                   'Cache control, diagnostics and app debugging',
//                   style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
//                 ),
//                 trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const DeveloperSettingsView(),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 16),

//             // 🚪 Logout Card WITH POP-UP TRIGGER
//             Container(
//               padding: const EdgeInsets.all(18),
//               decoration: BoxDecoration(
//                 color: widget.cardBgColor,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: widget.borderColor, width: 1.5),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Logout Session', style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w900, fontSize: 15)),
//                         const SizedBox(height: 4),
//                         Text('Terminates current session and redirects to initial splash.', style: TextStyle(color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.bold)),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   ElevatedButton.icon(
//                     onPressed: () => _showLogoutConfirmationDialog(context),
//                     icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 16),
//                     label: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFEF4444),
//                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:login_setup/core/services/notification_service.dart';
import 'package:login_setup/presentation/screens/auth/forgot_password_helper.dart';
import 'package:login_setup/presentation/screens/setting/historybook_view.dart';
import 'package:login_setup/presentation/screens/setting/saved_reports_screen.dart';

import '../../../core/providers/global_provider_hub.dart';
import '../../widgets/customer_dialogs.dart';
import 'developer_settings_view.dart';

class SettingsControlPanel extends ConsumerStatefulWidget {
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

  @override
  ConsumerState<SettingsControlPanel> createState() => _SettingsControlPanelState();
}

class _SettingsControlPanelState extends ConsumerState<SettingsControlPanel> {
  final _backupEmailController = TextEditingController();

  bool _isAutoBackupEnabled = false;
  bool _isRestoring = false;
  bool _isDeleting = false;
  bool _isBackingUp = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      _backupEmailController.text = user.email!;
    }
  }

  @override
  void dispose() {
    _backupEmailController.dispose();
    super.dispose();
  }

  // 🚪 Perform Actual Firebase Logout
  Future<void> _performLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    // 🔔 TRIGGER NOTIFICATION
    await NotificationService.sendNotification(
      title: 'Session Ended',
      body: 'You have been successfully logged out of your account.',
      type: 'update',
    );

    if (context.mounted) {
      CustomerDialogs.showTopNotification(context, 'Successfully logged out!');
      context.go('/splash');
    }
  }

  // 🟢 🚪 RESPONSIVE LOGOUT CONFIRMATION POP-UP DIALOG (Left: Cancel, Right: Exit)
  void _showLogoutConfirmationDialog(BuildContext context) {
    final bool isDark = widget.isDark;
    final Color dialogBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final Color titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final Color subTextColor = isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: dialogBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
          ),
          title: Row(
            children: [
              const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Exit / Logout Session',
                  style: TextStyle(color: titleColor, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to exit and logout from current screen session?',
            style: TextStyle(color: subTextColor, fontSize: 13, height: 1.4),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: isDark ? const Color(0xFF334155) : Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.of(dialogCtx).pop();
                      CustomerDialogs.showTopNotification(context, 'Logout cancelled.');
                    },
                    child: Text('Cancel', style: TextStyle(color: subTextColor, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.of(dialogCtx).pop();
                      _performLogout(context);
                    },
                    child: const Text('Exit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ☁️ ALL PLATFORM SAFE CLOUD BACKUP
  Future<void> _startBackupProcessWithProgressWindow() async {
    final email = _backupEmailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      CustomerDialogs.showTopNotification(context, 'Please enter a valid email address!', isError: true);
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    if (_isBackingUp) return;
    setState(() => _isBackingUp = true);

    try {
      final customersSnap = await FirebaseFirestore.instance
          .collection('customers')
          .where('operatorUid', isEqualTo: currentUser.uid)
          .get();

      final txSnap = await FirebaseFirestore.instance
          .collection('transactions')
          .where('operatorUid', isEqualTo: currentUser.uid)
          .get();

      final historySnap = await FirebaseFirestore.instance
          .collection('deleted_products_history')
          .where('operatorUid', isEqualTo: currentUser.uid)
          .get();

      final totalCustomers = customersSnap.docs.length;
      final totalTx = txSnap.docs.length;
      final totalHistory = historySnap.docs.length;

      if (totalCustomers == 0 && totalTx == 0 && totalHistory == 0) {
        if (mounted) {
          setState(() => _isBackingUp = false);
          CustomerDialogs.showTopNotification(
            context,
            'No local records found to backup! Add data first.',
            isError: true,
          );
        }
        return;
      }

      final customersList = customersSnap.docs.map((d) {
        var data = d.data();
        data['docId'] = d.id;
        return data;
      }).toList();

      final txList = txSnap.docs.map((d) => d.data()).toList();
      final historyList = historySnap.docs.map((d) => d.data()).toList();

      final backupRef = FirebaseFirestore.instance.collection('cloud_user_backups').doc(currentUser.uid);
      await backupRef.set({
        'backupEmail': email,
        'operatorUid': currentUser.uid,
        'isAutoBackupActive': _isAutoBackupEnabled,
        'updatedAt': FieldValue.serverTimestamp(),
        'customers': customersList,
        'transactions': txList,
        'deletedProductsHistory': historyList,
      }, SetOptions(merge: true));

      // 🔔 TRIGGER NOTIFICATION
      await NotificationService.sendNotification(
        title: 'Cloud Backup Complete',
        body: 'Backed up $totalCustomers accounts & $totalTx records to $email.',
        type: 'add',
      );

      if (mounted) {
        setState(() => _isBackingUp = false);
        CustomerDialogs.showTopNotification(
          context,
          'Cloud Backup Complete! $totalCustomers Accounts & $totalTx Records saved to $email',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isBackingUp = false);
        CustomerDialogs.showTopNotification(context, 'Cloud sync failed!', isError: true);
      }
    }
  }

  // Restore Security Modal Dialog
  void _openRestoreSecurityModal() {
    final emailController = TextEditingController(text: _backupEmailController.text);
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isAuthenticating = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF10B981))),
              title: const Row(
                children: [
                  Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 22),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Restore Account Security', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Enter registered username/email and password to verify:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: emailController,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          labelText: 'Registered Username / Email *',
                          labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF10B981))),
                        ),
                        validator: (v) => (v == null || !v.contains('@')) ? 'Please enter a valid email' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          labelText: 'Account Password *',
                          labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF10B981))),
                        ),
                        validator: (v) => (v == null || v.length < 6) ? 'Please enter password' : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isAuthenticating
                      ? null
                      : () {
                          if (Navigator.of(dialogCtx, rootNavigator: true).canPop()) {
                            Navigator.of(dialogCtx, rootNavigator: true).pop();
                          }
                          CustomerDialogs.showTopNotification(context, 'Restore cancelled.');
                        },
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                  onPressed: isAuthenticating
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setModalState(() => isAuthenticating = true);
                            try {
                              AuthCredential cred = EmailAuthProvider.credential(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                              );
                              await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(cred);

                              if (dialogCtx.mounted && Navigator.of(dialogCtx, rootNavigator: true).canPop()) {
                                Navigator.of(dialogCtx, rootNavigator: true).pop();
                              }
                              CustomerDialogs.showTopNotification(context, 'Security verified! Starting restore...');
                              _executeSmartReplaceRestore();
                            } catch (e) {
                              setModalState(() => isAuthenticating = false);
                              if (mounted) {
                                CustomerDialogs.showTopNotification(context, 'Invalid Username or Password!', isError: true);
                              }
                            }
                          }
                        },
                  child: isAuthenticating
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Verify & Restore', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Restore Execution Logic
  Future<void> _executeSmartReplaceRestore() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() => _isRestoring = true);
    try {
      final backupDoc = await FirebaseFirestore.instance.collection('cloud_user_backups').doc(currentUser.uid).get();

      if (!backupDoc.exists || backupDoc.data() == null) {
        if (mounted) {
          setState(() => _isRestoring = false);
          CustomerDialogs.showTopNotification(context, 'No Cloud Backup record found! Please backup first.', isError: true);
        }
        return;
      }

      final backupData = backupDoc.data()!;
      
      final List customers = (backupData['customers'] is List) ? backupData['customers'] : [];
      final List transactions = (backupData['transactions'] is List) ? backupData['transactions'] : [];
      final List history = (backupData['deletedProductsHistory'] is List) ? backupData['deletedProductsHistory'] : [];

      if (customers.isEmpty && transactions.isEmpty && history.isEmpty) {
        if (mounted) {
          setState(() => _isRestoring = false);
          CustomerDialogs.showTopNotification(context, 'Your Cloud Backup is currently empty!', isError: true);
        }
        return;
      }

      final existingCustSnap = await FirebaseFirestore.instance
          .collection('customers')
          .where('operatorUid', isEqualTo: currentUser.uid)
          .get();

      Map<String, String> existingNameToIdMap = {};
      for (var doc in existingCustSnap.docs) {
        final name = (doc.data()['name'] ?? '').toString().trim().toLowerCase();
        if (name.isNotEmpty) {
          existingNameToIdMap[name] = doc.id;
        }
      }

      for (var c in customers) {
        if (c is Map) {
          final Map<String, dynamic> cMap = Map<String, dynamic>.from(c);
          final String cName = (cMap['name'] ?? '').toString().trim().toLowerCase();

          if (existingNameToIdMap.containsKey(cName)) {
            String existingDocId = existingNameToIdMap[cName]!;
            await FirebaseFirestore.instance.collection('customers').doc(existingDocId).set(cMap, SetOptions(merge: true));
          } else {
            await FirebaseFirestore.instance.collection('customers').add(cMap);
          }
        }
      }

      for (var t in transactions) {
        if (t is Map) {
          final Map<String, dynamic> tMap = Map<String, dynamic>.from(t);
          await FirebaseFirestore.instance.collection('transactions').add(tMap);
        }
      }

      for (var h in history) {
        if (h is Map) {
          final Map<String, dynamic> hMap = Map<String, dynamic>.from(h);
          await FirebaseFirestore.instance.collection('deleted_products_history').add(hMap);
        }
      }

      // 🔔 TRIGGER NOTIFICATION
      await NotificationService.sendNotification(
        title: 'Data Restored Successfully',
        body: 'Synced ${customers.length} accounts and related ledger records from cloud.',
        type: 'add',
      );

      if (mounted) {
        setState(() => _isRestoring = false);
        CustomerDialogs.showTopNotification(
          context,
          'Data Restored Successfully! Synced ${customers.length} Accounts & Records.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRestoring = false);
        CustomerDialogs.showTopNotification(context, 'Restore operation failed!', isError: true);
      }
    }
  }

  // Security Modal for Data Purge
  void _openDataPurgeSecurityModal({required bool purgeCloudBackupToo}) {
    final emailController = TextEditingController(text: _backupEmailController.text);
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isAuthenticating = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: purgeCloudBackupToo ? Colors.redAccent : Colors.orangeAccent, width: 1.5),
              ),
              title: Row(
                children: [
                  Icon(
                    purgeCloudBackupToo ? Icons.delete_forever_rounded : Icons.cleaning_services_rounded,
                    color: purgeCloudBackupToo ? Colors.redAccent : Colors.orangeAccent,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      purgeCloudBackupToo ? 'Hard Delete All Data' : 'Purge Live Data (Keep Backup)',
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        purgeCloudBackupToo
                            ? 'WARNING: This will permanently delete ALL live account data AND your cloud backup. Enter username and password to proceed.'
                            : 'This will purge all live app records. Data stored in your cloud backup will be preserved. Enter credentials to proceed.',
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.3),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: emailController,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          labelText: 'Registered Username / Email *',
                          labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
                        ),
                        validator: (v) => (v == null || !v.contains('@')) ? 'Please enter a valid email' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          labelText: 'Account Password *',
                          labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
                        ),
                        validator: (v) => (v == null || v.length < 6) ? 'Please enter password' : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isAuthenticating
                      ? null
                      : () {
                          if (Navigator.of(dialogCtx, rootNavigator: true).canPop()) {
                            Navigator.of(dialogCtx, rootNavigator: true).pop();
                          }
                          CustomerDialogs.showTopNotification(context, 'Data purge cancelled.');
                        },
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: purgeCloudBackupToo ? Colors.red : Colors.orange.shade800),
                  onPressed: isAuthenticating
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setModalState(() => isAuthenticating = true);
                            try {
                              AuthCredential cred = EmailAuthProvider.credential(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                              );
                              final authResult = await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(cred);

                              if (authResult?.user != null && authResult!.user!.email != null) {
                                await FirebaseAuth.instance.sendPasswordResetEmail(email: authResult.user!.email!);
                              }

                              if (dialogCtx.mounted && Navigator.of(dialogCtx, rootNavigator: true).canPop()) {
                                Navigator.of(dialogCtx, rootNavigator: true).pop();
                              }
                              CustomerDialogs.showTopNotification(context, 'Identity verified! Executing data purge...');
                              _startDirectPurgeExecution(purgeCloudBackupToo: purgeCloudBackupToo);
                            } catch (e) {
                              setModalState(() => isAuthenticating = false);
                              if (mounted) {
                                CustomerDialogs.showTopNotification(context, 'Authentication Failed! Incorrect Credentials.', isError: true);
                              }
                            }
                          }
                        },
                  child: isAuthenticating
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          purgeCloudBackupToo ? 'Confirm Hard Purge' : 'Confirm Purge',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Safe Direct Purge Execution
  Future<void> _startDirectPurgeExecution({required bool purgeCloudBackupToo}) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    if (_isDeleting) return;
    setState(() => _isDeleting = true);

    try {
      final custSnap = await FirebaseFirestore.instance.collection('customers').where('operatorUid', isEqualTo: currentUser.uid).get();
      final txSnap = await FirebaseFirestore.instance.collection('transactions').where('operatorUid', isEqualTo: currentUser.uid).get();
      final histSnap = await FirebaseFirestore.instance.collection('deleted_products_history').where('operatorUid', isEqualTo: currentUser.uid).get();

      for (var doc in custSnap.docs) {
        await doc.reference.delete();
      }

      for (var doc in txSnap.docs) {
        await doc.reference.delete();
      }

      for (var doc in histSnap.docs) {
        await doc.reference.delete();
      }

      if (purgeCloudBackupToo) {
        await FirebaseFirestore.instance.collection('cloud_user_backups').doc(currentUser.uid).delete();
      }

      // 🔔 TRIGGER NOTIFICATION
      await NotificationService.sendNotification(
        title: purgeCloudBackupToo ? 'All Data Purged' : 'Live Data Purged',
        body: purgeCloudBackupToo 
            ? 'All live records and cloud backup files were permanently purged.'
            : 'All live app records were purged. Cloud backup was retained.',
        type: 'delete',
      );

      if (mounted) {
        setState(() => _isDeleting = false);
        CustomerDialogs.showTopNotification(
          context,
          purgeCloudBackupToo
              ? 'All data & cloud backups purged successfully!'
              : 'Live data purged! Cloud backup retained.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        CustomerDialogs.showTopNotification(context, 'Data purge operation failed!', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeModeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktopOrWeb = kIsWeb || screenWidth > 800;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: isDesktopOrWeb ? 750 : double.infinity),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isDesktopOrWeb ? 32.0 : 16.0,
            vertical: 20.0,
          ).copyWith(bottom: 120.0),
          children: [
            Text(
              'SYSTEM THEME CONFIGURATION CANVAS',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                letterSpacing: 1.0,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: widget.cardBgColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: widget.borderColor, width: 1.5),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ThemeMode>(
                  value: currentTheme,
                  dropdownColor: widget.cardBgColor,
                  icon: const Icon(Icons.palette_rounded, color: Color(0xFF38BDF8)),
                  isExpanded: true,
                  style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w900, fontSize: 13),
                  onChanged: (ThemeMode? val) {
                    if (val != null) {
                      ref.read(themeModeProvider.notifier).state = val;
                      String modeName = val == ThemeMode.dark
                          ? 'Dark Slate'
                          : val == ThemeMode.light
                              ? 'Light Clean'
                              : 'System Sync';
                      CustomerDialogs.showTopNotification(context, '$modeName Theme Applied!');
                    }
                  },
                  items: [
                    DropdownMenuItem(value: ThemeMode.dark, child: Text('Activate Dark Slate System Profile', style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w900))),
                    DropdownMenuItem(value: ThemeMode.light, child: Text('Activate Light Clean System Profile', style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w900))),
                    DropdownMenuItem(value: ThemeMode.system, child: Text('Synchronize Local Operating System Theme', style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w900))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // REAL CLOUD BACKUP & SMART RECOVERY DESK
            Text(
              'REAL CLOUD BACKUP & SMART RECOVERY DESK',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                letterSpacing: 1.0,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: widget.cardBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: widget.borderColor, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF38BDF8).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.cloud_sync_rounded, color: Color(0xFF38BDF8), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Cloud Sync & Auto Backup', style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w900, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(
                              'Store data safely on cloud. Accounts with matching names will be merged/replaced on restore.',
                              style: TextStyle(color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.isDark ? Colors.black : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.autorenew_rounded, color: _isAutoBackupEnabled ? const Color(0xFF10B981) : Colors.grey, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'Auto Cloud Sync',
                              style: TextStyle(color: widget.textColor, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        Switch(
                          value: _isAutoBackupEnabled,
                          activeColor: const Color(0xFF10B981),
                          onChanged: (val) {
                            setState(() => _isAutoBackupEnabled = val);
                            CustomerDialogs.showTopNotification(
                              context,
                              val ? 'Auto Cloud Sync Activated!' : 'Auto Sync Deactivated! Manual backup mode enabled.',
                            );
                          },
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: _backupEmailController,
                    style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w900, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Primary Cloud Backup Email *',
                      labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                      prefixIcon: const Icon(Icons.mark_email_read_rounded, color: Color(0xFF38BDF8), size: 18),
                      suffixIcon: const Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 20),
                      filled: true,
                      fillColor: widget.isDark ? Colors.black : const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Responsive Buttons
                  LayoutBuilder(
                    builder: (context, constraints) {
                      bool isSmallScreen = constraints.maxWidth < 360;
                      return Flex(
                        direction: isSmallScreen ? Axis.vertical : Axis.horizontal,
                        children: [
                          Expanded(
                            flex: isSmallScreen ? 0 : 1,
                            child: SizedBox(
                              width: isSmallScreen ? double.infinity : null,
                              height: 44,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isAutoBackupEnabled ? const Color(0xFF0066CC) : Colors.grey.shade700,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: (_isAutoBackupEnabled && !_isBackingUp) ? _startBackupProcessWithProgressWindow : null,
                                icon: _isBackingUp 
                                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 18),
                                label: Text(_isBackingUp ? 'Backing Up...' : 'Cloud Backup', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                              ),
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 0 : 12, height: isSmallScreen ? 10 : 0),
                          Expanded(
                            flex: isSmallScreen ? 0 : 1,
                            child: SizedBox(
                              width: isSmallScreen ? double.infinity : null,
                              height: 44,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: _isRestoring ? null : _openRestoreSecurityModal,
                                icon: _isRestoring
                                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Icon(Icons.cloud_download_rounded, color: Colors.white, size: 18),
                                label: const Text('Restore Data', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ACCOUNT DATA PURGE DESK
            Text(
              'ACCOUNT DATA PURGE DESK',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.red.shade400,
                letterSpacing: 1.0,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: widget.cardBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.shade900.withOpacity(0.5), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Data Erasure Controls',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Requires username & password verification. Verification details sent to backup email.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      bool isSmallScreen = constraints.maxWidth < 360;
                      return Flex(
                        direction: isSmallScreen ? Axis.vertical : Axis.horizontal,
                        children: [
                          Expanded(
                            flex: isSmallScreen ? 0 : 1,
                            child: SizedBox(
                              width: isSmallScreen ? double.infinity : null,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.orangeAccent,
                                  side: const BorderSide(color: Colors.orangeAccent),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: _isDeleting ? null : () => _openDataPurgeSecurityModal(purgeCloudBackupToo: false),
                                icon: const Icon(Icons.cleaning_services_rounded, size: 16),
                                label: const Text('Purge Live Data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 0 : 12, height: isSmallScreen ? 10 : 0),
                          Expanded(
                            flex: isSmallScreen ? 0 : 1,
                            child: SizedBox(
                              width: isSmallScreen ? double.infinity : null,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade800,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: _isDeleting ? null : () => _openDataPurgeSecurityModal(purgeCloudBackupToo: true),
                                icon: const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 16),
                                label: const Text('Hard Purge All', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // HISTORYBOOK ACCESS TILE
            Container(
              decoration: BoxDecoration(
                color: widget.cardBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: widget.borderColor, width: 1.5),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.menu_book_rounded, color: Color(0xFF38BDF8), size: 22),
                ),
                title: Text(
                  'Global Cloud Historybook',
                  style: TextStyle(fontWeight: FontWeight.w900, color: widget.textColor, fontSize: 14),
                ),
                subtitle: const Text(
                  'View pushed customer archives with daily, weekly & monthly filters',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistorybookView(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // 📄 SAVED PDF REPORTS TILE
            Container(
              decoration: BoxDecoration(
                color: widget.cardBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: widget.borderColor, width: 1.5),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFEF4444), size: 22),
                ),
                title: Text(
                  'Saved PDF Reports',
                  style: TextStyle(fontWeight: FontWeight.w900, color: widget.textColor, fontSize: 14),
                ),
                subtitle: const Text(
                  'Manage exported reports (Share, Download, Delete)',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SavedReportsScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // FORGOT / RESET PASSWORD
            Container(
              decoration: BoxDecoration(
                color: widget.cardBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: widget.borderColor, width: 1.5),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.lock_reset_rounded, color: Colors.orangeAccent, size: 22),
                ),
                title: Text(
                  'Forgot / Reset Password',
                  style: TextStyle(fontWeight: FontWeight.w900, color: widget.textColor, fontSize: 14),
                ),
                subtitle: const Text(
                  'Reset password via Mobile OTP or Email Link',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
                onTap: () {
                  ForgotPasswordHelper.showForgotPasswordDialog(context);
                },
              ),
            ),
            const SizedBox(height: 16),

            // Developer Settings Option Card
            Container(
              decoration: BoxDecoration(
                color: widget.cardBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: widget.borderColor, width: 1.5),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.developer_mode_rounded, color: Colors.purpleAccent, size: 22),
                ),
                title: Text(
                  'Developer Settings',
                  style: TextStyle(fontWeight: FontWeight.w900, color: widget.textColor, fontSize: 14),
                ),
                subtitle: const Text(
                  'Cache control, diagnostics and app debugging',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DeveloperSettingsView(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // 🚪 Logout Card WITH POP-UP TRIGGER
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: widget.cardBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: widget.borderColor, width: 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Logout Session', style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w900, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text('Terminates current session and redirects to initial splash.', style: TextStyle(color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showLogoutConfirmationDialog(context),
                    icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 16),
                    label: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// // import 'package:flutter/material.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:go_router/go_router.dart';
// // import '../../../core/providers/global_provider_hub.dart';
// // import '../../widgets/customer_dialogs.dart';
// // import 'developer_settings_view.dart';

// // class SettingsControlPanel extends ConsumerStatefulWidget {
// //   final bool isDark;
// //   final Color textColor;
// //   final Color cardBgColor;
// //   final Color borderColor;

// //   const SettingsControlPanel({
// //     Key? key,
// //     required this.isDark,
// //     required this.textColor,
// //     required this.cardBgColor,
// //     required this.borderColor,
// //   }) : super(key: key);

// //   @override
// //   ConsumerState<SettingsControlPanel> createState() => _SettingsControlPanelState();
// // }

// // class _SettingsControlPanelState extends ConsumerState<SettingsControlPanel> {
// //   final _backupEmailController = TextEditingController();
// //   bool _isAutoBackupEnabled = false;
// //   bool _isRestoring = false;
// //   bool _isDeleting = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //     final user = FirebaseAuth.instance.currentUser;
// //     if (user != null && user.email != null) {
// //       _backupEmailController.text = user.email!;
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _backupEmailController.dispose();
// //     super.dispose();
// //   }

// //   Future<void> _performLogout(BuildContext context) async {
// //     await FirebaseAuth.instance.signOut();
// //     if (context.mounted) {
// //       context.go('/splash');
// //     }
// //   }

// //   // Cloud Backup Window with Real-Time Progress Visualizer
// //   void _startBackupProcessWithProgressWindow() async {
// //     final email = _backupEmailController.text.trim();
// //     if (email.isEmpty || !email.contains('@')) {
// //       CustomerDialogs.showTopNotification(context, 'Please enter a valid email address!', isError: true);
// //       return;
// //     }

// //     final currentUser = FirebaseAuth.instance.currentUser;
// //     if (currentUser == null) return;

// //     int syncedCustomers = 0;
// //     int syncedTx = 0;
// //     int syncedHistory = 0;
// //     int totalCustomers = 0;
// //     int totalTx = 0;
// //     int totalHistory = 0;
// //     bool isCompleted = false;

// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder: (dialogCtx) {
// //         return StatefulBuilder(
// //           builder: (context, setDialogState) {
// //             if (!isCompleted) {
// //               Future.microtask(() async {
// //                 try {
// //                   final customersSnap = await FirebaseFirestore.instance
// //                       .collection('customers')
// //                       .where('operatorUid', isEqualTo: currentUser.uid)
// //                       .get();

// //                   final txSnap = await FirebaseFirestore.instance
// //                       .collection('transactions')
// //                       .where('operatorUid', isEqualTo: currentUser.uid)
// //                       .get();

// //                   final historySnap = await FirebaseFirestore.instance
// //                       .collection('deleted_products_history')
// //                       .where('operatorUid', isEqualTo: currentUser.uid)
// //                       .get();

// //                   final customersList = customersSnap.docs.map((d) {
// //                     var data = d.data();
// //                     data['docId'] = d.id;
// //                     return data;
// //                   }).toList();

// //                   final txList = txSnap.docs.map((d) => d.data()).toList();
// //                   final historyList = historySnap.docs.map((d) => d.data()).toList();

// //                   totalCustomers = customersList.length;
// //                   totalTx = txList.length;
// //                   totalHistory = historyList.length;

// //                   for (int i = 0; i < totalCustomers; i++) {
// //                     await Future.delayed(const Duration(milliseconds: 30));
// //                     setDialogState(() => syncedCustomers = i + 1);
// //                   }

// //                   for (int i = 0; i < totalTx; i++) {
// //                     await Future.delayed(const Duration(milliseconds: 15));
// //                     setDialogState(() => syncedTx = i + 1);
// //                   }

// //                   for (int i = 0; i < totalHistory; i++) {
// //                     await Future.delayed(const Duration(milliseconds: 15));
// //                     setDialogState(() => syncedHistory = i + 1);
// //                   }

// //                   final backupRef = FirebaseFirestore.instance.collection('cloud_user_backups').doc(currentUser.uid);
// //                   await backupRef.set({
// //                     'backupEmail': email,
// //                     'operatorUid': currentUser.uid,
// //                     'isAutoBackupActive': _isAutoBackupEnabled,
// //                     'updatedAt': FieldValue.serverTimestamp(),
// //                     'customers': customersList,
// //                     'transactions': txList,
// //                     'deletedProductsHistory': historyList,
// //                   }, SetOptions(merge: true));

// //                   isCompleted = true;
// //                   setDialogState(() {});

// //                   await Future.delayed(const Duration(milliseconds: 500));
// //                   if (mounted) {
// //                     Navigator.pop(dialogCtx);
// //                     CustomerDialogs.showTopNotification(
// //                       context,
// //                       'Cloud Backup Complete! $totalCustomers Accounts & $totalTx Records saved to $email',
// //                     );
// //                   }
// //                 } catch (e) {
// //                   Navigator.pop(dialogCtx);
// //                   CustomerDialogs.showTopNotification(context, 'Cloud sync failed!', isError: true);
// //                 }
// //               });
// //             }

// //             return AlertDialog(
// //               backgroundColor: const Color(0xFF0F172A),
// //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF38BDF8))),
// //               content: Padding(
// //                 padding: const EdgeInsets.symmetric(vertical: 12),
// //                 child: Column(
// //                   mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     const SizedBox(
// //                       width: 50,
// //                       height: 50,
// //                       child: CircularProgressIndicator(color: Color(0xFF38BDF8), strokeWidth: 4),
// //                     ),
// //                     const SizedBox(height: 20),
// //                     const Text('Cloud Syncing Data...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
// //                     const SizedBox(height: 12),
// //                     Container(
// //                       padding: const EdgeInsets.all(12),
// //                       decoration: BoxDecoration(color: const Color(0xFF070A0F), borderRadius: BorderRadius.circular(10)),
// //                       child: Column(
// //                         children: [
// //                           Row(
// //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                             children: [
// //                               const Text('Accounts Synced:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold)),
// //                               Text('$syncedCustomers / $totalCustomers', style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 13)),
// //                             ],
// //                           ),
// //                           const SizedBox(height: 6),
// //                           Row(
// //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                             children: [
// //                               const Text('Ledger Records:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold)),
// //                               Text('$syncedTx / $totalTx', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13)),
// //                             ],
// //                           ),
// //                           const SizedBox(height: 6),
// //                           Row(
// //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                             children: [
// //                               const Text('History Records:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold)),
// //                               Text('$syncedHistory / $totalHistory', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
// //                             ],
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }

// //   // Restore Modal Dialog
// //   void _openRestoreSecurityModal() {
// //     final emailController = TextEditingController(text: _backupEmailController.text);
// //     final passwordController = TextEditingController();
// //     final formKey = GlobalKey<FormState>();
// //     bool isAuthenticating = false;

// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder: (dialogCtx) {
// //         return StatefulBuilder(
// //           builder: (context, setModalState) {
// //             return AlertDialog(
// //               backgroundColor: const Color(0xFF0F172A),
// //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF10B981))),
// //               title: const Row(
// //                 children: [
// //                   Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 24),
// //                   SizedBox(width: 10),
// //                   Text('Restore Account Security', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
// //                 ],
// //               ),
// //               content: Form(
// //                 key: formKey,
// //                 child: Column(
// //                   mainAxisSize: MainAxisSize.min,
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     const Text('Enter registered username/email and password to verify:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
// //                     const SizedBox(height: 14),
// //                     TextFormField(
// //                       controller: emailController,
// //                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// //                       decoration: const InputDecoration(
// //                         labelText: 'Registered Username / Email *',
// //                         labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
// //                         focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF10B981))),
// //                       ),
// //                       validator: (v) => (v == null || !v.contains('@')) ? 'Please enter a valid email' : null,
// //                     ),
// //                     const SizedBox(height: 10),
// //                     TextFormField(
// //                       controller: passwordController,
// //                       obscureText: true,
// //                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// //                       decoration: const InputDecoration(
// //                         labelText: 'Account Password *',
// //                         labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
// //                         focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF10B981))),
// //                       ),
// //                       validator: (v) => (v == null || v.length < 6) ? 'Please enter password' : null,
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               actions: [
// //                 TextButton(
// //                   onPressed: isAuthenticating ? null : () => Navigator.pop(dialogCtx),
// //                   child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
// //                 ),
// //                 ElevatedButton(
// //                   style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
// //                   onPressed: isAuthenticating
// //                       ? null
// //                       : () async {
// //                           if (formKey.currentState!.validate()) {
// //                             setModalState(() => isAuthenticating = true);
// //                             try {
// //                               AuthCredential cred = EmailAuthProvider.credential(
// //                                 email: emailController.text.trim(),
// //                                 password: passwordController.text.trim(),
// //                               );
// //                               await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(cred);

// //                               Navigator.pop(dialogCtx);
// //                               _executeSmartReplaceRestore();
// //                             } catch (e) {
// //                               setModalState(() => isAuthenticating = false);
// //                               CustomerDialogs.showTopNotification(context, 'Invalid Username or Password!', isError: true);
// //                             }
// //                           }
// //                         },
// //                   child: isAuthenticating
// //                       ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
// //                       : const Text('Verify & Restore', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
// //                 ),
// //               ],
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }

// //   // Restore Execution Logic
// //   Future<void> _executeSmartReplaceRestore() async {
// //     final currentUser = FirebaseAuth.instance.currentUser;
// //     if (currentUser == null) return;

// //     setState(() => _isRestoring = true);
// //     try {
// //       final backupDoc = await FirebaseFirestore.instance.collection('cloud_user_backups').doc(currentUser.uid).get();

// //       if (!backupDoc.exists || backupDoc.data() == null) {
// //         setState(() => _isRestoring = false);
// //         CustomerDialogs.showTopNotification(context, 'No Cloud Backup record found for this user!', isError: true);
// //         return;
// //       }

// //       final backupData = backupDoc.data()!;
// //       final List customers = backupData['customers'] ?? [];
// //       final List transactions = backupData['transactions'] ?? [];
// //       final List history = backupData['deletedProductsHistory'] ?? [];

// //       final existingCustSnap = await FirebaseFirestore.instance
// //           .collection('customers')
// //           .where('operatorUid', isEqualTo: currentUser.uid)
// //           .get();

// //       Map<String, String> existingNameToIdMap = {};
// //       for (var doc in existingCustSnap.docs) {
// //         final name = (doc.data()['name'] ?? '').toString().trim().toLowerCase();
// //         if (name.isNotEmpty) {
// //           existingNameToIdMap[name] = doc.id;
// //         }
// //       }

// //       for (var c in customers) {
// //         final Map<String, dynamic> cMap = Map<String, dynamic>.from(c);
// //         final String cName = (cMap['name'] ?? '').toString().trim().toLowerCase();

// //         if (existingNameToIdMap.containsKey(cName)) {
// //           String existingDocId = existingNameToIdMap[cName]!;
// //           await FirebaseFirestore.instance.collection('customers').doc(existingDocId).set(cMap, SetOptions(merge: true));
// //         } else {
// //           await FirebaseFirestore.instance.collection('customers').add(cMap);
// //         }
// //       }

// //       for (var t in transactions) {
// //         final Map<String, dynamic> tMap = Map<String, dynamic>.from(t);
// //         await FirebaseFirestore.instance.collection('transactions').add(tMap);
// //       }

// //       for (var h in history) {
// //         final Map<String, dynamic> hMap = Map<String, dynamic>.from(h);
// //         await FirebaseFirestore.instance.collection('deleted_products_history').add(hMap);
// //       }

// //       setState(() => _isRestoring = false);
// //       if (mounted) {
// //         CustomerDialogs.showTopNotification(
// //           context,
// //           'Data Restored Successfully! Synced ${customers.length} Accounts & Records.',
// //         );
// //       }
// //     } catch (e) {
// //       setState(() => _isRestoring = false);
// //       if (mounted) {
// //         CustomerDialogs.showTopNotification(context, 'Restore operation failed!', isError: true);
// //       }
// //     }
// //   }

// //   // 🗑️ SECURITY MODAL FOR DATA PURGE (PRESERVE BACKUP vs HARD PURGE)
// //   void _openDataPurgeSecurityModal({required bool purgeCloudBackupToo}) {
// //     final emailController = TextEditingController(text: _backupEmailController.text);
// //     final passwordController = TextEditingController();
// //     final formKey = GlobalKey<FormState>();
// //     bool isAuthenticating = false;

// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder: (dialogCtx) {
// //         return StatefulBuilder(
// //           builder: (context, setModalState) {
// //             return AlertDialog(
// //               backgroundColor: const Color(0xFF0F172A),
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(16),
// //                 side: BorderSide(color: purgeCloudBackupToo ? Colors.redAccent : Colors.orangeAccent, width: 1.5),
// //               ),
// //               title: Row(
// //                 children: [
// //                   Icon(
// //                     purgeCloudBackupToo ? Icons.delete_forever_rounded : Icons.cleaning_services_rounded,
// //                     color: purgeCloudBackupToo ? Colors.redAccent : Colors.orangeAccent,
// //                     size: 24,
// //                   ),
// //                   const SizedBox(width: 10),
// //                   Expanded(
// //                     child: Text(
// //                       purgeCloudBackupToo ? 'Hard Delete All Data' : 'Purge Live Data (Keep Backup)',
// //                       style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               content: Form(
// //                 key: formKey,
// //                 child: Column(
// //                   mainAxisSize: MainAxisSize.min,
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       purgeCloudBackupToo
// //                           ? 'WARNING: This will permanently delete ALL live account data AND your cloud backup. Enter username and password to proceed.'
// //                           : 'This will purge all live app records. Data stored in your cloud backup will be preserved. Enter credentials to proceed.',
// //                       style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.3),
// //                     ),
// //                     const SizedBox(height: 14),
// //                     TextFormField(
// //                       controller: emailController,
// //                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// //                       decoration: const InputDecoration(
// //                         labelText: 'Registered Username / Email *',
// //                         labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
// //                         focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
// //                       ),
// //                       validator: (v) => (v == null || !v.contains('@')) ? 'Please enter a valid email' : null,
// //                     ),
// //                     const SizedBox(height: 10),
// //                     TextFormField(
// //                       controller: passwordController,
// //                       obscureText: true,
// //                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// //                       decoration: const InputDecoration(
// //                         labelText: 'Account Password *',
// //                         labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
// //                         focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
// //                       ),
// //                       validator: (v) => (v == null || v.length < 6) ? 'Please enter password' : null,
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               actions: [
// //                 TextButton(
// //                   onPressed: isAuthenticating ? null : () => Navigator.pop(dialogCtx),
// //                   child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
// //                 ),
// //                 ElevatedButton(
// //                   style: ElevatedButton.styleFrom(backgroundColor: purgeCloudBackupToo ? Colors.red : Colors.orange.shade800),
// //                   onPressed: isAuthenticating
// //                       ? null
// //                       : () async {
// //                           if (formKey.currentState!.validate()) {
// //                             setModalState(() => isAuthenticating = true);
// //                             try {
// //                               AuthCredential cred = EmailAuthProvider.credential(
// //                                 email: emailController.text.trim(),
// //                                 password: passwordController.text.trim(),
// //                               );
// //                               final authResult = await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(cred);

// //                               // Send notification email link
// //                               if (authResult?.user != null && authResult!.user!.email != null) {
// //                                 await FirebaseAuth.instance.sendPasswordResetEmail(email: authResult.user!.email!);
// //                               }

// //                               Navigator.pop(dialogCtx);
// //                               _executeAccountDataPurge(purgeCloudBackupToo: purgeCloudBackupToo);
// //                             } catch (e) {
// //                               setModalState(() => isAuthenticating = false);
// //                               CustomerDialogs.showTopNotification(context, 'Authentication Failed! Incorrect Credentials.', isError: true);
// //                             }
// //                           }
// //                         },
// //                   child: isAuthenticating
// //                       ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
// //                       : Text(
// //                           purgeCloudBackupToo ? 'Confirm Hard Purge' : 'Confirm Purge',
// //                           style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// //                         ),
// //                 ),
// //               ],
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }

// //   // 🧹 PURGE EXECUTION ENGINE
// //   Future<void> _executeAccountDataPurge({required bool purgeCloudBackupToo}) async {
// //     final currentUser = FirebaseAuth.instance.currentUser;
// //     if (currentUser == null) return;

// //     setState(() => _isDeleting = true);
// //     try {
// //       // 1. Purge Live Customers Collection
// //       final custSnap = await FirebaseFirestore.instance.collection('customers').where('operatorUid', isEqualTo: currentUser.uid).get();
// //       for (var doc in custSnap.docs) {
// //         await doc.reference.delete();
// //       }

// //       // 2. Purge Live Transactions Collection
// //       final txSnap = await FirebaseFirestore.instance.collection('transactions').where('operatorUid', isEqualTo: currentUser.uid).get();
// //       for (var doc in txSnap.docs) {
// //         await doc.reference.delete();
// //       }

// //       // 3. Purge Live Deleted Products History
// //       final histSnap = await FirebaseFirestore.instance.collection('deleted_products_history').where('operatorUid', isEqualTo: currentUser.uid).get();
// //       for (var doc in histSnap.docs) {
// //         await doc.reference.delete();
// //       }

// //       // 4. Optionally Purge Cloud Backup Snapshot
// //       if (purgeCloudBackupToo) {
// //         await FirebaseFirestore.instance.collection('cloud_user_backups').doc(currentUser.uid).delete();
// //       }

// //       setState(() => _isDeleting = false);
// //       if (mounted) {
// //         CustomerDialogs.showTopNotification(
// //           context,
// //           purgeCloudBackupToo
// //               ? 'All data including cloud backups purged successfully!'
// //               : 'All live data purged. Backup retained in cloud store.',
// //         );
// //       }
// //     } catch (e) {
// //       setState(() => _isDeleting = false);
// //       if (mounted) {
// //         CustomerDialogs.showTopNotification(context, 'Data purge operation failed!', isError: true);
// //       }
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final currentTheme = ref.watch(themeModeProvider);
// //     final screenWidth = MediaQuery.of(context).size.width;
// //     final isDesktopOrWeb = screenWidth > 800;

// //     return Center(
// //       child: Container(
// //         constraints: BoxConstraints(maxWidth: isDesktopOrWeb ? 750 : double.infinity),
// //         child: ListView(
// //           padding: EdgeInsets.symmetric(
// //             horizontal: isDesktopOrWeb ? 32.0 : 16.0,
// //             vertical: 24.0,
// //           ),
// //           children: [
// //             Text(
// //               'SYSTEM THEME CONFIGURATION CANVAS',
// //               style: TextStyle(
// //                 fontWeight: FontWeight.w900,
// //                 color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade700,
// //                 letterSpacing: 1.0,
// //                 fontSize: 11,
// //               ),
// //             ),
// //             const SizedBox(height: 16),
// //             Container(
// //               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //               decoration: BoxDecoration(
// //                 color: widget.cardBgColor,
// //                 borderRadius: BorderRadius.circular(14),
// //                 border: Border.all(color: widget.borderColor, width: 1.5),
// //               ),
// //               child: DropdownButtonHideUnderline(
// //                 child: DropdownButton<ThemeMode>(
// //                   value: currentTheme,
// //                   dropdownColor: widget.cardBgColor,
// //                   icon: const Icon(Icons.palette_rounded, color: Color(0xFF38BDF8)),
// //                   isExpanded: true,
// //                   style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w900, fontSize: 14),
// //                   onChanged: (ThemeMode? val) {
// //                     if (val != null) ref.read(themeModeProvider.notifier).state = val;
// //                   },
// //                   items: [
// //                     DropdownMenuItem(value: ThemeMode.dark, child: Text('Activate Dark Slate System Profile', style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w900))),
// //                     DropdownMenuItem(value: ThemeMode.light, child: Text('Activate Light Clean System Profile', style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w900))),
// //                     DropdownMenuItem(value: ThemeMode.system, child: Text('Synchronize Local Operating System Theme', style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w900))),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //             const SizedBox(height: 28),

// //             Text(
// //               'REAL CLOUD BACKUP & SMART RECOVERY DESK',
// //               style: TextStyle(
// //                 fontWeight: FontWeight.w900,
// //                 color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade700,
// //                 letterSpacing: 1.0,
// //                 fontSize: 11,
// //               ),
// //             ),
// //             const SizedBox(height: 16),
// //             Container(
// //               padding: const EdgeInsets.all(20),
// //               decoration: BoxDecoration(
// //                 color: widget.cardBgColor,
// //                 borderRadius: BorderRadius.circular(16),
// //                 border: Border.all(color: widget.borderColor, width: 1.5),
// //               ),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Row(
// //                     children: [
// //                       Container(
// //                         padding: const EdgeInsets.all(8),
// //                         decoration: BoxDecoration(
// //                           color: const Color(0xFF38BDF8).withOpacity(0.15),
// //                           borderRadius: BorderRadius.circular(10),
// //                         ),
// //                         child: const Icon(Icons.cloud_sync_rounded, color: Color(0xFF38BDF8), size: 22),
// //                       ),
// //                       const SizedBox(width: 12),
// //                       Expanded(
// //                         child: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Text('Cloud Sync & Auto Backup', style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w900, fontSize: 15)),
// //                             const SizedBox(height: 2),
// //                             Text(
// //                               'Store data safely on cloud. Accounts with matching names will be merged/replaced on restore.',
// //                               style: TextStyle(color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.bold),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 16),

// //                   Container(
// //                     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
// //                     decoration: BoxDecoration(
// //                       color: widget.isDark ? Colors.black : const Color(0xFFF1F5F9),
// //                       borderRadius: BorderRadius.circular(12),
// //                     ),
// //                     child: Row(
// //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                       children: [
// //                         Row(
// //                           children: [
// //                             Icon(Icons.autorenew_rounded, color: _isAutoBackupEnabled ? const Color(0xFF10B981) : Colors.grey, size: 20),
// //                             const SizedBox(width: 10),
// //                             Text(
// //                               'Auto Cloud Sync',
// //                               style: TextStyle(color: widget.textColor, fontWeight: FontWeight.bold, fontSize: 13),
// //                             ),
// //                           ],
// //                         ),
// //                         Switch(
// //                           value: _isAutoBackupEnabled,
// //                           activeColor: const Color(0xFF10B981),
// //                           onChanged: (val) {
// //                             setState(() => _isAutoBackupEnabled = val);
// //                             CustomerDialogs.showTopNotification(
// //                               context,
// //                               val ? 'Auto Cloud Sync Activated!' : 'Auto Sync Deactivated! Manual backup mode enabled.',
// //                             );
// //                           },
// //                         )
// //                       ],
// //                     ),
// //                   ),
// //                   const SizedBox(height: 14),

// //                   TextField(
// //                     controller: _backupEmailController,
// //                     style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w900, fontSize: 13),
// //                     decoration: InputDecoration(
// //                       labelText: 'Primary Cloud Backup Email *',
// //                       labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
// //                       prefixIcon: const Icon(Icons.mark_email_read_rounded, color: Color(0xFF38BDF8), size: 18),
// //                       suffixIcon: const Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 20),
// //                       filled: true,
// //                       fillColor: widget.isDark ? Colors.black : const Color(0xFFF1F5F9),
// //                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 16),

// //                   Row(
// //                     children: [
// //                       Expanded(
// //                         child: SizedBox(
// //                           height: 44,
// //                           child: ElevatedButton.icon(
// //                             style: ElevatedButton.styleFrom(
// //                               backgroundColor: _isAutoBackupEnabled ? const Color(0xFF0066CC) : Colors.grey.shade700,
// //                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// //                             ),
// //                             onPressed: _isAutoBackupEnabled ? _startBackupProcessWithProgressWindow : null,
// //                             icon: const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 18),
// //                             label: const Text('Cloud Backup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
// //                           ),
// //                         ),
// //                       ),
// //                       const SizedBox(width: 12),
// //                       Expanded(
// //                         child: SizedBox(
// //                           height: 44,
// //                           child: ElevatedButton.icon(
// //                             style: ElevatedButton.styleFrom(
// //                               backgroundColor: const Color(0xFF10B981),
// //                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// //                             ),
// //                             onPressed: _isRestoring ? null : _openRestoreSecurityModal,
// //                             icon: _isRestoring
// //                                 ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
// //                                 : const Icon(Icons.cloud_download_rounded, color: Colors.white, size: 18),
// //                             label: const Text('Restore Data', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   )
// //                 ],
// //               ),
// //             ),
// //             const SizedBox(height: 28),

// //             // ⚠️ DATA PURGE & ACCOUNT CLEAR DESK
// //             Text(
// //               'ACCOUNT DATA PURGE DESK',
// //               style: TextStyle(
// //                 fontWeight: FontWeight.w900,
// //                 color: Colors.red.shade400,
// //                 letterSpacing: 1.0,
// //                 fontSize: 11,
// //               ),
// //             ),
// //             const SizedBox(height: 16),
// //             Container(
// //               padding: const EdgeInsets.all(20),
// //               decoration: BoxDecoration(
// //                 color: widget.cardBgColor,
// //                 borderRadius: BorderRadius.circular(16),
// //                 border: Border.all(color: Colors.red.shade900.withOpacity(0.5), width: 1.5),
// //               ),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   const Text(
// //                     'Data Erasure Controls',
// //                     style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
// //                   ),
// //                   const SizedBox(height: 4),
// //                   const Text(
// //                     'Requires username & password verification. Verification details sent to backup email.',
// //                     style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold),
// //                   ),
// //                   const SizedBox(height: 16),
// //                   Row(
// //                     children: [
// //                       Expanded(
// //                         child: OutlinedButton.icon(
// //                           style: OutlinedButton.styleFrom(
// //                             foregroundColor: Colors.orangeAccent,
// //                             side: const BorderSide(color: Colors.orangeAccent),
// //                             padding: const EdgeInsets.symmetric(vertical: 12),
// //                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// //                           ),
// //                           onPressed: _isDeleting ? null : () => _openDataPurgeSecurityModal(purgeCloudBackupToo: false),
// //                           icon: const Icon(Icons.cleaning_services_rounded, size: 16),
// //                           label: const Text('Purge Live Data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
// //                         ),
// //                       ),
// //                       const SizedBox(width: 12),
// //                       Expanded(
// //                         child: ElevatedButton.icon(
// //                           style: ElevatedButton.styleFrom(
// //                             backgroundColor: Colors.red.shade800,
// //                             padding: const EdgeInsets.symmetric(vertical: 12),
// //                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// //                           ),
// //                           onPressed: _isDeleting ? null : () => _openDataPurgeSecurityModal(purgeCloudBackupToo: true),
// //                           icon: const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 16),
// //                           label: const Text('Hard Purge All', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             const SizedBox(height: 28),

// //             // Developer Settings Option Card
// //             Container(
// //               decoration: BoxDecoration(
// //                 color: widget.cardBgColor,
// //                 borderRadius: BorderRadius.circular(16),
// //                 border: Border.all(color: widget.borderColor, width: 1.5),
// //               ),
// //               child: ListTile(
// //                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
// //                 leading: Container(
// //                   padding: const EdgeInsets.all(8),
// //                   decoration: BoxDecoration(
// //                     color: Colors.purple.withOpacity(0.15),
// //                     borderRadius: BorderRadius.circular(10),
// //                   ),
// //                   child: const Icon(Icons.developer_mode_rounded, color: Colors.purpleAccent, size: 22),
// //                 ),
// //                 title: Text(
// //                   'Developer Settings',
// //                   style: TextStyle(fontWeight: FontWeight.w900, color: widget.textColor, fontSize: 14),
// //                 ),
// //                 subtitle: const Text(
// //                   'Cache control, diagnostics and app debugging',
// //                   style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
// //                 ),
// //                 trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
// //                 onTap: () {
// //                   Navigator.push(
// //                     context,
// //                     MaterialPageRoute(
// //                       builder: (context) => const DeveloperSettingsView(),
// //                     ),
// //                   );
// //                 },
// //               ),
// //             ),
// //             const SizedBox(height: 28),

// //             // Logout Card
// //             Container(
// //               padding: const EdgeInsets.all(20),
// //               decoration: BoxDecoration(color: widget.cardBgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: widget.borderColor, width: 1.5)),
// //               child: Row(
// //                 children: [
// //                   Expanded(
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text('Logout Session', style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w900, fontSize: 16)),
// //                         const SizedBox(height: 4),
// //                         Text('Terminates current session and redirects to initial splash.', style: TextStyle(color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
// //                       ],
// //                     ),
// //                   ),
// //                   const SizedBox(width: 16),
// //                   ElevatedButton.icon(
// //                     onPressed: () => _performLogout(context),
// //                     icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
// //                     label: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
// //                     style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:go_router/go_router.dart';
// import 'package:login_setup/presentation/screens/setting/historybook_view.dart' show HistorybookView;

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

//   Future<void> _performLogout(BuildContext context) async {
//     await FirebaseAuth.instance.signOut();
//     if (context.mounted) {
//       context.go('/splash');
//     }
//   }

//   // Cloud Backup Window
//   void _startBackupProcessWithProgressWindow() async {
//     final email = _backupEmailController.text.trim();
//     if (email.isEmpty || !email.contains('@')) {
//       CustomerDialogs.showTopNotification(context, 'Please enter a valid email address!', isError: true);
//       return;
//     }

//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) return;

//     int syncedCustomers = 0;
//     int syncedTx = 0;
//     int syncedHistory = 0;
//     int totalCustomers = 0;
//     int totalTx = 0;
//     int totalHistory = 0;
//     bool isCompleted = false;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogCtx) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             if (!isCompleted) {
//               Future.microtask(() async {
//                 try {
//                   final customersSnap = await FirebaseFirestore.instance
//                       .collection('customers')
//                       .where('operatorUid', isEqualTo: currentUser.uid)
//                       .get();

//                   final txSnap = await FirebaseFirestore.instance
//                       .collection('transactions')
//                       .where('operatorUid', isEqualTo: currentUser.uid)
//                       .get();

//                   final historySnap = await FirebaseFirestore.instance
//                       .collection('deleted_products_history')
//                       .where('operatorUid', isEqualTo: currentUser.uid)
//                       .get();

//                   final customersList = customersSnap.docs.map((d) {
//                     var data = d.data();
//                     data['docId'] = d.id;
//                     return data;
//                   }).toList();

//                   final txList = txSnap.docs.map((d) => d.data()).toList();
//                   final historyList = historySnap.docs.map((d) => d.data()).toList();

//                   totalCustomers = customersList.length;
//                   totalTx = txList.length;
//                   totalHistory = historyList.length;

//                   for (int i = 0; i < totalCustomers; i++) {
//                     await Future.delayed(const Duration(milliseconds: 30));
//                     setDialogState(() => syncedCustomers = i + 1);
//                   }

//                   for (int i = 0; i < totalTx; i++) {
//                     await Future.delayed(const Duration(milliseconds: 15));
//                     setDialogState(() => syncedTx = i + 1);
//                   }

//                   for (int i = 0; i < totalHistory; i++) {
//                     await Future.delayed(const Duration(milliseconds: 15));
//                     setDialogState(() => syncedHistory = i + 1);
//                   }

//                   final backupRef = FirebaseFirestore.instance.collection('cloud_user_backups').doc(currentUser.uid);
//                   await backupRef.set({
//                     'backupEmail': email,
//                     'operatorUid': currentUser.uid,
//                     'isAutoBackupActive': _isAutoBackupEnabled,
//                     'updatedAt': FieldValue.serverTimestamp(),
//                     'customers': customersList,
//                     'transactions': txList,
//                     'deletedProductsHistory': historyList,
//                   }, SetOptions(merge: true));

//                   isCompleted = true;
//                   setDialogState(() {});

//                   await Future.delayed(const Duration(milliseconds: 500));
//                   if (mounted) {
//                     Navigator.pop(dialogCtx);
//                     CustomerDialogs.showTopNotification(
//                       context,
//                       'Cloud Backup Complete! $totalCustomers Accounts & $totalTx Records saved to $email',
//                     );
//                   }
//                 } catch (e) {
//                   Navigator.pop(dialogCtx);
//                   CustomerDialogs.showTopNotification(context, 'Cloud sync failed!', isError: true);
//                 }
//               });
//             }

//             return AlertDialog(
//               backgroundColor: const Color(0xFF0F172A),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF38BDF8))),
//               content: Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const SizedBox(
//                       width: 50,
//                       height: 50,
//                       child: CircularProgressIndicator(color: Color(0xFF38BDF8), strokeWidth: 4),
//                     ),
//                     const SizedBox(height: 20),
//                     const Text('Cloud Syncing Data...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
//                     const SizedBox(height: 12),
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(color: const Color(0xFF070A0F), borderRadius: BorderRadius.circular(10)),
//                       child: Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text('Accounts Synced:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold)),
//                               Text('$syncedCustomers / $totalCustomers', style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 13)),
//                             ],
//                           ),
//                           const SizedBox(height: 6),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text('Ledger Records:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold)),
//                               Text('$syncedTx / $totalTx', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13)),
//                             ],
//                           ),
//                           const SizedBox(height: 6),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text('History Records:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold)),
//                               Text('$syncedHistory / $totalHistory', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   // Restore Modal Dialog
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
//                   Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 24),
//                   SizedBox(width: 10),
//                   Text('Restore Account Security', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
//                 ],
//               ),
//               content: Form(
//                 key: formKey,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('Enter registered username/email and password to verify:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
//                     const SizedBox(height: 14),
//                     TextFormField(
//                       controller: emailController,
//                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                       decoration: const InputDecoration(
//                         labelText: 'Registered Username / Email *',
//                         labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
//                         focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF10B981))),
//                       ),
//                       validator: (v) => (v == null || !v.contains('@')) ? 'Please enter a valid email' : null,
//                     ),
//                     const SizedBox(height: 10),
//                     TextFormField(
//                       controller: passwordController,
//                       obscureText: true,
//                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                       decoration: const InputDecoration(
//                         labelText: 'Account Password *',
//                         labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
//                         focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF10B981))),
//                       ),
//                       validator: (v) => (v == null || v.length < 6) ? 'Please enter password' : null,
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: isAuthenticating ? null : () => Navigator.pop(dialogCtx),
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

//                               Navigator.pop(dialogCtx);
//                               _executeSmartReplaceRestore();
//                             } catch (e) {
//                               setModalState(() => isAuthenticating = false);
//                               CustomerDialogs.showTopNotification(context, 'Invalid Username or Password!', isError: true);
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
//         setState(() => _isRestoring = false);
//         CustomerDialogs.showTopNotification(context, 'No Cloud Backup record found for this user!', isError: true);
//         return;
//       }

//       final backupData = backupDoc.data()!;
//       final List customers = backupData['customers'] ?? [];
//       final List transactions = backupData['transactions'] ?? [];
//       final List history = backupData['deletedProductsHistory'] ?? [];

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
//         final Map<String, dynamic> cMap = Map<String, dynamic>.from(c);
//         final String cName = (cMap['name'] ?? '').toString().trim().toLowerCase();

//         if (existingNameToIdMap.containsKey(cName)) {
//           String existingDocId = existingNameToIdMap[cName]!;
//           await FirebaseFirestore.instance.collection('customers').doc(existingDocId).set(cMap, SetOptions(merge: true));
//         } else {
//           await FirebaseFirestore.instance.collection('customers').add(cMap);
//         }
//       }

//       for (var t in transactions) {
//         final Map<String, dynamic> tMap = Map<String, dynamic>.from(t);
//         await FirebaseFirestore.instance.collection('transactions').add(tMap);
//       }

//       for (var h in history) {
//         final Map<String, dynamic> hMap = Map<String, dynamic>.from(h);
//         await FirebaseFirestore.instance.collection('deleted_products_history').add(hMap);
//       }

//       setState(() => _isRestoring = false);
//       if (mounted) {
//         CustomerDialogs.showTopNotification(
//           context,
//           'Data Restored Successfully! Synced ${customers.length} Accounts & Records.',
//         );
//       }
//     } catch (e) {
//       setState(() => _isRestoring = false);
//       if (mounted) {
//         CustomerDialogs.showTopNotification(context, 'Restore operation failed!', isError: true);
//       }
//     }
//   }

//   // 🗑️ SECURITY MODAL FOR DATA PURGE
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
//                     size: 24,
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: Text(
//                       purgeCloudBackupToo ? 'Hard Delete All Data' : 'Purge Live Data (Keep Backup)',
//                       style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ],
//               ),
//               content: Form(
//                 key: formKey,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       purgeCloudBackupToo
//                           ? 'WARNING: This will permanently delete ALL live account data AND your cloud backup. Enter username and password to proceed.'
//                           : 'This will purge all live app records. Data stored in your cloud backup will be preserved. Enter credentials to proceed.',
//                       style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.3),
//                     ),
//                     const SizedBox(height: 14),
//                     TextFormField(
//                       controller: emailController,
//                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                       decoration: const InputDecoration(
//                         labelText: 'Registered Username / Email *',
//                         labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
//                         focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
//                       ),
//                       validator: (v) => (v == null || !v.contains('@')) ? 'Please enter a valid email' : null,
//                     ),
//                     const SizedBox(height: 10),
//                     TextFormField(
//                       controller: passwordController,
//                       obscureText: true,
//                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                       decoration: const InputDecoration(
//                         labelText: 'Account Password *',
//                         labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
//                         focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
//                       ),
//                       validator: (v) => (v == null || v.length < 6) ? 'Please enter password' : null,
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: isAuthenticating ? null : () => Navigator.pop(dialogCtx),
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

//                               Navigator.pop(dialogCtx);
//                               _startAnimatedPurgeProgressDialog(purgeCloudBackupToo: purgeCloudBackupToo);
//                             } catch (e) {
//                               setModalState(() => isAuthenticating = false);
//                               CustomerDialogs.showTopNotification(context, 'Authentication Failed! Incorrect Credentials.', isError: true);
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

//   // 🔴 ANIMATED PURGE PROGRESS CIRCLE DIALOG
//   void _startAnimatedPurgeProgressDialog({required bool purgeCloudBackupToo}) async {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) return;

//     int deletedCust = 0;
//     int deletedTx = 0;
//     int deletedHistory = 0;
//     int totalCust = 0;
//     int totalTx = 0;
//     int totalHistory = 0;
//     bool isBackupPurged = false;
//     bool isCompleted = false;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (purgeCtx) {
//         return StatefulBuilder(
//           builder: (context, setPurgeState) {
//             if (!isCompleted && !_isDeleting) {
//               _isDeleting = true;
//               Future.microtask(() async {
//                 try {
//                   final custSnap = await FirebaseFirestore.instance.collection('customers').where('operatorUid', isEqualTo: currentUser.uid).get();
//                   final txSnap = await FirebaseFirestore.instance.collection('transactions').where('operatorUid', isEqualTo: currentUser.uid).get();
//                   final histSnap = await FirebaseFirestore.instance.collection('deleted_products_history').where('operatorUid', isEqualTo: currentUser.uid).get();

//                   totalCust = custSnap.docs.length;
//                   totalTx = txSnap.docs.length;
//                   totalHistory = histSnap.docs.length;

//                   for (var doc in custSnap.docs) {
//                     await doc.reference.delete();
//                     await Future.delayed(const Duration(milliseconds: 25));
//                     setPurgeState(() => deletedCust++);
//                   }

//                   for (var doc in txSnap.docs) {
//                     await doc.reference.delete();
//                     await Future.delayed(const Duration(milliseconds: 15));
//                     setPurgeState(() => deletedTx++);
//                   }

//                   for (var doc in histSnap.docs) {
//                     await doc.reference.delete();
//                     await Future.delayed(const Duration(milliseconds: 15));
//                     setPurgeState(() => deletedHistory++);
//                   }

//                   if (purgeCloudBackupToo) {
//                     await FirebaseFirestore.instance.collection('cloud_user_backups').doc(currentUser.uid).delete();
//                     setPurgeState(() => isBackupPurged = true);
//                   }

//                   isCompleted = true;
//                   _isDeleting = false;

//                   await Future.delayed(const Duration(milliseconds: 400));
//                   if (mounted) {
//                     Navigator.pop(purgeCtx);
//                     CustomerDialogs.showTopNotification(
//                       context,
//                       purgeCloudBackupToo
//                           ? 'All data & cloud backups purged successfully!'
//                           : 'Live data purged! Cloud backup retained.',
//                     );
//                   }
//                 } catch (e) {
//                   _isDeleting = false;
//                   Navigator.pop(purgeCtx);
//                   CustomerDialogs.showTopNotification(context, 'Data purge operation failed!', isError: true);
//                 }
//               });
//             }

//             int grandTotal = totalCust + totalTx + totalHistory;
//             int totalDeletedSoFar = deletedCust + deletedTx + deletedHistory;
//             double progressRatio = grandTotal > 0 ? (totalDeletedSoFar / grandTotal) : 0.0;

//             return AlertDialog(
//               backgroundColor: const Color(0xFF0F172A),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//                 side: BorderSide(color: purgeCloudBackupToo ? Colors.redAccent : Colors.orangeAccent, width: 2),
//               ),
//               content: Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         SizedBox(
//                           width: 84,
//                           height: 84,
//                           child: CircularProgressIndicator(
//                             value: grandTotal > 0 ? progressRatio : null,
//                             color: purgeCloudBackupToo ? Colors.redAccent : Colors.orangeAccent,
//                             backgroundColor: const Color(0xFF1E293B),
//                             strokeWidth: 6,
//                           ),
//                         ),
//                         Icon(
//                           purgeCloudBackupToo ? Icons.delete_forever_rounded : Icons.cleaning_services_rounded,
//                           color: purgeCloudBackupToo ? Colors.redAccent : Colors.orangeAccent,
//                           size: 36,
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     Text(
//                       purgeCloudBackupToo ? 'Hard Purging All Data...' : 'Purging Live Application Data...',
//                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 14),
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(color: const Color(0xFF070A0F), borderRadius: BorderRadius.circular(12)),
//                       child: Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text('Accounts Deleted:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold)),
//                               Text('$deletedCust / $totalCust', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13)),
//                             ],
//                           ),
//                           const SizedBox(height: 6),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text('Ledgers Purged:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold)),
//                               Text('$deletedTx / $totalTx', style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 13)),
//                             ],
//                           ),
//                           const SizedBox(height: 6),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text('History Purged:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold)),
//                               Text('$deletedHistory / $totalHistory', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
//                             ],
//                           ),
//                           if (purgeCloudBackupToo) ...[
//                             const SizedBox(height: 6),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 const Text('Cloud Backup:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold)),
//                                 Text(isBackupPurged ? 'Deleted' : 'Purging...', style: TextStyle(color: isBackupPurged ? Colors.redAccent : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
//                               ],
//                             ),
//                           ]
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 18),
//                     SizedBox(
//                       width: double.infinity,
//                       child: OutlinedButton.icon(
//                         style: OutlinedButton.styleFrom(
//                           side: const BorderSide(color: Color(0xFF334155)),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                         ),
//                         onPressed: () => Navigator.pop(purgeCtx),
//                         icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 16),
//                         label: const Text('Minimize & Close Dialog', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentTheme = ref.watch(themeModeProvider);
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isDesktopOrWeb = screenWidth > 800;

//     return Center(
//       child: Container(
//         constraints: BoxConstraints(maxWidth: isDesktopOrWeb ? 750 : double.infinity),
//         child: ListView(
//           padding: EdgeInsets.symmetric(
//             horizontal: isDesktopOrWeb ? 32.0 : 16.0,
//             vertical: 24.0,
//           ),
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
//             const SizedBox(height: 16),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
//                   style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w900, fontSize: 14),
//                   onChanged: (ThemeMode? val) {
//                     if (val != null) ref.read(themeModeProvider.notifier).state = val;
//                   },
//                   items: [
//                     DropdownMenuItem(value: ThemeMode.dark, child: Text('Activate Dark Slate System Profile', style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w900))),
//                     DropdownMenuItem(value: ThemeMode.light, child: Text('Activate Light Clean System Profile', style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w900))),
//                     DropdownMenuItem(value: ThemeMode.system, child: Text('Synchronize Local Operating System Theme', style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w900))),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 28),

//             // ☁️ REAL CLOUD BACKUP & SMART RECOVERY DESK
//             Text(
//               'REAL CLOUD BACKUP & SMART RECOVERY DESK',
//               style: TextStyle(
//                 fontWeight: FontWeight.w900,
//                 color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade700,
//                 letterSpacing: 1.0,
//                 fontSize: 11,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Container(
//               padding: const EdgeInsets.all(20),
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

//                   Row(
//                     children: [
//                       Expanded(
//                         child: SizedBox(
//                           height: 44,
//                           child: ElevatedButton.icon(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: _isAutoBackupEnabled ? const Color(0xFF0066CC) : Colors.grey.shade700,
//                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                             ),
//                             onPressed: _isAutoBackupEnabled ? _startBackupProcessWithProgressWindow : null,
//                             icon: const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 18),
//                             label: const Text('Cloud Backup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: SizedBox(
//                           height: 44,
//                           child: ElevatedButton.icon(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF10B981),
//                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                             ),
//                             onPressed: _isRestoring ? null : _openRestoreSecurityModal,
//                             icon: _isRestoring
//                                 ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                                 : const Icon(Icons.cloud_download_rounded, color: Colors.white, size: 18),
//                             label: const Text('Restore Data', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
//                           ),
//                         ),
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//             ),
//             const SizedBox(height: 28),

//             // ⚠️ ACCOUNT DATA PURGE DESK
//             Text(
//               'ACCOUNT DATA PURGE DESK',
//               style: TextStyle(
//                 fontWeight: FontWeight.w900,
//                 color: Colors.red.shade400,
//                 letterSpacing: 1.0,
//                 fontSize: 11,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Container(
//               padding: const EdgeInsets.all(20),
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
//                   Row(
//                     children: [
//                       Expanded(
//                         child: OutlinedButton.icon(
//                           style: OutlinedButton.styleFrom(
//                             foregroundColor: Colors.orangeAccent,
//                             side: const BorderSide(color: Colors.orangeAccent),
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                           ),
//                           onPressed: _isDeleting ? null : () => _openDataPurgeSecurityModal(purgeCloudBackupToo: false),
//                           icon: const Icon(Icons.cleaning_services_rounded, size: 16),
//                           label: const Text('Purge Live Data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: ElevatedButton.icon(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.red.shade800,
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                           ),
//                           onPressed: _isDeleting ? null : () => _openDataPurgeSecurityModal(purgeCloudBackupToo: true),
//                           icon: const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 16),
//                           label: const Text('Hard Purge All', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             // 📚 HISTORYBOOK ACCESS TILE (SettingsControlPanel मध्ये ठेवा)
// Container(
//   decoration: BoxDecoration(
//     color: widget.cardBgColor,
//     borderRadius: BorderRadius.circular(16),
//     border: Border.all(color: widget.borderColor, width: 1.5),
//   ),
//   child: ListTile(
//     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//     leading: Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: Colors.blue.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: const Icon(Icons.menu_book_rounded, color: Color(0xFF38BDF8), size: 22),
//     ),
//     title: Text(
//       'Global Cloud Historybook',
//       style: TextStyle(fontWeight: FontWeight.w900, color: widget.textColor, fontSize: 14),
//     ),
//     subtitle: const Text(
//       'View pushed customer archives with daily, weekly & monthly filters',
//       style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
//     ),
//     trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
//     onTap: () {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const HistorybookView(),
//         ),
//       );
//     },
//   ),
// ),
//             const SizedBox(height: 28),

//             // 💻 Developer Settings Option Card
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
//             const SizedBox(height: 28),

//             // 🚪 Logout Card
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(color: widget.cardBgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: widget.borderColor, width: 1.5)),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Logout Session', style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w900, fontSize: 16)),
//                         const SizedBox(height: 4),
//                         Text('Terminates current session and redirects to initial splash.', style: TextStyle(color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   ElevatedButton.icon(
//                     onPressed: () => _performLogout(context),
//                     icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
//                     label: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFEF4444),
//                       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:go_router/go_router.dart';
// import 'package:login_setup/presentation/screens/setting/historybook_view.dart' show HistorybookView;

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

//   Future<void> _performLogout(BuildContext context) async {
//     await FirebaseAuth.instance.signOut();
//     if (context.mounted) {
//       context.go('/splash');
//     }
//   }

//   // Cloud Backup Window
//   void _startBackupProcessWithProgressWindow() async {
//     final email = _backupEmailController.text.trim();
//     if (email.isEmpty || !email.contains('@')) {
//       CustomerDialogs.showTopNotification(context, 'Please enter a valid email address!', isError: true);
//       return;
//     }

//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) return;

//     int syncedCustomers = 0;
//     int syncedTx = 0;
//     int syncedHistory = 0;
//     int totalCustomers = 0;
//     int totalTx = 0;
//     int totalHistory = 0;
//     bool isCompleted = false;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogCtx) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             if (!isCompleted) {
//               Future.microtask(() async {
//                 try {
//                   final customersSnap = await FirebaseFirestore.instance
//                       .collection('customers')
//                       .where('operatorUid', isEqualTo: currentUser.uid)
//                       .get();

//                   final txSnap = await FirebaseFirestore.instance
//                       .collection('transactions')
//                       .where('operatorUid', isEqualTo: currentUser.uid)
//                       .get();

//                   final historySnap = await FirebaseFirestore.instance
//                       .collection('deleted_products_history')
//                       .where('operatorUid', isEqualTo: currentUser.uid)
//                       .get();

//                   final customersList = customersSnap.docs.map((d) {
//                     var data = d.data();
//                     data['docId'] = d.id;
//                     return data;
//                   }).toList();

//                   final txList = txSnap.docs.map((d) => d.data()).toList();
//                   final historyList = historySnap.docs.map((d) => d.data()).toList();

//                   totalCustomers = customersList.length;
//                   totalTx = txList.length;
//                   totalHistory = historyList.length;

//                   for (int i = 0; i < totalCustomers; i++) {
//                     await Future.delayed(const Duration(milliseconds: 30));
//                     setDialogState(() => syncedCustomers = i + 1);
//                   }

//                   for (int i = 0; i < totalTx; i++) {
//                     await Future.delayed(const Duration(milliseconds: 15));
//                     setDialogState(() => syncedTx = i + 1);
//                   }

//                   for (int i = 0; i < totalHistory; i++) {
//                     await Future.delayed(const Duration(milliseconds: 15));
//                     setDialogState(() => syncedHistory = i + 1);
//                   }

//                   final backupRef = FirebaseFirestore.instance.collection('cloud_user_backups').doc(currentUser.uid);
//                   await backupRef.set({
//                     'backupEmail': email,
//                     'operatorUid': currentUser.uid,
//                     'isAutoBackupActive': _isAutoBackupEnabled,
//                     'updatedAt': FieldValue.serverTimestamp(),
//                     'customers': customersList,
//                     'transactions': txList,
//                     'deletedProductsHistory': historyList,
//                   }, SetOptions(merge: true));

//                   isCompleted = true;
//                   setDialogState(() {});

//                   await Future.delayed(const Duration(milliseconds: 500));
//                   if (mounted) {
//                     Navigator.pop(dialogCtx);
//                     CustomerDialogs.showTopNotification(
//                       context,
//                       'Cloud Backup Complete! $totalCustomers Accounts & $totalTx Records saved to $email',
//                     );
//                   }
//                 } catch (e) {
//                   Navigator.pop(dialogCtx);
//                   CustomerDialogs.showTopNotification(context, 'Cloud sync failed!', isError: true);
//                 }
//               });
//             }

//             return AlertDialog(
//               backgroundColor: const Color(0xFF0F172A),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF38BDF8))),
//               content: Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const SizedBox(
//                       width: 50,
//                       height: 50,
//                       child: CircularProgressIndicator(color: Color(0xFF38BDF8), strokeWidth: 4),
//                     ),
//                     const SizedBox(height: 20),
//                     const Text('Cloud Syncing Data...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
//                     const SizedBox(height: 12),
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(color: const Color(0xFF070A0F), borderRadius: BorderRadius.circular(10)),
//                       child: Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text('Accounts Synced:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold)),
//                               Text('$syncedCustomers / $totalCustomers', style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 13)),
//                             ],
//                           ),
//                           const SizedBox(height: 6),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text('Ledger Records:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold)),
//                               Text('$syncedTx / $totalTx', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13)),
//                             ],
//                           ),
//                           const SizedBox(height: 6),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text('History Records:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold)),
//                               Text('$syncedHistory / $totalHistory', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   // Restore Modal Dialog
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
//                   Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 24),
//                   SizedBox(width: 10),
//                   Text('Restore Account Security', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
//                 ],
//               ),
//               content: Form(
//                 key: formKey,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('Enter registered username/email and password to verify:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
//                     const SizedBox(height: 14),
//                     TextFormField(
//                       controller: emailController,
//                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                       decoration: const InputDecoration(
//                         labelText: 'Registered Username / Email *',
//                         labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
//                         focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF10B981))),
//                       ),
//                       validator: (v) => (v == null || !v.contains('@')) ? 'Please enter a valid email' : null,
//                     ),
//                     const SizedBox(height: 10),
//                     TextFormField(
//                       controller: passwordController,
//                       obscureText: true,
//                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                       decoration: const InputDecoration(
//                         labelText: 'Account Password *',
//                         labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
//                         focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF10B981))),
//                       ),
//                       validator: (v) => (v == null || v.length < 6) ? 'Please enter password' : null,
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: isAuthenticating ? null : () => Navigator.pop(dialogCtx),
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

//                               Navigator.pop(dialogCtx);
//                               _executeSmartReplaceRestore();
//                             } catch (e) {
//                               setModalState(() => isAuthenticating = false);
//                               CustomerDialogs.showTopNotification(context, 'Invalid Username or Password!', isError: true);
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
//         setState(() => _isRestoring = false);
//         CustomerDialogs.showTopNotification(context, 'No Cloud Backup record found for this user!', isError: true);
//         return;
//       }

//       final backupData = backupDoc.data()!;
//       final List customers = backupData['customers'] ?? [];
//       final List transactions = backupData['transactions'] ?? [];
//       final List history = backupData['deletedProductsHistory'] ?? [];

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
//         final Map<String, dynamic> cMap = Map<String, dynamic>.from(c);
//         final String cName = (cMap['name'] ?? '').toString().trim().toLowerCase();

//         if (existingNameToIdMap.containsKey(cName)) {
//           String existingDocId = existingNameToIdMap[cName]!;
//           await FirebaseFirestore.instance.collection('customers').doc(existingDocId).set(cMap, SetOptions(merge: true));
//         } else {
//           await FirebaseFirestore.instance.collection('customers').add(cMap);
//         }
//       }

//       for (var t in transactions) {
//         final Map<String, dynamic> tMap = Map<String, dynamic>.from(t);
//         await FirebaseFirestore.instance.collection('transactions').add(tMap);
//       }

//       for (var h in history) {
//         final Map<String, dynamic> hMap = Map<String, dynamic>.from(h);
//         await FirebaseFirestore.instance.collection('deleted_products_history').add(hMap);
//       }

//       setState(() => _isRestoring = false);
//       if (mounted) {
//         CustomerDialogs.showTopNotification(
//           context,
//           'Data Restored Successfully! Synced ${customers.length} Accounts & Records.',
//         );
//       }
//     } catch (e) {
//       setState(() => _isRestoring = false);
//       if (mounted) {
//         CustomerDialogs.showTopNotification(context, 'Restore operation failed!', isError: true);
//       }
//     }
//   }

//   // 🗑️ SECURITY MODAL FOR DATA PURGE
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
//                     size: 24,
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: Text(
//                       purgeCloudBackupToo ? 'Hard Delete All Data' : 'Purge Live Data (Keep Backup)',
//                       style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ],
//               ),
//               content: Form(
//                 key: formKey,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       purgeCloudBackupToo
//                           ? 'WARNING: This will permanently delete ALL live account data AND your cloud backup. Enter username and password to proceed.'
//                           : 'This will purge all live app records. Data stored in your cloud backup will be preserved. Enter credentials to proceed.',
//                       style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.3),
//                     ),
//                     const SizedBox(height: 14),
//                     TextFormField(
//                       controller: emailController,
//                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                       decoration: const InputDecoration(
//                         labelText: 'Registered Username / Email *',
//                         labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
//                         focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
//                       ),
//                       validator: (v) => (v == null || !v.contains('@')) ? 'Please enter a valid email' : null,
//                     ),
//                     const SizedBox(height: 10),
//                     TextFormField(
//                       controller: passwordController,
//                       obscureText: true,
//                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                       decoration: const InputDecoration(
//                         labelText: 'Account Password *',
//                         labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
//                         focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
//                       ),
//                       validator: (v) => (v == null || v.length < 6) ? 'Please enter password' : null,
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: isAuthenticating ? null : () => Navigator.pop(dialogCtx),
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

//                               Navigator.pop(dialogCtx);
//                               _startAnimatedPurgeProgressDialog(purgeCloudBackupToo: purgeCloudBackupToo);
//                             } catch (e) {
//                               setModalState(() => isAuthenticating = false);
//                               CustomerDialogs.showTopNotification(context, 'Authentication Failed! Incorrect Credentials.', isError: true);
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

//   // 🔴 ANIMATED PURGE PROGRESS CIRCLE DIALOG
//   void _startAnimatedPurgeProgressDialog({required bool purgeCloudBackupToo}) async {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) return;

//     int deletedCust = 0;
//     int deletedTx = 0;
//     int deletedHistory = 0;
//     int totalCust = 0;
//     int totalTx = 0;
//     int totalHistory = 0;
//     bool isBackupPurged = false;
//     bool isCompleted = false;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (purgeCtx) {
//         return StatefulBuilder(
//           builder: (context, setPurgeState) {
//             if (!isCompleted && !_isDeleting) {
//               _isDeleting = true;
//               Future.microtask(() async {
//                 try {
//                   final custSnap = await FirebaseFirestore.instance.collection('customers').where('operatorUid', isEqualTo: currentUser.uid).get();
//                   final txSnap = await FirebaseFirestore.instance.collection('transactions').where('operatorUid', isEqualTo: currentUser.uid).get();
//                   final histSnap = await FirebaseFirestore.instance.collection('deleted_products_history').where('operatorUid', isEqualTo: currentUser.uid).get();

//                   totalCust = custSnap.docs.length;
//                   totalTx = txSnap.docs.length;
//                   totalHistory = histSnap.docs.length;

//                   for (var doc in custSnap.docs) {
//                     await doc.reference.delete();
//                     await Future.delayed(const Duration(milliseconds: 25));
//                     setPurgeState(() => deletedCust++);
//                   }

//                   for (var doc in txSnap.docs) {
//                     await doc.reference.delete();
//                     await Future.delayed(const Duration(milliseconds: 15));
//                     setPurgeState(() => deletedTx++);
//                   }

//                   for (var doc in histSnap.docs) {
//                     await doc.reference.delete();
//                     await Future.delayed(const Duration(milliseconds: 15));
//                     setPurgeState(() => deletedHistory++);
//                   }

//                   if (purgeCloudBackupToo) {
//                     await FirebaseFirestore.instance.collection('cloud_user_backups').doc(currentUser.uid).delete();
//                     setPurgeState(() => isBackupPurged = true);
//                   }

//                   isCompleted = true;
//                   _isDeleting = false;

//                   await Future.delayed(const Duration(milliseconds: 400));
//                   if (mounted) {
//                     Navigator.pop(purgeCtx);
//                     CustomerDialogs.showTopNotification(
//                       context,
//                       purgeCloudBackupToo
//                           ? 'All data & cloud backups purged successfully!'
//                           : 'Live data purged! Cloud backup retained.',
//                     );
//                   }
//                 } catch (e) {
//                   _isDeleting = false;
//                   Navigator.pop(purgeCtx);
//                   CustomerDialogs.showTopNotification(context, 'Data purge operation failed!', isError: true);
//                 }
//               });
//             }

//             int grandTotal = totalCust + totalTx + totalHistory;
//             int totalDeletedSoFar = deletedCust + deletedTx + deletedHistory;
//             double progressRatio = grandTotal > 0 ? (totalDeletedSoFar / grandTotal) : 0.0;

//             return AlertDialog(
//               backgroundColor: const Color(0xFF0F172A),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//                 side: BorderSide(color: purgeCloudBackupToo ? Colors.redAccent : Colors.orangeAccent, width: 2),
//               ),
//               content: Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         SizedBox(
//                           width: 84,
//                           height: 84,
//                           child: CircularProgressIndicator(
//                             value: grandTotal > 0 ? progressRatio : null,
//                             color: purgeCloudBackupToo ? Colors.redAccent : Colors.orangeAccent,
//                             backgroundColor: const Color(0xFF1E293B),
//                             strokeWidth: 6,
//                           ),
//                         ),
//                         Icon(
//                           purgeCloudBackupToo ? Icons.delete_forever_rounded : Icons.cleaning_services_rounded,
//                           color: purgeCloudBackupToo ? Colors.redAccent : Colors.orangeAccent,
//                           size: 36,
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     Text(
//                       purgeCloudBackupToo ? 'Hard Purging All Data...' : 'Purging Live Application Data...',
//                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 14),
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(color: const Color(0xFF070A0F), borderRadius: BorderRadius.circular(12)),
//                       child: Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text('Accounts Deleted:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold)),
//                               Text('$deletedCust / $totalCust', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13)),
//                             ],
//                           ),
//                           const SizedBox(height: 6),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text('Ledgers Purged:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold)),
//                               Text('$deletedTx / $totalTx', style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 13)),
//                             ],
//                           ),
//                           const SizedBox(height: 6),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text('History Purged:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold)),
//                               Text('$deletedHistory / $totalHistory', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
//                             ],
//                           ),
//                           if (purgeCloudBackupToo) ...[
//                             const SizedBox(height: 6),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 const Text('Cloud Backup:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold)),
//                                 Text(isBackupPurged ? 'Deleted' : 'Purging...', style: TextStyle(color: isBackupPurged ? Colors.redAccent : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
//                               ],
//                             ),
//                           ]
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 18),
//                     SizedBox(
//                       width: double.infinity,
//                       child: OutlinedButton.icon(
//                         style: OutlinedButton.styleFrom(
//                           side: const BorderSide(color: Color(0xFF334155)),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                         ),
//                         onPressed: () => Navigator.pop(purgeCtx),
//                         icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 16),
//                         label: const Text('Minimize & Close Dialog', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // 🟢 Dynamic theme reading via Riverpod
//     final currentTheme = ref.watch(themeModeProvider);
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isDesktopOrWeb = screenWidth > 800;

//     return Center(
//       child: Container(
//         constraints: BoxConstraints(maxWidth: isDesktopOrWeb ? 750 : double.infinity),
//         child: ListView(
//           physics: const BouncingScrollPhysics(),
//           // 🟢 120px Bottom Padding दिल्यामुळे Logout Buton Floating Bar च्या पूर्णपणे वर स्क्रोल होऊन सहज Click होईल
//           padding: EdgeInsets.only(
//             left: isDesktopOrWeb ? 32.0 : 16.0,
//             right: isDesktopOrWeb ? 32.0 : 16.0,
//             top: 24.0,
//             bottom: 120.0, 
//           ),
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
//             const SizedBox(height: 16),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
//                   style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w900, fontSize: 14),
//                   onChanged: (ThemeMode? val) {
//                     if (val != null) {
//                       // 🟢 Riverpod ने थीम रिअल-टाईम अपडेट करणे
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
//             const SizedBox(height: 28),

//             // ☁️ REAL CLOUD BACKUP & SMART RECOVERY DESK
//             Text(
//               'REAL CLOUD BACKUP & SMART RECOVERY DESK',
//               style: TextStyle(
//                 fontWeight: FontWeight.w900,
//                 color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade700,
//                 letterSpacing: 1.0,
//                 fontSize: 11,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Container(
//               padding: const EdgeInsets.all(20),
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

//                   Row(
//                     children: [
//                       Expanded(
//                         child: SizedBox(
//                           height: 44,
//                           child: ElevatedButton.icon(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: _isAutoBackupEnabled ? const Color(0xFF0066CC) : Colors.grey.shade700,
//                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                             ),
//                             onPressed: _isAutoBackupEnabled ? _startBackupProcessWithProgressWindow : null,
//                             icon: const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 18),
//                             label: const Text('Cloud Backup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: SizedBox(
//                           height: 44,
//                           child: ElevatedButton.icon(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF10B981),
//                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                             ),
//                             onPressed: _isRestoring ? null : _openRestoreSecurityModal,
//                             icon: _isRestoring
//                                 ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                                 : const Icon(Icons.cloud_download_rounded, color: Colors.white, size: 18),
//                             label: const Text('Restore Data', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
//                           ),
//                         ),
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//             ),
//             const SizedBox(height: 28),

//             // ⚠️ ACCOUNT DATA PURGE DESK
//             Text(
//               'ACCOUNT DATA PURGE DESK',
//               style: TextStyle(
//                 fontWeight: FontWeight.w900,
//                 color: Colors.red.shade400,
//                 letterSpacing: 1.0,
//                 fontSize: 11,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Container(
//               padding: const EdgeInsets.all(20),
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
//                   Row(
//                     children: [
//                       Expanded(
//                         child: OutlinedButton.icon(
//                           style: OutlinedButton.styleFrom(
//                             foregroundColor: Colors.orangeAccent,
//                             side: const BorderSide(color: Colors.orangeAccent),
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                           ),
//                           onPressed: _isDeleting ? null : () => _openDataPurgeSecurityModal(purgeCloudBackupToo: false),
//                           icon: const Icon(Icons.cleaning_services_rounded, size: 16),
//                           label: const Text('Purge Live Data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: ElevatedButton.icon(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.red.shade800,
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                           ),
//                           onPressed: _isDeleting ? null : () => _openDataPurgeSecurityModal(purgeCloudBackupToo: true),
//                           icon: const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 16),
//                           label: const Text('Hard Purge All', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),

//             // 📚 HISTORYBOOK ACCESS TILE
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

//             // 💻 Developer Settings Option Card
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

//             // 🚪 Logout Card (आता १२०px Padding मुळे सहज Click होईल)
//             Container(
//               padding: const EdgeInsets.all(20),
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
//                         Text('Logout Session', style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w900, fontSize: 16)),
//                         const SizedBox(height: 4),
//                         Text('Terminates current session and redirects to initial splash.', style: TextStyle(color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   ElevatedButton.icon(
//                     onPressed: () => _performLogout(context),
//                     icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
//                     label: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFEF4444),
//                       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
import 'package:login_setup/presentation/screens/auth/forgot_password_helper.dart';
import 'package:login_setup/presentation/screens/setting/historybook_view.dart' show HistorybookView;

import '../../../core/providers/global_provider_hub.dart';
import '../../widgets/customer_dialogs.dart';
import 'developer_settings_view.dart';
// 🟢 नवीन Forgot Password Helper ची फाईल इम्पोर्ट केली आहे (तुमच्या फोल्डरनुसार पाथ बदलू शकता)

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

  Future<void> _performLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      context.go('/splash');
    }
  }

  // Cloud Backup Window
  void _startBackupProcessWithProgressWindow() async {
    final email = _backupEmailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      CustomerDialogs.showTopNotification(context, 'Please enter a valid email address!', isError: true);
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    int syncedCustomers = 0;
    int syncedTx = 0;
    int syncedHistory = 0;
    int totalCustomers = 0;
    int totalTx = 0;
    int totalHistory = 0;
    bool isCompleted = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            if (!isCompleted) {
              Future.microtask(() async {
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

                  final customersList = customersSnap.docs.map((d) {
                    var data = d.data();
                    data['docId'] = d.id;
                    return data;
                  }).toList();

                  final txList = txSnap.docs.map((d) => d.data()).toList();
                  final historyList = historySnap.docs.map((d) => d.data()).toList();

                  totalCustomers = customersList.length;
                  totalTx = txList.length;
                  totalHistory = historyList.length;

                  for (int i = 0; i < totalCustomers; i++) {
                    await Future.delayed(const Duration(milliseconds: 30));
                    setDialogState(() => syncedCustomers = i + 1);
                  }

                  for (int i = 0; i < totalTx; i++) {
                    await Future.delayed(const Duration(milliseconds: 15));
                    setDialogState(() => syncedTx = i + 1);
                  }

                  for (int i = 0; i < totalHistory; i++) {
                    await Future.delayed(const Duration(milliseconds: 15));
                    setDialogState(() => syncedHistory = i + 1);
                  }

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

                  isCompleted = true;
                  setDialogState(() {});

                  await Future.delayed(const Duration(milliseconds: 500));
                  if (mounted) {
                    Navigator.pop(dialogCtx);
                    CustomerDialogs.showTopNotification(
                      context,
                      'Cloud Backup Complete! $totalCustomers Accounts & $totalTx Records saved to $email',
                    );
                  }
                } catch (e) {
                  Navigator.pop(dialogCtx);
                  CustomerDialogs.showTopNotification(context, 'Cloud sync failed!', isError: true);
                }
              });
            }

            return AlertDialog(
              backgroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF38BDF8))),
              content: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(color: Color(0xFF38BDF8), strokeWidth: 4),
                    ),
                    const SizedBox(height: 20),
                    const Text('Cloud Syncing Data...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFF070A0F), borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Accounts Synced:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold)),
                              Text('$syncedCustomers / $totalCustomers', style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Ledger Records:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold)),
                              Text('$syncedTx / $totalTx', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('History Records:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold)),
                              Text('$syncedHistory / $totalHistory', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Restore Modal Dialog
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
                  Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 24),
                  SizedBox(width: 10),
                  Text('Restore Account Security', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Form(
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
              actions: [
                TextButton(
                  onPressed: isAuthenticating ? null : () => Navigator.pop(dialogCtx),
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

                              Navigator.pop(dialogCtx);
                              _executeSmartReplaceRestore();
                            } catch (e) {
                              setModalState(() => isAuthenticating = false);
                              CustomerDialogs.showTopNotification(context, 'Invalid Username or Password!', isError: true);
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
        setState(() => _isRestoring = false);
        CustomerDialogs.showTopNotification(context, 'No Cloud Backup record found for this user!', isError: true);
        return;
      }

      final backupData = backupDoc.data()!;
      final List customers = backupData['customers'] ?? [];
      final List transactions = backupData['transactions'] ?? [];
      final List history = backupData['deletedProductsHistory'] ?? [];

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
        final Map<String, dynamic> cMap = Map<String, dynamic>.from(c);
        final String cName = (cMap['name'] ?? '').toString().trim().toLowerCase();

        if (existingNameToIdMap.containsKey(cName)) {
          String existingDocId = existingNameToIdMap[cName]!;
          await FirebaseFirestore.instance.collection('customers').doc(existingDocId).set(cMap, SetOptions(merge: true));
        } else {
          await FirebaseFirestore.instance.collection('customers').add(cMap);
        }
      }

      for (var t in transactions) {
        final Map<String, dynamic> tMap = Map<String, dynamic>.from(t);
        await FirebaseFirestore.instance.collection('transactions').add(tMap);
      }

      for (var h in history) {
        final Map<String, dynamic> hMap = Map<String, dynamic>.from(h);
        await FirebaseFirestore.instance.collection('deleted_products_history').add(hMap);
      }

      setState(() => _isRestoring = false);
      if (mounted) {
        CustomerDialogs.showTopNotification(
          context,
          'Data Restored Successfully! Synced ${customers.length} Accounts & Records.',
        );
      }
    } catch (e) {
      setState(() => _isRestoring = false);
      if (mounted) {
        CustomerDialogs.showTopNotification(context, 'Restore operation failed!', isError: true);
      }
    }
  }

  // 🗑️ SECURITY MODAL FOR DATA PURGE
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
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      purgeCloudBackupToo ? 'Hard Delete All Data' : 'Purge Live Data (Keep Backup)',
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: Form(
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
              actions: [
                TextButton(
                  onPressed: isAuthenticating ? null : () => Navigator.pop(dialogCtx),
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

                              Navigator.pop(dialogCtx);
                              _startAnimatedPurgeProgressDialog(purgeCloudBackupToo: purgeCloudBackupToo);
                            } catch (e) {
                              setModalState(() => isAuthenticating = false);
                              CustomerDialogs.showTopNotification(context, 'Authentication Failed! Incorrect Credentials.', isError: true);
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

  // 🔴 ANIMATED PURGE PROGRESS CIRCLE DIALOG
  void _startAnimatedPurgeProgressDialog({required bool purgeCloudBackupToo}) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    int deletedCust = 0;
    int deletedTx = 0;
    int deletedHistory = 0;
    int totalCust = 0;
    int totalTx = 0;
    int totalHistory = 0;
    bool isBackupPurged = false;
    bool isCompleted = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (purgeCtx) {
        return StatefulBuilder(
          builder: (context, setPurgeState) {
            if (!isCompleted && !_isDeleting) {
              _isDeleting = true;
              Future.microtask(() async {
                try {
                  final custSnap = await FirebaseFirestore.instance.collection('customers').where('operatorUid', isEqualTo: currentUser.uid).get();
                  final txSnap = await FirebaseFirestore.instance.collection('transactions').where('operatorUid', isEqualTo: currentUser.uid).get();
                  final histSnap = await FirebaseFirestore.instance.collection('deleted_products_history').where('operatorUid', isEqualTo: currentUser.uid).get();

                  totalCust = custSnap.docs.length;
                  totalTx = txSnap.docs.length;
                  totalHistory = histSnap.docs.length;

                  for (var doc in custSnap.docs) {
                    await doc.reference.delete();
                    await Future.delayed(const Duration(milliseconds: 25));
                    setPurgeState(() => deletedCust++);
                  }

                  for (var doc in txSnap.docs) {
                    await doc.reference.delete();
                    await Future.delayed(const Duration(milliseconds: 15));
                    setPurgeState(() => deletedTx++);
                  }

                  for (var doc in histSnap.docs) {
                    await doc.reference.delete();
                    await Future.delayed(const Duration(milliseconds: 15));
                    setPurgeState(() => deletedHistory++);
                  }

                  if (purgeCloudBackupToo) {
                    await FirebaseFirestore.instance.collection('cloud_user_backups').doc(currentUser.uid).delete();
                    setPurgeState(() => isBackupPurged = true);
                  }

                  isCompleted = true;
                  _isDeleting = false;

                  await Future.delayed(const Duration(milliseconds: 400));
                  if (mounted) {
                    Navigator.pop(purgeCtx);
                    CustomerDialogs.showTopNotification(
                      context,
                      purgeCloudBackupToo
                          ? 'All data & cloud backups purged successfully!'
                          : 'Live data purged! Cloud backup retained.',
                    );
                  }
                } catch (e) {
                  _isDeleting = false;
                  Navigator.pop(purgeCtx);
                  CustomerDialogs.showTopNotification(context, 'Data purge operation failed!', isError: true);
                }
              });
            }

            int grandTotal = totalCust + totalTx + totalHistory;
            int totalDeletedSoFar = deletedCust + deletedTx + deletedHistory;
            double progressRatio = grandTotal > 0 ? (totalDeletedSoFar / grandTotal) : 0.0;

            return AlertDialog(
              backgroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: purgeCloudBackupToo ? Colors.redAccent : Colors.orangeAccent, width: 2),
              ),
              content: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 84,
                          height: 84,
                          child: CircularProgressIndicator(
                            value: grandTotal > 0 ? progressRatio : null,
                            color: purgeCloudBackupToo ? Colors.redAccent : Colors.orangeAccent,
                            backgroundColor: const Color(0xFF1E293B),
                            strokeWidth: 6,
                          ),
                        ),
                        Icon(
                          purgeCloudBackupToo ? Icons.delete_forever_rounded : Icons.cleaning_services_rounded,
                          color: purgeCloudBackupToo ? Colors.redAccent : Colors.orangeAccent,
                          size: 36,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      purgeCloudBackupToo ? 'Hard Purging All Data...' : 'Purging Live Application Data...',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFF070A0F), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Accounts Deleted:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold)),
                              Text('$deletedCust / $totalCust', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Ledgers Purged:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold)),
                              Text('$deletedTx / $totalTx', style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('History Purged:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold)),
                              Text('$deletedHistory / $totalHistory', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          if (purgeCloudBackupToo) ...[
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Cloud Backup:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold)),
                                Text(isBackupPurged ? 'Deleted' : 'Purging...', style: TextStyle(color: isBackupPurged ? Colors.redAccent : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          ]
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF334155)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => Navigator.pop(purgeCtx),
                        icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 16),
                        label: const Text('Minimize & Close Dialog', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🟢 Dynamic theme reading via Riverpod
    final currentTheme = ref.watch(themeModeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktopOrWeb = screenWidth > 800;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: isDesktopOrWeb ? 750 : double.infinity),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          // 🟢 120px Bottom Padding दिल्यामुळे Logout Buton Floating Bar च्या पूर्णपणे वर स्क्रोल होऊन सहज Click होईल
          padding: EdgeInsets.only(
            left: isDesktopOrWeb ? 32.0 : 16.0,
            right: isDesktopOrWeb ? 32.0 : 16.0,
            top: 24.0,
            bottom: 120.0, 
          ),
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
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w900, fontSize: 14),
                  onChanged: (ThemeMode? val) {
                    if (val != null) {
                      // 🟢 Riverpod ने थीम रिअल-टाईम अपडेट करणे
                      ref.read(themeModeProvider.notifier).state = val;
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
            const SizedBox(height: 28),

            // ☁️ REAL CLOUD BACKUP & SMART RECOVERY DESK
            Text(
              'REAL CLOUD BACKUP & SMART RECOVERY DESK',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                letterSpacing: 1.0,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
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

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isAutoBackupEnabled ? const Color(0xFF0066CC) : Colors.grey.shade700,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _isAutoBackupEnabled ? _startBackupProcessWithProgressWindow : null,
                            icon: const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 18),
                            label: const Text('Cloud Backup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
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
                  )
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ⚠️ ACCOUNT DATA PURGE DESK
            Text(
              'ACCOUNT DATA PURGE DESK',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.red.shade400,
                letterSpacing: 1.0,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
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
                  Row(
                    children: [
                      Expanded(
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
                      const SizedBox(width: 12),
                      Expanded(
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
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 📚 HISTORYBOOK ACCESS TILE
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

            // 🟢 🔒 NEW FORGOT / RESET PASSWORD BUTTON ADDED HERE
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
                  child: const Icon(Icons.lock_reset_rounded, color: Colors.redAccent, size: 22),
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
                  // हे डायलॉग ओपन करेल
                  ForgotPasswordHelper.showForgotPasswordDialog(context);
                },
              ),
            ),
            const SizedBox(height: 16),

            // 💻 Developer Settings Option Card
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

            // 🚪 Logout Card
            Container(
              padding: const EdgeInsets.all(20),
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
                        Text('Logout Session', style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w900, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('Terminates current session and redirects to initial splash.', style: TextStyle(color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => _performLogout(context),
                    icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
                    label: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
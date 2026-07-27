
// // // // import 'dart:async';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:cloud_firestore/cloud_firestore.dart';

// // // // class CustomerDialogs {
// // // //   // 🔔 GUARANTEED TOP OVERLAY NOTIFICATION (ALWAYS VISIBLE AT TOP)
// // // //   static void showTopNotification(BuildContext context, String message, {bool isError = false}) {
// // // //     final overlay = Overlay.maybeOf(context);
// // // //     if (overlay == null) return;

// // // //     final overlayEntry = OverlayEntry(
// // // //       builder: (context) => Positioned(
// // // //         top: MediaQuery.of(context).padding.top + 10,
// // // //         left: 16,
// // // //         right: 16,
// // // //         child: Material(
// // // //           color: Colors.transparent,
// // // //           child: AnimatedContainer(
// // // //             duration: const Duration(milliseconds: 300),
// // // //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// // // //             decoration: BoxDecoration(
// // // //               color: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
// // // //               borderRadius: BorderRadius.circular(12),
// // // //               boxShadow: [
// // // //                 BoxShadow(
// // // //                   color: Colors.black.withOpacity(0.3),
// // // //                   blurRadius: 10,
// // // //                   offset: const Offset(0, 4),
// // // //                 )
// // // //               ],
// // // //             ),
// // // //             child: Row(
// // // //               children: [
// // // //                 Icon(
// // // //                   isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
// // // //                   color: Colors.white,
// // // //                   size: 22,
// // // //                 ),
// // // //                 const SizedBox(width: 12),
// // // //                 Expanded(
// // // //                   child: Text(
// // // //                     message,
// // // //                     style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
// // // //                   ),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );

// // // //     overlay.insert(overlayEntry);
// // // //     Future.delayed(const Duration(milliseconds: 2200), () {
// // // //       overlayEntry.remove();
// // // //     });
// // // //   }

// // // //   // 🚨 SECURE DELETE DIALOG WITH PROPER SPINNER
// // // //   static Future<bool> openSecureDeleteDialog({
// // // //     required BuildContext context,
// // // //     required String customerId,
// // // //     required String customerName,
// // // //     required bool Function(String id) isButtonLoading,
// // // //     required Function(String id, bool loading) setButtonLoading,
// // // //     bool isPermanent = false,
// // // //   }) async {
// // // //     final verifyController = TextEditingController();
// // // //     final formKey = GlobalKey<FormState>();

// // // //     bool? result = await showDialog<bool>(
// // // //       context: context,
// // // //       barrierDismissible: false,
// // // //       builder: (ctx) => StatefulBuilder(
// // // //         builder: (context, setDialogState) {
// // // //           bool isDeleting = isButtonLoading(isPermanent ? 'perm_$customerId' : 'del_$customerId');

// // // //           return AlertDialog(
// // // //             backgroundColor: const Color(0xFF0F172A),
// // // //             shape: RoundedRectangleBorder(
// // // //               borderRadius: BorderRadius.circular(18),
// // // //               side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
// // // //             ),
// // // //             title: Row(
// // // //               children: [
// // // //                 const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 28),
// // // //                 const SizedBox(width: 10),
// // // //                 Text(
// // // //                   isPermanent ? 'Permanent Purge' : 'Move to Recycle Bin',
// // // //                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //             content: Form(
// // // //               key: formKey,
// // // //               child: Column(
// // // //                 mainAxisSize: MainAxisSize.min,
// // // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // // //                 children: [
// // // //                   Text(
// // // //                     isPermanent
// // // //                         ? 'Type the required customer name below to permanently erase all records:'
// // // //                         : 'Type the customer name below to move account & transactions to history bin:',
// // // //                     style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.4),
// // // //                   ),
// // // //                   const SizedBox(height: 12),
// // // //                   Container(
// // // //                     width: double.infinity,
// // // //                     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
// // // //                     decoration: BoxDecoration(
// // // //                       color: const Color(0xFF1E293B),
// // // //                       borderRadius: BorderRadius.circular(10),
// // // //                       border: Border.all(color: const Color(0xFF334155)),
// // // //                     ),
// // // //                     child: Row(
// // // //                       children: [
// // // //                         const Icon(Icons.person_outline_rounded, size: 16, color: Color(0xFF38BDF8)),
// // // //                         const SizedBox(width: 8),
// // // //                         Expanded(
// // // //                           child: Text(
// // // //                             customerName,
// // // //                             style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
// // // //                           ),
// // // //                         ),
// // // //                       ],
// // // //                     ),
// // // //                   ),
// // // //                   const SizedBox(height: 14),
// // // //                   TextFormField(
// // // //                     controller: verifyController,
// // // //                     enabled: !isDeleting,
// // // //                     style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// // // //                     decoration: InputDecoration(
// // // //                       hintText: customerName,
// // // //                       hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
// // // //                       filled: true,
// // // //                       fillColor: const Color(0xFF070A0F),
// // // //                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
// // // //                       focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEF4444))),
// // // //                     ),
// // // //                     validator: (val) {
// // // //                       if (val == null || val.trim().toLowerCase() != customerName.trim().toLowerCase()) {
// // // //                         return 'Customer name does not match!';
// // // //                       }
// // // //                       return null;
// // // //                     },
// // // //                   ),
// // // //                 ],
// // // //               ),
// // // //             ),
// // // //             actions: [
// // // //               TextButton(
// // // //                 onPressed: isDeleting ? null : () => Navigator.pop(ctx, false),
// // // //                 child: const Text('Cancel', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
// // // //               ),
// // // //               ElevatedButton(
// // // //                 style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
// // // //                 onPressed: isDeleting
// // // //                     ? null
// // // //                     : () {
// // // //                         if (formKey.currentState!.validate()) {
// // // //                           Navigator.pop(ctx, true);
// // // //                         }
// // // //                       },
// // // //                 child: isDeleting
// // // //                     ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
// // // //                     : Text(isPermanent ? 'Purge Forever' : 'Confirm Action', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
// // // //               ),
// // // //             ],
// // // //           );
// // // //         },
// // // //       ),
// // // //     );

// // // //     return result ?? false;
// // // //   }

// // // //   // 🎯 CUSTOM FILTER MODAL
// // // //   static void openCustomFilterModal({
// // // //     required BuildContext context,
// // // //     required double? customMinFilter,
// // // //     required Function(String filter, double? minVal) onFilterApplied,
// // // //   }) {
// // // //     final customValController = TextEditingController(text: customMinFilter != null ? customMinFilter.toStringAsFixed(0) : '');

// // // //     showDialog(
// // // //       context: context,
// // // //       builder: (ctx) => AlertDialog(
// // // //         backgroundColor: const Color(0xFF0F172A),
// // // //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF38BDF8))),
// // // //         title: const Text('Customize Credit Limit Filter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
// // // //         content: Column(
// // // //           mainAxisSize: MainAxisSize.min,
// // // //           children: [
// // // //             const Text('Enter minimum balance amount threshold (₹):', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
// // // //             const SizedBox(height: 12),
// // // //             TextField(
// // // //               controller: customValController,
// // // //               keyboardType: TextInputType.number,
// // // //               style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// // // //               decoration: InputDecoration(
// // // //                 prefixText: '₹ ',
// // // //                 prefixStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// // // //                 hintText: 'e.g. 2500',
// // // //                 filled: true,
// // // //                 fillColor: const Color(0xFF070A0F),
// // // //                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
// // // //               ),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //         actions: [
// // // //           TextButton(
// // // //             onPressed: () {
// // // //               onFilterApplied('all', null);
// // // //               Navigator.pop(ctx);
// // // //             },
// // // //             child: const Text('Reset All', style: TextStyle(color: Colors.redAccent)),
// // // //           ),
// // // //           ElevatedButton(
// // // //             style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8)),
// // // //             onPressed: () {
// // // //               final parsed = double.tryParse(customValController.text.trim());
// // // //               if (parsed != null) {
// // // //                 onFilterApplied('custom', parsed);
// // // //                 Navigator.pop(ctx);
// // // //                 showTopNotification(context, 'Applied custom filter: ₹${parsed.toStringAsFixed(0)}+');
// // // //               }
// // // //             },
// // // //             child: const Text('Apply Filter', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
// // // //           )
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ✏️ EDIT CUSTOMER MODAL
// // // //   static void openEditCustomerModal({
// // // //     required BuildContext context,
// // // //     required String customerId,
// // // //     required Map<String, dynamic> currentData,
// // // //     required bool Function(String id) isButtonLoading,
// // // //     required Function(String id, bool loading) setButtonLoading,
// // // //   }) {
// // // //     final formKey = GlobalKey<FormState>();
// // // //     final nameController = TextEditingController(text: currentData['name'] ?? '');
// // // //     final phoneController = TextEditingController(text: currentData['phone'] ?? '');
// // // //     final addressController = TextEditingController(text: currentData['address'] ?? '');
// // // //     final operatorUid = currentData['operatorUid'] ?? '';

// // // //     String? nameError;
// // // //     String? phoneError;
// // // //     Timer? debounce;

// // // //     showDialog(
// // // //       context: context,
// // // //       barrierDismissible: false,
// // // //       builder: (ctx) => StatefulBuilder(
// // // //         builder: (dialogCtx, setDialogState) {
// // // //           bool isUpdating = isButtonLoading('edit_$customerId');

// // // //           void checkLiveName(String val) {
// // // //             if (debounce?.isActive ?? false) debounce!.cancel();
// // // //             debounce = Timer(const Duration(milliseconds: 300), () async {
// // // //               final text = val.trim().toLowerCase();
// // // //               if (text.isEmpty) {
// // // //                 setDialogState(() => nameError = null);
// // // //                 return;
// // // //               }
// // // //               final query = await FirebaseFirestore.instance
// // // //                   .collection('customers')
// // // //                   .where('operatorUid', isEqualTo: operatorUid)
// // // //                   .get();

// // // //               bool duplicate = query.docs.any((d) => d.id != customerId && (d.data()['name'] ?? '').toString().trim().toLowerCase() == text);
// // // //               setDialogState(() {
// // // //                 nameError = duplicate ? 'Already Name Exists!' : null;
// // // //               });
// // // //               if (duplicate) {
// // // //                 showTopNotification(context, 'Customer "$val" already exists!', isError: true);
// // // //               }
// // // //             });
// // // //           }

// // // //           void checkLivePhone(String val) {
// // // //             if (debounce?.isActive ?? false) debounce!.cancel();
// // // //             debounce = Timer(const Duration(milliseconds: 300), () async {
// // // //               final text = val.trim();
// // // //               if (text.length != 10) {
// // // //                 setDialogState(() => phoneError = null);
// // // //                 return;
// // // //               }
// // // //               final query = await FirebaseFirestore.instance
// // // //                   .collection('customers')
// // // //                   .where('operatorUid', isEqualTo: operatorUid)
// // // //                   .where('phone', isEqualTo: text)
// // // //                   .get();

// // // //               bool duplicate = query.docs.any((d) => d.id != customerId);
// // // //               setDialogState(() {
// // // //                 phoneError = duplicate ? 'Already Phone Number Exists!' : null;
// // // //               });
// // // //               if (duplicate) {
// // // //                 showTopNotification(context, 'Mobile number +91 $text already registered!', isError: true);
// // // //               }
// // // //             });
// // // //           }

// // // //           return AlertDialog(
// // // //             backgroundColor: const Color(0xFF0F172A),
// // // //             shape: RoundedRectangleBorder(
// // // //               borderRadius: BorderRadius.circular(16),
// // // //               side: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
// // // //             ),
// // // //             title: const Text('Edit Customer Details', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 16)),
// // // //             content: Form(
// // // //               key: formKey,
// // // //               child: SingleChildScrollView(
// // // //                 child: Column(
// // // //                   mainAxisSize: MainAxisSize.min,
// // // //                   children: [
// // // //                     TextFormField(
// // // //                       controller: nameController,
// // // //                       enabled: !isUpdating,
// // // //                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// // // //                       decoration: InputDecoration(
// // // //                         labelText: 'Customer Full Name *',
// // // //                         labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
// // // //                         errorText: nameError,
// // // //                         errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
// // // //                       ),
// // // //                       onChanged: checkLiveName,
// // // //                       validator: (v) => (v == null || v.trim().isEmpty) ? 'Name required.' : nameError,
// // // //                     ),
// // // //                     const SizedBox(height: 12),
// // // //                     TextFormField(
// // // //                       controller: phoneController,
// // // //                       enabled: !isUpdating,
// // // //                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// // // //                       keyboardType: TextInputType.phone,
// // // //                       maxLength: 10,
// // // //                       decoration: InputDecoration(
// // // //                         labelText: 'Mobile Number *',
// // // //                         prefixText: '+91 ',
// // // //                         counterText: '',
// // // //                         labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
// // // //                         errorText: phoneError,
// // // //                         errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
// // // //                       ),
// // // //                       onChanged: checkLivePhone,
// // // //                       validator: (v) => (v == null || v.trim().length != 10) ? 'Enter valid 10-digit number.' : phoneError,
// // // //                     ),
// // // //                     const SizedBox(height: 12),
// // // //                     TextFormField(
// // // //                       controller: addressController,
// // // //                       enabled: !isUpdating,
// // // //                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// // // //                       decoration: const InputDecoration(labelText: 'Address *', labelStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
// // // //                       validator: (v) => (v == null || v.trim().isEmpty) ? 'Address required.' : null,
// // // //                     ),
// // // //                   ],
// // // //                 ),
// // // //               ),
// // // //             ),
// // // //             actions: [
// // // //               TextButton(onPressed: isUpdating ? null : () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70))),
// // // //               ElevatedButton(
// // // //                 style: ElevatedButton.styleFrom(
// // // //                   backgroundColor: (nameError != null || phoneError != null) ? Colors.grey : const Color(0xFF38BDF8),
// // // //                 ),
// // // //                 onPressed: (isUpdating || nameError != null || phoneError != null)
// // // //                     ? null
// // // //                     : () async {
// // // //                         if (formKey.currentState!.validate()) {
// // // //                           setButtonLoading('edit_$customerId', true);
// // // //                           setDialogState(() {});

// // // //                           try {
// // // //                             final updatedName = nameController.text.trim();
// // // //                             await FirebaseFirestore.instance.collection('customers').doc(customerId).update({
// // // //                               'name': updatedName,
// // // //                               'phone': phoneController.text.trim(),
// // // //                               'address': addressController.text.trim(),
// // // //                             });

// // // //                             setButtonLoading('edit_$customerId', false);
// // // //                             if (ctx.mounted) Navigator.pop(ctx);
// // // //                             if (context.mounted) {
// // // //                               showTopNotification(context, 'Customer "$updatedName" updated successfully!');
// // // //                             }
// // // //                           } catch (e) {
// // // //                             setButtonLoading('edit_$customerId', false);
// // // //                             setDialogState(() {});
// // // //                             if (context.mounted) {
// // // //                               showTopNotification(context, 'Failed to update customer!', isError: true);
// // // //                             }
// // // //                           }
// // // //                         }
// // // //                       },
// // // //                 child: isUpdating
// // // //                     ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
// // // //                     : const Text('Update Ledger', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
// // // //               )
// // // //             ],
// // // //           );
// // // //         },
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ➕ ADD NEW CUSTOMER MODAL
// // // //   static void openAddNewCustomerModal({
// // // //     required BuildContext context,
// // // //     required String operatorUid,
// // // //     required Color textColor,
// // // //     required Color cardBgColor,
// // // //     required bool Function(String id) isButtonLoading,
// // // //     required Function(String id, bool loading) setButtonLoading,
// // // //   }) {
// // // //     final formModalKey = GlobalKey<FormState>();
// // // //     final nameController = TextEditingController();
// // // //     final phoneController = TextEditingController();
// // // //     final addressController = TextEditingController();

// // // //     String? liveNameError;
// // // //     String? livePhoneError;
// // // //     Timer? debounceTimer;

// // // //     showDialog(
// // // //       context: context,
// // // //       barrierDismissible: false,
// // // //       builder: (ctx) => StatefulBuilder(
// // // //         builder: (dialogCtx, setModalState) {
// // // //           bool isAdding = isButtonLoading('add_customer');

// // // //           void checkNameLive(String value) {
// // // //             if (debounceTimer?.isActive ?? false) debounceTimer!.cancel();
// // // //             debounceTimer = Timer(const Duration(milliseconds: 300), () async {
// // // //               final text = value.trim().toLowerCase();
// // // //               if (text.isEmpty) {
// // // //                 setModalState(() => liveNameError = null);
// // // //                 return;
// // // //               }

// // // //               final check = await FirebaseFirestore.instance
// // // //                   .collection('customers')
// // // //                   .where('operatorUid', isEqualTo: operatorUid)
// // // //                   .get();

// // // //               bool duplicate = check.docs.any((d) => (d.data()['name'] ?? '').toString().trim().toLowerCase() == text);

// // // //               setModalState(() {
// // // //                 liveNameError = duplicate ? 'Already Name Exists!' : null;
// // // //               });

// // // //               if (duplicate) {
// // // //                 showTopNotification(context, 'Customer "$value" already exists!', isError: true);
// // // //               }
// // // //             });
// // // //           }

// // // //           void checkPhoneLive(String value) {
// // // //             if (debounceTimer?.isActive ?? false) debounceTimer!.cancel();
// // // //             debounceTimer = Timer(const Duration(milliseconds: 300), () async {
// // // //               final text = value.trim();
// // // //               if (text.length != 10) {
// // // //                 setModalState(() => livePhoneError = null);
// // // //                 return;
// // // //               }

// // // //               final check = await FirebaseFirestore.instance
// // // //                   .collection('customers')
// // // //                   .where('operatorUid', isEqualTo: operatorUid)
// // // //                   .where('phone', isEqualTo: text)
// // // //                   .get();

// // // //               bool duplicate = check.docs.isNotEmpty;
// // // //               setModalState(() {
// // // //                 livePhoneError = duplicate ? 'Already Phone Number Exists!' : null;
// // // //               });

// // // //               if (duplicate) {
// // // //                 showTopNotification(context, 'Mobile number +91 $text already registered!', isError: true);
// // // //               }
// // // //             });
// // // //           }

// // // //           return AlertDialog(
// // // //             backgroundColor: cardBgColor,
// // // //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// // // //             title: Text('Add New Customer Account', style: TextStyle(fontWeight: FontWeight.w900, color: textColor, fontSize: 16)),
// // // //             content: Form(
// // // //               key: formModalKey,
// // // //               child: SingleChildScrollView(
// // // //                 child: Column(
// // // //                   mainAxisSize: MainAxisSize.min,
// // // //                   children: [
// // // //                     TextFormField(
// // // //                       controller: nameController,
// // // //                       enabled: !isAdding,
// // // //                       style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
// // // //                       decoration: InputDecoration(
// // // //                         labelText: 'Customer Full Name *',
// // // //                         labelStyle: TextStyle(fontSize: 12, color: textColor),
// // // //                         errorText: liveNameError,
// // // //                         errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
// // // //                       ),
// // // //                       onChanged: checkNameLive,
// // // //                       validator: (v) => (v == null || v.trim().isEmpty) ? 'Customer name mandatory.' : liveNameError,
// // // //                     ),
// // // //                     const SizedBox(height: 12),
// // // //                     TextFormField(
// // // //                       controller: phoneController,
// // // //                       enabled: !isAdding,
// // // //                       style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
// // // //                       keyboardType: TextInputType.phone,
// // // //                       maxLength: 10,
// // // //                       decoration: InputDecoration(
// // // //                         labelText: 'Mobile Number *',
// // // //                         prefixText: '+91 ',
// // // //                         counterText: '',
// // // //                         labelStyle: TextStyle(fontSize: 12, color: textColor),
// // // //                         errorText: livePhoneError,
// // // //                         errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
// // // //                       ),
// // // //                       onChanged: checkPhoneLive,
// // // //                       validator: (v) => (v == null || v.trim().length != 10) ? 'Enter 10-digit primary mobile.' : livePhoneError,
// // // //                     ),
// // // //                     const SizedBox(height: 12),
// // // //                     TextFormField(
// // // //                       controller: addressController,
// // // //                       enabled: !isAdding,
// // // //                       style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
// // // //                       decoration: InputDecoration(
// // // //                         labelText: 'Address / Location *',
// // // //                         labelStyle: TextStyle(fontSize: 12, color: textColor),
// // // //                       ),
// // // //                       validator: (v) => (v == null || v.trim().isEmpty) ? 'Location address mandatory.' : null,
// // // //                     ),
// // // //                   ],
// // // //                 ),
// // // //               ),
// // // //             ),
// // // //             actions: [
// // // //               TextButton(onPressed: isAdding ? null : () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(fontWeight: FontWeight.w900, color: textColor))),
// // // //               ElevatedButton(
// // // //                 style: ElevatedButton.styleFrom(
// // // //                   backgroundColor: (liveNameError != null || livePhoneError != null) ? Colors.grey : const Color(0xFF10B981),
// // // //                 ),
// // // //                 onPressed: (isAdding || liveNameError != null || livePhoneError != null)
// // // //                     ? null
// // // //                     : () async {
// // // //                         if (formModalKey.currentState!.validate()) {
// // // //                           setButtonLoading('add_customer', true);
// // // //                           setModalState(() {});

// // // //                           try {
// // // //                             final inputName = nameController.text.trim();
// // // //                             final inputPhone = phoneController.text.trim();

// // // //                             await FirebaseFirestore.instance.collection('customers').add({
// // // //                               'operatorUid': operatorUid,
// // // //                               'name': inputName,
// // // //                               'phone': inputPhone,
// // // //                               'address': addressController.text.trim(),
// // // //                               'balance': 0.0,
// // // //                               'isArchived': false,
// // // //                               'createdAt': FieldValue.serverTimestamp(),
// // // //                             });

// // // //                             setButtonLoading('add_customer', false);
// // // //                             if (ctx.mounted) Navigator.pop(ctx);
// // // //                             if (context.mounted) {
// // // //                               showTopNotification(context, 'New Customer "$inputName" added successfully!');
// // // //                             }
// // // //                           } catch (e) {
// // // //                             setButtonLoading('add_customer', false);
// // // //                             setModalState(() {});
// // // //                             if (context.mounted) {
// // // //                               showTopNotification(context, 'Failed to add customer!', isError: true);
// // // //                             }
// // // //                           }
// // // //                         }
// // // //                       },
// // // //                 child: isAdding
// // // //                     ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
// // // //                     : const Text('Save Customer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
// // // //               )
// // // //             ],
// // // //           );
// // // //         },
// // // //       ),
// // // //     );
// // // //   }

// // // //   // 📦 ADD PRODUCT / TRANSACTION HELPER FUNCTION
// // // //   static Future<void> addProductTransaction({
// // // //     required BuildContext context,
// // // //     required String customerId,
// // // //     required String customerName,
// // // //     required String operatorUid,
// // // //     required String productName,
// // // //     required int quantity,
// // // //     required double pricePerUnit,
// // // //     required String transactionType,
// // // //     String? note,
// // // //   }) async {
// // // //     try {
// // // //       final double totalAmount = quantity * pricePerUnit;

// // // //       await FirebaseFirestore.instance.collection('transactions').add({
// // // //         'customerId': customerId,
// // // //         'customerName': customerName,
// // // //         'operatorUid': operatorUid,
// // // //         'productName': productName,
// // // //         'quantity': quantity,
// // // //         'pricePerUnit': pricePerUnit,
// // // //         'totalPrice': totalAmount,
// // // //         'type': transactionType,
// // // //         'commitMessage': note ?? '',
// // // //         'timestamp': FieldValue.serverTimestamp(),
// // // //       });

// // // //       final double balanceAdjustment = transactionType == 'credit' ? totalAmount : -totalAmount;
// // // //       await FirebaseFirestore.instance.collection('customers').doc(customerId).update({
// // // //         'balance': FieldValue.increment(balanceAdjustment),
// // // //       });

// // // //       if (context.mounted) {
// // // //         showTopNotification(context, 'Added "$productName" (₹${totalAmount.toStringAsFixed(2)}) for $customerName');
// // // //       }
// // // //     } catch (e) {
// // // //       if (context.mounted) {
// // // //         showTopNotification(context, 'Failed to add transaction record!', isError: true);
// // // //       }
// // // //     }
// // // //   }
// // // // }

// // // // ignore_for_file: use_build_context_synchronously

// // // import 'dart:async';
// // // import 'dart:convert';
// // // import 'package:flutter/material.dart';
// // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // import 'package:url_launcher/url_launcher.dart';
// // // import 'package:http/http.dart' as http;

// // // class CustomerDialogs {
// // //   // 🌍 UNLIMITED REAL-TIME LOCATION SUGGESTIONS (USING OPENSTREETMAP API)
// // //   static Future<List<String>> fetchAddressSuggestions(String query) async {
// // //     if (query.trim().length < 2) return [];
    
// // //     final encodedQuery = Uri.encodeComponent(query.trim());
// // //     final url = Uri.parse(
// // //       'https://nominatim.openstreetmap.org/search?q=$encodedQuery&format=json&addressdetails=1&limit=8',
// // //     );

// // //     try {
// // //       final response = await http.get(
// // //         url,
// // //         headers: {'User-Agent': 'FlutterCustomerApp/1.0'},
// // //       );

// // //       if (response.statusCode == 200) {
// // //         final List data = json.decode(response.body);
// // //         return data.map<String>((item) => item['display_name'].toString()).toList();
// // //       }
// // //     } catch (_) {
// // //       // Return empty list on network error
// // //     }
// // //     return [];
// // //   }

// // //   // 🗺️ GOOGLE MAPS LAUNCHER HELPER
// // //   static Future<void> openGoogleMaps(BuildContext context, String address) async {
// // //     final cleanAddress = address.trim();
// // //     if (cleanAddress.isEmpty) {
// // //       showTopNotification(context, 'Please enter a valid address or location first!', isError: true);
// // //       return;
// // //     }

// // //     final Uri googleMapsUrl = Uri.parse(
// // //       'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(cleanAddress)}',
// // //     );

// // //     try {
// // //       if (await canLaunchUrl(googleMapsUrl)) {
// // //         await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
// // //       } else {
// // //         if (context.mounted) {
// // //           showTopNotification(context, 'Unable to open Google Maps app!', isError: true);
// // //         }
// // //       }
// // //     } catch (e) {
// // //       if (context.mounted) {
// // //         showTopNotification(context, 'Could not launch Google Maps navigation', isError: true);
// // //       }
// // //     }
// // //   }

// // //   // 🪟 SMALL MAP LOCATION PREVIEW WINDOW WITH CANCEL BUTTON
// // //   static void showLocationMapPreviewDialog(BuildContext context, String customerName, String address) {
// // //     showDialog(
// // //       context: context,
// // //       builder: (ctx) => Dialog(
// // //         backgroundColor: Colors.transparent,
// // //         child: Container(
// // //           width: 420,
// // //           padding: const EdgeInsets.all(20),
// // //           decoration: BoxDecoration(
// // //             color: const Color(0xFF0F172A),
// // //             borderRadius: BorderRadius.circular(20),
// // //             border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
// // //             boxShadow: [
// // //               BoxShadow(
// // //                 color: Colors.black.withOpacity(0.5),
// // //                 blurRadius: 20,
// // //                 offset: const Offset(0, 10),
// // //               )
// // //             ],
// // //           ),
// // //           child: Column(
// // //             mainAxisSize: MainAxisSize.min,
// // //             crossAxisAlignment: CrossAxisAlignment.start,
// // //             children: [
// // //               // 🔝 HEADER WITH CANCEL BUTTON
// // //               Row(
// // //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                 children: [
// // //                   Row(
// // //                     children: [
// // //                       const Icon(Icons.location_on_rounded, color: Color(0xFF10B981), size: 24),
// // //                       const SizedBox(width: 8),
// // //                       Text(
// // //                         '$customerName\'s Location',
// // //                         style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                   // ❌ CANCEL / CLOSE ICON BUTTON
// // //                   IconButton(
// // //                     icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
// // //                     padding: EdgeInsets.zero,
// // //                     constraints: const BoxConstraints(),
// // //                     tooltip: 'Cancel',
// // //                     onPressed: () => Navigator.pop(ctx),
// // //                   ),
// // //                 ],
// // //               ),
// // //               const Divider(color: Colors.white12, height: 24),

// // //               const Text(
// // //                 'STORED PHYSICAL ADDRESS:',
// // //                 style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
// // //               ),
// // //               const SizedBox(height: 8),

// // //               Container(
// // //                 width: double.infinity,
// // //                 padding: const EdgeInsets.all(14),
// // //                 decoration: BoxDecoration(
// // //                   color: const Color(0xFF1E293B),
// // //                   borderRadius: BorderRadius.circular(12),
// // //                   border: Border.all(color: const Color(0xFF334155)),
// // //                 ),
// // //                 child: Row(
// // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // //                   children: [
// // //                     const Icon(Icons.map_outlined, color: Color(0xFF38BDF8), size: 18),
// // //                     const SizedBox(width: 10),
// // //                     Expanded(
// // //                       child: Text(
// // //                         address.isNotEmpty ? address : 'No specific address recorded.',
// // //                         style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ),
// // //               const SizedBox(height: 20),

// // //               // 🗺️ ACTION BUTTONS
// // //               Row(
// // //                 mainAxisAlignment: MainAxisAlignment.end,
// // //                 children: [
// // //                   TextButton(
// // //                     onPressed: () => Navigator.pop(ctx),
// // //                     child: const Text('Cancel', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
// // //                   ),
// // //                   const SizedBox(width: 8),
// // //                   ElevatedButton.icon(
// // //                     style: ElevatedButton.styleFrom(
// // //                       backgroundColor: const Color(0xFF10B981),
// // //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// // //                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// // //                     ),
// // //                     onPressed: () {
// // //                       Navigator.pop(ctx);
// // //                       openGoogleMaps(context, address);
// // //                     },
// // //                     icon: const Icon(Icons.directions_rounded, color: Colors.white, size: 18),
// // //                     label: const Text('Open Maps', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
// // //                   ),
// // //                 ],
// // //               )
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // 🔔 GUARANTEED TOP OVERLAY NOTIFICATION
// // //   static void showTopNotification(BuildContext context, String message, {bool isError = false}) {
// // //     final overlay = Overlay.maybeOf(context);
// // //     if (overlay == null) return;

// // //     final overlayEntry = OverlayEntry(
// // //       builder: (context) => Positioned(
// // //         top: MediaQuery.of(context).padding.top + 10,
// // //         left: 16,
// // //         right: 16,
// // //         child: Material(
// // //           color: Colors.transparent,
// // //           child: AnimatedContainer(
// // //             duration: const Duration(milliseconds: 300),
// // //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// // //             decoration: BoxDecoration(
// // //               color: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
// // //               borderRadius: BorderRadius.circular(12),
// // //               boxShadow: [
// // //                 BoxShadow(
// // //                   color: Colors.black.withOpacity(0.3),
// // //                   blurRadius: 10,
// // //                   offset: const Offset(0, 4),
// // //                 )
// // //               ],
// // //             ),
// // //             child: Row(
// // //               children: [
// // //                 Icon(
// // //                   isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
// // //                   color: Colors.white,
// // //                   size: 22,
// // //                 ),
// // //                 const SizedBox(width: 12),
// // //                 Expanded(
// // //                   child: Text(
// // //                     message,
// // //                     style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );

// // //     overlay.insert(overlayEntry);
// // //     Future.delayed(const Duration(milliseconds: 2200), () {
// // //       overlayEntry.remove();
// // //     });
// // //   }

// // //   // 🚨 SECURE DELETE DIALOG WITH PROPER SPINNER
// // //   static Future<bool> openSecureDeleteDialog({
// // //     required BuildContext context,
// // //     required String customerId,
// // //     required String customerName,
// // //     required bool Function(String id) isButtonLoading,
// // //     required Function(String id, bool loading) setButtonLoading,
// // //     bool isPermanent = false,
// // //   }) async {
// // //     final verifyController = TextEditingController();
// // //     final formKey = GlobalKey<FormState>();

// // //     bool? result = await showDialog<bool>(
// // //       context: context,
// // //       barrierDismissible: false,
// // //       builder: (ctx) => StatefulBuilder(
// // //         builder: (context, setDialogState) {
// // //           bool isDeleting = isButtonLoading(isPermanent ? 'perm_$customerId' : 'del_$customerId');

// // //           return AlertDialog(
// // //             backgroundColor: const Color(0xFF0F172A),
// // //             shape: RoundedRectangleBorder(
// // //               borderRadius: BorderRadius.circular(18),
// // //               side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
// // //             ),
// // //             title: Row(
// // //               children: [
// // //                 const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 28),
// // //                 const SizedBox(width: 10),
// // //                 Text(
// // //                   isPermanent ? 'Permanent Purge' : 'Move to Recycle Bin',
// // //                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
// // //                 ),
// // //               ],
// // //             ),
// // //             content: Form(
// // //               key: formKey,
// // //               child: Column(
// // //                 mainAxisSize: MainAxisSize.min,
// // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // //                 children: [
// // //                   Text(
// // //                     isPermanent
// // //                         ? 'Type the required customer name below to permanently erase all records:'
// // //                         : 'Type the customer name below to move account & transactions to history bin:',
// // //                     style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.4),
// // //                   ),
// // //                   const SizedBox(height: 12),
// // //                   Container(
// // //                     width: double.infinity,
// // //                     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
// // //                     decoration: BoxDecoration(
// // //                       color: const Color(0xFF1E293B),
// // //                       borderRadius: BorderRadius.circular(10),
// // //                       border: Border.all(color: const Color(0xFF334155)),
// // //                     ),
// // //                     child: Row(
// // //                       children: [
// // //                         const Icon(Icons.person_outline_rounded, size: 16, color: Color(0xFF38BDF8)),
// // //                         const SizedBox(width: 8),
// // //                         Expanded(
// // //                           child: Text(
// // //                             customerName,
// // //                             style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
// // //                           ),
// // //                         ),
// // //                       ],
// // //                     ),
// // //                   ),
// // //                   const SizedBox(height: 14),
// // //                   TextFormField(
// // //                     controller: verifyController,
// // //                     enabled: !isDeleting,
// // //                     style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// // //                     decoration: InputDecoration(
// // //                       hintText: customerName,
// // //                       hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
// // //                       filled: true,
// // //                       fillColor: const Color(0xFF070A0F),
// // //                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
// // //                       focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEF4444))),
// // //                     ),
// // //                     validator: (val) {
// // //                       if (val == null || val.trim().toLowerCase() != customerName.trim().toLowerCase()) {
// // //                         return 'Customer name does not match!';
// // //                       }
// // //                       return null;
// // //                     },
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //             actions: [
// // //               TextButton(
// // //                 onPressed: isDeleting ? null : () => Navigator.pop(ctx, false),
// // //                 child: const Text('Cancel', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
// // //               ),
// // //               ElevatedButton(
// // //                 style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
// // //                 onPressed: isDeleting
// // //                     ? null
// // //                     : () {
// // //                         if (formKey.currentState!.validate()) {
// // //                           Navigator.pop(ctx, true);
// // //                         }
// // //                       },
// // //                 child: isDeleting
// // //                     ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
// // //                     : Text(isPermanent ? 'Purge Forever' : 'Confirm Action', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
// // //               ),
// // //             ],
// // //           );
// // //         },
// // //       ),
// // //     );

// // //     return result ?? false;
// // //   }

// // //   // 🎯 CUSTOM FILTER MODAL
// // //   static void openCustomFilterModal({
// // //     required BuildContext context,
// // //     required double? customMinFilter,
// // //     required Function(String filter, double? minVal) onFilterApplied,
// // //   }) {
// // //     final customValController = TextEditingController(text: customMinFilter != null ? customMinFilter.toStringAsFixed(0) : '');

// // //     showDialog(
// // //       context: context,
// // //       builder: (ctx) => AlertDialog(
// // //         backgroundColor: const Color(0xFF0F172A),
// // //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF38BDF8))),
// // //         title: const Text('Customize Credit Limit Filter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
// // //         content: Column(
// // //           mainAxisSize: MainAxisSize.min,
// // //           children: [
// // //             const Text('Enter minimum balance amount threshold (₹):', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
// // //             const SizedBox(height: 12),
// // //             TextField(
// // //               controller: customValController,
// // //               keyboardType: TextInputType.number,
// // //               style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// // //               decoration: InputDecoration(
// // //                 prefixText: '₹ ',
// // //                 prefixStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// // //                 hintText: 'e.g. 2500',
// // //                 filled: true,
// // //                 fillColor: const Color(0xFF070A0F),
// // //                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //         actions: [
// // //           TextButton(
// // //             onPressed: () {
// // //               onFilterApplied('all', null);
// // //               Navigator.pop(ctx);
// // //             },
// // //             child: const Text('Reset All', style: TextStyle(color: Colors.redAccent)),
// // //           ),
// // //           ElevatedButton(
// // //             style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8)),
// // //             onPressed: () {
// // //               final parsed = double.tryParse(customValController.text.trim());
// // //               if (parsed != null) {
// // //                 onFilterApplied('custom', parsed);
// // //                 Navigator.pop(ctx);
// // //                 showTopNotification(context, 'Applied custom filter: ₹${parsed.toStringAsFixed(0)}+');
// // //               }
// // //             },
// // //             child: const Text('Apply Filter', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
// // //           )
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   // ✏️ EDIT CUSTOMER MODAL
// // //   static void openEditCustomerModal({
// // //     required BuildContext context,
// // //     required String customerId,
// // //     required Map<String, dynamic> currentData,
// // //     required bool Function(String id) isButtonLoading,
// // //     required Function(String id, bool loading) setButtonLoading,
// // //   }) {
// // //     final formKey = GlobalKey<FormState>();
// // //     final nameController = TextEditingController(text: currentData['name'] ?? '');
// // //     final phoneController = TextEditingController(text: currentData['phone'] ?? '');
// // //     final addressController = TextEditingController(text: currentData['address'] ?? '');
// // //     final operatorUid = currentData['operatorUid'] ?? '';

// // //     String? nameError;
// // //     String? phoneError;
// // //     Timer? debounce;

// // //     List<String> apiSuggestions = [];
// // //     bool isFetchingApi = false;

// // //     showDialog(
// // //       context: context,
// // //       barrierDismissible: false,
// // //       builder: (ctx) => StatefulBuilder(
// // //         builder: (dialogCtx, setDialogState) {
// // //           bool isUpdating = isButtonLoading('edit_$customerId');

// // //           void checkLiveName(String val) {
// // //             if (debounce?.isActive ?? false) debounce!.cancel();
// // //             debounce = Timer(const Duration(milliseconds: 300), () async {
// // //               final text = val.trim().toLowerCase();
// // //               if (text.isEmpty) {
// // //                 setDialogState(() => nameError = null);
// // //                 return;
// // //               }
// // //               final query = await FirebaseFirestore.instance
// // //                   .collection('customers')
// // //                   .where('operatorUid', isEqualTo: operatorUid)
// // //                   .get();

// // //               bool duplicate = query.docs.any((d) => d.id != customerId && (d.data()['name'] ?? '').toString().trim().toLowerCase() == text);
// // //               setDialogState(() {
// // //                 nameError = duplicate ? 'Already Name Exists!' : null;
// // //               });
// // //               if (duplicate) {
// // //                 showTopNotification(context, 'Customer "$val" already exists!', isError: true);
// // //               }
// // //             });
// // //           }

// // //           void checkLivePhone(String val) {
// // //             if (debounce?.isActive ?? false) debounce!.cancel();
// // //             debounce = Timer(const Duration(milliseconds: 300), () async {
// // //               final text = val.trim();
// // //               if (text.length != 10) {
// // //                 setDialogState(() => phoneError = null);
// // //                 return;
// // //               }
// // //               final query = await FirebaseFirestore.instance
// // //                   .collection('customers')
// // //                   .where('operatorUid', isEqualTo: operatorUid)
// // //                   .where('phone', isEqualTo: text)
// // //                   .get();

// // //               bool duplicate = query.docs.any((d) => d.id != customerId);
// // //               setDialogState(() {
// // //                 phoneError = duplicate ? 'Already Phone Number Exists!' : null;
// // //               });
// // //               if (duplicate) {
// // //                 showTopNotification(context, 'Mobile number +91 $text already registered!', isError: true);
// // //               }
// // //             });
// // //           }

// // //           void onAddressInputChanged(String val) {
// // //             if (debounce?.isActive ?? false) debounce!.cancel();
// // //             if (val.trim().length < 2) {
// // //               setDialogState(() {
// // //                 apiSuggestions = [];
// // //                 isFetchingApi = false;
// // //               });
// // //               return;
// // //             }

// // //             setDialogState(() => isFetchingApi = true);
// // //             debounce = Timer(const Duration(milliseconds: 400), () async {
// // //               final results = await fetchAddressSuggestions(val);
// // //               setDialogState(() {
// // //                 apiSuggestions = results;
// // //                 isFetchingApi = false;
// // //               });
// // //             });
// // //           }

// // //           return AlertDialog(
// // //             backgroundColor: const Color(0xFF0F172A),
// // //             shape: RoundedRectangleBorder(
// // //               borderRadius: BorderRadius.circular(16),
// // //               side: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
// // //             ),
// // //             title: Row(
// // //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //               children: [
// // //                 const Text('Edit Customer Details', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 16)),
// // //                 IconButton(
// // //                   icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
// // //                   padding: EdgeInsets.zero,
// // //                   constraints: const BoxConstraints(),
// // //                   tooltip: 'Cancel',
// // //                   onPressed: () => Navigator.pop(ctx),
// // //                 ),
// // //               ],
// // //             ),
// // //             content: Form(
// // //               key: formKey,
// // //               child: SingleChildScrollView(
// // //                 child: Column(
// // //                   mainAxisSize: MainAxisSize.min,
// // //                   children: [
// // //                     TextFormField(
// // //                       controller: nameController,
// // //                       enabled: !isUpdating,
// // //                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// // //                       decoration: InputDecoration(
// // //                         labelText: 'Customer Full Name *',
// // //                         labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
// // //                         errorText: nameError,
// // //                         errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
// // //                       ),
// // //                       onChanged: checkLiveName,
// // //                       validator: (v) => (v == null || v.trim().isEmpty) ? 'Name required.' : nameError,
// // //                     ),
// // //                     const SizedBox(height: 12),
// // //                     TextFormField(
// // //                       controller: phoneController,
// // //                       enabled: !isUpdating,
// // //                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// // //                       keyboardType: TextInputType.phone,
// // //                       maxLength: 10,
// // //                       decoration: InputDecoration(
// // //                         labelText: 'Mobile Number *',
// // //                         prefixText: '+91 ',
// // //                         counterText: '',
// // //                         labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
// // //                         errorText: phoneError,
// // //                         errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
// // //                       ),
// // //                       onChanged: checkLivePhone,
// // //                       validator: (v) => (v == null || v.trim().length != 10) ? 'Enter valid 10-digit number.' : phoneError,
// // //                     ),
// // //                     const SizedBox(height: 12),

// // //                     TextFormField(
// // //                       controller: addressController,
// // //                       enabled: !isUpdating,
// // //                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// // //                       decoration: InputDecoration(
// // //                         labelText: 'Address / Location *',
// // //                         labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
// // //                         prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF38BDF8), size: 20),
// // //                         suffixIcon: isFetchingApi
// // //                             ? const Padding(
// // //                                 padding: EdgeInsets.all(8.0),
// // //                                 child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Color(0xFF38BDF8), strokeWidth: 2)),
// // //                               )
// // //                             : null,
// // //                       ),
// // //                       onChanged: onAddressInputChanged,
// // //                       validator: (v) => (v == null || v.trim().isEmpty) ? 'Address required.' : null,
// // //                     ),

// // //                     if (apiSuggestions.isNotEmpty)
// // //                       Container(
// // //                         constraints: const BoxConstraints(maxHeight: 160),
// // //                         margin: const EdgeInsets.only(top: 6),
// // //                         decoration: BoxDecoration(
// // //                           color: const Color(0xFF1E293B),
// // //                           borderRadius: BorderRadius.circular(10),
// // //                           border: Border.all(color: const Color(0xFF38BDF8)),
// // //                         ),
// // //                         child: ListView.separated(
// // //                           shrinkWrap: true,
// // //                           itemCount: apiSuggestions.length,
// // //                           separatorBuilder: (ctx, i) => const Divider(color: Colors.white12, height: 1),
// // //                           itemBuilder: (context, index) {
// // //                             final sug = apiSuggestions[index];
// // //                             return ListTile(
// // //                               dense: true,
// // //                               contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
// // //                               leading: const Icon(Icons.pin_drop_rounded, color: Color(0xFF10B981), size: 16),
// // //                               title: Text(
// // //                                 sug,
// // //                                 style: const TextStyle(color: Colors.white, fontSize: 12),
// // //                                 maxLines: 2,
// // //                                 overflow: TextOverflow.ellipsis,
// // //                               ),
// // //                               onTap: () {
// // //                                 addressController.text = sug;
// // //                                 setDialogState(() => apiSuggestions = []);
// // //                               },
// // //                             );
// // //                           },
// // //                         ),
// // //                       ),
// // //                   ],
// // //                 ),
// // //               ),
// // //             ),
// // //             actions: [
// // //               TextButton(onPressed: isUpdating ? null : () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70))),
// // //               ElevatedButton(
// // //                 style: ElevatedButton.styleFrom(
// // //                   backgroundColor: (nameError != null || phoneError != null) ? Colors.grey : const Color(0xFF38BDF8),
// // //                 ),
// // //                 onPressed: (isUpdating || nameError != null || phoneError != null)
// // //                     ? null
// // //                     : () async {
// // //                         if (formKey.currentState!.validate()) {
// // //                           setButtonLoading('edit_$customerId', true);
// // //                           setDialogState(() {});

// // //                           try {
// // //                             final updatedName = nameController.text.trim();
// // //                             await FirebaseFirestore.instance.collection('customers').doc(customerId).update({
// // //                               'name': updatedName,
// // //                               'phone': phoneController.text.trim(),
// // //                               'address': addressController.text.trim(),
// // //                             });

// // //                             setButtonLoading('edit_$customerId', false);
// // //                             if (ctx.mounted) Navigator.pop(ctx);
// // //                             if (context.mounted) {
// // //                               showTopNotification(context, 'Customer "$updatedName" updated successfully!');
// // //                             }
// // //                           } catch (e) {
// // //                             setButtonLoading('edit_$customerId', false);
// // //                             setDialogState(() {});
// // //                             if (context.mounted) {
// // //                               showTopNotification(context, 'Failed to update customer!', isError: true);
// // //                             }
// // //                           }
// // //                         }
// // //                       },
// // //                 child: isUpdating
// // //                     ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
// // //                     : const Text('Update Ledger', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
// // //               )
// // //             ],
// // //           );
// // //         },
// // //       ),
// // //     );
// // //   }

// // //   // ➕ ADD NEW CUSTOMER MODAL
// // //   static void openAddNewCustomerModal({
// // //     required BuildContext context,
// // //     required String operatorUid,
// // //     required Color textColor,
// // //     required Color cardBgColor,
// // //     required bool Function(String id) isButtonLoading,
// // //     required Function(String id, bool loading) setButtonLoading,
// // //   }) {
// // //     final formModalKey = GlobalKey<FormState>();
// // //     final nameController = TextEditingController();
// // //     final phoneController = TextEditingController();
// // //     final addressController = TextEditingController();

// // //     String? liveNameError;
// // //     String? livePhoneError;
// // //     Timer? debounceTimer;

// // //     List<String> apiSuggestions = [];
// // //     bool isFetchingApi = false;

// // //     showDialog(
// // //       context: context,
// // //       barrierDismissible: false,
// // //       builder: (ctx) => StatefulBuilder(
// // //         builder: (dialogCtx, setModalState) {
// // //           bool isAdding = isButtonLoading('add_customer');

// // //           void checkNameLive(String value) {
// // //             if (debounceTimer?.isActive ?? false) debounceTimer!.cancel();
// // //             debounceTimer = Timer(const Duration(milliseconds: 300), () async {
// // //               final text = value.trim().toLowerCase();
// // //               if (text.isEmpty) {
// // //                 setModalState(() => liveNameError = null);
// // //                 return;
// // //               }

// // //               final check = await FirebaseFirestore.instance
// // //                   .collection('customers')
// // //                   .where('operatorUid', isEqualTo: operatorUid)
// // //                   .get();

// // //               bool duplicate = check.docs.any((d) => (d.data()['name'] ?? '').toString().trim().toLowerCase() == text);

// // //               setModalState(() {
// // //                 liveNameError = duplicate ? 'Already Name Exists!' : null;
// // //               });

// // //               if (duplicate) {
// // //                 showTopNotification(context, 'Customer "$value" already exists!', isError: true);
// // //               }
// // //             });
// // //           }

// // //           void checkPhoneLive(String value) {
// // //             if (debounceTimer?.isActive ?? false) debounceTimer!.cancel();
// // //             debounceTimer = Timer(const Duration(milliseconds: 300), () async {
// // //               final text = value.trim();
// // //               if (text.length != 10) {
// // //                 setModalState(() => livePhoneError = null);
// // //                 return;
// // //               }

// // //               final check = await FirebaseFirestore.instance
// // //                   .collection('customers')
// // //                   .where('operatorUid', isEqualTo: operatorUid)
// // //                   .where('phone', isEqualTo: text)
// // //                   .get();

// // //               bool duplicate = check.docs.isNotEmpty;
// // //               setModalState(() {
// // //                 livePhoneError = duplicate ? 'Already Phone Number Exists!' : null;
// // //               });

// // //               if (duplicate) {
// // //                 showTopNotification(context, 'Mobile number +91 $text already registered!', isError: true);
// // //               }
// // //             });
// // //           }

// // //           void onAddressInputChanged(String val) {
// // //             if (debounceTimer?.isActive ?? false) debounceTimer!.cancel();
// // //             if (val.trim().length < 2) {
// // //               setModalState(() {
// // //                 apiSuggestions = [];
// // //                 isFetchingApi = false;
// // //               });
// // //               return;
// // //             }

// // //             setModalState(() => isFetchingApi = true);
// // //             debounceTimer = Timer(const Duration(milliseconds: 400), () async {
// // //               final results = await fetchAddressSuggestions(val);
// // //               setModalState(() {
// // //                 apiSuggestions = results;
// // //                 isFetchingApi = false;
// // //               });
// // //             });
// // //           }

// // //           return AlertDialog(
// // //             backgroundColor: cardBgColor,
// // //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// // //             title: Row(
// // //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //               children: [
// // //                 Text('Add Customer', style: TextStyle(fontWeight: FontWeight.w900, color: textColor, fontSize: 16)),
// // //                 IconButton(
// // //                   icon: Icon(Icons.close_rounded, color: textColor.withOpacity(0.7), size: 22),
// // //                   padding: EdgeInsets.zero,
// // //                   constraints: const BoxConstraints(),
// // //                   tooltip: 'Cancel',
// // //                   onPressed: () => Navigator.pop(ctx),
// // //                 ),
// // //               ],
// // //             ),
// // //             content: Form(
// // //               key: formModalKey,
// // //               child: SingleChildScrollView(
// // //                 child: Column(
// // //                   mainAxisSize: MainAxisSize.min,
// // //                   children: [
// // //                     TextFormField(
// // //                       controller: nameController,
// // //                       enabled: !isAdding,
// // //                       style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
// // //                       decoration: InputDecoration(
// // //                         labelText: 'Customer Full Name *',
// // //                         labelStyle: TextStyle(fontSize: 12, color: textColor),
// // //                         errorText: liveNameError,
// // //                         errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
// // //                       ),
// // //                       onChanged: checkNameLive,
// // //                       validator: (v) => (v == null || v.trim().isEmpty) ? 'Customer name mandatory.' : liveNameError,
// // //                     ),
// // //                     const SizedBox(height: 12),
// // //                     TextFormField(
// // //                       controller: phoneController,
// // //                       enabled: !isAdding,
// // //                       style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
// // //                       keyboardType: TextInputType.phone,
// // //                       maxLength: 10,
// // //                       decoration: InputDecoration(
// // //                         labelText: 'Mobile Number *',
// // //                         prefixText: '+91 ',
// // //                         counterText: '',
// // //                         labelStyle: TextStyle(fontSize: 12, color: textColor),
// // //                         errorText: livePhoneError,
// // //                         errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
// // //                       ),
// // //                       onChanged: checkPhoneLive,
// // //                       validator: (v) => (v == null || v.trim().length != 10) ? 'Enter 10-digit primary mobile.' : livePhoneError,
// // //                     ),
// // //                     const SizedBox(height: 12),

// // //                     TextFormField(
// // //                       controller: addressController,
// // //                       enabled: !isAdding,
// // //                       style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
// // //                       decoration: InputDecoration(
// // //                         labelText: 'Address / Location *',
// // //                         labelStyle: TextStyle(fontSize: 12, color: textColor),
// // //                         prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF38BDF8), size: 20),
// // //                         suffixIcon: isFetchingApi
// // //                             ? const Padding(
// // //                                 padding: EdgeInsets.all(8.0),
// // //                                 child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Color(0xFF38BDF8), strokeWidth: 2)),
// // //                               )
// // //                             : null,
// // //                       ),
// // //                       onChanged: onAddressInputChanged,
// // //                       validator: (v) => (v == null || v.trim().isEmpty) ? 'Location address mandatory.' : null,
// // //                     ),

// // //                     if (apiSuggestions.isNotEmpty)
// // //                       Container(
// // //                         constraints: const BoxConstraints(maxHeight: 160),
// // //                         margin: const EdgeInsets.only(top: 6),
// // //                         decoration: BoxDecoration(
// // //                           color: const Color(0xFF1E293B),
// // //                           borderRadius: BorderRadius.circular(10),
// // //                           border: Border.all(color: const Color(0xFF38BDF8)),
// // //                         ),
// // //                         child: ListView.separated(
// // //                           shrinkWrap: true,
// // //                           itemCount: apiSuggestions.length,
// // //                           separatorBuilder: (ctx, i) => const Divider(color: Colors.white12, height: 1),
// // //                           itemBuilder: (context, index) {
// // //                             final sug = apiSuggestions[index];
// // //                             return ListTile(
// // //                               dense: true,
// // //                               contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
// // //                               leading: const Icon(Icons.pin_drop_rounded, color: Color(0xFF10B981), size: 16),
// // //                               title: Text(
// // //                                 sug,
// // //                                 style: const TextStyle(color: Colors.white, fontSize: 12),
// // //                                 maxLines: 2,
// // //                                 overflow: TextOverflow.ellipsis,
// // //                               ),
// // //                               onTap: () {
// // //                                 addressController.text = sug;
// // //                                 setModalState(() => apiSuggestions = []);
// // //                               },
// // //                             );
// // //                           },
// // //                         ),
// // //                       ),
// // //                   ],
// // //                 ),
// // //               ),
// // //             ),
// // //             actions: [
// // //               TextButton(onPressed: isAdding ? null : () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(fontWeight: FontWeight.w900, color: textColor))),
// // //               ElevatedButton(
// // //                 style: ElevatedButton.styleFrom(
// // //                   backgroundColor: (liveNameError != null || livePhoneError != null) ? Colors.grey : const Color(0xFF10B981),
// // //                 ),
// // //                 onPressed: (isAdding || liveNameError != null || livePhoneError != null)
// // //                     ? null
// // //                     : () async {
// // //                         if (formModalKey.currentState!.validate()) {
// // //                           setButtonLoading('add_customer', true);
// // //                           setModalState(() {});

// // //                           try {
// // //                             final inputName = nameController.text.trim();
// // //                             final inputPhone = phoneController.text.trim();

// // //                             await FirebaseFirestore.instance.collection('customers').add({
// // //                               'operatorUid': operatorUid,
// // //                               'name': inputName,
// // //                               'phone': inputPhone,
// // //                               'address': addressController.text.trim(),
// // //                               'balance': 0.0,
// // //                               'isArchived': false,
// // //                               'createdAt': FieldValue.serverTimestamp(),
// // //                             });

// // //                             setButtonLoading('add_customer', false);
// // //                             if (ctx.mounted) Navigator.pop(ctx);
// // //                             if (context.mounted) {
// // //                               showTopNotification(context, 'New Customer "$inputName" added successfully!');
// // //                             }
// // //                           } catch (e) {
// // //                             setButtonLoading('add_customer', false);
// // //                             setModalState(() {});
// // //                             if (context.mounted) {
// // //                               showTopNotification(context, 'Failed to add customer!', isError: true);
// // //                             }
// // //                           }
// // //                         }
// // //                       },
// // //                 child: isAdding
// // //                     ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
// // //                     : const Text('Save Customer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
// // //               )
// // //             ],
// // //           );
// // //         },
// // //       ),
// // //     );
// // //   }

// // //   // 📦 ADD PRODUCT / TRANSACTION HELPER FUNCTION
// // //   static Future<void> addProductTransaction({
// // //     required BuildContext context,
// // //     required String customerId,
// // //     required String customerName,
// // //     required String operatorUid,
// // //     required String productName,
// // //     required int quantity,
// // //     required double pricePerUnit,
// // //     required String transactionType,
// // //     String? note,
// // //   }) async {
// // //     try {
// // //       final double totalAmount = quantity * pricePerUnit;

// // //       await FirebaseFirestore.instance.collection('transactions').add({
// // //         'customerId': customerId,
// // //         'customerName': customerName,
// // //         'operatorUid': operatorUid,
// // //         'productName': productName,
// // //         'quantity': quantity,
// // //         'pricePerUnit': pricePerUnit,
// // //         'totalPrice': totalAmount,
// // //         'type': transactionType,
// // //         'commitMessage': note ?? '',
// // //         'timestamp': FieldValue.serverTimestamp(),
// // //       });

// // //       final double balanceAdjustment = transactionType == 'credit' ? totalAmount : -totalAmount;
// // //       await FirebaseFirestore.instance.collection('customers').doc(customerId).update({
// // //         'balance': FieldValue.increment(balanceAdjustment),
// // //       });

// // //       if (context.mounted) {
// // //         showTopNotification(context, 'Added "$productName" (₹${totalAmount.toStringAsFixed(2)}) for $customerName');
// // //       }
// // //     } catch (e) {
// // //       if (context.mounted) {
// // //         showTopNotification(context, 'Failed to add transaction record!', isError: true);
// // //       }
// // //     }
// // //   }
// // // }

// // // /// 📱 CUSTOMER CARD WIDGET (Main Screen Card Row with Map, Edit, Archive, and Delete Icons)
// // // class CustomerCardWidget extends StatelessWidget {
// // //   final String customerId;
// // //   final Map<String, dynamic> customerData;
// // //   final VoidCallback onWhatsApp;
// // //   final VoidCallback onEdit;
// // //   final VoidCallback onArchive;
// // //   final VoidCallback onDelete;

// // //   const CustomerCardWidget({
// // //     super.key,
// // //     required this.customerId,
// // //     required this.customerData,
// // //     required this.onWhatsApp,
// // //     required this.onEdit,
// // //     required this.onArchive,
// // //     required this.onDelete,
// // //   });

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final String name = customerData['name'] ?? 'Unknown Customer';
// // //     final String phone = customerData['phone'] ?? '';
// // //     final String address = customerData['address'] ?? '';
// // //     final double balance = (customerData['balance'] ?? 0.0).toDouble();

// // //     return Container(
// // //       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
// // //       padding: const EdgeInsets.all(16),
// // //       decoration: BoxDecoration(
// // //         color: const Color(0xFF0F172A),
// // //         borderRadius: BorderRadius.circular(16),
// // //         border: Border.all(color: const Color(0xFF1E293B)),
// // //       ),
// // //       child: Column(
// // //         crossAxisAlignment: CrossAxisAlignment.start,
// // //         children: [
// // //           Row(
// // //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //             crossAxisAlignment: CrossAxisAlignment.center,
// // //             children: [
// // //               // Customer Details
// // //               Expanded(
// // //                 child: Column(
// // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // //                   children: [
// // //                     Text(
// // //                       name,
// // //                       style: const TextStyle(
// // //                         color: Colors.white,
// // //                         fontWeight: FontWeight.bold,
// // //                         fontSize: 16,
// // //                       ),
// // //                     ),
// // //                     const SizedBox(height: 2),
// // //                     Text(
// // //                       '+91 $phone',
// // //                       style: const TextStyle(
// // //                         color: Color(0xFF94A3B8),
// // //                         fontSize: 13,
// // //                         fontWeight: FontWeight.w600,
// // //                       ),
// // //                     ),
// // //                     if (address.isNotEmpty) ...[
// // //                       const SizedBox(height: 2),
// // //                       Text(
// // //                         address,
// // //                         style: const TextStyle(
// // //                           color: Color(0xFF64748B),
// // //                           fontSize: 12,
// // //                         ),
// // //                         maxLines: 1,
// // //                         overflow: TextOverflow.ellipsis,
// // //                       ),
// // //                     ]
// // //                   ],
// // //                 ),
// // //               ),

// // //               // 🎯 Balance Amount & Action Icons Row
// // //               Row(
// // //                 mainAxisSize: MainAxisSize.min,
// // //                 children: [
// // //                   Text(
// // //                     '${balance >= 0 ? '+' : ''}₹${balance.abs().toStringAsFixed(2)}',
// // //                     style: TextStyle(
// // //                       color: balance >= 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
// // //                       fontWeight: FontWeight.bold,
// // //                       fontSize: 14,
// // //                     ),
// // //                   ),
// // //                   const SizedBox(width: 8),

// // //                   // 1. WhatsApp Icon (Green)
// // //                   IconButton(
// // //                     icon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF10B981), size: 18),
// // //                     padding: const EdgeInsets.all(4),
// // //                     constraints: const BoxConstraints(),
// // //                     tooltip: 'WhatsApp',
// // //                     onPressed: onWhatsApp,
// // //                   ),
// // //                   const SizedBox(width: 6),

// // //                   // 2. Pencil / Edit Icon (Blue)
// // //                   IconButton(
// // //                     icon: const Icon(Icons.edit_outlined, color: Color(0xFF38BDF8), size: 18),
// // //                     padding: const EdgeInsets.all(4),
// // //                     constraints: const BoxConstraints(),
// // //                     tooltip: 'Edit',
// // //                     onPressed: onEdit,
// // //                   ),
// // //                   const SizedBox(width: 6),

// // //                   // 🗺️ 3. MAP ICON (SHOWS CUSTOMER LOCATION DIRECTLY)
// // //                   IconButton(
// // //                     icon: const Icon(Icons.location_on_outlined, color: Color(0xFF38BDF8), size: 18),
// // //                     padding: const EdgeInsets.all(4),
// // //                     constraints: const BoxConstraints(),
// // //                     tooltip: 'Customer Map Location',
// // //                     onPressed: () {
// // //                       CustomerDialogs.showLocationMapPreviewDialog(context, name, address);
// // //                     },
// // //                   ),
// // //                   const SizedBox(width: 6),

// // //                   // 4. Archive Icon (Yellow Box)
// // //                   IconButton(
// // //                     icon: const Icon(Icons.archive_rounded, color: Color(0xFFF59E0B), size: 18),
// // //                     padding: const EdgeInsets.all(4),
// // //                     constraints: const BoxConstraints(),
// // //                     tooltip: 'Archive',
// // //                     onPressed: onArchive,
// // //                   ),
// // //                   const SizedBox(width: 6),

// // //                   // 5. Delete Icon (Red Trash)
// // //                   IconButton(
// // //                     icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 18),
// // //                     padding: const EdgeInsets.all(4),
// // //                     constraints: const BoxConstraints(),
// // //                     tooltip: 'Delete',
// // //                     onPressed: onDelete,
// // //                   ),
// // //                 ],
// // //               ),
// // //             ],
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }

// // // ignore_for_file: use_build_context_synchronously

// // import 'dart:async';
// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:url_launcher/url_launcher.dart';
// // import 'package:http/http.dart' as http;

// // class CustomerDialogs {
// //   // 🌍 SAFE REAL-TIME LOCATION SUGGESTIONS
// //   static Future<List<String>> fetchAddressSuggestions(String query) async {
// //     if (query.trim().length < 2) return [];

// //     final encodedQuery = Uri.encodeComponent(query.trim());
// //     final url = Uri.parse(
// //       'https://nominatim.openstreetmap.org/search?q=$encodedQuery&format=json&addressdetails=1&limit=6',
// //     );

// //     try {
// //       final response = await http.get(
// //         url,
// //         headers: {'User-Agent': 'FlutterCustomerApp/1.0'},
// //       ).timeout(const Duration(seconds: 3));

// //       if (response.statusCode == 200) {
// //         final List data = json.decode(response.body);
// //         return data.map<String>((item) => item['display_name'].toString()).toList();
// //       }
// //     } catch (_) {
// //       // Safe fallback
// //     }
// //     return [];
// //   }

// //   // 🗺️ GOOGLE MAPS LAUNCHER
// //   static Future<void> openGoogleMaps(BuildContext context, String address) async {
// //     final cleanAddress = address.trim();
// //     if (cleanAddress.isEmpty) {
// //       showTopNotification(context, 'Please enter a valid address first!', isError: true);
// //       return;
// //     }

// //     final Uri googleMapsUrl = Uri.parse(
// //       'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(cleanAddress)}',
// //     );

// //     try {
// //       if (await canLaunchUrl(googleMapsUrl)) {
// //         await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
// //       } else {
// //         if (context.mounted) {
// //           showTopNotification(context, 'Unable to open Google Maps app!', isError: true);
// //         }
// //       }
// //     } catch (e) {
// //       if (context.mounted) {
// //         showTopNotification(context, 'Could not launch navigation', isError: true);
// //       }
// //     }
// //   }

// //   // 🔔 GUARANTEED TOP OVERLAY NOTIFICATION
// //   static void showTopNotification(BuildContext context, String message, {bool isError = false}) {
// //     final overlay = Overlay.maybeOf(context);
// //     if (overlay == null) return;

// //     final overlayEntry = OverlayEntry(
// //       builder: (context) => Positioned(
// //         top: MediaQuery.of(context).padding.top + 10,
// //         left: 16,
// //         right: 16,
// //         child: Material(
// //           color: Colors.transparent,
// //           child: AnimatedContainer(
// //             duration: const Duration(milliseconds: 300),
// //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //             decoration: BoxDecoration(
// //               color: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
// //               borderRadius: BorderRadius.circular(12),
// //               boxShadow: [
// //                 BoxShadow(
// //                   color: Colors.black.withOpacity(0.3),
// //                   blurRadius: 10,
// //                   offset: const Offset(0, 4),
// //                 )
// //               ],
// //             ),
// //             child: Row(
// //               children: [
// //                 Icon(
// //                   isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
// //                   color: Colors.white,
// //                   size: 22,
// //                 ),
// //                 const SizedBox(width: 12),
// //                 Expanded(
// //                   child: Text(
// //                     message,
// //                     style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );

// //     overlay.insert(overlayEntry);
// //     Future.delayed(const Duration(milliseconds: 2200), () {
// //       overlayEntry.remove();
// //     });
// //   }

// //   // 🚨 SECURE DELETE DIALOG
// //   static Future<bool> openSecureDeleteDialog({
// //     required BuildContext context,
// //     required String customerId,
// //     required String customerName,
// //     required bool Function(String id) isButtonLoading,
// //     required Function(String id, bool loading) setButtonLoading,
// //     bool isPermanent = false,
// //   }) async {
// //     final verifyController = TextEditingController();
// //     final formKey = GlobalKey<FormState>();

// //     bool? result = await showDialog<bool>(
// //       context: context,
// //       barrierDismissible: false,
// //       builder: (ctx) => StatefulBuilder(
// //         builder: (context, setDialogState) {
// //           bool isDeleting = isButtonLoading(isPermanent ? 'perm_$customerId' : 'del_$customerId');

// //           return AlertDialog(
// //             backgroundColor: const Color(0xFF0F172A),
// //             shape: RoundedRectangleBorder(
// //               borderRadius: BorderRadius.circular(18),
// //               side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
// //             ),
// //             title: Row(
// //               children: [
// //                 const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 28),
// //                 const SizedBox(width: 10),
// //                 Text(
// //                   isPermanent ? 'Permanent Purge' : 'Move to Recycle Bin',
// //                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
// //                 ),
// //               ],
// //             ),
// //             content: Form(
// //               key: formKey,
// //               child: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     isPermanent
// //                         ? 'Type the required customer name below to permanently erase all records:'
// //                         : 'Type the customer name below to move account to history bin:',
// //                     style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.4),
// //                   ),
// //                   const SizedBox(height: 12),
// //                   Container(
// //                     width: double.infinity,
// //                     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
// //                     decoration: BoxDecoration(
// //                       color: const Color(0xFF1E293B),
// //                       borderRadius: BorderRadius.circular(10),
// //                       border: Border.all(color: const Color(0xFF334155)),
// //                     ),
// //                     child: Text(
// //                       customerName,
// //                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 14),
// //                   TextFormField(
// //                     controller: verifyController,
// //                     enabled: !isDeleting,
// //                     style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// //                     decoration: InputDecoration(
// //                       hintText: customerName,
// //                       hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
// //                       filled: true,
// //                       fillColor: const Color(0xFF070A0F),
// //                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
// //                       focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEF4444))),
// //                     ),
// //                     validator: (val) {
// //                       if (val == null || val.trim().toLowerCase() != customerName.trim().toLowerCase()) {
// //                         return 'Customer name does not match!';
// //                       }
// //                       return null;
// //                     },
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             actions: [
// //               TextButton(
// //                 onPressed: isDeleting ? null : () => Navigator.pop(ctx, false),
// //                 child: const Text('Cancel', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
// //               ),
// //               ElevatedButton(
// //                 style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
// //                 onPressed: isDeleting
// //                     ? null
// //                     : () {
// //                         if (formKey.currentState!.validate()) {
// //                           Navigator.pop(ctx, true);
// //                         }
// //                       },
// //                 child: isDeleting
// //                     ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
// //                     : Text(isPermanent ? 'Purge Forever' : 'Confirm Action', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
// //               ),
// //             ],
// //           );
// //         },
// //       ),
// //     );

// //     return result ?? false;
// //   }

// //   // 🎯 CUSTOM FILTER MODAL
// //   static void openCustomFilterModal({
// //     required BuildContext context,
// //     required double? customMinFilter,
// //     required Function(String filter, double? minVal) onFilterApplied,
// //   }) {
// //     final customValController = TextEditingController(text: customMinFilter != null ? customMinFilter.toStringAsFixed(0) : '');

// //     showDialog(
// //       context: context,
// //       builder: (ctx) => AlertDialog(
// //         backgroundColor: const Color(0xFF0F172A),
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF38BDF8))),
// //         title: const Text('Customize Credit Limit Filter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
// //         content: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             const Text('Enter minimum balance amount threshold (₹):', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
// //             const SizedBox(height: 12),
// //             TextField(
// //               controller: customValController,
// //               keyboardType: TextInputType.number,
// //               style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// //               decoration: InputDecoration(
// //                 prefixText: '₹ ',
// //                 prefixStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// //                 hintText: 'e.g. 2500',
// //                 filled: true,
// //                 fillColor: const Color(0xFF070A0F),
// //                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
// //               ),
// //             ),
// //           ],
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () {
// //               onFilterApplied('all', null);
// //               Navigator.pop(ctx);
// //             },
// //             child: const Text('Reset All', style: TextStyle(color: Colors.redAccent)),
// //           ),
// //           ElevatedButton(
// //             style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8)),
// //             onPressed: () {
// //               final parsed = double.tryParse(customValController.text.trim());
// //               if (parsed != null) {
// //                 onFilterApplied('custom', parsed);
// //                 Navigator.pop(ctx);
// //                 showTopNotification(context, 'Applied custom filter: ₹${parsed.toStringAsFixed(0)}+');
// //               }
// //             },
// //             child: const Text('Apply Filter', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
// //           )
// //         ],
// //       ),
// //     );
// //   }

// //   // ✏️ EDIT CUSTOMER MODAL (NO BLANK SCREEN / NO FREEZE)
// //   static void openEditCustomerModal({
// //     required BuildContext context,
// //     required String customerId,
// //     required Map<String, dynamic> currentData,
// //     required bool Function(String id) isButtonLoading,
// //     required Function(String id, bool loading) setButtonLoading,
// //   }) {
// //     final formKey = GlobalKey<FormState>();
// //     final nameController = TextEditingController(text: currentData['name'] ?? '');
// //     final phoneController = TextEditingController(text: currentData['phone'] ?? '');
// //     final addressController = TextEditingController(text: currentData['address'] ?? '');
// //     final operatorUid = currentData['operatorUid'] ?? '';

// //     String? nameError;
// //     String? phoneError;
// //     Timer? debounce;

// //     List<String> apiSuggestions = [];
// //     bool isFetchingApi = false;

// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder: (ctx) => StatefulBuilder(
// //         builder: (dialogCtx, setDialogState) {
// //           bool isUpdating = isButtonLoading('edit_$customerId');

// //           void checkLiveName(String val) {
// //             if (debounce?.isActive ?? false) debounce!.cancel();
// //             debounce = Timer(const Duration(milliseconds: 300), () async {
// //               final text = val.trim().toLowerCase();
// //               if (text.isEmpty) {
// //                 if (dialogCtx.mounted) setDialogState(() => nameError = null);
// //                 return;
// //               }
// //               final query = await FirebaseFirestore.instance
// //                   .collection('customers')
// //                   .where('operatorUid', isEqualTo: operatorUid)
// //                   .get();

// //               bool duplicate = query.docs.any((d) => d.id != customerId && (d.data()['name'] ?? '').toString().trim().toLowerCase() == text);
// //               if (dialogCtx.mounted) {
// //                 setDialogState(() {
// //                   nameError = duplicate ? 'Already Name Exists!' : null;
// //                 });
// //               }
// //             });
// //           }

// //           void checkLivePhone(String val) {
// //             if (debounce?.isActive ?? false) debounce!.cancel();
// //             debounce = Timer(const Duration(milliseconds: 300), () async {
// //               final text = val.trim();
// //               if (text.length != 10) {
// //                 if (dialogCtx.mounted) setDialogState(() => phoneError = null);
// //                 return;
// //               }
// //               final query = await FirebaseFirestore.instance
// //                   .collection('customers')
// //                   .where('operatorUid', isEqualTo: operatorUid)
// //                   .where('phone', isEqualTo: text)
// //                   .get();

// //               bool duplicate = query.docs.any((d) => d.id != customerId);
// //               if (dialogCtx.mounted) {
// //                 setDialogState(() {
// //                   phoneError = duplicate ? 'Already Phone Number Exists!' : null;
// //                 });
// //               }
// //             });
// //           }

// //           void onAddressInputChanged(String val) {
// //             if (debounce?.isActive ?? false) debounce!.cancel();
// //             if (val.trim().length < 2) {
// //               if (dialogCtx.mounted) {
// //                 setDialogState(() {
// //                   apiSuggestions = [];
// //                   isFetchingApi = false;
// //                 });
// //               }
// //               return;
// //             }

// //             if (dialogCtx.mounted) setDialogState(() => isFetchingApi = true);
// //             debounce = Timer(const Duration(milliseconds: 400), () async {
// //               final results = await fetchAddressSuggestions(val);
// //               if (dialogCtx.mounted) {
// //                 setDialogState(() {
// //                   apiSuggestions = results;
// //                   isFetchingApi = false;
// //                 });
// //               }
// //             });
// //           }

// //           return AlertDialog(
// //             backgroundColor: const Color(0xFF0F172A),
// //             shape: RoundedRectangleBorder(
// //               borderRadius: BorderRadius.circular(16),
// //               side: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
// //             ),
// //             title: Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 const Text('Edit Customer Details', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 16)),
// //                 IconButton(
// //                   icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
// //                   padding: EdgeInsets.zero,
// //                   constraints: const BoxConstraints(),
// //                   tooltip: 'Cancel',
// //                   onPressed: () => Navigator.pop(ctx),
// //                 ),
// //               ],
// //             ),
// //             content: Form(
// //               key: formKey,
// //               child: SingleChildScrollView(
// //                 child: Column(
// //                   mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     TextFormField(
// //                       controller: nameController,
// //                       enabled: !isUpdating,
// //                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// //                       decoration: InputDecoration(
// //                         labelText: 'Customer Full Name *',
// //                         labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
// //                         errorText: nameError,
// //                         errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
// //                       ),
// //                       onChanged: checkLiveName,
// //                       validator: (v) => (v == null || v.trim().isEmpty) ? 'Name required.' : nameError,
// //                     ),
// //                     const SizedBox(height: 12),
// //                     TextFormField(
// //                       controller: phoneController,
// //                       enabled: !isUpdating,
// //                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// //                       keyboardType: TextInputType.phone,
// //                       maxLength: 10,
// //                       decoration: InputDecoration(
// //                         labelText: 'Mobile Number *',
// //                         prefixText: '+91 ',
// //                         counterText: '',
// //                         labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
// //                         errorText: phoneError,
// //                         errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
// //                       ),
// //                       onChanged: checkLivePhone,
// //                       validator: (v) => (v == null || v.trim().length != 10) ? 'Enter valid 10-digit number.' : phoneError,
// //                     ),
// //                     const SizedBox(height: 12),

// //                     TextFormField(
// //                       controller: addressController,
// //                       enabled: !isUpdating,
// //                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// //                       decoration: InputDecoration(
// //                         labelText: 'Address / Location *',
// //                         labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
// //                         prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF38BDF8), size: 20),
// //                         suffixIcon: isFetchingApi
// //                             ? const Padding(
// //                                 padding: EdgeInsets.all(8.0),
// //                                 child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Color(0xFF38BDF8), strokeWidth: 2)),
// //                               )
// //                             : null,
// //                       ),
// //                       onChanged: onAddressInputChanged,
// //                       validator: (v) => (v == null || v.trim().isEmpty) ? 'Address required.' : null,
// //                     ),

// //                     // ⚡ STABLE SUGGESTION LIST
// //                     if (apiSuggestions.isNotEmpty)
// //                       Container(
// //                         height: 130,
// //                         margin: const EdgeInsets.only(top: 6),
// //                         decoration: BoxDecoration(
// //                           color: const Color(0xFF1E293B),
// //                           borderRadius: BorderRadius.circular(10),
// //                           border: Border.all(color: const Color(0xFF38BDF8)),
// //                         ),
// //                         child: Material(
// //                           color: Colors.transparent,
// //                           child: ListView.separated(
// //                             physics: const BouncingScrollPhysics(),
// //                             itemCount: apiSuggestions.length,
// //                             separatorBuilder: (ctx, i) => const Divider(color: Colors.white12, height: 1),
// //                             itemBuilder: (context, index) {
// //                               final sug = apiSuggestions[index];
// //                               return ListTile(
// //                                 dense: true,
// //                                 contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
// //                                 leading: const Icon(Icons.pin_drop_rounded, color: Color(0xFF10B981), size: 16),
// //                                 title: Text(
// //                                   sug,
// //                                   style: const TextStyle(color: Colors.white, fontSize: 12),
// //                                   maxLines: 2,
// //                                   overflow: TextOverflow.ellipsis,
// //                                 ),
// //                                 onTap: () {
// //                                   addressController.text = sug;
// //                                   setDialogState(() => apiSuggestions = []);
// //                                 },
// //                               );
// //                             },
// //                           ),
// //                         ),
// //                       ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //             actions: [
// //               TextButton(onPressed: isUpdating ? null : () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70))),
// //               ElevatedButton(
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: (nameError != null || phoneError != null) ? Colors.grey : const Color(0xFF38BDF8),
// //                 ),
// //                 onPressed: (isUpdating || nameError != null || phoneError != null)
// //                     ? null
// //                     : () async {
// //                         if (formKey.currentState!.validate()) {
// //                           setButtonLoading('edit_$customerId', true);
// //                           setDialogState(() {});

// //                           try {
// //                             final updatedName = nameController.text.trim();
// //                             await FirebaseFirestore.instance.collection('customers').doc(customerId).update({
// //                               'name': updatedName,
// //                               'phone': phoneController.text.trim(),
// //                               'address': addressController.text.trim(),
// //                             });

// //                             setButtonLoading('edit_$customerId', false);
// //                             if (ctx.mounted) Navigator.pop(ctx);
// //                             if (context.mounted) {
// //                               showTopNotification(context, 'Customer "$updatedName" updated successfully!');
// //                             }
// //                           } catch (e) {
// //                             setButtonLoading('edit_$customerId', false);
// //                             setDialogState(() {});
// //                             if (context.mounted) {
// //                               showTopNotification(context, 'Failed to update customer!', isError: true);
// //                             }
// //                           }
// //                         }
// //                       },
// //                 child: isUpdating
// //                     ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
// //                     : const Text('Update Ledger', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
// //               )
// //             ],
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   // ➕ ADD NEW CUSTOMER MODAL
// //   static void openAddNewCustomerModal({
// //     required BuildContext context,
// //     required String operatorUid,
// //     required Color textColor,
// //     required Color cardBgColor,
// //     required bool Function(String id) isButtonLoading,
// //     required Function(String id, bool loading) setButtonLoading,
// //   }) {
// //     final formModalKey = GlobalKey<FormState>();
// //     final nameController = TextEditingController();
// //     final phoneController = TextEditingController();
// //     final addressController = TextEditingController();

// //     String? liveNameError;
// //     String? livePhoneError;
// //     Timer? debounceTimer;

// //     List<String> apiSuggestions = [];
// //     bool isFetchingApi = false;

// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder: (ctx) => StatefulBuilder(
// //         builder: (dialogCtx, setModalState) {
// //           bool isAdding = isButtonLoading('add_customer');

// //           void checkNameLive(String value) {
// //             if (debounceTimer?.isActive ?? false) debounceTimer!.cancel();
// //             debounceTimer = Timer(const Duration(milliseconds: 300), () async {
// //               final text = value.trim().toLowerCase();
// //               if (text.isEmpty) {
// //                 if (dialogCtx.mounted) setModalState(() => liveNameError = null);
// //                 return;
// //               }

// //               final check = await FirebaseFirestore.instance
// //                   .collection('customers')
// //                   .where('operatorUid', isEqualTo: operatorUid)
// //                   .get();

// //               bool duplicate = check.docs.any((d) => (d.data()['name'] ?? '').toString().trim().toLowerCase() == text);

// //               if (dialogCtx.mounted) {
// //                 setModalState(() {
// //                   liveNameError = duplicate ? 'Already Name Exists!' : null;
// //                 });
// //               }
// //             });
// //           }

// //           void checkPhoneLive(String value) {
// //             if (debounceTimer?.isActive ?? false) debounceTimer!.cancel();
// //             debounceTimer = Timer(const Duration(milliseconds: 300), () async {
// //               final text = value.trim();
// //               if (text.length != 10) {
// //                 if (dialogCtx.mounted) setModalState(() => livePhoneError = null);
// //                 return;
// //               }

// //               final check = await FirebaseFirestore.instance
// //                   .collection('customers')
// //                   .where('operatorUid', isEqualTo: operatorUid)
// //                   .where('phone', isEqualTo: text)
// //                   .get();

// //               bool duplicate = check.docs.isNotEmpty;
// //               if (dialogCtx.mounted) {
// //                 setModalState(() {
// //                   livePhoneError = duplicate ? 'Already Phone Number Exists!' : null;
// //                 });
// //               }
// //             });
// //           }

// //           void onAddressInputChanged(String val) {
// //             if (debounceTimer?.isActive ?? false) debounceTimer!.cancel();
// //             if (val.trim().length < 2) {
// //               if (dialogCtx.mounted) {
// //                 setModalState(() {
// //                   apiSuggestions = [];
// //                   isFetchingApi = false;
// //                 });
// //               }
// //               return;
// //             }

// //             if (dialogCtx.mounted) setModalState(() => isFetchingApi = true);
// //             debounceTimer = Timer(const Duration(milliseconds: 400), () async {
// //               final results = await fetchAddressSuggestions(val);
// //               if (dialogCtx.mounted) {
// //                 setModalState(() {
// //                   apiSuggestions = results;
// //                   isFetchingApi = false;
// //                 });
// //               }
// //             });
// //           }

// //           return AlertDialog(
// //             backgroundColor: cardBgColor,
// //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //             title: Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Text('Add Customer', style: TextStyle(fontWeight: FontWeight.w900, color: textColor, fontSize: 16)),
// //                 IconButton(
// //                   icon: Icon(Icons.close_rounded, color: textColor.withOpacity(0.7), size: 22),
// //                   padding: EdgeInsets.zero,
// //                   constraints: const BoxConstraints(),
// //                   tooltip: 'Cancel',
// //                   onPressed: () => Navigator.pop(ctx),
// //                 ),
// //               ],
// //             ),
// //             content: Form(
// //               key: formModalKey,
// //               child: SingleChildScrollView(
// //                 child: Column(
// //                   mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     TextFormField(
// //                       controller: nameController,
// //                       enabled: !isAdding,
// //                       style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
// //                       decoration: InputDecoration(
// //                         labelText: 'Customer Full Name *',
// //                         labelStyle: TextStyle(fontSize: 12, color: textColor),
// //                         errorText: liveNameError,
// //                         errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
// //                       ),
// //                       onChanged: checkNameLive,
// //                       validator: (v) => (v == null || v.trim().isEmpty) ? 'Customer name mandatory.' : liveNameError,
// //                     ),
// //                     const SizedBox(height: 12),
// //                     TextFormField(
// //                       controller: phoneController,
// //                       enabled: !isAdding,
// //                       style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
// //                       keyboardType: TextInputType.phone,
// //                       maxLength: 10,
// //                       decoration: InputDecoration(
// //                         labelText: 'Mobile Number *',
// //                         prefixText: '+91 ',
// //                         counterText: '',
// //                         labelStyle: TextStyle(fontSize: 12, color: textColor),
// //                         errorText: livePhoneError,
// //                         errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
// //                       ),
// //                       onChanged: checkPhoneLive,
// //                       validator: (v) => (v == null || v.trim().length != 10) ? 'Enter 10-digit primary mobile.' : livePhoneError,
// //                     ),
// //                     const SizedBox(height: 12),

// //                     TextFormField(
// //                       controller: addressController,
// //                       enabled: !isAdding,
// //                       style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
// //                       decoration: InputDecoration(
// //                         labelText: 'Address / Location *',
// //                         labelStyle: TextStyle(fontSize: 12, color: textColor),
// //                         prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF38BDF8), size: 20),
// //                         suffixIcon: isFetchingApi
// //                             ? const Padding(
// //                                 padding: EdgeInsets.all(8.0),
// //                                 child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Color(0xFF38BDF8), strokeWidth: 2)),
// //                               )
// //                             : null,
// //                       ),
// //                       onChanged: onAddressInputChanged,
// //                       validator: (v) => (v == null || v.trim().isEmpty) ? 'Location address mandatory.' : null,
// //                     ),

// //                     if (apiSuggestions.isNotEmpty)
// //                       Container(
// //                         height: 130,
// //                         margin: const EdgeInsets.only(top: 6),
// //                         decoration: BoxDecoration(
// //                           color: const Color(0xFF1E293B),
// //                           borderRadius: BorderRadius.circular(10),
// //                           border: Border.all(color: const Color(0xFF38BDF8)),
// //                         ),
// //                         child: Material(
// //                           color: Colors.transparent,
// //                           child: ListView.separated(
// //                             physics: const BouncingScrollPhysics(),
// //                             itemCount: apiSuggestions.length,
// //                             separatorBuilder: (ctx, i) => const Divider(color: Colors.white12, height: 1),
// //                             itemBuilder: (context, index) {
// //                               final sug = apiSuggestions[index];
// //                               return ListTile(
// //                                 dense: true,
// //                                 contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
// //                                 leading: const Icon(Icons.pin_drop_rounded, color: Color(0xFF10B981), size: 16),
// //                                 title: Text(
// //                                   sug,
// //                                   style: const TextStyle(color: Colors.white, fontSize: 12),
// //                                   maxLines: 2,
// //                                   overflow: TextOverflow.ellipsis,
// //                                 ),
// //                                 onTap: () {
// //                                   addressController.text = sug;
// //                                   setModalState(() => apiSuggestions = []);
// //                                 },
// //                               );
// //                             },
// //                           ),
// //                         ),
// //                       ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //             actions: [
// //               TextButton(onPressed: isAdding ? null : () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(fontWeight: FontWeight.w900, color: textColor))),
// //               ElevatedButton(
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: (liveNameError != null || livePhoneError != null) ? Colors.grey : const Color(0xFF10B981),
// //                 ),
// //                 onPressed: (isAdding || liveNameError != null || livePhoneError != null)
// //                     ? null
// //                     : () async {
// //                         if (formModalKey.currentState!.validate()) {
// //                           setButtonLoading('add_customer', true);
// //                           setModalState(() {});

// //                           try {
// //                             final inputName = nameController.text.trim();
// //                             final inputPhone = phoneController.text.trim();

// //                             await FirebaseFirestore.instance.collection('customers').add({
// //                               'operatorUid': operatorUid,
// //                               'name': inputName,
// //                               'phone': inputPhone,
// //                               'address': addressController.text.trim(),
// //                               'balance': 0.0,
// //                               'isArchived': false,
// //                               'createdAt': FieldValue.serverTimestamp(),
// //                             });

// //                             setButtonLoading('add_customer', false);
// //                             if (ctx.mounted) Navigator.pop(ctx);
// //                             if (context.mounted) {
// //                               showTopNotification(context, 'New Customer "$inputName" added successfully!');
// //                             }
// //                           } catch (e) {
// //                             setButtonLoading('add_customer', false);
// //                             setModalState(() {});
// //                             if (context.mounted) {
// //                               showTopNotification(context, 'Failed to add customer!', isError: true);
// //                             }
// //                           }
// //                         }
// //                       },
// //                 child: isAdding
// //                     ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
// //                     : const Text('Save Customer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
// //               )
// //             ],
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }

// // ignore_for_file: use_build_context_synchronously

// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:http/http.dart' as http;

// class CustomerDialogs {
//   // 🌍 SAFE REAL-TIME LOCATION SUGGESTIONS
//   static Future<List<String>> fetchAddressSuggestions(String query) async {
//     if (query.trim().length < 2) return [];

//     final encodedQuery = Uri.encodeComponent(query.trim());
//     final url = Uri.parse(
//       'https://nominatim.openstreetmap.org/search?q=$encodedQuery&format=json&addressdetails=1&limit=5',
//     );

//     try {
//       final response = await http.get(
//         url,
//         headers: {'User-Agent': 'FlutterCustomerApp/1.0'},
//       ).timeout(const Duration(seconds: 3));

//       if (response.statusCode == 200) {
//         final List data = json.decode(response.body);
//         return data.map<String>((item) => item['display_name'].toString()).toList();
//       }
//     } catch (_) {
//       // Safe fallback
//     }
//     return [];
//   }

//   // 🗺️ GOOGLE MAPS LAUNCHER
//   static Future<void> openGoogleMaps(BuildContext context, String address) async {
//     final cleanAddress = address.trim();
//     if (cleanAddress.isEmpty) {
//       showTopNotification(context, 'Please enter a valid address first!', isError: true);
//       return;
//     }

//     final Uri googleMapsUrl = Uri.parse(
//       'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(cleanAddress)}',
//     );

//     try {
//       if (await canLaunchUrl(googleMapsUrl)) {
//         await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
//       } else {
//         if (context.mounted) {
//           showTopNotification(context, 'Unable to open Google Maps app!', isError: true);
//         }
//       }
//     } catch (e) {
//       if (context.mounted) {
//         showTopNotification(context, 'Could not launch navigation', isError: true);
//       }
//     }
//   }

//   // 🔔 GUARANTEED TOP OVERLAY NOTIFICATION
//   static void showTopNotification(BuildContext context, String message, {bool isError = false}) {
//     final overlay = Overlay.maybeOf(context);
//     if (overlay == null) return;

//     final overlayEntry = OverlayEntry(
//       builder: (context) => Positioned(
//         top: MediaQuery.of(context).padding.top + 10,
//         left: 16,
//         right: 16,
//         child: Material(
//           color: Colors.transparent,
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 300),
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: BoxDecoration(
//               color: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.3),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 )
//               ],
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
//                   color: Colors.white,
//                   size: 22,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     message,
//                     style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );

//     overlay.insert(overlayEntry);
//     Future.delayed(const Duration(milliseconds: 2200), () {
//       overlayEntry.remove();
//     });
//   }

//   // 🚨 SECURE DELETE DIALOG
//   static Future<bool> openSecureDeleteDialog({
//     required BuildContext context,
//     required String customerId,
//     required String customerName,
//     required bool Function(String id) isButtonLoading,
//     required Function(String id, bool loading) setButtonLoading,
//     bool isPermanent = false,
//   }) async {
//     final verifyController = TextEditingController();
//     final formKey = GlobalKey<FormState>();

//     bool? result = await showDialog<bool>(
//       context: context,
//       barrierDismissible: false,
//       builder: (ctx) => StatefulBuilder(
//         builder: (context, setDialogState) {
//           bool isDeleting = isButtonLoading(isPermanent ? 'perm_$customerId' : 'del_$customerId');

//           return AlertDialog(
//             backgroundColor: const Color(0xFF0F172A),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(18),
//               side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
//             ),
//             title: Row(
//               children: [
//                 const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 28),
//                 const SizedBox(width: 10),
//                 Text(
//                   isPermanent ? 'Permanent Purge' : 'Move to Recycle Bin',
//                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
//                 ),
//               ],
//             ),
//             content: Form(
//               key: formKey,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     isPermanent
//                         ? 'Type the required customer name below to permanently erase all records:'
//                         : 'Type the customer name below to move account to history bin:',
//                     style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.4),
//                   ),
//                   const SizedBox(height: 12),
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF1E293B),
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: const Color(0xFF334155)),
//                     ),
//                     child: Text(
//                       customerName,
//                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
//                     ),
//                   ),
//                   const SizedBox(height: 14),
//                   TextFormField(
//                     controller: verifyController,
//                     enabled: !isDeleting,
//                     style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                     decoration: InputDecoration(
//                       hintText: customerName,
//                       hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
//                       filled: true,
//                       fillColor: const Color(0xFF070A0F),
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
//                       focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEF4444))),
//                     ),
//                     validator: (val) {
//                       if (val == null || val.trim().toLowerCase() != customerName.trim().toLowerCase()) {
//                         return 'Customer name does not match!';
//                       }
//                       return null;
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: isDeleting ? null : () => Navigator.pop(ctx, false),
//                 child: const Text('Cancel', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
//               ),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
//                 onPressed: isDeleting
//                     ? null
//                     : () {
//                         if (formKey.currentState!.validate()) {
//                           Navigator.pop(ctx, true);
//                         }
//                       },
//                 child: isDeleting
//                     ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                     : Text(isPermanent ? 'Purge Forever' : 'Confirm Action', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
//               ),
//             ],
//           );
//         },
//       ),
//     );

//     return result ?? false;
//   }

//   // 🎯 CUSTOM FILTER MODAL
//   static void openCustomFilterModal({
//     required BuildContext context,
//     required double? customMinFilter,
//     required Function(String filter, double? minVal) onFilterApplied,
//   }) {
//     final customValController = TextEditingController(text: customMinFilter != null ? customMinFilter.toStringAsFixed(0) : '');

//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         backgroundColor: const Color(0xFF0F172A),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF38BDF8))),
//         title: const Text('Customize Credit Limit Filter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text('Enter minimum balance amount threshold (₹):', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
//             const SizedBox(height: 12),
//             TextField(
//               controller: customValController,
//               keyboardType: TextInputType.number,
//               style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//               decoration: InputDecoration(
//                 prefixText: '₹ ',
//                 prefixStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                 hintText: 'e.g. 2500',
//                 filled: true,
//                 fillColor: const Color(0xFF070A0F),
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               onFilterApplied('all', null);
//               Navigator.pop(ctx);
//             },
//             child: const Text('Reset All', style: TextStyle(color: Colors.redAccent)),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8)),
//             onPressed: () {
//               final parsed = double.tryParse(customValController.text.trim());
//               if (parsed != null) {
//                 onFilterApplied('custom', parsed);
//                 Navigator.pop(ctx);
//                 showTopNotification(context, 'Applied custom filter: ₹${parsed.toStringAsFixed(0)}+');
//               }
//             },
//             child: const Text('Apply Filter', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
//           )
//         ],
//       ),
//     );
//   }

//   // ✏️ EDIT CUSTOMER MODAL (100% STABLE - NO CRASH)
//   static void openEditCustomerModal({
//     required BuildContext context,
//     required String customerId,
//     required Map<String, dynamic> currentData,
//     required bool Function(String id) isButtonLoading,
//     required Function(String id, bool loading) setButtonLoading,
//   }) {
//     final formKey = GlobalKey<FormState>();
//     final nameController = TextEditingController(text: currentData['name'] ?? '');
//     final phoneController = TextEditingController(text: currentData['phone'] ?? '');
//     final addressController = TextEditingController(text: currentData['address'] ?? '');
//     final operatorUid = currentData['operatorUid'] ?? '';

//     String? nameError;
//     String? phoneError;
//     Timer? debounce;

//     List<String> apiSuggestions = [];
//     bool isFetchingApi = false;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (ctx) => StatefulBuilder(
//         builder: (dialogCtx, setDialogState) {
//           bool isUpdating = isButtonLoading('edit_$customerId');

//           void checkLiveName(String val) {
//             if (debounce?.isActive ?? false) debounce!.cancel();
//             debounce = Timer(const Duration(milliseconds: 300), () async {
//               final text = val.trim().toLowerCase();
//               if (text.isEmpty) {
//                 if (dialogCtx.mounted) setDialogState(() => nameError = null);
//                 return;
//               }
//               final query = await FirebaseFirestore.instance
//                   .collection('customers')
//                   .where('operatorUid', isEqualTo: operatorUid)
//                   .get();

//               bool duplicate = query.docs.any((d) => d.id != customerId && (d.data()['name'] ?? '').toString().trim().toLowerCase() == text);
//               if (dialogCtx.mounted) {
//                 setDialogState(() {
//                   nameError = duplicate ? 'Already Name Exists!' : null;
//                 });
//               }
//             });
//           }

//           void checkLivePhone(String val) {
//             if (debounce?.isActive ?? false) debounce!.cancel();
//             debounce = Timer(const Duration(milliseconds: 300), () async {
//               final text = val.trim();
//               if (text.length != 10) {
//                 if (dialogCtx.mounted) setDialogState(() => phoneError = null);
//                 return;
//               }
//               final query = await FirebaseFirestore.instance
//                   .collection('customers')
//                   .where('operatorUid', isEqualTo: operatorUid)
//                   .where('phone', isEqualTo: text)
//                   .get();

//               bool duplicate = query.docs.any((d) => d.id != customerId);
//               if (dialogCtx.mounted) {
//                 setDialogState(() {
//                   phoneError = duplicate ? 'Already Phone Number Exists!' : null;
//                 });
//               }
//             });
//           }

//           void onAddressInputChanged(String val) {
//             if (debounce?.isActive ?? false) debounce!.cancel();
//             if (val.trim().length < 2) {
//               if (dialogCtx.mounted) {
//                 setDialogState(() {
//                   apiSuggestions = [];
//                   isFetchingApi = false;
//                 });
//               }
//               return;
//             }

//             if (dialogCtx.mounted) setDialogState(() => isFetchingApi = true);
//             debounce = Timer(const Duration(milliseconds: 400), () async {
//               final results = await fetchAddressSuggestions(val);
//               if (dialogCtx.mounted) {
//                 setDialogState(() {
//                   apiSuggestions = results;
//                   isFetchingApi = false;
//                 });
//               }
//             });
//           }

//           return Dialog(
//             backgroundColor: const Color(0xFF0F172A),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//               side: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
//             ),
//             child: Container(
//               width: 420,
//               padding: const EdgeInsets.all(20),
//               child: Form(
//                 key: formKey,
//                 child: SingleChildScrollView(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text('Edit Customer Details', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 16)),
//                           IconButton(
//                             icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
//                             padding: EdgeInsets.zero,
//                             constraints: const BoxConstraints(),
//                             tooltip: 'Cancel',
//                             onPressed: () => Navigator.pop(ctx),
//                           ),
//                         ],
//                       ),
//                       const Divider(color: Colors.white12, height: 20),
//                       TextFormField(
//                         controller: nameController,
//                         enabled: !isUpdating,
//                         style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                         decoration: InputDecoration(
//                           labelText: 'Customer Full Name *',
//                           labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
//                           errorText: nameError,
//                           errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
//                         ),
//                         onChanged: checkLiveName,
//                         validator: (v) => (v == null || v.trim().isEmpty) ? 'Name required.' : nameError,
//                       ),
//                       const SizedBox(height: 12),
//                       TextFormField(
//                         controller: phoneController,
//                         enabled: !isUpdating,
//                         style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                         keyboardType: TextInputType.phone,
//                         maxLength: 10,
//                         decoration: InputDecoration(
//                           labelText: 'Mobile Number *',
//                           prefixText: '+91 ',
//                           counterText: '',
//                           labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
//                           errorText: phoneError,
//                           errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
//                         ),
//                         onChanged: checkLivePhone,
//                         validator: (v) => (v == null || v.trim().length != 10) ? 'Enter valid 10-digit number.' : phoneError,
//                       ),
//                       const SizedBox(height: 12),

//                       TextFormField(
//                         controller: addressController,
//                         enabled: !isUpdating,
//                         style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                         decoration: InputDecoration(
//                           labelText: 'Address / Location *',
//                           labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
//                           prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF38BDF8), size: 20),
//                           suffixIcon: isFetchingApi
//                               ? const Padding(
//                                   padding: EdgeInsets.all(8.0),
//                                   child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Color(0xFF38BDF8), strokeWidth: 2)),
//                                 )
//                               : null,
//                         ),
//                         onChanged: onAddressInputChanged,
//                         validator: (v) => (v == null || v.trim().isEmpty) ? 'Address required.' : null,
//                       ),

//                       // ⚡ ZERO CRASH SUGGESTION LIST
//                       if (apiSuggestions.isNotEmpty) ...[
//                         const SizedBox(height: 8),
//                         Container(
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF1E293B),
//                             borderRadius: BorderRadius.circular(10),
//                             border: Border.all(color: const Color(0xFF38BDF8)),
//                           ),
//                           child: Column(
//                             children: apiSuggestions.map((sug) {
//                               return InkWell(
//                                 onTap: () {
//                                   addressController.text = sug;
//                                   setDialogState(() => apiSuggestions = []);
//                                 },
//                                 child: Padding(
//                                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                                   child: Row(
//                                     children: [
//                                       const Icon(Icons.pin_drop_rounded, color: Color(0xFF10B981), size: 16),
//                                       const SizedBox(width: 8),
//                                       Expanded(
//                                         child: Text(
//                                           sug,
//                                           style: const TextStyle(color: Colors.white, fontSize: 12),
//                                           maxLines: 2,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             }).toList(),
//                           ),
//                         ),
//                       ],

//                       const SizedBox(height: 20),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           TextButton(
//                             onPressed: isUpdating ? null : () => Navigator.pop(ctx),
//                             child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
//                           ),
//                           const SizedBox(width: 8),
//                           ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: (nameError != null || phoneError != null) ? Colors.grey : const Color(0xFF38BDF8),
//                             ),
//                             onPressed: (isUpdating || nameError != null || phoneError != null)
//                                 ? null
//                                 : () async {
//                                     if (formKey.currentState!.validate()) {
//                                       setButtonLoading('edit_$customerId', true);
//                                       setDialogState(() {});

//                                       try {
//                                         final updatedName = nameController.text.trim();
//                                         await FirebaseFirestore.instance.collection('customers').doc(customerId).update({
//                                           'name': updatedName,
//                                           'phone': phoneController.text.trim(),
//                                           'address': addressController.text.trim(),
//                                         });

//                                         setButtonLoading('edit_$customerId', false);
//                                         if (ctx.mounted) Navigator.pop(ctx);
//                                         if (context.mounted) {
//                                           showTopNotification(context, 'Customer "$updatedName" updated successfully!');
//                                         }
//                                       } catch (e) {
//                                         setButtonLoading('edit_$customerId', false);
//                                         if (dialogCtx.mounted) setDialogState(() {});
//                                         if (context.mounted) {
//                                           showTopNotification(context, 'Failed to update customer!', isError: true);
//                                         }
//                                       }
//                                     }
//                                   },
//                             child: isUpdating
//                                 ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
//                                 : const Text('Update Ledger', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // ➕ ADD NEW CUSTOMER MODAL
//   static void openAddNewCustomerModal({
//     required BuildContext context,
//     required String operatorUid,
//     required Color textColor,
//     required Color cardBgColor,
//     required bool Function(String id) isButtonLoading,
//     required Function(String id, bool loading) setButtonLoading,
//   }) {
//     final formModalKey = GlobalKey<FormState>();
//     final nameController = TextEditingController();
//     final phoneController = TextEditingController();
//     final addressController = TextEditingController();

//     String? liveNameError;
//     String? livePhoneError;
//     Timer? debounceTimer;

//     List<String> apiSuggestions = [];
//     bool isFetchingApi = false;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (ctx) => StatefulBuilder(
//         builder: (dialogCtx, setModalState) {
//           bool isAdding = isButtonLoading('add_customer');

//           void checkNameLive(String value) {
//             if (debounceTimer?.isActive ?? false) debounceTimer!.cancel();
//             debounceTimer = Timer(const Duration(milliseconds: 300), () async {
//               final text = value.trim().toLowerCase();
//               if (text.isEmpty) {
//                 if (dialogCtx.mounted) setModalState(() => liveNameError = null);
//                 return;
//               }

//               final check = await FirebaseFirestore.instance
//                   .collection('customers')
//                   .where('operatorUid', isEqualTo: operatorUid)
//                   .get();

//               bool duplicate = check.docs.any((d) => (d.data()['name'] ?? '').toString().trim().toLowerCase() == text);

//               if (dialogCtx.mounted) {
//                 setModalState(() {
//                   liveNameError = duplicate ? 'Already Name Exists!' : null;
//                 });
//               }
//             });
//           }

//           void checkPhoneLive(String value) {
//             if (debounceTimer?.isActive ?? false) debounceTimer!.cancel();
//             debounceTimer = Timer(const Duration(milliseconds: 300), () async {
//               final text = value.trim();
//               if (text.length != 10) {
//                 if (dialogCtx.mounted) setModalState(() => livePhoneError = null);
//                 return;
//               }

//               final check = await FirebaseFirestore.instance
//                   .collection('customers')
//                   .where('operatorUid', isEqualTo: operatorUid)
//                   .where('phone', isEqualTo: text)
//                   .get();

//               bool duplicate = check.docs.isNotEmpty;
//               if (dialogCtx.mounted) {
//                 setModalState(() {
//                   livePhoneError = duplicate ? 'Already Phone Number Exists!' : null;
//                 });
//               }
//             });
//           }

//           void onAddressInputChanged(String val) {
//             if (debounceTimer?.isActive ?? false) debounceTimer!.cancel();
//             if (val.trim().length < 2) {
//               if (dialogCtx.mounted) {
//                 setModalState(() {
//                   apiSuggestions = [];
//                   isFetchingApi = false;
//                 });
//               }
//               return;
//             }

//             if (dialogCtx.mounted) setModalState(() => isFetchingApi = true);
//             debounceTimer = Timer(const Duration(milliseconds: 400), () async {
//               final results = await fetchAddressSuggestions(val);
//               if (dialogCtx.mounted) {
//                 setModalState(() {
//                   apiSuggestions = results;
//                   isFetchingApi = false;
//                 });
//               }
//             });
//           }

//           return Dialog(
//             backgroundColor: cardBgColor,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//             child: Container(
//               width: 420,
//               padding: const EdgeInsets.all(20),
//               child: Form(
//                 key: formModalKey,
//                 child: SingleChildScrollView(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text('Add Customer', style: TextStyle(fontWeight: FontWeight.w900, color: textColor, fontSize: 16)),
//                           IconButton(
//                             icon: Icon(Icons.close_rounded, color: textColor.withOpacity(0.7), size: 22),
//                             padding: EdgeInsets.zero,
//                             constraints: const BoxConstraints(),
//                             tooltip: 'Cancel',
//                             onPressed: () => Navigator.pop(ctx),
//                           ),
//                         ],
//                       ),
//                       const Divider(height: 20),
//                       TextFormField(
//                         controller: nameController,
//                         enabled: !isAdding,
//                         style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
//                         decoration: InputDecoration(
//                           labelText: 'Customer Full Name *',
//                           labelStyle: TextStyle(fontSize: 12, color: textColor),
//                           errorText: liveNameError,
//                           errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
//                         ),
//                         onChanged: checkNameLive,
//                         validator: (v) => (v == null || v.trim().isEmpty) ? 'Customer name mandatory.' : liveNameError,
//                       ),
//                       const SizedBox(height: 12),
//                       TextFormField(
//                         controller: phoneController,
//                         enabled: !isAdding,
//                         style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
//                         keyboardType: TextInputType.phone,
//                         maxLength: 10,
//                         decoration: InputDecoration(
//                           labelText: 'Mobile Number *',
//                           prefixText: '+91 ',
//                           counterText: '',
//                           labelStyle: TextStyle(fontSize: 12, color: textColor),
//                           errorText: livePhoneError,
//                           errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
//                         ),
//                         onChanged: checkPhoneLive,
//                         validator: (v) => (v == null || v.trim().length != 10) ? 'Enter 10-digit primary mobile.' : livePhoneError,
//                       ),
//                       const SizedBox(height: 12),

//                       TextFormField(
//                         controller: addressController,
//                         enabled: !isAdding,
//                         style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
//                         decoration: InputDecoration(
//                           labelText: 'Address / Location *',
//                           labelStyle: TextStyle(fontSize: 12, color: textColor),
//                           prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF38BDF8), size: 20),
//                           suffixIcon: isFetchingApi
//                               ? const Padding(
//                                   padding: EdgeInsets.all(8.0),
//                                   child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Color(0xFF38BDF8), strokeWidth: 2)),
//                                 )
//                               : null,
//                         ),
//                         onChanged: onAddressInputChanged,
//                         validator: (v) => (v == null || v.trim().isEmpty) ? 'Location address mandatory.' : null,
//                       ),

//                       if (apiSuggestions.isNotEmpty) ...[
//                         const SizedBox(height: 8),
//                         Container(
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF1E293B),
//                             borderRadius: BorderRadius.circular(10),
//                             border: Border.all(color: const Color(0xFF38BDF8)),
//                           ),
//                           child: Column(
//                             children: apiSuggestions.map((sug) {
//                               return InkWell(
//                                 onTap: () {
//                                   addressController.text = sug;
//                                   setModalState(() => apiSuggestions = []);
//                                 },
//                                 child: Padding(
//                                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                                   child: Row(
//                                     children: [
//                                       const Icon(Icons.pin_drop_rounded, color: Color(0xFF10B981), size: 16),
//                                       const SizedBox(width: 8),
//                                       Expanded(
//                                         child: Text(
//                                           sug,
//                                           style: const TextStyle(color: Colors.white, fontSize: 12),
//                                           maxLines: 2,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             }).toList(),
//                           ),
//                         ),
//                       ],

//                       const SizedBox(height: 20),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           TextButton(onPressed: isAdding ? null : () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(fontWeight: FontWeight.w900, color: textColor))),
//                           const SizedBox(width: 8),
//                           ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: (liveNameError != null || livePhoneError != null) ? Colors.grey : const Color(0xFF10B981),
//                             ),
//                             onPressed: (isAdding || liveNameError != null || livePhoneError != null)
//                                 ? null
//                                 : () async {
//                                     if (formModalKey.currentState!.validate()) {
//                                       setButtonLoading('add_customer', true);
//                                       setModalState(() {});

//                                       try {
//                                         final inputName = nameController.text.trim();
//                                         final inputPhone = phoneController.text.trim();

//                                         await FirebaseFirestore.instance.collection('customers').add({
//                                           'operatorUid': operatorUid,
//                                           'name': inputName,
//                                           'phone': inputPhone,
//                                           'address': addressController.text.trim(),
//                                           'balance': 0.0,
//                                           'isArchived': false,
//                                           'createdAt': FieldValue.serverTimestamp(),
//                                         });

//                                         setButtonLoading('add_customer', false);
//                                         if (ctx.mounted) Navigator.pop(ctx);
//                                         if (context.mounted) {
//                                           showTopNotification(context, 'New Customer "$inputName" added successfully!');
//                                         }
//                                       } catch (e) {
//                                         setButtonLoading('add_customer', false);
//                                         if (dialogCtx.mounted) setModalState(() {});
//                                         if (context.mounted) {
//                                           showTopNotification(context, 'Failed to add customer!', isError: true);
//                                         }
//                                       }
//                                     }
//                                   },
//                             child: isAdding
//                                 ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                                 : const Text('Save Customer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class CustomerDialogs {
  // 🌍 SAFE REAL-TIME LOCATION SUGGESTIONS (API)
  static Future<List<String>> fetchAddressSuggestions(String query) async {
    if (query.trim().length < 2) return [];

    final encodedQuery = Uri.encodeComponent(query.trim());
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$encodedQuery&format=json&addressdetails=1&limit=5',
    );

    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': 'FlutterCustomerApp/1.0'},
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map<String>((item) => item['display_name'].toString()).toList();
      }
    } catch (_) {
      // Safe error catch
    }
    return [];
  }

  // 🗺️ GOOGLE MAPS LAUNCHER
  static Future<void> openGoogleMaps(BuildContext context, String address) async {
    final cleanAddress = address.trim();
    if (cleanAddress.isEmpty) {
      showTopNotification(context, 'Please enter a valid address first!', isError: true);
      return;
    }

    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(cleanAddress)}',
    );

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          showTopNotification(context, 'Unable to open Google Maps app!', isError: true);
        }
      }
    } catch (e) {
      if (context.mounted) {
        showTopNotification(context, 'Could not launch navigation', isError: true);
      }
    }
  }

  // 🔔 TOP OVERLAY NOTIFICATION
  static void showTopNotification(BuildContext context, String message, {bool isError = false}) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
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
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(milliseconds: 2200), () {
      overlayEntry.remove();
    });
  }

  // 🚨 SECURE DELETE DIALOG
  static Future<bool> openSecureDeleteDialog({
    required BuildContext context,
    required String customerId,
    required String customerName,
    required bool Function(String id) isButtonLoading,
    required Function(String id, bool loading) setButtonLoading,
    bool isPermanent = false,
  }) async {
    final verifyController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          bool isDeleting = isButtonLoading(isPermanent ? 'perm_$customerId' : 'del_$customerId');

          return AlertDialog(
            backgroundColor: const Color(0xFF0F172A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 28),
                const SizedBox(width: 10),
                Text(
                  isPermanent ? 'Permanent Purge' : 'Move to Recycle Bin',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
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
                    isPermanent
                        ? 'Type the required customer name below to permanently erase all records:'
                        : 'Type the customer name below to move account to history bin:',
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Text(
                      customerName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: verifyController,
                    enabled: !isDeleting,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: customerName,
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                      filled: true,
                      fillColor: const Color(0xFF070A0F),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEF4444))),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().toLowerCase() != customerName.trim().toLowerCase()) {
                        return 'Customer name does not match!';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isDeleting ? null : () => Navigator.pop(ctx, false),
                child: const Text('Cancel', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                onPressed: isDeleting
                    ? null
                    : () {
                        if (formKey.currentState!.validate()) {
                          Navigator.pop(ctx, true);
                        }
                      },
                child: isDeleting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(isPermanent ? 'Purge Forever' : 'Confirm Action', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              ),
            ],
          );
        },
      ),
    );

    return result ?? false;
  }

  // 🎯 CUSTOM FILTER MODAL
  static void openCustomFilterModal({
    required BuildContext context,
    required double? customMinFilter,
    required Function(String filter, double? minVal) onFilterApplied,
  }) {
    final customValController = TextEditingController(text: customMinFilter != null ? customMinFilter.toStringAsFixed(0) : '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF38BDF8))),
        title: const Text('Customize Credit Limit Filter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter minimum balance amount threshold (₹):', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
            const SizedBox(height: 12),
            TextField(
              controller: customValController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                hintText: 'e.g. 2500',
                filled: true,
                fillColor: const Color(0xFF070A0F),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              onFilterApplied('all', null);
              Navigator.pop(ctx);
            },
            child: const Text('Reset All', style: TextStyle(color: Colors.redAccent)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8)),
            onPressed: () {
              final parsed = double.tryParse(customValController.text.trim());
              if (parsed != null) {
                onFilterApplied('custom', parsed);
                Navigator.pop(ctx);
                showTopNotification(context, 'Applied custom filter: ₹${parsed.toStringAsFixed(0)}+');
              }
            },
            child: const Text('Apply Filter', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // ✏️ EDIT CUSTOMER MODAL (AUTO-FILL & SMOOTH DROPDOWN)
  static void openEditCustomerModal({
    required BuildContext context,
    required String customerId,
    required Map<String, dynamic> currentData,
    required bool Function(String id) isButtonLoading,
    required Function(String id, bool loading) setButtonLoading,
  }) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: currentData['name'] ?? '');
    final phoneController = TextEditingController(text: currentData['phone'] ?? '');
    final addressController = TextEditingController(text: currentData['address'] ?? '');
    final operatorUid = currentData['operatorUid'] ?? '';

    String? nameError;
    String? phoneError;
    Timer? debounce;

    List<String> apiSuggestions = [];
    bool isFetchingApi = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          bool isUpdating = isButtonLoading('edit_$customerId');

          void checkLiveName(String val) {
            if (debounce?.isActive ?? false) debounce!.cancel();
            debounce = Timer(const Duration(milliseconds: 300), () async {
              final text = val.trim().toLowerCase();
              if (text.isEmpty) {
                if (dialogCtx.mounted) setDialogState(() => nameError = null);
                return;
              }
              final query = await FirebaseFirestore.instance
                  .collection('customers')
                  .where('operatorUid', isEqualTo: operatorUid)
                  .get();

              bool duplicate = query.docs.any((d) => d.id != customerId && (d.data()['name'] ?? '').toString().trim().toLowerCase() == text);
              if (dialogCtx.mounted) {
                setDialogState(() {
                  nameError = duplicate ? 'Already Name Exists!' : null;
                });
              }
            });
          }

          void checkLivePhone(String val) {
            if (debounce?.isActive ?? false) debounce!.cancel();
            debounce = Timer(const Duration(milliseconds: 300), () async {
              final text = val.trim();
              if (text.length != 10) {
                if (dialogCtx.mounted) setDialogState(() => phoneError = null);
                return;
              }
              final query = await FirebaseFirestore.instance
                  .collection('customers')
                  .where('operatorUid', isEqualTo: operatorUid)
                  .where('phone', isEqualTo: text)
                  .get();

              bool duplicate = query.docs.any((d) => d.id != customerId);
              if (dialogCtx.mounted) {
                setDialogState(() {
                  phoneError = duplicate ? 'Already Phone Number Exists!' : null;
                });
              }
            });
          }

          void onAddressInputChanged(String val) {
            if (debounce?.isActive ?? false) debounce!.cancel();
            if (val.trim().length < 2) {
              if (dialogCtx.mounted) {
                setDialogState(() {
                  apiSuggestions = [];
                  isFetchingApi = false;
                });
              }
              return;
            }

            if (dialogCtx.mounted) setDialogState(() => isFetchingApi = true);
            debounce = Timer(const Duration(milliseconds: 350), () async {
              final results = await fetchAddressSuggestions(val);
              if (dialogCtx.mounted) {
                setDialogState(() {
                  apiSuggestions = results;
                  isFetchingApi = false;
                });
              }
            });
          }

          return Dialog(
            backgroundColor: const Color(0xFF0F172A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
            ),
            child: Container(
              width: 420,
              padding: const EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Edit Customer Details', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 16)),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: 'Cancel',
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white12, height: 20),
                      TextFormField(
                        controller: nameController,
                        enabled: !isUpdating,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          labelText: 'Customer Full Name *',
                          labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          errorText: nameError,
                          errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                        ),
                        onChanged: checkLiveName,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Name required.' : nameError,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneController,
                        enabled: !isUpdating,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        decoration: InputDecoration(
                          labelText: 'Mobile Number *',
                          prefixText: '+91 ',
                          counterText: '',
                          labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          errorText: phoneError,
                          errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                        ),
                        onChanged: checkLivePhone,
                        validator: (v) => (v == null || v.trim().length != 10) ? 'Enter valid 10-digit number.' : phoneError,
                      ),
                      const SizedBox(height: 12),

                      // 📍 ADDRESS INPUT FIELD
                      TextFormField(
                        controller: addressController,
                        enabled: !isUpdating,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          labelText: 'Address / Location *',
                          labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF38BDF8), size: 20),
                          suffixIcon: isFetchingApi
                              ? const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Color(0xFF38BDF8), strokeWidth: 2)),
                                )
                              : null,
                        ),
                        onChanged: onAddressInputChanged,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Address required.' : null,
                      ),

                      // 🎯 REAL-TIME DROPDOWN SUGGESTIONS (DIRECTLY BELOW FIELD & AUTO-FILLS ON TAP)
                      if (apiSuggestions.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 150),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF38BDF8)),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: apiSuggestions.map((sug) {
                                  return InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () {
                                      addressController.text = sug;
                                      if (dialogCtx.mounted) {
                                        setDialogState(() => apiSuggestions = []);
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.pin_drop_rounded, color: Color(0xFF10B981), size: 16),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              sug,
                                              style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.3),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: isUpdating ? null : () => Navigator.pop(ctx),
                            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: (nameError != null || phoneError != null) ? Colors.grey : const Color(0xFF38BDF8),
                            ),
                            onPressed: (isUpdating || nameError != null || phoneError != null)
                                ? null
                                : () async {
                                    if (formKey.currentState!.validate()) {
                                      setButtonLoading('edit_$customerId', true);
                                      setDialogState(() {});

                                      try {
                                        final updatedName = nameController.text.trim();
                                        await FirebaseFirestore.instance.collection('customers').doc(customerId).update({
                                          'name': updatedName,
                                          'phone': phoneController.text.trim(),
                                          'address': addressController.text.trim(),
                                        });

                                        setButtonLoading('edit_$customerId', false);
                                        if (ctx.mounted) Navigator.pop(ctx);
                                        if (context.mounted) {
                                          showTopNotification(context, 'Customer "$updatedName" updated successfully!');
                                        }
                                      } catch (e) {
                                        setButtonLoading('edit_$customerId', false);
                                        if (dialogCtx.mounted) setDialogState(() {});
                                        if (context.mounted) {
                                          showTopNotification(context, 'Failed to update customer!', isError: true);
                                        }
                                      }
                                    }
                                  },
                            child: isUpdating
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                                : const Text('Update Ledger', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ➕ ADD NEW CUSTOMER MODAL (AUTO-FILL & SMOOTH DROPDOWN)
  static void openAddNewCustomerModal({
    required BuildContext context,
    required String operatorUid,
    required Color textColor,
    required Color cardBgColor,
    required bool Function(String id) isButtonLoading,
    required Function(String id, bool loading) setButtonLoading,
  }) {
    final formModalKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    String? liveNameError;
    String? livePhoneError;
    Timer? debounceTimer;

    List<String> apiSuggestions = [];
    bool isFetchingApi = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setModalState) {
          bool isAdding = isButtonLoading('add_customer');

          void checkNameLive(String value) {
            if (debounceTimer?.isActive ?? false) debounceTimer!.cancel();
            debounceTimer = Timer(const Duration(milliseconds: 300), () async {
              final text = value.trim().toLowerCase();
              if (text.isEmpty) {
                if (dialogCtx.mounted) setModalState(() => liveNameError = null);
                return;
              }

              final check = await FirebaseFirestore.instance
                  .collection('customers')
                  .where('operatorUid', isEqualTo: operatorUid)
                  .get();

              bool duplicate = check.docs.any((d) => (d.data()['name'] ?? '').toString().trim().toLowerCase() == text);

              if (dialogCtx.mounted) {
                setModalState(() {
                  liveNameError = duplicate ? 'Already Name Exists!' : null;
                });
              }
            });
          }

          void checkPhoneLive(String value) {
            if (debounceTimer?.isActive ?? false) debounceTimer!.cancel();
            debounceTimer = Timer(const Duration(milliseconds: 300), () async {
              final text = value.trim();
              if (text.length != 10) {
                if (dialogCtx.mounted) setModalState(() => livePhoneError = null);
                return;
              }

              final check = await FirebaseFirestore.instance
                  .collection('customers')
                  .where('operatorUid', isEqualTo: operatorUid)
                  .where('phone', isEqualTo: text)
                  .get();

              bool duplicate = check.docs.isNotEmpty;
              if (dialogCtx.mounted) {
                setModalState(() {
                  livePhoneError = duplicate ? 'Already Phone Number Exists!' : null;
                });
              }
            });
          }

          void onAddressInputChanged(String val) {
            if (debounceTimer?.isActive ?? false) debounceTimer!.cancel();
            if (val.trim().length < 2) {
              if (dialogCtx.mounted) {
                setModalState(() {
                  apiSuggestions = [];
                  isFetchingApi = false;
                });
              }
              return;
            }

            if (dialogCtx.mounted) setModalState(() => isFetchingApi = true);
            debounceTimer = Timer(const Duration(milliseconds: 350), () async {
              final results = await fetchAddressSuggestions(val);
              if (dialogCtx.mounted) {
                setModalState(() {
                  apiSuggestions = results;
                  isFetchingApi = false;
                });
              }
            });
          }

          return Dialog(
            backgroundColor: cardBgColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: 420,
              padding: const EdgeInsets.all(20),
              child: Form(
                key: formModalKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Add Customer', style: TextStyle(fontWeight: FontWeight.w900, color: textColor, fontSize: 16)),
                          IconButton(
                            icon: Icon(Icons.close_rounded, color: textColor.withOpacity(0.7), size: 22),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: 'Cancel',
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      TextFormField(
                        controller: nameController,
                        enabled: !isAdding,
                        style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
                        decoration: InputDecoration(
                          labelText: 'Customer Full Name *',
                          labelStyle: TextStyle(fontSize: 12, color: textColor),
                          errorText: liveNameError,
                          errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                        ),
                        onChanged: checkNameLive,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Customer name mandatory.' : liveNameError,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneController,
                        enabled: !isAdding,
                        style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        decoration: InputDecoration(
                          labelText: 'Mobile Number *',
                          prefixText: '+91 ',
                          counterText: '',
                          labelStyle: TextStyle(fontSize: 12, color: textColor),
                          errorText: livePhoneError,
                          errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                        ),
                        onChanged: checkPhoneLive,
                        validator: (v) => (v == null || v.trim().length != 10) ? 'Enter 10-digit primary mobile.' : livePhoneError,
                      ),
                      const SizedBox(height: 12),

                      // 📍 ADDRESS INPUT FIELD
                      TextFormField(
                        controller: addressController,
                        enabled: !isAdding,
                        style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
                        decoration: InputDecoration(
                          labelText: 'Address / Location *',
                          labelStyle: TextStyle(fontSize: 12, color: textColor),
                          prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF38BDF8), size: 20),
                          suffixIcon: isFetchingApi
                              ? const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Color(0xFF38BDF8), strokeWidth: 2)),
                                )
                              : null,
                        ),
                        onChanged: onAddressInputChanged,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Location address mandatory.' : null,
                      ),

                      // 🎯 REAL-TIME DROPDOWN SUGGESTIONS (DIRECTLY BELOW FIELD & AUTO-FILLS ON TAP)
                      if (apiSuggestions.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 150),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF38BDF8)),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: apiSuggestions.map((sug) {
                                  return InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () {
                                      addressController.text = sug;
                                      if (dialogCtx.mounted) {
                                        setModalState(() => apiSuggestions = []);
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.pin_drop_rounded, color: Color(0xFF10B981), size: 16),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              sug,
                                              style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.3),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(onPressed: isAdding ? null : () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(fontWeight: FontWeight.w900, color: textColor))),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: (liveNameError != null || livePhoneError != null) ? Colors.grey : const Color(0xFF10B981),
                            ),
                            onPressed: (isAdding || liveNameError != null || livePhoneError != null)
                                ? null
                                : () async {
                                    if (formModalKey.currentState!.validate()) {
                                      setButtonLoading('add_customer', true);
                                      setModalState(() {});

                                      try {
                                        final inputName = nameController.text.trim();
                                        final inputPhone = phoneController.text.trim();

                                        await FirebaseFirestore.instance.collection('customers').add({
                                          'operatorUid': operatorUid,
                                          'name': inputName,
                                          'phone': inputPhone,
                                          'address': addressController.text.trim(),
                                          'balance': 0.0,
                                          'isArchived': false,
                                          'createdAt': FieldValue.serverTimestamp(),
                                        });

                                        setButtonLoading('add_customer', false);
                                        if (ctx.mounted) Navigator.pop(ctx);
                                        if (context.mounted) {
                                          showTopNotification(context, 'New Customer "$inputName" added successfully!');
                                        }
                                      } catch (e) {
                                        setButtonLoading('add_customer', false);
                                        if (dialogCtx.mounted) setModalState(() {});
                                        if (context.mounted) {
                                          showTopNotification(context, 'Failed to add customer!', isError: true);
                                        }
                                      }
                                    }
                                  },
                            child: isAdding
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Save Customer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
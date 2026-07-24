
// // // import 'package:flutter/material.dart';
// // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // import 'package:firebase_auth/firebase_auth.dart';
// // // import 'package:intl/intl.dart';
// // // import '../../widgets/customer_dialogs.dart';

// // // class CustomerLedgerScreen extends StatefulWidget {
// // //   final String customerId;
// // //   final String customerName;
// // //   final String customerPhone;
// // //   final String customerAddress;

// // //   const CustomerLedgerScreen({
// // //     Key? key,
// // //     required this.customerId,
// // //     required this.customerName,
// // //     required this.customerPhone,
// // //     required this.customerAddress,
// // //   }) : super(key: key);

// // //   @override
// // //   State<CustomerLedgerScreen> createState() => _CustomerLedgerScreenState();
// // // }

// // // class _CustomerLedgerScreenState extends State<CustomerLedgerScreen> {
// // //   String? _editingTransactionId;
// // //   double _customerLiveBalance = 0.0;
// // //   final Map<String, bool> _buttonLoadingState = {};

// // //   void _setButtonLoading(String id, bool loading) {
// // //     if (mounted) {
// // //       setState(() {
// // //         _buttonLoadingState[id] = loading;
// // //       });
// // //     }
// // //   }

// // //   bool _isButtonLoading(String id) => _buttonLoadingState[id] ?? false;

// // //   Future<void> _commitTransactionPage({
// // //     required String productName,
// // //     required double price,
// // //     required double quantity,
// // //     required String commitMessage,
// // //     required String type,
// // //   }) async {
// // //     final user = FirebaseAuth.instance.currentUser;
// // //     if (user == null || productName.isEmpty) return;

// // //     double calculatedTotalPrice = price * quantity;

// // //     final txData = {
// // //       'operatorUid': user.uid,
// // //       'customerId': widget.customerId,
// // //       'customerName': widget.customerName,
// // //       'productName': productName.trim(),
// // //       'price': price,
// // //       'quantity': quantity,
// // //       'totalPrice': calculatedTotalPrice,
// // //       'type': type,
// // //       'commitMessage': commitMessage.trim(),
// // //       'timestamp': FieldValue.serverTimestamp(),
// // //     };

// // //     try {
// // //       if (_editingTransactionId != null) {
// // //         await _deleteTransactionImpact(_editingTransactionId!);
// // //         await FirebaseFirestore.instance.collection('transactions').doc(_editingTransactionId).update(txData);
// // //         _editingTransactionId = null;

// // //         if (mounted) {
// // //           CustomerDialogs.showTopNotification(context, 'Transaction entry updated successfully!');
// // //         }
// // //       } else {
// // //         await FirebaseFirestore.instance.collection('transactions').add(txData);
// // //         if (mounted) {
// // //           CustomerDialogs.showTopNotification(context, 'Added "$productName" (₹${calculatedTotalPrice.toStringAsFixed(2)})');
// // //         }
// // //       }

// // //       final customerRef = FirebaseFirestore.instance.collection('customers').doc(widget.customerId);
// // //       await FirebaseFirestore.instance.runTransaction((transaction) async {
// // //         final snapshot = await transaction.get(customerRef);
// // //         if (!snapshot.exists) return;
// // //         double currentBalance = double.tryParse(snapshot.data()?['balance']?.toString() ?? '0.0') ?? 0.0;
// // //         double newBalance = type == 'credit'
// // //             ? currentBalance + calculatedTotalPrice
// // //             : currentBalance - calculatedTotalPrice;
// // //         transaction.update(customerRef, {'balance': newBalance});
// // //       });
// // //     } catch (e) {
// // //       if (mounted) {
// // //         CustomerDialogs.showTopNotification(context, 'Failed to log transaction!', isError: true);
// // //       }
// // //     }
// // //   }

// // //   Future<void> _deleteTransactionImpact(String txId) async {
// // //     final txDoc = await FirebaseFirestore.instance.collection('transactions').doc(txId).get();
// // //     if (!txDoc.exists) return;

// // //     final txData = txDoc.data()!;
// // //     double oldTotal = double.tryParse(txData['totalPrice']?.toString() ?? '0.0') ?? 0.0;
// // //     String oldType = txData['type'] ?? 'credit';

// // //     final customerRef = FirebaseFirestore.instance.collection('customers').doc(widget.customerId);
// // //     await FirebaseFirestore.instance.runTransaction((transaction) async {
// // //       final snapshot = await transaction.get(customerRef);
// // //       if (!snapshot.exists) return;
// // //       double currentBalance = double.tryParse(snapshot.data()?['balance']?.toString() ?? '0.0') ?? 0.0;
// // //       double reversedBalance = oldType == 'credit' ? currentBalance - oldTotal : currentBalance + oldTotal;
// // //       transaction.update(customerRef, {'balance': reversedBalance});
// // //     });
// // //   }

// // //   void _triggerEditMode(DocumentSnapshot doc) {
// // //     final data = doc.data() as Map<String, dynamic>;
// // //     _editingTransactionId = doc.id;

// // //     _openTransactionFormSheet(
// // //       context: context,
// // //       initialType: data['type'] ?? 'credit',
// // //       prefillName: data['productName'] ?? '',
// // //       prefillPrice: (data['price'] ?? 0.0).toString(),
// // //       prefillQty: (data['quantity'] ?? 0.0).toString(),
// // //       prefillCommit: data['commitMessage'] ?? '',
// // //     );
// // //   }

// // //   // 🗑️ UPDATED DELETE TRIGGER: Archives to `deleted_products_history` instead of direct purge
// // //   void _triggerDelete(String txId, String productName, Map<String, dynamic> txData) async {
// // //     bool confirm = await CustomerDialogs.openSecureDeleteDialog(
// // //       context: context,
// // //       customerId: txId,
// // //       customerName: productName,
// // //       isButtonLoading: _isButtonLoading,
// // //       setButtonLoading: _setButtonLoading,
// // //       isPermanent: true,
// // //     );

// // //     if (confirm) {
// // //       _setButtonLoading('tx_del_$txId', true);
// // //       try {
// // //         final currentUser = FirebaseAuth.instance.currentUser;

// // //         // 1. Save deleted product details to deleted_products_history collection
// // //         await FirebaseFirestore.instance.collection('deleted_products_history').add({
// // //           ...txData,
// // //           'originalTxId': txId,
// // //           'operatorUid': currentUser?.uid ?? txData['operatorUid'],
// // //           'deletedAt': FieldValue.serverTimestamp(),
// // //           'deletedAtIso': DateTime.now().toIso8601String(),
// // //         });

// // //         // 2. Adjust customer balance impact
// // //         await _deleteTransactionImpact(txId);

// // //         // 3. Remove entry from active transactions collection
// // //         await FirebaseFirestore.instance.collection('transactions').doc(txId).delete();

// // //         _setButtonLoading('tx_del_$txId', false);
// // //         if (mounted) {
// // //           CustomerDialogs.showTopNotification(context, '"$productName" moved to History successfully!');
// // //         }
// // //       } catch (e) {
// // //         _setButtonLoading('tx_del_$txId', false);
// // //         if (mounted) {
// // //           CustomerDialogs.showTopNotification(context, 'Failed to move product to history!', isError: true);
// // //         }
// // //       }
// // //     }
// // //   }

// // //   void _showCommitNoteModal(String productName, String commitMessage) {
// // //     showDialog(
// // //       context: context,
// // //       builder: (ctx) => AlertDialog(
// // //         backgroundColor: const Color(0xFF0F172A),
// // //         shape: RoundedRectangleBorder(
// // //           borderRadius: BorderRadius.circular(16),
// // //           side: const BorderSide(color: Color(0xFF38BDF8), width: 1.2),
// // //         ),
// // //         title: Row(
// // //           children: [
// // //             const Icon(Icons.note_alt_rounded, color: Color(0xFF38BDF8), size: 22),
// // //             const SizedBox(width: 8),
// // //             Expanded(
// // //               child: Text(
// // //                 'Audit Note: $productName',
// // //                 style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
// // //                 overflow: TextOverflow.ellipsis,
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //         content: Container(
// // //           width: double.maxFinite,
// // //           padding: const EdgeInsets.all(14),
// // //           decoration: BoxDecoration(
// // //             color: const Color(0xFF070A0F),
// // //             borderRadius: BorderRadius.circular(10),
// // //             border: Border.all(color: const Color(0xFF1E293B)),
// // //           ),
// // //           child: Text(
// // //             commitMessage.isNotEmpty ? commitMessage : 'No audit commitment note attached to this entry.',
// // //             style: TextStyle(
// // //               color: commitMessage.isNotEmpty ? Colors.white70 : Colors.grey.shade600,
// // //               fontSize: 13,
// // //               height: 1.4,
// // //               fontStyle: commitMessage.isNotEmpty ? FontStyle.normal : FontStyle.italic,
// // //             ),
// // //           ),
// // //         ),
// // //         actions: [
// // //           ElevatedButton(
// // //             style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8)),
// // //             onPressed: () => Navigator.pop(ctx),
// // //             child: const Text('Close', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   void _openTransactionFormSheet({
// // //     required BuildContext context,
// // //     required String initialType,
// // //     String prefillName = '',
// // //     String prefillPrice = '',
// // //     String prefillQty = '',
// // //     String prefillCommit = '',
// // //   }) {
// // //     final nameController = TextEditingController(text: prefillName);
// // //     final priceController = TextEditingController(text: prefillPrice);
// // //     final qtyController = TextEditingController(text: prefillQty);
// // //     final commitController = TextEditingController(text: prefillCommit);
// // //     final formKey = GlobalKey<FormState>();

// // //     double localTotalCalculated = 0.0;

// // //     showModalBottomSheet(
// // //       context: context,
// // //       isScrollControlled: true,
// // //       backgroundColor: const Color(0xFF0F172A),
// // //       shape: const RoundedRectangleBorder(
// // //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// // //       ),
// // //       builder: (sheetContext) {
// // //         return StatefulBuilder(
// // //           builder: (BuildContext context, StateSetter setSheetState) {
// // //             void updateLocalSum() {
// // //               double p = double.tryParse(priceController.text) ?? 0.0;
// // //               double q = double.tryParse(qtyController.text) ?? 0.0;
// // //               setSheetState(() {
// // //                 localTotalCalculated = p * q;
// // //               });
// // //             }

// // //             if (priceController.text.isNotEmpty && qtyController.text.isNotEmpty && localTotalCalculated == 0.0) {
// // //               double p = double.tryParse(priceController.text) ?? 0.0;
// // //               double q = double.tryParse(qtyController.text) ?? 0.0;
// // //               localTotalCalculated = p * q;
// // //             }

// // //             return Padding(
// // //               padding: EdgeInsets.only(
// // //                 bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
// // //                 left: 24,
// // //                 right: 24,
// // //                 top: 24,
// // //               ),
// // //               child: Form(
// // //                 key: formKey,
// // //                 child: SingleChildScrollView(
// // //                   child: Column(
// // //                     crossAxisAlignment: CrossAxisAlignment.stretch,
// // //                     mainAxisSize: MainAxisSize.min,
// // //                     children: [
// // //                       Row(
// // //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                         children: [
// // //                           Text(
// // //                             _editingTransactionId != null
// // //                                 ? 'Edit Entry Record'
// // //                                 : (initialType == 'credit' ? 'New Asset Credit Entry' : 'New Asset Debit Entry'),
// // //                             style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
// // //                           ),
// // //                           CircleAvatar(
// // //                             backgroundColor: initialType == 'credit'
// // //                                 ? const Color(0xFFEF4444).withOpacity(0.2)
// // //                                 : const Color(0xFF10B981).withOpacity(0.2),
// // //                             radius: 12,
// // //                             child: Container(
// // //                               width: 8,
// // //                               height: 8,
// // //                               decoration: BoxDecoration(
// // //                                 shape: BoxShape.circle,
// // //                                 color: initialType == 'credit' ? const Color(0xFFEF4444) : const Color(0xFF10B981),
// // //                               ),
// // //                             ),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                       const Divider(color: Color(0xFF1E293B), height: 24),
// // //                       TextFormField(
// // //                         controller: nameController,
// // //                         style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// // //                         decoration: const InputDecoration(
// // //                           labelText: 'Product / Service Nomenclature *',
// // //                           labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
// // //                           focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF38BDF8))),
// // //                         ),
// // //                         validator: (v) => (v == null || v.trim().isEmpty) ? 'Product description required.' : null,
// // //                       ),
// // //                       const SizedBox(height: 14),
// // //                       Row(
// // //                         children: [
// // //                           Expanded(
// // //                             child: TextFormField(
// // //                               controller: priceController,
// // //                               keyboardType: TextInputType.number,
// // //                               style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// // //                               decoration: const InputDecoration(
// // //                                 labelText: 'Unit Price (₹) *',
// // //                                 labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
// // //                                 focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF38BDF8))),
// // //                               ),
// // //                               onChanged: (v) => updateLocalSum(),
// // //                               validator: (v) => (v == null || double.tryParse(v) == null) ? 'Invalid Price.' : null,
// // //                             ),
// // //                           ),
// // //                           const SizedBox(width: 16),
// // //                           Expanded(
// // //                             child: TextFormField(
// // //                               controller: qtyController,
// // //                               keyboardType: TextInputType.number,
// // //                               style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// // //                               decoration: const InputDecoration(
// // //                                 labelText: 'Count (Qty) *',
// // //                                 labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
// // //                                 focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF38BDF8))),
// // //                               ),
// // //                               onChanged: (v) => updateLocalSum(),
// // //                               validator: (v) => (v == null || double.tryParse(v) == null) ? 'Invalid Qty.' : null,
// // //                             ),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                       const SizedBox(height: 14),
// // //                       TextFormField(
// // //                         controller: commitController,
// // //                         style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// // //                         decoration: const InputDecoration(
// // //                           labelText: 'Optional Audit Commitment Message',
// // //                           labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
// // //                           focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF38BDF8))),
// // //                         ),
// // //                       ),
// // //                       const SizedBox(height: 20),
// // //                       Container(
// // //                         padding: const EdgeInsets.all(14),
// // //                         decoration: BoxDecoration(
// // //                           color: const Color(0xFF070A0F),
// // //                           borderRadius: BorderRadius.circular(10),
// // //                           border: Border.all(color: const Color(0xFF1E293B)),
// // //                         ),
// // //                         child: Row(
// // //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                           children: [
// // //                             const Text('Calculated Total:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.bold)),
// // //                             Text('₹${localTotalCalculated.toStringAsFixed(2)}', style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.w900)),
// // //                           ],
// // //                         ),
// // //                       ),
// // //                       const SizedBox(height: 24),
// // //                       SizedBox(
// // //                         height: 48,
// // //                         child: ElevatedButton(
// // //                           style: ElevatedButton.styleFrom(
// // //                             backgroundColor: const Color(0xFF38BDF8),
// // //                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// // //                           ),
// // //                           onPressed: () {
// // //                             if (formKey.currentState!.validate()) {
// // //                               _commitTransactionPage(
// // //                                 productName: nameController.text,
// // //                                 price: double.parse(priceController.text),
// // //                                 quantity: double.parse(qtyController.text),
// // //                                 commitMessage: commitController.text,
// // //                                 type: initialType,
// // //                               );
// // //                               Navigator.pop(sheetContext);
// // //                             }
// // //                           },
// // //                           child: const Text('Save & Update Changes', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
// // //                         ),
// // //                       )
// // //                     ],
// // //                   ),
// // //                 ),
// // //               ),
// // //             );
// // //           },
// // //         );
// // //       },
// // //     );
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final double screenWidth = MediaQuery.of(context).size.width;
// // //     final bool isDesktop = screenWidth > 1024;

// // //     return Scaffold(
// // //       backgroundColor: Colors.black,
// // //       appBar: AppBar(
// // //         backgroundColor: const Color(0xFF0F172A),
// // //         elevation: 0,
// // //         title: Text(widget.customerName, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 18)),
// // //         iconTheme: const IconThemeData(color: Colors.white),
// // //         actions: [
// // //           IconButton(
// // //             icon: const Icon(Icons.cloud_upload_rounded, color: Color(0xFF38BDF8)),
// // //             tooltip: 'Push Ledger History Logs',
// // //             onPressed: () {
// // //               CustomerDialogs.showTopNotification(context, 'Ledger workspace snapshot saved to data nodes.');
// // //             },
// // //           ),
// // //           const SizedBox(width: 8),
// // //         ],
// // //         shape: const Border(bottom: BorderSide(color: Color(0xFF1E293B), width: 1)),
// // //       ),
// // //       body: isDesktop ? _buildWebDesktopLayout() : _buildMobileLayout(),
// // //     );
// // //   }

// // //   Widget _buildWebDesktopLayout() {
// // //     return Row(
// // //       children: [
// // //         Container(
// // //           width: 280,
// // //           padding: const EdgeInsets.all(24),
// // //           decoration: const BoxDecoration(
// // //             color: Color(0xFF0F172A),
// // //             border: Border(right: BorderSide(color: Color(0xFF1E293B), width: 1.5)),
// // //           ),
// // //           child: Column(
// // //             crossAxisAlignment: CrossAxisAlignment.stretch,
// // //             children: [
// // //               const Text('TRANSACTION DESK', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2)),
// // //               const SizedBox(height: 24),
// // //               SizedBox(
// // //                 height: 50,
// // //                 child: ElevatedButton.icon(
// // //                   style: ElevatedButton.styleFrom(
// // //                     backgroundColor: const Color(0xFFEF4444),
// // //                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // //                   ),
// // //                   onPressed: () => _openTransactionFormSheet(context: context, initialType: 'credit'),
// // //                   icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.white, size: 18),
// // //                   label: const Text('Asset Credit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
// // //                 ),
// // //               ),
// // //               const SizedBox(height: 16),
// // //               SizedBox(
// // //                 height: 50,
// // //                 child: ElevatedButton.icon(
// // //                   style: ElevatedButton.styleFrom(
// // //                     backgroundColor: const Color(0xFF10B981),
// // //                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // //                   ),
// // //                   onPressed: () => _openTransactionFormSheet(context: context, initialType: 'debit'),
// // //                   icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 18),
// // //                   label: const Text('Asset Debit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
// // //                 ),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //         Expanded(
// // //           child: SingleChildScrollView(
// // //             padding: const EdgeInsets.all(32),
// // //             child: Column(
// // //               crossAxisAlignment: CrossAxisAlignment.stretch,
// // //               children: [
// // //                 _buildCustomerHeaderCard(),
// // //                 const SizedBox(height: 32),
// // //                 const Text('Historical Ledger Node Pages', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.3)),
// // //                 const SizedBox(height: 16),
// // //                 _buildTransactionGridStream(isDesktop: true),
// // //               ],
// // //             ),
// // //           ),
// // //         )
// // //       ],
// // //     );
// // //   }

// // //   Widget _buildMobileLayout() {
// // //     return Column(
// // //       children: [
// // //         Expanded(
// // //           child: SingleChildScrollView(
// // //             padding: const EdgeInsets.all(16),
// // //             child: Column(
// // //               crossAxisAlignment: CrossAxisAlignment.stretch,
// // //               children: [
// // //                 _buildCustomerHeaderCard(),
// // //                 const SizedBox(height: 20),
// // //                 const Text('Historical Ledger Node Pages', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.3)),
// // //                 const SizedBox(height: 12),
// // //                 _buildTransactionGridStream(isDesktop: false),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //         Container(
// // //           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
// // //           decoration: const BoxDecoration(
// // //             color: Color(0xFF0F172A),
// // //             border: Border(top: BorderSide(color: Color(0xFF1E293B), width: 1.5)),
// // //           ),
// // //           child: Row(
// // //             children: [
// // //               Expanded(
// // //                 child: SizedBox(
// // //                   height: 48,
// // //                   child: ElevatedButton.icon(
// // //                     style: ElevatedButton.styleFrom(
// // //                       backgroundColor: const Color(0xFFEF4444),
// // //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // //                     ),
// // //                     onPressed: () => _openTransactionFormSheet(context: context, initialType: 'credit'),
// // //                     icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.white, size: 18),
// // //                     label: const Text('Asset Credit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
// // //                   ),
// // //                 ),
// // //               ),
// // //               const SizedBox(width: 14),
// // //               Expanded(
// // //                 child: SizedBox(
// // //                   height: 48,
// // //                   child: ElevatedButton.icon(
// // //                     style: ElevatedButton.styleFrom(
// // //                       backgroundColor: const Color(0xFF10B981),
// // //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // //                     ),
// // //                     onPressed: () => _openTransactionFormSheet(context: context, initialType: 'debit'),
// // //                     icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 18),
// // //                     label: const Text('Asset Debit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
// // //                   ),
// // //                 ),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   Widget _buildCustomerHeaderCard() {
// // //     return Container(
// // //       padding: const EdgeInsets.all(20),
// // //       decoration: BoxDecoration(
// // //         color: const Color(0xFF0F172A),
// // //         borderRadius: BorderRadius.circular(14),
// // //         border: Border.all(color: const Color(0xFF1E293B), width: 1.5),
// // //       ),
// // //       child: Column(
// // //         crossAxisAlignment: CrossAxisAlignment.start,
// // //         children: [
// // //           Row(
// // //             children: [
// // //               const Icon(Icons.phone_iphone_rounded, color: Color(0xFF38BDF8), size: 16),
// // //               const SizedBox(width: 8),
// // //               Text('Primary Comm Line: +91 ${widget.customerPhone}', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13)),
// // //             ],
// // //           ),
// // //           const SizedBox(height: 8),
// // //           Row(
// // //             children: [
// // //               const Icon(Icons.location_on_outlined, color: Colors.grey, size: 16),
// // //               const SizedBox(width: 8),
// // //               Expanded(
// // //                 child: Text('Warehouse Node: ${widget.customerAddress}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600)),
// // //               ),
// // //             ],
// // //           ),
// // //           const SizedBox(height: 14),
// // //           StreamBuilder<DocumentSnapshot>(
// // //             stream: FirebaseFirestore.instance.collection('customers').doc(widget.customerId).snapshots(),
// // //             builder: (context, snapshot) {
// // //               if (snapshot.hasData && snapshot.data!.exists) {
// // //                 _customerLiveBalance = double.tryParse(snapshot.data!['balance']?.toString() ?? '0.0') ?? 0.0;
// // //               }

// // //               final double absoluteDisplayValue = _customerLiveBalance.abs();
// // //               final String formattedBalance = '+₹${absoluteDisplayValue.toStringAsFixed(2)}';

// // //               return Container(
// // //                 padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
// // //                 decoration: BoxDecoration(
// // //                   color: const Color(0xFF070A0F),
// // //                   borderRadius: BorderRadius.circular(10),
// // //                   border: Border.all(color: const Color(0xFF1E293B)),
// // //                 ),
// // //                 child: Row(
// // //                   mainAxisSize: MainAxisSize.min,
// // //                   children: [
// // //                     const Text('Active Balance Matrix: ', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.bold)),
// // //                     Text(
// // //                       formattedBalance,
// // //                       style: TextStyle(
// // //                         color: _customerLiveBalance >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
// // //                         fontSize: 16,
// // //                         fontWeight: FontWeight.w900,
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               );
// // //             },
// // //           )
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildTransactionGridStream({required bool isDesktop}) {
// // //     return StreamBuilder<QuerySnapshot>(
// // //       stream: FirebaseFirestore.instance
// // //           .collection('transactions')
// // //           .where('customerId', isEqualTo: widget.customerId)
// // //           .snapshots(),
// // //       builder: (context, snapshot) {
// // //         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
// // //           return const Padding(
// // //             padding: EdgeInsets.symmetric(vertical: 40),
// // //             child: Center(child: Text('No transaction entries logged on this account array.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.bold))),
// // //           );
// // //         }

// // //         return isDesktop
// // //             ? GridView.builder(
// // //                 shrinkWrap: true,
// // //                 physics: const NeverScrollableScrollPhysics(),
// // //                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// // //                   crossAxisCount: 2,
// // //                   crossAxisSpacing: 16,
// // //                   mainAxisSpacing: 12,
// // //                   childAspectRatio: 4.2,
// // //                 ),
// // //                 itemCount: snapshot.data!.docs.length,
// // //                 itemBuilder: (context, idx) => _buildTransactionItemRow(snapshot.data!.docs[idx]),
// // //               )
// // //             : ListView.builder(
// // //                 shrinkWrap: true,
// // //                 physics: const NeverScrollableScrollPhysics(),
// // //                 itemCount: snapshot.data!.docs.length,
// // //                 itemBuilder: (context, idx) => _buildTransactionItemRow(snapshot.data!.docs[idx]),
// // //               );
// // //       },
// // //     );
// // //   }

// // //   Widget _buildTransactionItemRow(DocumentSnapshot doc) {
// // //     final tx = doc.data() as Map<String, dynamic>;
// // //     final String txId = doc.id;
// // //     final String productName = tx['productName'] ?? 'Item Entry';
// // //     final String commitMsg = (tx['commitMessage'] ?? '').toString();
// // //     final double tPrice = double.tryParse(tx['totalPrice']?.toString() ?? '0.0') ?? 0.0;
    
// // //     final Timestamp? timestamp = tx['timestamp'] as Timestamp?;
// // //     final DateTime txDate = timestamp != null ? timestamp.toDate() : DateTime.now();
// // //     final String formattedTime = DateFormat('dd MMM, hh:mm a').format(txDate);

// // //     bool isDeleting = _isButtonLoading('tx_del_$txId');

// // //     return Container(
// // //       margin: const EdgeInsets.only(bottom: 10),
// // //       padding: const EdgeInsets.all(14),
// // //       decoration: BoxDecoration(
// // //         color: const Color(0xFF0F172A),
// // //         borderRadius: BorderRadius.circular(12),
// // //         border: Border.all(color: const Color(0xFF1E293B), width: 1.2),
// // //       ),
// // //       child: Row(
// // //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //         children: [
// // //           Expanded(
// // //             child: Column(
// // //               crossAxisAlignment: CrossAxisAlignment.start,
// // //               mainAxisAlignment: MainAxisAlignment.center,
// // //               children: [
// // //                 Text(
// // //                   productName,
// // //                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
// // //                   maxLines: 1,
// // //                   overflow: TextOverflow.ellipsis,
// // //                 ),
// // //                 const SizedBox(height: 3),
// // //                 Text(
// // //                   'Vol: ${tx['quantity']} x ₹${tx['price']}  •  $formattedTime',
// // //                   style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold),
// // //                   maxLines: 1,
// // //                   overflow: TextOverflow.ellipsis,
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //           Row(
// // //             children: [
// // //               Text(
// // //                 '₹${tPrice.toStringAsFixed(2)}',
// // //                 style: TextStyle(
// // //                   color: tx['type'] == 'credit' ? const Color(0xFFEF4444) : const Color(0xFF10B981),
// // //                   fontWeight: FontWeight.w900,
// // //                   fontSize: 14,
// // //                 ),
// // //               ),
// // //               const SizedBox(width: 6),
// // //               IconButton(
// // //                 padding: EdgeInsets.zero,
// // //                 constraints: const BoxConstraints(),
// // //                 icon: Icon(
// // //                   Icons.chat_bubble_outline_rounded,
// // //                   color: commitMsg.isNotEmpty ? const Color(0xFF38BDF8) : Colors.grey.shade700,
// // //                   size: 18,
// // //                 ),
// // //                 tooltip: 'View Commitment Note',
// // //                 onPressed: () => _showCommitNoteModal(productName, commitMsg),
// // //               ),
// // //               const SizedBox(width: 8),
// // //               IconButton(
// // //                 padding: EdgeInsets.zero,
// // //                 constraints: const BoxConstraints(),
// // //                 icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF38BDF8), size: 22),
// // //                 tooltip: 'Edit Record Entry',
// // //                 onPressed: () => _triggerEditMode(doc),
// // //               ),
// // //               const SizedBox(width: 8),
// // //               IconButton(
// // //                 padding: EdgeInsets.zero,
// // //                 constraints: const BoxConstraints(),
// // //                 icon: isDeleting
// // //                     ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Color(0xFFEF4444), strokeWidth: 2))
// // //                     : const Icon(Icons.delete_forever_rounded, color: Color(0xFFEF4444), size: 20),
// // //                 tooltip: 'Delete Record Entry',
// // //                 onPressed: () => _triggerDelete(txId, productName, tx), // 👈 Updated to pass tx data
// // //               ),
// // //             ],
// // //           )
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }

// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:intl/intl.dart';
// // import '../../widgets/customer_dialogs.dart';

// // class CustomerLedgerScreen extends StatefulWidget {
// //   final String customerId;
// //   final String customerName;
// //   final String customerPhone;
// //   final String customerAddress;

// //   const CustomerLedgerScreen({
// //     Key? key,
// //     required this.customerId,
// //     required this.customerName,
// //     required this.customerPhone,
// //     required this.customerAddress,
// //   }) : super(key: key);

// //   @override
// //   State<CustomerLedgerScreen> createState() => _CustomerLedgerScreenState();
// // }

// // class _CustomerLedgerScreenState extends State<CustomerLedgerScreen> {
// //   String? _editingTransactionId;
// //   double _customerLiveBalance = 0.0;
// //   final Map<String, bool> _buttonLoadingState = {};

// //   void _setButtonLoading(String id, bool loading) {
// //     if (mounted) {
// //       setState(() {
// //         _buttonLoadingState[id] = loading;
// //       });
// //     }
// //   }

// //   bool _isButtonLoading(String id) => _buttonLoadingState[id] ?? false;

// //   // 💰 Commit Transaction Logic with Debit Cap Limit
// //   Future<void> _commitTransactionPage({
// //     required String productName,
// //     required double price,
// //     required double quantity,
// //     required String commitMessage,
// //     required String type,
// //   }) async {
// //     final user = FirebaseAuth.instance.currentUser;
// //     if (user == null || productName.isEmpty) return;

// //     double calculatedTotalPrice = price * quantity;

// //     // 🛑 Limit check: Asset Debit standard balance पेक्षा जास्त असू शकत नाही
// //     if (type == 'debit' && _editingTransactionId == null) {
// //       if (calculatedTotalPrice > _customerLiveBalance) {
// //         CustomerDialogs.showTopNotification(
// //           context,
// //           'Debit amount (₹${calculatedTotalPrice.toStringAsFixed(2)}) cannot exceed total active credit (₹${_customerLiveBalance.toStringAsFixed(2)})!',
// //           isError: true,
// //         );
// //         return;
// //       }
// //     }

// //     final txData = {
// //       'operatorUid': user.uid,
// //       'customerId': widget.customerId,
// //       'customerName': widget.customerName,
// //       'productName': productName.trim(),
// //       'price': price,
// //       'quantity': quantity,
// //       'totalPrice': calculatedTotalPrice,
// //       'type': type,
// //       'commitMessage': commitMessage.trim(),
// //       'timestamp': FieldValue.serverTimestamp(),
// //     };

// //     try {
// //       if (_editingTransactionId != null) {
// //         await _deleteTransactionImpact(_editingTransactionId!);
// //         await FirebaseFirestore.instance.collection('transactions').doc(_editingTransactionId).update(txData);
// //         _editingTransactionId = null;

// //         if (mounted) {
// //           CustomerDialogs.showTopNotification(context, 'Transaction entry updated successfully!');
// //         }
// //       } else {
// //         await FirebaseFirestore.instance.collection('transactions').add(txData);
// //         if (mounted) {
// //           CustomerDialogs.showTopNotification(context, 'Added "$productName" (₹${calculatedTotalPrice.toStringAsFixed(2)})');
// //         }
// //       }

// //       // 🔄 Update Customer Account Balance
// //       final customerRef = FirebaseFirestore.instance.collection('customers').doc(widget.customerId);
// //       await FirebaseFirestore.instance.runTransaction((transaction) async {
// //         final snapshot = await transaction.get(customerRef);
// //         if (!snapshot.exists) return;
// //         double currentBalance = double.tryParse(snapshot.data()?['balance']?.toString() ?? '0.0') ?? 0.0;
        
// //         // Credit increases balance, Debit reduces it
// //         double newBalance = type == 'credit'
// //             ? currentBalance + calculatedTotalPrice
// //             : currentBalance - calculatedTotalPrice;
            
// //         transaction.update(customerRef, {'balance': newBalance < 0 ? 0.0 : newBalance});
// //       });
// //     } catch (e) {
// //       if (mounted) {
// //         CustomerDialogs.showTopNotification(context, 'Failed to log transaction!', isError: true);
// //       }
// //     }
// //   }

// //   // 🔄 Reverse Balance on Delete/Edit
// //   Future<void> _deleteTransactionImpact(String txId) async {
// //     final txDoc = await FirebaseFirestore.instance.collection('transactions').doc(txId).get();
// //     if (!txDoc.exists) return;

// //     final txData = txDoc.data()!;
// //     double oldTotal = double.tryParse(txData['totalPrice']?.toString() ?? '0.0') ?? 0.0;
// //     String oldType = txData['type'] ?? 'credit';

// //     final customerRef = FirebaseFirestore.instance.collection('customers').doc(widget.customerId);
// //     await FirebaseFirestore.instance.runTransaction((transaction) async {
// //       final snapshot = await transaction.get(customerRef);
// //       if (!snapshot.exists) return;
// //       double currentBalance = double.tryParse(snapshot.data()?['balance']?.toString() ?? '0.0') ?? 0.0;
      
// //       double reversedBalance = oldType == 'credit' ? currentBalance - oldTotal : currentBalance + oldTotal;
// //       transaction.update(customerRef, {'balance': reversedBalance < 0 ? 0.0 : reversedBalance});
// //     });
// //   }
// //   // ✏️ Trigger Edit Mode
// //   void _triggerEditMode(DocumentSnapshot doc) {
// //     final data = doc.data() as Map<String, dynamic>;
// //     _editingTransactionId = doc.id;

// //     _openTransactionFormSheet(
// //       context: context,
// //       initialType: data['type'] ?? 'credit',
// //       prefillName: data['productName'] ?? '',
// //       prefillPrice: (data['price'] ?? 0.0).toString(),
// //       prefillQty: (data['quantity'] ?? 0.0).toString(),
// //       prefillCommit: data['commitMessage'] ?? '',
// //     );
// //   }

// //   // ☁️ Push Data to Historybook Dialog Function
// //   void _showPushToHistoryDialog() {
// //     showDialog(
// //       context: context,
// //       builder: (dialogCtx) => AlertDialog(
// //         backgroundColor: const Color(0xFF0F172A),
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(16),
// //           side: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
// //         ),
// //         title: const Row(
// //           children: [
// //             Icon(Icons.cloud_upload_rounded, color: Color(0xFF38BDF8), size: 24),
// //             SizedBox(width: 10),
// //             Text('Push Data in Historybook?', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
// //           ],
// //         ),
// //         content: const Text(
// //           'This action will create a permanent historical snapshot of all entries logged for this account in the global Historybook.',
// //           style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.4),
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(dialogCtx),
// //             child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
// //           ),
// //           ElevatedButton(
// //             style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8)),
// //             onPressed: () async {
// //               Navigator.pop(dialogCtx);
// //               await _executePushToHistorybook();
// //             },
// //             child: const Text('Push Now', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ☁️ Execute Historybook Push Logic
// //   Future<void> _executePushToHistorybook() async {
// //     final currentUser = FirebaseAuth.instance.currentUser;
// //     if (currentUser == null) return;

// //     try {
// //       final txSnap = await FirebaseFirestore.instance
// //           .collection('transactions')
// //           .where('customerId', isEqualTo: widget.customerId)
// //           .get();

// //       if (txSnap.docs.isEmpty) {
// //         CustomerDialogs.showTopNotification(context, 'No transactions found to push!', isError: true);
// //         return;
// //       }

// //       final batch = FirebaseFirestore.instance.batch();
// //       for (var doc in txSnap.docs) {
// //         final data = doc.data();
// //         final historyRef = FirebaseFirestore.instance.collection('historybook').doc();
// //         batch.set(historyRef, {
// //           ...data,
// //           'pushedAt': FieldValue.serverTimestamp(),
// //           'operatorUid': currentUser.uid,
// //           'customerName': widget.customerName,
// //         });
// //       }

// //       await batch.commit();
// //       if (mounted) {
// //         CustomerDialogs.showTopNotification(context, 'Pushed ${txSnap.docs.length} entries to Historybook successfully!');
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         CustomerDialogs.showTopNotification(context, 'Failed to push to Historybook!', isError: true);
// //       }
// //     }
// //   }

// //   void _triggerDelete(String txId, String productName, Map<String, dynamic> txData) async {
// //     bool confirm = await CustomerDialogs.openSecureDeleteDialog(
// //       context: context,
// //       customerId: txId,
// //       customerName: productName,
// //       isButtonLoading: _isButtonLoading,
// //       setButtonLoading: _setButtonLoading,
// //       isPermanent: true,
// //     );

// //     if (confirm) {
// //       _setButtonLoading('tx_del_$txId', true);
// //       try {
// //         final currentUser = FirebaseAuth.instance.currentUser;

// //         await FirebaseFirestore.instance.collection('deleted_products_history').add({
// //           ...txData,
// //           'originalTxId': txId,
// //           'operatorUid': currentUser?.uid ?? txData['operatorUid'],
// //           'deletedAt': FieldValue.serverTimestamp(),
// //         });

// //         await _deleteTransactionImpact(txId);
// //         await FirebaseFirestore.instance.collection('transactions').doc(txId).delete();

// //         _setButtonLoading('tx_del_$txId', false);
// //         if (mounted) {
// //           CustomerDialogs.showTopNotification(context, '"$productName" removed & balance adjusted!');
// //         }
// //       } catch (e) {
// //         _setButtonLoading('tx_del_$txId', false);
// //         if (mounted) {
// //           CustomerDialogs.showTopNotification(context, 'Failed to remove entry!', isError: true);
// //         }
// //       }
// //     }
// //   }

// //   void _showCommitNoteModal(String productName, String commitMessage) {
// //     showDialog(
// //       context: context,
// //       builder: (ctx) => AlertDialog(
// //         backgroundColor: const Color(0xFF0F172A),
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(16),
// //           side: const BorderSide(color: Color(0xFF38BDF8), width: 1.2),
// //         ),
// //         title: Row(
// //           children: [
// //             const Icon(Icons.note_alt_rounded, color: Color(0xFF38BDF8), size: 22),
// //             const SizedBox(width: 8),
// //             Expanded(
// //               child: Text(
// //                 'Audit Note: $productName',
// //                 style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
// //                 overflow: TextOverflow.ellipsis,
// //               ),
// //             ),
// //           ],
// //         ),
// //         content: Container(
// //           width: double.maxFinite,
// //           padding: const EdgeInsets.all(14),
// //           decoration: BoxDecoration(
// //             color: const Color(0xFF070A0F),
// //             borderRadius: BorderRadius.circular(10),
// //             border: Border.all(color: const Color(0xFF1E293B)),
// //           ),
// //           child: Text(
// //             commitMessage.isNotEmpty ? commitMessage : 'No audit commitment note attached.',
// //             style: TextStyle(
// //               color: commitMessage.isNotEmpty ? Colors.white70 : Colors.grey.shade600,
// //               fontSize: 13,
// //             ),
// //           ),
// //         ),
// //         actions: [
// //           ElevatedButton(
// //             style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8)),
// //             onPressed: () => Navigator.pop(ctx),
// //             child: const Text('Close', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   void _openTransactionFormSheet({
// //     required BuildContext context,
// //     required String initialType,
// //     String prefillName = '',
// //     String prefillPrice = '',
// //     String prefillQty = '',
// //     String prefillCommit = '',
// //   }) {
// //     final nameController = TextEditingController(text: prefillName);
// //     final priceController = TextEditingController(text: prefillPrice);
// //     final qtyController = TextEditingController(text: prefillQty);
// //     final commitController = TextEditingController(text: prefillCommit);
// //     final formKey = GlobalKey<FormState>();

// //     double localTotalCalculated = 0.0;

// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       backgroundColor: const Color(0xFF0F172A),
// //       shape: const RoundedRectangleBorder(
// //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //       ),
// //       builder: (sheetContext) {
// //         return StatefulBuilder(
// //           builder: (BuildContext context, StateSetter setSheetState) {
// //             void updateLocalSum() {
// //               double p = double.tryParse(priceController.text) ?? 0.0;
// //               double q = double.tryParse(qtyController.text) ?? 0.0;
// //               setSheetState(() {
// //                 localTotalCalculated = p * q;
// //               });
// //             }

// //             if (priceController.text.isNotEmpty && qtyController.text.isNotEmpty && localTotalCalculated == 0.0) {
// //               double p = double.tryParse(priceController.text) ?? 0.0;
// //               double q = double.tryParse(qtyController.text) ?? 0.0;
// //               localTotalCalculated = p * q;
// //             }

// //             return Padding(
// //               padding: EdgeInsets.only(
// //                 bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
// //                 left: 24,
// //                 right: 24,
// //                 top: 24,
// //               ),
// //               child: Form(
// //                 key: formKey,
// //                 child: SingleChildScrollView(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.stretch,
// //                     mainAxisSize: MainAxisSize.min,
// //                     children: [
// //                       Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           Text(
// //                             _editingTransactionId != null
// //                                 ? 'Edit Entry Record'
// //                                 : (initialType == 'credit' ? 'New Asset Credit Entry' : 'New Asset Debit Entry'),
// //                             style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
// //                           ),
// //                           CircleAvatar(
// //                             backgroundColor: initialType == 'credit'
// //                                 ? const Color(0xFFEF4444).withOpacity(0.2)
// //                                 : const Color(0xFF10B981).withOpacity(0.2),
// //                             radius: 12,
// //                             child: Container(
// //                               width: 8,
// //                               height: 8,
// //                               decoration: BoxDecoration(
// //                                 shape: BoxShape.circle,
// //                                 color: initialType == 'credit' ? const Color(0xFFEF4444) : const Color(0xFF10B981),
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       const Divider(color: Color(0xFF1E293B), height: 24),
// //                       TextFormField(
// //                         controller: nameController,
// //                         style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// //                         decoration: const InputDecoration(
// //                           labelText: 'Product / Service Description *',
// //                           labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
// //                           focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF38BDF8))),
// //                         ),
// //                         validator: (v) => (v == null || v.trim().isEmpty) ? 'Product description required.' : null,
// //                       ),
// //                       const SizedBox(height: 14),
// //                       Row(
// //                         children: [
// //                           Expanded(
// //                             child: TextFormField(
// //                               controller: priceController,
// //                               keyboardType: TextInputType.number,
// //                               style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// //                               decoration: const InputDecoration(
// //                                 labelText: 'Unit Price (₹) *',
// //                                 labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
// //                                 focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF38BDF8))),
// //                               ),
// //                               onChanged: (v) => updateLocalSum(),
// //                               validator: (v) => (v == null || double.tryParse(v) == null) ? 'Invalid Price.' : null,
// //                             ),
// //                           ),
// //                           const SizedBox(width: 16),
// //                           Expanded(
// //                             child: TextFormField(
// //                               controller: qtyController,
// //                               keyboardType: TextInputType.number,
// //                               style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// //                               decoration: const InputDecoration(
// //                                 labelText: 'Count (Qty) *',
// //                                 labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
// //                                 focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF38BDF8))),
// //                               ),
// //                               onChanged: (v) => updateLocalSum(),
// //                               validator: (v) => (v == null || double.tryParse(v) == null) ? 'Invalid Qty.' : null,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 14),
// //                       TextFormField(
// //                         controller: commitController,
// //                         style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// //                         decoration: const InputDecoration(
// //                           labelText: 'Optional Audit Message',
// //                           labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
// //                           focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF38BDF8))),
// //                         ),
// //                       ),
// //                       const SizedBox(height: 20),
// //                       Container(
// //                         padding: const EdgeInsets.all(14),
// //                         decoration: BoxDecoration(
// //                           color: const Color(0xFF070A0F),
// //                           borderRadius: BorderRadius.circular(10),
// //                           border: Border.all(color: const Color(0xFF1E293B)),
// //                         ),
// //                         child: Row(
// //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                           children: [
// //                             const Text('Calculated Total:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.bold)),
// //                             Text('₹${localTotalCalculated.toStringAsFixed(2)}', style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.w900)),
// //                           ],
// //                         ),
// //                       ),
// //                       const SizedBox(height: 24),
// //                       SizedBox(
// //                         height: 48,
// //                         child: ElevatedButton(
// //                           style: ElevatedButton.styleFrom(
// //                             backgroundColor: const Color(0xFF38BDF8),
// //                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// //                           ),
// //                           onPressed: () {
// //                             if (formKey.currentState!.validate()) {
// //                               _commitTransactionPage(
// //                                 productName: nameController.text,
// //                                 price: double.parse(priceController.text),
// //                                 quantity: double.parse(qtyController.text),
// //                                 commitMessage: commitController.text,
// //                                 type: initialType,
// //                               );
// //                               Navigator.pop(sheetContext);
// //                             }
// //                           },
// //                           child: const Text('Save & Update Changes', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
// //                         ),
// //                       )
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final double screenWidth = MediaQuery.of(context).size.width;
// //     final bool isDesktop = screenWidth > 1024;

// //     return Scaffold(
// //       backgroundColor: Colors.black,
// //       appBar: AppBar(
// //         backgroundColor: const Color(0xFF0F172A),
// //         elevation: 0,
// //         title: Text(widget.customerName, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 18)),
// //         iconTheme: const IconThemeData(color: Colors.white),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.cloud_upload_rounded, color: Color(0xFF38BDF8)),
// //             tooltip: 'Push Data in Historybook',
// //             onPressed: _showPushToHistoryDialog, // 👈 Triggers Historybook Dialog
// //           ),
// //           const SizedBox(width: 8),
// //         ],
// //         shape: const Border(bottom: BorderSide(color: Color(0xFF1E293B), width: 1)),
// //       ),
// //       body: isDesktop ? _buildWebDesktopLayout() : _buildMobileLayout(),
// //     );
// //   }

// //   Widget _buildWebDesktopLayout() {
// //     return Row(
// //       children: [
// //         Container(
// //           width: 280,
// //           padding: const EdgeInsets.all(24),
// //           decoration: const BoxDecoration(
// //             color: Color(0xFF0F172A),
// //             border: Border(right: BorderSide(color: Color(0xFF1E293B), width: 1.5)),
// //           ),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.stretch,
// //             children: [
// //               const Text('TRANSACTION DESK', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2)),
// //               const SizedBox(height: 24),
// //               SizedBox(
// //                 height: 50,
// //                 child: ElevatedButton.icon(
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: const Color(0xFFEF4444),
// //                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //                   ),
// //                   onPressed: () => _openTransactionFormSheet(context: context, initialType: 'credit'),
// //                   icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.white, size: 18),
// //                   label: const Text('Asset Credit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
// //                 ),
// //               ),
// //               const SizedBox(height: 16),
// //               SizedBox(
// //                 height: 50,
// //                 child: ElevatedButton.icon(
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: const Color(0xFF10B981),
// //                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //                   ),
// //                   onPressed: () => _openTransactionFormSheet(context: context, initialType: 'debit'),
// //                   icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 18),
// //                   label: const Text('Asset Debit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //         Expanded(
// //           child: SingleChildScrollView(
// //             padding: const EdgeInsets.all(32),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.stretch,
// //               children: [
// //                 _buildCustomerHeaderCard(),
// //                 const SizedBox(height: 32),
// //                 const Text('Historical Ledger Node Pages', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.3)),
// //                 const SizedBox(height: 16),
// //                 _buildTransactionGridStream(isDesktop: true),
// //               ],
// //             ),
// //           ),
// //         )
// //       ],
// //     );
// //   }

// //   Widget _buildMobileLayout() {
// //     return Column(
// //       children: [
// //         Expanded(
// //           child: SingleChildScrollView(
// //             padding: const EdgeInsets.all(16),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.stretch,
// //               children: [
// //                 _buildCustomerHeaderCard(),
// //                 const SizedBox(height: 20),
// //                 const Text('Historical Ledger Node Pages', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.3)),
// //                 const SizedBox(height: 12),
// //                 _buildTransactionGridStream(isDesktop: false),
// //               ],
// //             ),
// //           ),
// //         ),
// //         Container(
// //           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
// //           decoration: const BoxDecoration(
// //             color: Color(0xFF0F172A),
// //             border: Border(top: BorderSide(color: Color(0xFF1E293B), width: 1.5)),
// //           ),
// //           child: Row(
// //             children: [
// //               Expanded(
// //                 child: SizedBox(
// //                   height: 48,
// //                   child: ElevatedButton.icon(
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: const Color(0xFFEF4444),
// //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //                     ),
// //                     onPressed: () => _openTransactionFormSheet(context: context, initialType: 'credit'),
// //                     icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.white, size: 18),
// //                     label: const Text('Asset Credit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(width: 14),
// //               Expanded(
// //                 child: SizedBox(
// //                   height: 48,
// //                   child: ElevatedButton.icon(
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: const Color(0xFF10B981),
// //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //                     ),
// //                     onPressed: () => _openTransactionFormSheet(context: context, initialType: 'debit'),
// //                     icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 18),
// //                     label: const Text('Asset Debit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildCustomerHeaderCard() {
// //     return Container(
// //       padding: const EdgeInsets.all(20),
// //       decoration: BoxDecoration(
// //         color: const Color(0xFF0F172A),
// //         borderRadius: BorderRadius.circular(14),
// //         border: Border.all(color: const Color(0xFF1E293B), width: 1.5),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             children: [
// //               const Icon(Icons.phone_iphone_rounded, color: Color(0xFF38BDF8), size: 16),
// //               const SizedBox(width: 8),
// //               Text('Primary Comm Line: +91 ${widget.customerPhone}', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13)),
// //             ],
// //           ),
// //           const SizedBox(height: 8),
// //           Row(
// //             children: [
// //               const Icon(Icons.location_on_outlined, color: Colors.grey, size: 16),
// //               const SizedBox(width: 8),
// //               Expanded(
// //                 child: Text('Warehouse Node: ${widget.customerAddress}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600)),
// //               ),
// //             ],
// //           ),
// //           const SizedBox(height: 14),
// //           StreamBuilder<DocumentSnapshot>(
// //             stream: FirebaseFirestore.instance.collection('customers').doc(widget.customerId).snapshots(),
// //             builder: (context, snapshot) {
// //               if (snapshot.hasData && snapshot.data!.exists) {
// //                 _customerLiveBalance = double.tryParse(snapshot.data!['balance']?.toString() ?? '0.0') ?? 0.0;
// //               }

// //               final String formattedBalance = '+₹${_customerLiveBalance.toStringAsFixed(2)}';

// //               return Container(
// //                 padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
// //                 decoration: BoxDecoration(
// //                   color: const Color(0xFF070A0F),
// //                   borderRadius: BorderRadius.circular(10),
// //                   border: Border.all(color: const Color(0xFF1E293B)),
// //                 ),
// //                 child: Row(
// //                   mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     const Text('Active Balance Matrix: ', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.bold)),
// //                     Text(
// //                       formattedBalance,
// //                       style: TextStyle(
// //                         color: _customerLiveBalance > 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
// //                         fontSize: 16,
// //                         fontWeight: FontWeight.w900,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               );
// //             },
// //           )
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildTransactionGridStream({required bool isDesktop}) {
// //     return StreamBuilder<QuerySnapshot>(
// //       stream: FirebaseFirestore.instance
// //           .collection('transactions')
// //           .where('customerId', isEqualTo: widget.customerId)
// //           .snapshots(),
// //       builder: (context, snapshot) {
// //         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
// //           return const Padding(
// //             padding: EdgeInsets.symmetric(vertical: 40),
// //             child: Center(child: Text('No transaction entries logged.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.bold))),
// //           );
// //         }

// //         return isDesktop
// //             ? GridView.builder(
// //                 shrinkWrap: true,
// //                 physics: const NeverScrollableScrollPhysics(),
// //                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //                   crossAxisCount: 2,
// //                   crossAxisSpacing: 16,
// //                   mainAxisSpacing: 12,
// //                   childAspectRatio: 4.2,
// //                 ),
// //                 itemCount: snapshot.data!.docs.length,
// //                 itemBuilder: (context, idx) => _buildTransactionItemRow(snapshot.data!.docs[idx]),
// //               )
// //             : ListView.builder(
// //                 shrinkWrap: true,
// //                 physics: const NeverScrollableScrollPhysics(),
// //                 itemCount: snapshot.data!.docs.length,
// //                 itemBuilder: (context, idx) => _buildTransactionItemRow(snapshot.data!.docs[idx]),
// //               );
// //       },
// //     );
// //   }

// //   Widget _buildTransactionItemRow(DocumentSnapshot doc) {
// //     final tx = doc.data() as Map<String, dynamic>;
// //     final String txId = doc.id;
// //     final String productName = tx['productName'] ?? 'Item Entry';
// //     final String commitMsg = (tx['commitMessage'] ?? '').toString();
// //     final double tPrice = double.tryParse(tx['totalPrice']?.toString() ?? '0.0') ?? 0.0;
    
// //     final Timestamp? timestamp = tx['timestamp'] as Timestamp?;
// //     final DateTime txDate = timestamp != null ? timestamp.toDate() : DateTime.now();
// //     final String formattedTime = DateFormat('dd MMM, hh:mm a').format(txDate);

// //     bool isDeleting = _isButtonLoading('tx_del_$txId');

// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 10),
// //       padding: const EdgeInsets.all(14),
// //       decoration: BoxDecoration(
// //         color: const Color(0xFF0F172A),
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: const Color(0xFF1E293B), width: 1.2),
// //       ),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: [
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Text(
// //                   productName,
// //                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
// //                   maxLines: 1,
// //                   overflow: TextOverflow.ellipsis,
// //                 ),
// //                 const SizedBox(height: 3),
// //                 Text(
// //                   'Vol: ${tx['quantity']} x ₹${tx['price']}  •  $formattedTime',
// //                   style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold),
// //                   maxLines: 1,
// //                   overflow: TextOverflow.ellipsis,
// //                 ),
// //               ],
// //             ),
// //           ),
// //           Row(
// //             children: [
// //               Text(
// //                 '₹${tPrice.toStringAsFixed(2)}',
// //                 style: TextStyle(
// //                   color: tx['type'] == 'credit' ? const Color(0xFFEF4444) : const Color(0xFF10B981),
// //                   fontWeight: FontWeight.w900,
// //                   fontSize: 14,
// //                 ),
// //               ),
// //               const SizedBox(width: 6),
// //               IconButton(
// //                 padding: EdgeInsets.zero,
// //                 constraints: const BoxConstraints(),
// //                 icon: Icon(
// //                   Icons.chat_bubble_outline_rounded,
// //                   color: commitMsg.isNotEmpty ? const Color(0xFF38BDF8) : Colors.grey.shade700,
// //                   size: 18,
// //                 ),
// //                 onPressed: () => _showCommitNoteModal(productName, commitMsg),
// //               ),
// //               const SizedBox(width: 8),
// //               IconButton(
// //                 padding: EdgeInsets.zero,
// //                 constraints: const BoxConstraints(),
// //                 icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF38BDF8), size: 22),
// //                 onPressed: () => _triggerEditMode(doc),
// //               ),
// //               const SizedBox(width: 8),
// //               IconButton(
// //                 padding: EdgeInsets.zero,
// //                 constraints: const BoxConstraints(),
// //                 icon: isDeleting
// //                     ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Color(0xFFEF4444), strokeWidth: 2))
// //                     : const Icon(Icons.delete_forever_rounded, color: Color(0xFFEF4444), size: 20),
// //                 onPressed: () => _triggerDelete(txId, productName, tx),
// //               ),
// //             ],
// //           )
// //         ],
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
// import '../../widgets/customer_dialogs.dart';

// class CustomerLedgerScreen extends StatefulWidget {
//   final String customerId;
//   final String customerName;
//   final String customerPhone;
//   final String customerAddress;

//   const CustomerLedgerScreen({
//     Key? key,
//     required this.customerId,
//     required this.customerName,
//     required this.customerPhone,
//     required this.customerAddress,
//   }) : super(key: key);

//   @override
//   State<CustomerLedgerScreen> createState() => _CustomerLedgerScreenState();
// }

// class _CustomerLedgerScreenState extends State<CustomerLedgerScreen> {
//   String? _editingTransactionId;
//   double _customerLiveBalance = 0.0;
//   final Map<String, bool> _buttonLoadingState = {};

//   void _setButtonLoading(String id, bool loading) {
//     if (mounted) {
//       setState(() {
//         _buttonLoadingState[id] = loading;
//       });
//     }
//   }

//   bool _isButtonLoading(String id) => _buttonLoadingState[id] ?? false;

//   // 💰 Commit Transaction Logic
//   Future<void> _commitTransactionPage({
//     required String productName,
//     required double price,
//     required double quantity,
//     required String commitMessage,
//     required String type,
//   }) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null || productName.isEmpty) return;

//     double calculatedTotalPrice = price * quantity;

//     if (type == 'debit' && _editingTransactionId == null) {
//       if (calculatedTotalPrice > _customerLiveBalance) {
//         CustomerDialogs.showTopNotification(
//           context,
//           'Debit amount (₹${calculatedTotalPrice.toStringAsFixed(2)}) cannot exceed total active credit (₹${_customerLiveBalance.toStringAsFixed(2)})!',
//           isError: true,
//         );
//         return;
//       }
//     }

//     final txData = {
//       'operatorUid': user.uid,
//       'customerId': widget.customerId,
//       'customerName': widget.customerName,
//       'productName': productName.trim(),
//       'price': price,
//       'quantity': quantity,
//       'totalPrice': calculatedTotalPrice,
//       'type': type,
//       'commitMessage': commitMessage.trim(),
//       'timestamp': FieldValue.serverTimestamp(),
//     };

//     try {
//       if (_editingTransactionId != null) {
//         await _deleteTransactionImpact(_editingTransactionId!);
//         await FirebaseFirestore.instance.collection('transactions').doc(_editingTransactionId).update(txData);
//         _editingTransactionId = null;

//         if (mounted) {
//           CustomerDialogs.showTopNotification(context, 'Transaction entry updated successfully!');
//         }
//       } else {
//         await FirebaseFirestore.instance.collection('transactions').add(txData);
//         if (mounted) {
//           CustomerDialogs.showTopNotification(context, 'Added "$productName" (₹${calculatedTotalPrice.toStringAsFixed(2)})');
//         }
//       }

//       final customerRef = FirebaseFirestore.instance.collection('customers').doc(widget.customerId);
//       await FirebaseFirestore.instance.runTransaction((transaction) async {
//         final snapshot = await transaction.get(customerRef);
//         if (!snapshot.exists) return;
//         double currentBalance = double.tryParse(snapshot.data()?['balance']?.toString() ?? '0.0') ?? 0.0;
        
//         double newBalance = type == 'credit'
//             ? currentBalance + calculatedTotalPrice
//             : currentBalance - calculatedTotalPrice;
            
//         transaction.update(customerRef, {'balance': newBalance < 0 ? 0.0 : newBalance});
//       });
//     } catch (e) {
//       if (mounted) {
//         CustomerDialogs.showTopNotification(context, 'Failed to log transaction!', isError: true);
//       }
//     }
//   }

//   // 🔄 Reverse Balance on Delete/Edit
//   Future<void> _deleteTransactionImpact(String txId) async {
//     final txDoc = await FirebaseFirestore.instance.collection('transactions').doc(txId).get();
//     if (!txDoc.exists) return;

//     final txData = txDoc.data()!;
//     double oldTotal = double.tryParse(txData['totalPrice']?.toString() ?? '0.0') ?? 0.0;
//     String oldType = txData['type'] ?? 'credit';

//     final customerRef = FirebaseFirestore.instance.collection('customers').doc(widget.customerId);
//     await FirebaseFirestore.instance.runTransaction((transaction) async {
//       final snapshot = await transaction.get(customerRef);
//       if (!snapshot.exists) return;
//       double currentBalance = double.tryParse(snapshot.data()?['balance']?.toString() ?? '0.0') ?? 0.0;
      
//       double reversedBalance = oldType == 'credit' ? currentBalance - oldTotal : currentBalance + oldTotal;
//       transaction.update(customerRef, {'balance': reversedBalance < 0 ? 0.0 : reversedBalance});
//     });
//   }

//   // ☁️ Push Data to Historybook Dialog Function
//   void _showPushToHistoryDialog() {
//     showDialog(
//       context: context,
//       builder: (dialogCtx) => AlertDialog(
//         backgroundColor: const Color(0xFF0F172A),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//           side: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
//         ),
//         title: const Row(
//           children: [
//             Icon(Icons.cloud_upload_rounded, color: Color(0xFF38BDF8), size: 24),
//             SizedBox(width: 10),
//             Text('Push Data in Historybook?', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
//           ],
//         ),
//         content: const Text(
//           'Pushing will archive all entries to the Historybook and CLEAR them from this live screen.',
//           style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.4),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogCtx),
//             child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8)),
//             onPressed: () async {
//               Navigator.pop(dialogCtx);
//               await _executePushToHistorybookAndRemove();
//             },
//             child: const Text('Push & Clear', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
//           ),
//         ],
//       ),
//     );
//   }

//   // ☁️ Execute Historybook Push and REMOVE from current screen logic
//   Future<void> _executePushToHistorybookAndRemove() async {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) return;

//     try {
//       final txSnap = await FirebaseFirestore.instance
//           .collection('transactions')
//           .where('customerId', isEqualTo: widget.customerId)
//           .get();

//       if (txSnap.docs.isEmpty) {
//         CustomerDialogs.showTopNotification(context, 'No active transactions to push!', isError: true);
//         return;
//       }

//       final batch = FirebaseFirestore.instance.batch();

//       // 1. Copy to historybook & delete from transactions
//       for (var doc in txSnap.docs) {
//         final data = doc.data();
//         final historyRef = FirebaseFirestore.instance.collection('historybook').doc();
//         batch.set(historyRef, {
//           ...data,
//           'pushedAt': FieldValue.serverTimestamp(),
//           'pushedAtIso': DateTime.now().toIso8601String(),
//           'operatorUid': currentUser.uid,
//           'customerName': widget.customerName,
//         });

//         batch.delete(doc.reference); // 👈 Delete from current live transactions
//       }

//       // 2. Reset customer active balance to 0.0
//       final customerRef = FirebaseFirestore.instance.collection('customers').doc(widget.customerId);
//       batch.update(customerRef, {'balance': 0.0});

//       await batch.commit();

//       if (mounted) {
//         CustomerDialogs.showTopNotification(context, 'Successfully pushed ${txSnap.docs.length} entries to Historybook and cleared page!');
//       }
//     } catch (e) {
//       if (mounted) {
//         CustomerDialogs.showTopNotification(context, 'Failed to push and clear entries!', isError: true);
//       }
//     }
//   }

//   void _triggerDelete(String txId, String productName, Map<String, dynamic> txData) async {
//     bool confirm = await CustomerDialogs.openSecureDeleteDialog(
//       context: context,
//       customerId: txId,
//       customerName: productName,
//       isButtonLoading: _isButtonLoading,
//       setButtonLoading: _setButtonLoading,
//       isPermanent: true,
//     );

//     if (confirm) {
//       _setButtonLoading('tx_del_$txId', true);
//       try {
//         final currentUser = FirebaseAuth.instance.currentUser;

//         await FirebaseFirestore.instance.collection('deleted_products_history').add({
//           ...txData,
//           'originalTxId': txId,
//           'operatorUid': currentUser?.uid ?? txData['operatorUid'],
//           'deletedAt': FieldValue.serverTimestamp(),
//         });

//         await _deleteTransactionImpact(txId);
//         await FirebaseFirestore.instance.collection('transactions').doc(txId).delete();

//         _setButtonLoading('tx_del_$txId', false);
//         if (mounted) {
//           CustomerDialogs.showTopNotification(context, '"$productName" removed & balance adjusted!');
//         }
//       } catch (e) {
//         _setButtonLoading('tx_del_$txId', false);
//         if (mounted) {
//           CustomerDialogs.showTopNotification(context, 'Failed to remove entry!', isError: true);
//         }
//       }
//     }
//   }

//   void _triggerEditMode(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     _editingTransactionId = doc.id;

//     _openTransactionFormSheet(
//       context: context,
//       initialType: data['type'] ?? 'credit',
//       prefillName: data['productName'] ?? '',
//       prefillPrice: (data['price'] ?? 0.0).toString(),
//       prefillQty: (data['quantity'] ?? 0.0).toString(),
//       prefillCommit: data['commitMessage'] ?? '',
//     );
//   }

//   void _showCommitNoteModal(String productName, String commitMessage) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         backgroundColor: const Color(0xFF0F172A),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//           side: const BorderSide(color: Color(0xFF38BDF8), width: 1.2),
//         ),
//         title: Row(
//           children: [
//             const Icon(Icons.note_alt_rounded, color: Color(0xFF38BDF8), size: 22),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 'Audit Note: $productName',
//                 style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//         content: Container(
//           width: double.maxFinite,
//           padding: const EdgeInsets.all(14),
//           decoration: BoxDecoration(
//             color: const Color(0xFF070A0F),
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: const Color(0xFF1E293B)),
//           ),
//           child: Text(
//             commitMessage.isNotEmpty ? commitMessage : 'No audit commitment note attached.',
//             style: TextStyle(
//               color: commitMessage.isNotEmpty ? Colors.white70 : Colors.grey.shade600,
//               fontSize: 13,
//             ),
//           ),
//         ),
//         actions: [
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8)),
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text('Close', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _openTransactionFormSheet({
//     required BuildContext context,
//     required String initialType,
//     String prefillName = '',
//     String prefillPrice = '',
//     String prefillQty = '',
//     String prefillCommit = '',
//   }) {
//     final nameController = TextEditingController(text: prefillName);
//     final priceController = TextEditingController(text: prefillPrice);
//     final qtyController = TextEditingController(text: prefillQty);
//     final commitController = TextEditingController(text: prefillCommit);
//     final formKey = GlobalKey<FormState>();

//     double localTotalCalculated = 0.0;

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: const Color(0xFF0F172A),
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (sheetContext) {
//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setSheetState) {
//             void updateLocalSum() {
//               double p = double.tryParse(priceController.text) ?? 0.0;
//               double q = double.tryParse(qtyController.text) ?? 0.0;
//               setSheetState(() {
//                 localTotalCalculated = p * q;
//               });
//             }

//             if (priceController.text.isNotEmpty && qtyController.text.isNotEmpty && localTotalCalculated == 0.0) {
//               double p = double.tryParse(priceController.text) ?? 0.0;
//               double q = double.tryParse(qtyController.text) ?? 0.0;
//               localTotalCalculated = p * q;
//             }

//             return Padding(
//               padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
//                 left: 24,
//                 right: 24,
//                 top: 24,
//               ),
//               child: Form(
//                 key: formKey,
//                 child: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             _editingTransactionId != null
//                                 ? 'Edit Entry Record'
//                                 : (initialType == 'credit' ? 'New Asset Credit Entry' : 'New Asset Debit Entry'),
//                             style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
//                           ),
//                           CircleAvatar(
//                             backgroundColor: initialType == 'credit'
//                                 ? const Color(0xFFEF4444).withOpacity(0.2)
//                                 : const Color(0xFF10B981).withOpacity(0.2),
//                             radius: 12,
//                             child: Container(
//                               width: 8,
//                               height: 8,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: initialType == 'credit' ? const Color(0xFFEF4444) : const Color(0xFF10B981),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const Divider(color: Color(0xFF1E293B), height: 24),
//                       TextFormField(
//                         controller: nameController,
//                         style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                         decoration: const InputDecoration(
//                           labelText: 'Product / Service Description *',
//                           labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
//                           focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF38BDF8))),
//                         ),
//                         validator: (v) => (v == null || v.trim().isEmpty) ? 'Product description required.' : null,
//                       ),
//                       const SizedBox(height: 14),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: TextFormField(
//                               controller: priceController,
//                               keyboardType: TextInputType.number,
//                               style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                               decoration: const InputDecoration(
//                                 labelText: 'Unit Price (₹) *',
//                                 labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
//                                 focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF38BDF8))),
//                               ),
//                               onChanged: (v) => updateLocalSum(),
//                               validator: (v) => (v == null || double.tryParse(v) == null) ? 'Invalid Price.' : null,
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: TextFormField(
//                               controller: qtyController,
//                               keyboardType: TextInputType.number,
//                               style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                               decoration: const InputDecoration(
//                                 labelText: 'Count (Qty) *',
//                                 labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
//                                 focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF38BDF8))),
//                               ),
//                               onChanged: (v) => updateLocalSum(),
//                               validator: (v) => (v == null || double.tryParse(v) == null) ? 'Invalid Qty.' : null,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 14),
//                       TextFormField(
//                         controller: commitController,
//                         style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                         decoration: const InputDecoration(
//                           labelText: 'Optional Audit Message',
//                           labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
//                           focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF38BDF8))),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       Container(
//                         padding: const EdgeInsets.all(14),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF070A0F),
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all(color: const Color(0xFF1E293B)),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Text('Calculated Total:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.bold)),
//                             Text('₹${localTotalCalculated.toStringAsFixed(2)}', style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.w900)),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//                       SizedBox(
//                         height: 48,
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF38BDF8),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                           ),
//                           onPressed: () {
//                             if (formKey.currentState!.validate()) {
//                               _commitTransactionPage(
//                                 productName: nameController.text,
//                                 price: double.parse(priceController.text),
//                                 quantity: double.parse(qtyController.text),
//                                 commitMessage: commitController.text,
//                                 type: initialType,
//                               );
//                               Navigator.pop(sheetContext);
//                             }
//                           },
//                           child: const Text('Save & Update Changes', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
//                         ),
//                       )
//                     ],
//                   ),
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
//     final double screenWidth = MediaQuery.of(context).size.width;
//     final bool isDesktop = screenWidth > 1024;

//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF0F172A),
//         elevation: 0,
//         title: Text(widget.customerName, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 18)),
//         iconTheme: const IconThemeData(color: Colors.white),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.cloud_upload_rounded, color: Color(0xFF38BDF8)),
//             tooltip: 'Push Data in Historybook',
//             onPressed: _showPushToHistoryDialog,
//           ),
//           const SizedBox(width: 8),
//         ],
//         shape: const Border(bottom: BorderSide(color: Color(0xFF1E293B), width: 1)),
//       ),
//       body: isDesktop ? _buildWebDesktopLayout() : _buildMobileLayout(),
//     );
//   }

//   Widget _buildWebDesktopLayout() {
//     return Row(
//       children: [
//         Container(
//           width: 280,
//           padding: const EdgeInsets.all(24),
//           decoration: const BoxDecoration(
//             color: Color(0xFF0F172A),
//             border: Border(right: BorderSide(color: Color(0xFF1E293B), width: 1.5)),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const Text('TRANSACTION DESK', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2)),
//               const SizedBox(height: 24),
//               SizedBox(
//                 height: 50,
//                 child: ElevatedButton.icon(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFFEF4444),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   onPressed: () => _openTransactionFormSheet(context: context, initialType: 'credit'),
//                   icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.white, size: 18),
//                   label: const Text('Asset Credit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               SizedBox(
//                 height: 50,
//                 child: ElevatedButton.icon(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF10B981),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   onPressed: () => _openTransactionFormSheet(context: context, initialType: 'debit'),
//                   icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 18),
//                   label: const Text('Asset Debit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(32),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 _buildCustomerHeaderCard(),
//                 const SizedBox(height: 32),
//                 const Text('Historical Ledger Node Pages', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.3)),
//                 const SizedBox(height: 16),
//                 _buildTransactionGridStream(isDesktop: true),
//               ],
//             ),
//           ),
//         )
//       ],
//     );
//   }

//   Widget _buildMobileLayout() {
//     return Column(
//       children: [
//         Expanded(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 _buildCustomerHeaderCard(),
//                 const SizedBox(height: 20),
//                 const Text('Historical Ledger Node Pages', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.3)),
//                 const SizedBox(height: 12),
//                 _buildTransactionGridStream(isDesktop: false),
//               ],
//             ),
//           ),
//         ),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//           decoration: const BoxDecoration(
//             color: Color(0xFF0F172A),
//             border: Border(top: BorderSide(color: Color(0xFF1E293B), width: 1.5)),
//           ),
//           child: Row(
//             children: [
//               Expanded(
//                 child: SizedBox(
//                   height: 48,
//                   child: ElevatedButton.icon(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFEF4444),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     ),
//                     onPressed: () => _openTransactionFormSheet(context: context, initialType: 'credit'),
//                     icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.white, size: 18),
//                     label: const Text('Asset Credit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: SizedBox(
//                   height: 48,
//                   child: ElevatedButton.icon(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF10B981),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     ),
//                     onPressed: () => _openTransactionFormSheet(context: context, initialType: 'debit'),
//                     icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 18),
//                     label: const Text('Asset Debit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCustomerHeaderCard() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: const Color(0xFF0F172A),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: const Color(0xFF1E293B), width: 1.5),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.phone_iphone_rounded, color: Color(0xFF38BDF8), size: 16),
//               const SizedBox(width: 8),
//               Text('Primary Comm Line: +91 ${widget.customerPhone}', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13)),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               const Icon(Icons.location_on_outlined, color: Colors.grey, size: 16),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text('Warehouse Node: ${widget.customerAddress}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600)),
//               ),
//             ],
//           ),
//           const SizedBox(height: 14),
//           StreamBuilder<DocumentSnapshot>(
//             stream: FirebaseFirestore.instance.collection('customers').doc(widget.customerId).snapshots(),
//             builder: (context, snapshot) {
//               if (snapshot.hasData && snapshot.data!.exists) {
//                 _customerLiveBalance = double.tryParse(snapshot.data!['balance']?.toString() ?? '0.0') ?? 0.0;
//               }

//               final String formattedBalance = '+₹${_customerLiveBalance.toStringAsFixed(2)}';

//               return Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF070A0F),
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: const Color(0xFF1E293B)),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Text('Active Balance Matrix: ', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.bold)),
//                     Text(
//                       formattedBalance,
//                       style: TextStyle(
//                         color: _customerLiveBalance > 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
//                         fontSize: 16,
//                         fontWeight: FontWeight.w900,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildTransactionGridStream({required bool isDesktop}) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('transactions')
//           .where('customerId', isEqualTo: widget.customerId)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Padding(
//             padding: EdgeInsets.symmetric(vertical: 40),
//             child: Center(child: Text('No transaction entries logged on this page.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.bold))),
//           );
//         }

//         return isDesktop
//             ? GridView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 16,
//                   mainAxisSpacing: 12,
//                   childAspectRatio: 4.2,
//                 ),
//                 itemCount: snapshot.data!.docs.length,
//                 itemBuilder: (context, idx) => _buildTransactionItemRow(snapshot.data!.docs[idx]),
//               )
//             : ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: snapshot.data!.docs.length,
//                 itemBuilder: (context, idx) => _buildTransactionItemRow(snapshot.data!.docs[idx]),
//               );
//       },
//     );
//   }

//   Widget _buildTransactionItemRow(DocumentSnapshot doc) {
//     final tx = doc.data() as Map<String, dynamic>;
//     final String txId = doc.id;
//     final String productName = tx['productName'] ?? 'Item Entry';
//     final String commitMsg = (tx['commitMessage'] ?? '').toString();
//     final double tPrice = double.tryParse(tx['totalPrice']?.toString() ?? '0.0') ?? 0.0;
    
//     final Timestamp? timestamp = tx['timestamp'] as Timestamp?;
//     final DateTime txDate = timestamp != null ? timestamp.toDate() : DateTime.now();
//     final String formattedTime = DateFormat('dd MMM, hh:mm a').format(txDate);

//     bool isDeleting = _isButtonLoading('tx_del_$txId');

//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: const Color(0xFF0F172A),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFF1E293B), width: 1.2),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   productName,
//                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 3),
//                 Text(
//                   'Vol: ${tx['quantity']} x ₹${tx['price']}  •  $formattedTime',
//                   style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//           Row(
//             children: [
//               Text(
//                 '₹${tPrice.toStringAsFixed(2)}',
//                 style: TextStyle(
//                   color: tx['type'] == 'credit' ? const Color(0xFFEF4444) : const Color(0xFF10B981),
//                   fontWeight: FontWeight.w900,
//                   fontSize: 14,
//                 ),
//               ),
//               const SizedBox(width: 6),
//               IconButton(
//                 padding: EdgeInsets.zero,
//                 constraints: const BoxConstraints(),
//                 icon: Icon(
//                   Icons.chat_bubble_outline_rounded,
//                   color: commitMsg.isNotEmpty ? const Color(0xFF38BDF8) : Colors.grey.shade700,
//                   size: 18,
//                 ),
//                 onPressed: () => _showCommitNoteModal(productName, commitMsg),
//               ),
//               const SizedBox(width: 8),
//               IconButton(
//                 padding: EdgeInsets.zero,
//                 constraints: const BoxConstraints(),
//                 icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF38BDF8), size: 22),
//                 onPressed: () => _triggerEditMode(doc),
//               ),
//               const SizedBox(width: 8),
//               IconButton(
//                 padding: EdgeInsets.zero,
//                 constraints: const BoxConstraints(),
//                 icon: isDeleting
//                     ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Color(0xFFEF4444), strokeWidth: 2))
//                     : const Icon(Icons.delete_forever_rounded, color: Color(0xFFEF4444), size: 20),
//                 onPressed: () => _triggerDelete(txId, productName, tx),
//               ),
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../widgets/customer_dialogs.dart';

class CustomerLedgerScreen extends StatefulWidget {
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String customerAddress;

  const CustomerLedgerScreen({
    Key? key,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
  }) : super(key: key);

  @override
  State<CustomerLedgerScreen> createState() => _CustomerLedgerScreenState();
}

class _CustomerLedgerScreenState extends State<CustomerLedgerScreen> {
  String? _editingTransactionId;
  double _customerLiveBalance = 0.0;
  final Map<String, bool> _buttonLoadingState = {};

  void _setButtonLoading(String id, bool loading) {
    if (mounted) {
      setState(() {
        _buttonLoadingState[id] = loading;
      });
    }
  }

  bool _isButtonLoading(String id) => _buttonLoadingState[id] ?? false;

  Future<void> _commitTransactionPage({
    required String productName,
    required double price,
    required double quantity,
    required String commitMessage,
    required String type,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || productName.isEmpty) return;

    double calculatedTotalPrice = price * quantity;

    if (type == 'debit' && _editingTransactionId == null) {
      if (calculatedTotalPrice > _customerLiveBalance) {
        CustomerDialogs.showTopNotification(
          context,
          'Debit amount (₹${calculatedTotalPrice.toStringAsFixed(2)}) cannot exceed total active credit (₹${_customerLiveBalance.toStringAsFixed(2)})!',
          isError: true,
        );
        return;
      }
    }

    final txData = {
      'operatorUid': user.uid,
      'customerId': widget.customerId,
      'customerName': widget.customerName,
      'productName': productName.trim(),
      'price': price,
      'quantity': quantity,
      'totalPrice': calculatedTotalPrice,
      'type': type,
      'commitMessage': commitMessage.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      if (_editingTransactionId != null) {
        await _deleteTransactionImpact(_editingTransactionId!);
        await FirebaseFirestore.instance.collection('transactions').doc(_editingTransactionId).update(txData);
        _editingTransactionId = null;

        if (mounted) {
          CustomerDialogs.showTopNotification(context, 'Transaction entry updated successfully!');
        }
      } else {
        await FirebaseFirestore.instance.collection('transactions').add(txData);
        if (mounted) {
          CustomerDialogs.showTopNotification(context, 'Added "$productName" (₹${calculatedTotalPrice.toStringAsFixed(2)})');
        }
      }

      final customerRef = FirebaseFirestore.instance.collection('customers').doc(widget.customerId);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(customerRef);
        if (!snapshot.exists) return;
        double currentBalance = double.tryParse(snapshot.data()?['balance']?.toString() ?? '0.0') ?? 0.0;

        double newBalance = type == 'credit'
            ? currentBalance + calculatedTotalPrice
            : currentBalance - calculatedTotalPrice;

        transaction.update(customerRef, {'balance': newBalance < 0 ? 0.0 : newBalance});
      });
    } catch (e) {
      if (mounted) {
        CustomerDialogs.showTopNotification(context, 'Failed to log transaction!', isError: true);
      }
    }
  }

  Future<void> _deleteTransactionImpact(String txId) async {
    final txDoc = await FirebaseFirestore.instance.collection('transactions').doc(txId).get();
    if (!txDoc.exists) return;

    final txData = txDoc.data()!;
    double oldTotal = double.tryParse(txData['totalPrice']?.toString() ?? '0.0') ?? 0.0;
    String oldType = txData['type'] ?? 'credit';

    final customerRef = FirebaseFirestore.instance.collection('customers').doc(widget.customerId);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(customerRef);
      if (!snapshot.exists) return;
      double currentBalance = double.tryParse(snapshot.data()?['balance']?.toString() ?? '0.0') ?? 0.0;

      double reversedBalance = oldType == 'credit' ? currentBalance - oldTotal : currentBalance + oldTotal;
      transaction.update(customerRef, {'balance': reversedBalance < 0 ? 0.0 : reversedBalance});
    });
  }

  void _showPushToHistoryDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
        ),
        title: Row(
          children: [
            const Icon(Icons.cloud_upload_rounded, color: Color(0xFF38BDF8), size: 24),
            const SizedBox(width: 10),
            Text(
              'Push Session in Historybook?',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'This will push current transactions into a NEW Session Batch in Historybook and clear this workspace screen.',
          style: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            fontSize: 12,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8)),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await _executePushSessionToHistorybook();
            },
            child: const Text('Push Now', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _executePushSessionToHistorybook() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final txSnap = await FirebaseFirestore.instance
          .collection('transactions')
          .where('customerId', isEqualTo: widget.customerId)
          .get();

      if (txSnap.docs.isEmpty) {
        CustomerDialogs.showTopNotification(context, 'No active entries found to push!', isError: true);
        return;
      }

      final String sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
      final String sessionLabel = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

      final batch = FirebaseFirestore.instance.batch();

      for (var doc in txSnap.docs) {
        final data = doc.data();
        final historyRef = FirebaseFirestore.instance.collection('historybook').doc();
        batch.set(historyRef, {
          ...data,
          'sessionId': sessionId,
          'sessionLabel': sessionLabel,
          'pushedAt': FieldValue.serverTimestamp(),
          'pushedAtIso': DateTime.now().toIso8601String(),
          'operatorUid': currentUser.uid,
          'customerName': widget.customerName,
        });

        batch.delete(doc.reference);
      }

      final customerRef = FirebaseFirestore.instance.collection('customers').doc(widget.customerId);
      batch.update(customerRef, {'balance': 0.0});

      await batch.commit();

      if (mounted) {
        CustomerDialogs.showTopNotification(context, 'Pushed session batch (${txSnap.docs.length} items) to Historybook!');
      }
    } catch (e) {
      if (mounted) {
        CustomerDialogs.showTopNotification(context, 'Failed to push session!', isError: true);
      }
    }
  }

  void _triggerDelete(String txId, String productName, Map<String, dynamic> txData) async {
    bool confirm = await CustomerDialogs.openSecureDeleteDialog(
      context: context,
      customerId: txId,
      customerName: productName,
      isButtonLoading: _isButtonLoading,
      setButtonLoading: _setButtonLoading,
      isPermanent: true,
    );

    if (confirm) {
      _setButtonLoading('tx_del_$txId', true);
      try {
        final currentUser = FirebaseAuth.instance.currentUser;

        await FirebaseFirestore.instance.collection('deleted_products_history').add({
          ...txData,
          'originalTxId': txId,
          'operatorUid': currentUser?.uid ?? txData['operatorUid'],
          'deletedAt': FieldValue.serverTimestamp(),
        });

        await _deleteTransactionImpact(txId);
        await FirebaseFirestore.instance.collection('transactions').doc(txId).delete();

        _setButtonLoading('tx_del_$txId', false);
        if (mounted) {
          CustomerDialogs.showTopNotification(context, '"$productName" removed & balance adjusted!');
        }
      } catch (e) {
        _setButtonLoading('tx_del_$txId', false);
        if (mounted) {
          CustomerDialogs.showTopNotification(context, 'Failed to remove entry!', isError: true);
        }
      }
    }
  }

  void _triggerEditMode(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    _editingTransactionId = doc.id;

    _openTransactionFormSheet(
      context: context,
      initialType: data['type'] ?? 'credit',
      prefillName: data['productName'] ?? '',
      prefillPrice: (data['price'] ?? 0.0).toString(),
      prefillQty: (data['quantity'] ?? 0.0).toString(),
      prefillCommit: data['commitMessage'] ?? '',
    );
  }

  void _showCommitNoteModal(String productName, String commitMessage, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF38BDF8), width: 1.2),
        ),
        title: Row(
          children: [
            const Icon(Icons.note_alt_rounded, color: Color(0xFF38BDF8), size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Audit Note: $productName',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF070A0F) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          ),
          child: Text(
            commitMessage.isNotEmpty ? commitMessage : 'No audit commitment note attached.',
            style: TextStyle(
              color: commitMessage.isNotEmpty
                  ? (isDark ? Colors.white70 : Colors.black87)
                  : (isDark ? Colors.grey.shade600 : Colors.grey.shade500),
              fontSize: 13,
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8)),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openTransactionFormSheet({
    required BuildContext context,
    required String initialType,
    String prefillName = '',
    String prefillPrice = '',
    String prefillQty = '',
    String prefillCommit = '',
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameController = TextEditingController(text: prefillName);
    final priceController = TextEditingController(text: prefillPrice);
    final qtyController = TextEditingController(text: prefillQty);
    final commitController = TextEditingController(text: prefillCommit);
    final formKey = GlobalKey<FormState>();

    double localTotalCalculated = 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            void updateLocalSum() {
              double p = double.tryParse(priceController.text) ?? 0.0;
              double q = double.tryParse(qtyController.text) ?? 0.0;
              setSheetState(() {
                localTotalCalculated = p * q;
              });
            }

            if (priceController.text.isNotEmpty && qtyController.text.isNotEmpty && localTotalCalculated == 0.0) {
              double p = double.tryParse(priceController.text) ?? 0.0;
              double q = double.tryParse(qtyController.text) ?? 0.0;
              localTotalCalculated = p * q;
            }

            final colorTheme = initialType == 'credit' ? const Color(0xFF10B981) : const Color(0xFFEF4444);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // 🟢 Circle Indicator for Type
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: colorTheme,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorTheme.withOpacity(0.4),
                                      blurRadius: 6,
                                      spreadRadius: 2,
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _editingTransactionId != null
                                    ? 'Edit Entry Record'
                                    : (initialType == 'credit' ? 'New Asset Credit Entry (+)' : 'New Asset Debit Entry (-)'),
                                style: TextStyle(
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorTheme.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colorTheme.withOpacity(0.3)),
                            ),
                            child: Text(
                              initialType.toUpperCase(),
                              style: TextStyle(
                                color: colorTheme,
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0), height: 24),
                      TextFormField(
                        controller: nameController,
                        style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          labelText: 'Product / Service Description *',
                          labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13),
                          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF38BDF8))),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Product description required.' : null,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: priceController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                labelText: 'Unit Price (₹) *',
                                labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13),
                                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF38BDF8))),
                              ),
                              onChanged: (v) => updateLocalSum(),
                              validator: (v) => (v == null || double.tryParse(v) == null) ? 'Invalid Price.' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: qtyController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                labelText: 'Count (Qty) *',
                                labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13),
                                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF38BDF8))),
                              ),
                              onChanged: (v) => updateLocalSum(),
                              validator: (v) => (v == null || double.tryParse(v) == null) ? 'Invalid Qty.' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: commitController,
                        style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          labelText: 'Optional Audit Message',
                          labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13),
                          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF38BDF8))),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF070A0F) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Calculated Total:',
                              style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Text('₹${localTotalCalculated.toStringAsFixed(2)}', style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF38BDF8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              _commitTransactionPage(
                                productName: nameController.text,
                                price: double.parse(priceController.text),
                                quantity: double.parse(qtyController.text),
                                commitMessage: commitController.text,
                                type: initialType,
                              );
                              Navigator.pop(sheetContext);
                            }
                          },
                          child: const Text('Save & Update Changes', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
                        ),
                      )
                    ],
                  ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 1024;

    final bgColor = isDark ? Colors.black : const Color(0xFFF8FAFC);
    final cardBgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardBgColor,
        elevation: 0,
        title: Row(
          children: [
            // 🟢 Active Client Indicator Circle
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.customerName,
              style: TextStyle(fontWeight: FontWeight.w900, color: textColor, fontSize: 18),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload_rounded, color: Color(0xFF38BDF8)),
            tooltip: 'Push Session in Historybook',
            onPressed: () => _showPushToHistoryDialog(isDark),
          ),
          const SizedBox(width: 8),
        ],
        shape: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      body: isDesktop
          ? _buildWebDesktopLayout(isDark, textColor, cardBgColor, borderColor)
          : _buildMobileLayout(isDark, textColor, cardBgColor, borderColor),
    );
  }

  Widget _buildWebDesktopLayout(bool isDark, Color textColor, Color cardBgColor, Color borderColor) {
    return Row(
      children: [
        Container(
          width: 280,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardBgColor,
            border: Border(right: BorderSide(color: borderColor, width: 1.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'TRANSACTION DESK',
                style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2),
              ),
              const SizedBox(height: 24),
              // 🟢 Green Button -> Asset Credit (+)
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _openTransactionFormSheet(context: context, initialType: 'credit'),
                  icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 18),
                  label: const Text('Asset Credit (+)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                ),
              ),
              const SizedBox(height: 16),
              // 🔴 Red Button -> Asset Debit (-)
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _openTransactionFormSheet(context: context, initialType: 'debit'),
                  icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.white, size: 18),
                  label: const Text('Asset Debit (-)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 32, right: 32, top: 32, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCustomerHeaderCard(isDark, textColor, cardBgColor, borderColor),
                const SizedBox(height: 32),
                Text('Historical Ledger Node Pages', style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.3)),
                const SizedBox(height: 16),
                _buildTransactionGridStream(isDesktop: true, isDark: isDark, textColor: textColor, cardBgColor: cardBgColor, borderColor: borderColor),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildMobileLayout(bool isDark, Color textColor, Color cardBgColor, Color borderColor) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCustomerHeaderCard(isDark, textColor, cardBgColor, borderColor),
                const SizedBox(height: 20),
                Text('Historical Ledger Node Pages', style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.3)),
                const SizedBox(height: 12),
                _buildTransactionGridStream(isDesktop: false, isDark: isDark, textColor: textColor, cardBgColor: cardBgColor, borderColor: borderColor),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: cardBgColor,
            border: Border(top: BorderSide(color: borderColor, width: 1.5)),
          ),
          child: Row(
            children: [
              // 🟢 Green Button -> Asset Credit (+)
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _openTransactionFormSheet(context: context, initialType: 'credit'),
                    icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 18),
                    label: const Text('Asset Credit (+)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // 🔴 Red Button -> Asset Debit (-)
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _openTransactionFormSheet(context: context, initialType: 'debit'),
                    icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.white, size: 18),
                    label: const Text('Asset Debit (-)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerHeaderCard(bool isDark, Color textColor, Color cardBgColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.phone_iphone_rounded, color: Color(0xFF38BDF8), size: 16),
              const SizedBox(width: 8),
              Text(
                'Primary Comm Line: +91 ${widget.customerPhone}',
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.grey, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Warehouse Node: ${widget.customerAddress}',
                  style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('customers').doc(widget.customerId).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.exists) {
                _customerLiveBalance = double.tryParse(snapshot.data!['balance']?.toString() ?? '0.0') ?? 0.0;
              }

              final String formattedBalance = '+₹${_customerLiveBalance.toStringAsFixed(2)}';

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF070A0F) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Active Balance Matrix: ',
                      style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      formattedBalance,
                      style: TextStyle(
                        color: _customerLiveBalance > 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildTransactionGridStream({
    required bool isDesktop,
    required bool isDark,
    required Color textColor,
    required Color cardBgColor,
    required Color borderColor,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .where('customerId', isEqualTo: widget.customerId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'No transaction entries logged on this page.',
                style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }

        return isDesktop
            ? GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 12,
                  childAspectRatio: 4.2,
                ),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, idx) => _buildTransactionItemRow(
                  snapshot.data!.docs[idx],
                  isDark,
                  textColor,
                  cardBgColor,
                  borderColor,
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, idx) => _buildTransactionItemRow(
                  snapshot.data!.docs[idx],
                  isDark,
                  textColor,
                  cardBgColor,
                  borderColor,
                ),
              );
      },
    );
  }

  Widget _buildTransactionItemRow(
    DocumentSnapshot doc,
    bool isDark,
    Color textColor,
    Color cardBgColor,
    Color borderColor,
  ) {
    final tx = doc.data() as Map<String, dynamic>;
    final String txId = doc.id;
    final String productName = tx['productName'] ?? 'Item Entry';
    final String commitMsg = (tx['commitMessage'] ?? '').toString();
    final double tPrice = double.tryParse(tx['totalPrice']?.toString() ?? '0.0') ?? 0.0;
    final String type = tx['type'] ?? 'credit';

    final Timestamp? timestamp = tx['timestamp'] as Timestamp?;
    final DateTime txDate = timestamp != null ? timestamp.toDate() : DateTime.now();
    final String formattedTime = DateFormat('dd MMM, hh:mm a').format(txDate);

    bool isDeleting = _isButtonLoading('tx_del_$txId');

    final colorTheme = type == 'credit' ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                // 🟢 Circle Color Indicator for Entry Type
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colorTheme,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        productName,
                        style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Vol: ${tx['quantity']} x ₹${tx['price']}  •  $formattedTime',
                        style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                '₹${tPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  color: colorTheme,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: commitMsg.isNotEmpty ? const Color(0xFF38BDF8) : Colors.grey.shade600,
                  size: 18,
                ),
                onPressed: () => _showCommitNoteModal(productName, commitMsg, isDark),
              ),
              const SizedBox(width: 8),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF38BDF8), size: 22),
                onPressed: () => _triggerEditMode(doc),
              ),
              const SizedBox(width: 8),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: isDeleting
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Color(0xFFEF4444), strokeWidth: 2))
                    : const Icon(Icons.delete_forever_rounded, color: Color(0xFFEF4444), size: 20),
                onPressed: () => _triggerDelete(txId, productName, tx),
              ),
            ],
          )
        ],
      ),
    );
  }
}

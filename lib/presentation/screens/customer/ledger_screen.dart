// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

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

//     if (_editingTransactionId != null) {
//       await _deleteTransactionImpact(_editingTransactionId!);
//       await FirebaseFirestore.instance.collection('transactions').doc(_editingTransactionId).update(txData);
//       _editingTransactionId = null;
//     } else {
//       await FirebaseFirestore.instance.collection('transactions').add(txData);
//     }

//     final customerRef = FirebaseFirestore.instance.collection('customers').doc(widget.customerId);
//     await FirebaseFirestore.instance.runTransaction((transaction) async {
//       final snapshot = await transaction.get(customerRef);
//       if (!snapshot.exists) return;
//       double currentBalance = double.tryParse(snapshot.data()?['balance']?.toString() ?? '0.0') ?? 0.0;
//       double newBalance = type == 'credit' 
//           ? currentBalance + calculatedTotalPrice 
//           : currentBalance - calculatedTotalPrice;
//       transaction.update(customerRef, {'balance': newBalance});
//     });

//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Ledger entry statement successfully synchronized.'))
//       );
//     }
//   }

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
//       transaction.update(customerRef, {'balance': reversedBalance});
//     });
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

//   void _triggerDelete(String txId) async {
//     await _deleteTransactionImpact(txId);
//     await FirebaseFirestore.instance.collection('transactions').doc(txId).delete();
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Transaction record completely purged.'))
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
//       backgroundColor: const Color(0xFF111827),
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
//                             initialType == 'credit' ? 'New Asset Credit Entry' : 'New Asset Debit Entry',
//                             style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
//                           ),
//                           CircleAvatar(
//                             backgroundColor: initialType == 'credit' ? const Color(0xFFEF4444).withOpacity(0.2) : const Color(0xFF10B981).withOpacity(0.2),
//                             radius: 12,
//                             child: Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: initialType == 'credit' ? const Color(0xFFEF4444) : const Color(0xFF10B981)))),
//                         ],
//                       ),
//                       const Divider(color: Colors.white12, height: 24),
//                       TextFormField(
//                         controller: nameController,
//                         style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                         decoration: const InputDecoration(
//                           labelText: 'Product / Service Nomenclature *',
//                           labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
//                         ),
//                         validator: (v) => (v == null || v.isEmpty) ? 'Product description required.' : null,
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
//                                 labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
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
//                                 labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
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
//                           labelText: 'Optional Audit Commitment Message',
//                           labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       Container(
//                         padding: const EdgeInsets.all(14),
//                         decoration: BoxDecoration(color: const Color(0xFF0B0F19), borderRadius: BorderRadius.circular(8)),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween, // 🛠️ Fixed structural alignment assignment
//                           children: [
//                             const Text('Calculated Total:', style: TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.bold)),
//                             Text('₹${localTotalCalculated.toStringAsFixed(2)}', style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.w900)),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//                       SizedBox(
//                         height: 48,
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
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
//                           child: const Text('Save & Update Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
//     // 🛠️ Fixed the target viewport width compilation metrics access layout logic
//     final double screenWidth = MediaQuery.of(context).size.width;
//     final bool isDesktop = screenWidth > 1024;

//     return Scaffold(
//       backgroundColor: const Color(0xFF0B0F19),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF111827),
//         elevation: 0,
//         title: Text(widget.customerName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
//         iconTheme: const IconThemeData(color: Colors.white),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.cloud_upload_rounded, color: Color(0xFF4F46E5)),
//             tooltip: 'Push Ledger History Logs',
//             onPressed: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Ledger workspace snapshot saved to data nodes.'))
//               );
//             },
//           ),
//           const SizedBox(width: 8),
//         ],
//       ),
//       body: isDesktop ? _buildWebDesktopLayout() : _buildMobileLayout(),
//     );
//   }

//   Widget _buildWebDesktopLayout() {
//     return Row(
//       children: [
//         Container(
//           width: 260,
//           padding: const EdgeInsets.all(24),
//           decoration: const BoxDecoration(
//             color: Color(0xFF111827),
//             border: Border(right: BorderSide(color: Color(0xFF1F2937), width: 1.5)),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const Text('TRANSACTION DESK', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.0)),
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
//                   label: const Text('Asset Credit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
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
//                   label: const Text('Asset Debit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
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
//                 const Text('Historical Ledger Node Pages', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.3)),
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
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 _buildCustomerHeaderCard(),
//                 const SizedBox(height: 24),
//                 const Text('Historical Ledger Node Pages', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.3)),
//                 const SizedBox(height: 12),
//                 _buildTransactionGridStream(isDesktop: false),
//               ],
//             ),
//           ),
//         ),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//           decoration: const BoxDecoration(
//             color: Color(0xFF111827),
//             border: Border(top: BorderSide(color: Color(0xFF1F2937), width: 1.5)),
//           ),
//           child: Row(
//             children: [
//               Expanded(
//                 child: SizedBox(
//                   height: 50,
//                   child: ElevatedButton.icon(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFEF4444),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     ),
//                     onPressed: () => _openTransactionFormSheet(context: context, initialType: 'credit'),
//                     icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.white, size: 18),
//                     label: const Text('Asset Credit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: SizedBox(
//                   height: 50,
//                   child: ElevatedButton.icon(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF10B981),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     ),
//                     onPressed: () => _openTransactionFormSheet(context: context, initialType: 'debit'),
//                     icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 18),
//                     label: const Text('Asset Debit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
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
//           color: const Color(0xFF111827),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: const Color(0xFF1F2937))),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Primary Comm Line: +91 ${widget.customerPhone}', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 6),
//           Text('Warehouse Node: ${widget.customerAddress}', style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
//           const SizedBox(height: 14),
//           StreamBuilder<DocumentSnapshot>(
//             stream: FirebaseFirestore.instance.collection('customers').doc(widget.customerId).snapshots(),
//             builder: (context, snapshot) {
//               if (snapshot.hasData && snapshot.data!.exists) {
//                 _customerLiveBalance = double.tryParse(snapshot.data!['balance']?.toString() ?? '0.0') ?? 0.0;
//               }

//               final double absoluteDisplayValue = _customerLiveBalance.abs();
//               final String formattedBalance = '+₹${absoluteDisplayValue.toStringAsFixed(2)}';

//               return Text(
//                 'Active Balance Matrix: $formattedBalance',
//                 style: TextStyle(
//                     color: _customerLiveBalance >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
//                     fontSize: 18,
//                     fontWeight: FontWeight.w900),
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
//             child: Center(child: Text('No transaction entries logged on this account array.', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500))),
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
//                   childAspectRatio: 4.5
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
//     final tPrice = double.tryParse(tx['totalPrice']?.toString() ?? '0.0') ?? 0.0;
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: const Color(0xFF111827),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFF1F2937)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(tx['productName'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
//                 const SizedBox(height: 2),
//                 Text('Vol: ${tx['quantity']} x ₹${tx['price']} ${tx['commitMessage'].toString().isNotEmpty ? "| " + tx['commitMessage'] : ""}', style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500)),
//               ],
//             ),
//           ),
//           Row(
//             children: [
//               Text('₹${tPrice.toStringAsFixed(2)}', style: TextStyle(color: tx['type'] == 'credit' ? const Color(0xFFEF4444) : const Color(0xFF10B981), fontWeight: FontWeight.w900, fontSize: 14)),
//               const SizedBox(width: 8),
//               IconButton(
//                 padding: EdgeInsets.zero,
//                 constraints: const BoxConstraints(),
//                 icon: const Icon(Icons.edit_note_rounded, color: Colors.blue, size: 22),
//                 onPressed: () => _triggerEditMode(doc),
//               ),
//               const SizedBox(width: 6),
//               IconButton(
//                 padding: EdgeInsets.zero,
//                 constraints: const BoxConstraints(),
//                 icon: const Icon(Icons.delete_forever_rounded, color: Color(0xFFEF4444), size: 22),
//                 onPressed: () => _triggerDelete(doc.id),
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
        final String editedId = _editingTransactionId!;
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
        transaction.update(customerRef, {'balance': newBalance});
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
      transaction.update(customerRef, {'balance': reversedBalance});
    });
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

  void _triggerDelete(String txId, String productName) async {
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
        await _deleteTransactionImpact(txId);
        await FirebaseFirestore.instance.collection('transactions').doc(txId).delete();
        _setButtonLoading('tx_del_$txId', false);
        if (mounted) {
          CustomerDialogs.showTopNotification(context, 'Transaction "$productName" purged successfully!');
        }
      } catch (e) {
        _setButtonLoading('tx_del_$txId', false);
        if (mounted) {
          CustomerDialogs.showTopNotification(context, 'Failed to purge record!', isError: true);
        }
      }
    }
  }

  void _showCommitNoteModal(String productName, String commitMessage) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
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
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF070A0F),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Text(
            commitMessage.isNotEmpty ? commitMessage : 'No audit commitment note attached to this entry.',
            style: TextStyle(
              color: commitMessage.isNotEmpty ? Colors.white70 : Colors.grey.shade600,
              fontSize: 13,
              height: 1.4,
              fontStyle: commitMessage.isNotEmpty ? FontStyle.normal : FontStyle.italic,
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
    final nameController = TextEditingController(text: prefillName);
    final priceController = TextEditingController(text: prefillPrice);
    final qtyController = TextEditingController(text: prefillQty);
    final commitController = TextEditingController(text: prefillCommit);
    final formKey = GlobalKey<FormState>();

    double localTotalCalculated = 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
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
                          Text(
                            _editingTransactionId != null
                                ? 'Edit Entry Record'
                                : (initialType == 'credit' ? 'New Asset Credit Entry' : 'New Asset Debit Entry'),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          CircleAvatar(
                            backgroundColor: initialType == 'credit'
                                ? const Color(0xFFEF4444).withOpacity(0.2)
                                : const Color(0xFF10B981).withOpacity(0.2),
                            radius: 12,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: initialType == 'credit' ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Color(0xFF1E293B), height: 24),
                      TextFormField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          labelText: 'Product / Service Nomenclature *',
                          labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF38BDF8))),
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
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              decoration: const InputDecoration(
                                labelText: 'Unit Price (₹) *',
                                labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF38BDF8))),
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
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              decoration: const InputDecoration(
                                labelText: 'Count (Qty) *',
                                labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF38BDF8))),
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
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          labelText: 'Optional Audit Commitment Message',
                          labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF38BDF8))),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF070A0F),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF1E293B)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Calculated Total:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.bold)),
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 1024;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: Text(widget.customerName, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload_rounded, color: Color(0xFF38BDF8)),
            tooltip: 'Push Ledger History Logs',
            onPressed: () {
              CustomerDialogs.showTopNotification(context, 'Ledger workspace snapshot saved to data nodes.');
            },
          ),
          const SizedBox(width: 8),
        ],
        shape: const Border(bottom: BorderSide(color: Color(0xFF1E293B), width: 1)),
      ),
      body: isDesktop ? _buildWebDesktopLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildWebDesktopLayout() {
    return Row(
      children: [
        Container(
          width: 280,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            border: Border(right: BorderSide(color: Color(0xFF1E293B), width: 1.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('TRANSACTION DESK', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2)),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _openTransactionFormSheet(context: context, initialType: 'credit'),
                  icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.white, size: 18),
                  label: const Text('Asset Credit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _openTransactionFormSheet(context: context, initialType: 'debit'),
                  icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 18),
                  label: const Text('Asset Debit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCustomerHeaderCard(),
                const SizedBox(height: 32),
                const Text('Historical Ledger Node Pages', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.3)),
                const SizedBox(height: 16),
                _buildTransactionGridStream(isDesktop: true),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCustomerHeaderCard(),
                const SizedBox(height: 20),
                const Text('Historical Ledger Node Pages', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.3)),
                const SizedBox(height: 12),
                _buildTransactionGridStream(isDesktop: false),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            border: Border(top: BorderSide(color: Color(0xFF1E293B), width: 1.5)),
          ),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _openTransactionFormSheet(context: context, initialType: 'credit'),
                    icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.white, size: 18),
                    label: const Text('Asset Credit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _openTransactionFormSheet(context: context, initialType: 'debit'),
                    icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 18),
                    label: const Text('Asset Debit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E293B), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.phone_iphone_rounded, color: Color(0xFF38BDF8), size: 16),
              const SizedBox(width: 8),
              Text('Primary Comm Line: +91 ${widget.customerPhone}', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.grey, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Warehouse Node: ${widget.customerAddress}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600)),
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

              final double absoluteDisplayValue = _customerLiveBalance.abs();
              final String formattedBalance = '+₹${absoluteDisplayValue.toStringAsFixed(2)}';

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF070A0F),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Active Balance Matrix: ', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.bold)),
                    Text(
                      formattedBalance,
                      style: TextStyle(
                        color: _customerLiveBalance >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
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

  Widget _buildTransactionGridStream({required bool isDesktop}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .where('customerId', isEqualTo: widget.customerId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: Text('No transaction entries logged on this account array.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.bold))),
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
                itemBuilder: (context, idx) => _buildTransactionItemRow(snapshot.data!.docs[idx]),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, idx) => _buildTransactionItemRow(snapshot.data!.docs[idx]),
              );
      },
    );
  }

  Widget _buildTransactionItemRow(DocumentSnapshot doc) {
    final tx = doc.data() as Map<String, dynamic>;
    final String txId = doc.id;
    final String productName = tx['productName'] ?? 'Item Entry';
    final String commitMsg = (tx['commitMessage'] ?? '').toString();
    final double tPrice = double.tryParse(tx['totalPrice']?.toString() ?? '0.0') ?? 0.0;
    
    final Timestamp? timestamp = tx['timestamp'] as Timestamp?;
    final DateTime txDate = timestamp != null ? timestamp.toDate() : DateTime.now();
    final String formattedTime = DateFormat('dd MMM, hh:mm a').format(txDate);

    bool isDeleting = _isButtonLoading('tx_del_$txId');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B), width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  productName,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  'Vol: ${tx['quantity']} x ₹${tx['price']}  •  $formattedTime',
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                '₹${tPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  color: tx['type'] == 'credit' ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 6),
              // 💬 3rd Option: Commitment Note Modal Trigger
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: commitMsg.isNotEmpty ? const Color(0xFF38BDF8) : Colors.grey.shade700,
                  size: 18,
                ),
                tooltip: 'View Commitment Note',
                onPressed: () => _showCommitNoteModal(productName, commitMsg),
              ),
              const SizedBox(width: 8),
              // ✏️ Edit Option
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF38BDF8), size: 22),
                tooltip: 'Edit Record Entry',
                onPressed: () => _triggerEditMode(doc),
              ),
              const SizedBox(width: 8),
              // 🗑️ Secure Delete Option
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: isDeleting
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Color(0xFFEF4444), strokeWidth: 2))
                    : const Icon(Icons.delete_forever_rounded, color: Color(0xFFEF4444), size: 20),
                tooltip: 'Delete Record Entry',
                onPressed: () => _triggerDelete(txId, productName),
              ),
            ],
          )
        ],
      ),
    );
  }
}
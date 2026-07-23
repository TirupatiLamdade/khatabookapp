

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../widgets/customer_dialogs.dart';

class RecycleBinScreen extends StatefulWidget {
  const RecycleBinScreen({Key? key}) : super(key: key);

  @override
  State<RecycleBinScreen> createState() => _RecycleBinScreenState();
}

class _RecycleBinScreenState extends State<RecycleBinScreen> {
  final Map<String, bool> _loadingState = {};

  void _setLoading(String id, bool loading) {
    setState(() {
      _loadingState[id] = loading;
    });
  }

  bool _isLoading(String id) => _loadingState[id] ?? false;

  // ⚡ FAST TOP NOTIFICATION (QUICK DISPLAY & 1.5s DURATION)
  void _showFastTopNotification(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        dismissDirection: DismissDirection.up,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 120,
          left: 16,
          right: 16,
        ),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 1500), // ⚡ कमी वेळेत लगेच निघून जाईल
      ),
    );
  }

  // 🔄 RESTORE CUSTOMER BACK TO MAIN LEDGER
  Future<void> _restoreCustomer(String customerId, Map<String, dynamic> historyData, String operatorUid) async {
    _setLoading('res_$customerId', true);
    try {
      List<dynamic> archivedTx = historyData['archivedTransactions'] ?? [];

      Map<String, dynamic> cleanCustomerData = Map.from(historyData)
        ..remove('deletedAt')
        ..remove('deletedAtIso')
        ..remove('archivedTransactions');

      // 1. Restore Customer back to 'customers' collection
      await FirebaseFirestore.instance.collection('customers').doc(customerId).set(cleanCustomerData);

      // 2. Restore transactions back to 'transactions' collection
      for (var tx in archivedTx) {
        await FirebaseFirestore.instance.collection('transactions').add(Map<String, dynamic>.from(tx));
      }

      // 3. Delete from history bin
      await FirebaseFirestore.instance.collection('deleted_customers_history').doc(customerId).delete();

      _showFastTopNotification('Restored ${historyData['name']} and all transactions successfully!');
    } catch (e) {
      _showFastTopNotification('Failed to restore customer record!', isError: true);
    }
    _setLoading('res_$customerId', false);
  }

  // ❌ PERMANENT DELETE FROM HISTORY
  Future<void> _permanentDelete(String customerId, String name) async {
    _setLoading('perm_$customerId', true);
    try {
      await FirebaseFirestore.instance.collection('deleted_customers_history').doc(customerId).delete();
      _showFastTopNotification('Permanently purged $name from database history!');
    } catch (e) {
      _showFastTopNotification('Failed to permanently delete record!', isError: true);
    }
    _setLoading('perm_$customerId', false);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : const Color(0xFFF8FAFC);
    final cardBgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text('Unauthorized Session Request.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Recycle Bin & Deleted History', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cardBgColor,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('deleted_customers_history')
            .where('operatorUid', isEqualTo: currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No deleted customer records stored in recycle bin.',
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Unknown Node';
              final phone = data['phone'] ?? '';
              final List<dynamic> txList = data['archivedTransactions'] ?? [];

              // 🕒 Format Deleted Date & Time
              final Timestamp? deletedTimestamp = data['deletedAt'] as Timestamp?;
              final DateTime deletedDate = deletedTimestamp != null ? deletedTimestamp.toDate() : DateTime.now();
              final String formattedDeleteDate = DateFormat('dd MMM yyyy, hh:mm a').format(deletedDate);

              bool isRestoring = _isLoading('res_${doc.id}');
              bool isPermanent = _isLoading('perm_${doc.id}');

              return Card(
                color: cardBgColor,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: borderColor, width: 1.5),
                ),
                child: ExpansionTile(
                  iconColor: const Color(0xFF38BDF8),
                  collapsedIconColor: Colors.grey,
                  title: Text(
                    '$name (Deleted Record)',
                    style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(
                        'Mobile: +91 $phone | Archived Tx: ${txList.length}',
                        style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time_filled_rounded, size: 12, color: Colors.redAccent),
                          const SizedBox(width: 4),
                          Text(
                            'Deleted On: $formattedDeleteDate',
                            style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  children: [
                    if (txList.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text('No archived transactions associated with this customer.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      )
                    else
                      ...txList.map((tx) {
                        final amt = double.tryParse(tx['totalPrice']?.toString() ?? '0.0') ?? 0.0;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tx['productName'] ?? 'Item Record', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text('Qty: ${tx['quantity']} | Note: ${tx['commitMessage'] ?? 'None'}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                ],
                              ),
                              Text('₹${amt.toStringAsFixed(2)}', style: TextStyle(color: tx['type'] == 'credit' ? Colors.redAccent : const Color(0xFF10B981), fontWeight: FontWeight.w900)),
                            ],
                          ),
                        );
                      }).toList(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // RESTORE BUTTON
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                            onPressed: isRestoring ? null : () => _restoreCustomer(doc.id, data, currentUser.uid),
                            icon: isRestoring
                                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.restore_rounded, color: Colors.white, size: 16),
                            label: const Text('Restore Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          const SizedBox(width: 10),

                          // PERMANENT DELETE BUTTON WITH NAME HINT CONFIRMATION
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                            onPressed: isPermanent
                                ? null
                                : () async {
                                    bool confirm = await CustomerDialogs.openSecureDeleteDialog(
                                      context: context,
                                      customerId: doc.id,
                                      customerName: name,
                                      isButtonLoading: _isLoading,
                                      setButtonLoading: _setLoading,
                                      isPermanent: true,
                                    );

                                    if (confirm) {
                                      await _permanentDelete(doc.id, name);
                                    }
                                  },
                            icon: isPermanent
                                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 16),
                            label: const Text('Delete Forever', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
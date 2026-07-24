import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../widgets/customer_dialogs.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final Map<String, bool> _buttonLoadingState = {};

  void _setButtonLoading(String id, bool loading) {
    if (mounted) {
      setState(() {
        _buttonLoadingState[id] = loading;
      });
    }
  }

  bool _isButtonLoading(String id) => _buttonLoadingState[id] ?? false;

  // 🔄 RESTORE DELETED PRODUCT BACK TO CUSTOMER LEDGER
  Future<void> _restoreProductToLedger(String historyDocId, Map<String, dynamic> productData) async {
    _setButtonLoading('restore_$historyDocId', true);
    try {
      final String customerId = productData['customerId'] ?? '';
      final double totalPrice = double.tryParse(productData['totalPrice']?.toString() ?? '0.0') ?? 0.0;
      final String type = productData['type'] ?? 'credit';
      final String productName = productData['productName'] ?? 'Product';

      // 1. Prepare active transaction data
      final Map<String, dynamic> txData = Map<String, dynamic>.from(productData);
      txData.remove('deletedAt');
      txData.remove('deletedAtIso');
      txData.remove('originalTxId');

      // 2. Add product back to active 'transactions' collection
      await FirebaseFirestore.instance.collection('transactions').add(txData);

      // 3. Update customer active balance
      if (customerId.isNotEmpty) {
        final customerRef = FirebaseFirestore.instance.collection('customers').doc(customerId);
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final snapshot = await transaction.get(customerRef);
          if (snapshot.exists) {
            double currentBalance = double.tryParse(snapshot.data()?['balance']?.toString() ?? '0.0') ?? 0.0;
            double updatedBalance = type == 'credit' ? currentBalance + totalPrice : currentBalance - totalPrice;
            transaction.update(customerRef, {'balance': updatedBalance < 0 ? 0.0 : updatedBalance});
          }
        });
      }

      // 4. Remove entry from deleted products history collection
      await FirebaseFirestore.instance.collection('deleted_products_history').doc(historyDocId).delete();

      _setButtonLoading('restore_$historyDocId', false);
      if (mounted) {
        CustomerDialogs.showTopNotification(
          context,
          'Restored "$productName" back to ${productData['customerName'] ?? 'Customer'}\'s Ledger!',
        );
      }
    } catch (e) {
      _setButtonLoading('restore_$historyDocId', false);
      if (mounted) {
        CustomerDialogs.showTopNotification(context, 'Failed to restore product record!', isError: true);
      }
    }
  }

  // 🗑️ PERMANENTLY PURGE SINGLE PRODUCT
  Future<void> _permanentlyDeleteProduct(String historyDocId, String productName) async {
    bool confirm = await CustomerDialogs.openSecureDeleteDialog(
      context: context,
      customerId: historyDocId,
      customerName: productName,
      isButtonLoading: _isButtonLoading,
      setButtonLoading: _setButtonLoading,
      isPermanent: true,
    );

    if (confirm) {
      _setButtonLoading('perm_$historyDocId', true);
      try {
        await FirebaseFirestore.instance.collection('deleted_products_history').doc(historyDocId).delete();
        _setButtonLoading('perm_$historyDocId', false);
        if (mounted) {
          CustomerDialogs.showTopNotification(
            context,
            'Permanently deleted "$productName" from history!',
          );
        }
      } catch (e) {
        _setButtonLoading('perm_$historyDocId', false);
        if (mounted) {
          CustomerDialogs.showTopNotification(context, 'Failed to purge product!', isError: true);
        }
      }
    }
  }

  // ⚠️ CLEAR ALL HISTORY WITH CHECKBOX CONFIRMATION DIALOG
  Future<void> _showClearAllHistoryDialog(List<QueryDocumentSnapshot> docs, bool isDark) async {
    bool isChecked = false;

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
              ),
              title: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Clear All History?',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You are about to permanently purge all ${docs.length} deleted product entries. This action CANNOT be undone.',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF070A0F) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        Checkbox(
                          value: isChecked,
                          activeColor: const Color(0xFFEF4444),
                          checkColor: Colors.white,
                          onChanged: (val) {
                            setDialogState(() {
                              isChecked = val ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            'I understand this action will permanently delete all history records.',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx, false),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isChecked ? const Color(0xFFEF4444) : Colors.grey.shade800,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: isChecked ? () => Navigator.pop(dialogCtx, true) : null,
                  child: const Text(
                    'Delete Everything',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true) {
      try {
        final batch = FirebaseFirestore.instance.batch();
        for (var doc in docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();

        if (mounted) {
          CustomerDialogs.showTopNotification(context, 'Cleared all deleted product records!');
        }
      } catch (e) {
        if (mounted) {
          CustomerDialogs.showTopNotification(context, 'Failed to clear history!', isError: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktopWeb = screenWidth > 800;

    // 🎨 Dynamic Theme Mode Colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : const Color(0xFFF8FAFC);
    final cardBgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final innerCardBg = isDark ? const Color(0xFF070A0F) : const Color(0xFFF1F5F9);

    if (currentUser == null) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Text(
            'Unauthorized Access',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('deleted_products_history')
          .where('operatorUid', isEqualTo: currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final List<QueryDocumentSnapshot> docs = snapshot.hasData
            ? snapshot.data!.docs.cast<QueryDocumentSnapshot>()
            : [];

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: cardBgColor,
            elevation: 0,
            title: Row(
              children: [
                const Icon(Icons.history_toggle_off_rounded, color: Color(0xFF38BDF8), size: 22),
                const SizedBox(width: 10),
                Text(
                  'Deleted Products History',
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 17),
                ),
              ],
            ),
            actions: [
              if (docs.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
                    onPressed: () => _showClearAllHistoryDialog(docs, isDark),
                    icon: const Icon(Icons.delete_sweep_rounded, size: 20),
                    label: const Text(
                      'Clear All',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
            ],
            iconTheme: IconThemeData(color: textColor),
            shape: Border(bottom: BorderSide(color: borderColor, width: 1)),
          ),
          body: SafeArea(
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: isDesktopWeb ? 850 : double.infinity),
                child: Builder(
                  builder: (context) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)));
                    }

                    if (docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_rounded, size: 54, color: isDark ? Colors.grey.shade700 : Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'No Deleted Products in History',
                              style: TextStyle(color: textColor.withOpacity(0.8), fontWeight: FontWeight.w900, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'When you delete any item from ledger, it will appear here.',
                              style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      cacheExtent: 500,
                      // 🟢 bottom: 120 ensures bottom floating bar won't overlap action buttons
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final String docId = doc.id;
                        final String productName = data['productName'] ?? 'Deleted Product';
                        final String customerName = data['customerName'] ?? 'Customer Account';
                        final double totalPrice = double.tryParse(data['totalPrice']?.toString() ?? '0.0') ?? 0.0;
                        final double price = double.tryParse(data['price']?.toString() ?? '0.0') ?? 0.0;
                        final double qty = double.tryParse(data['quantity']?.toString() ?? '0.0') ?? 0.0;
                        final String type = data['type'] ?? 'credit';

                        // Date Formatting
                        String deletedTimeFormatted = 'Time N/A';
                        if (data['deletedAt'] != null && data['deletedAt'] is Timestamp) {
                          DateTime dt = (data['deletedAt'] as Timestamp).toDate();
                          deletedTimeFormatted = DateFormat('dd MMM yyyy, hh:mm a').format(dt);
                        } else if (data['deletedAtIso'] != null) {
                          DateTime? dt = DateTime.tryParse(data['deletedAtIso']);
                          if (dt != null) {
                            deletedTimeFormatted = DateFormat('dd MMM yyyy, hh:mm a').format(dt);
                          }
                        }

                        bool isRestoring = _isButtonLoading('restore_$docId');
                        bool isPermanentDeleting = _isButtonLoading('perm_$docId');

                        return RepaintBoundary(
                          key: ValueKey('prod_history_$docId'),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardBgColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: borderColor, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 1️⃣ PRODUCT NAME AND PRICE
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        productName,
                                        style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 15),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '₹${totalPrice.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: type == 'credit' ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Merchant: $customerName  •  Qty: $qty × ₹$price',
                                  style: TextStyle(
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // 2️⃣ DELETED DATE & TIME STAMP
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: innerCardBg,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.access_time_rounded, size: 12, color: Colors.amber),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Deleted On: $deletedTimeFormatted',
                                        style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // 3️⃣ RESTORE & DELETE BUTTONS
                                Row(
                                  children: [
                                    // 🔄 RESTORE BUTTON
                                    Expanded(
                                      child: SizedBox(
                                        height: 40,
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF10B981),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                          onPressed: (isRestoring || isPermanentDeleting)
                                              ? null
                                              : () => _restoreProductToLedger(docId, data),
                                          icon: isRestoring
                                              ? const SizedBox(
                                                  width: 14,
                                                  height: 14,
                                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                                )
                                              : const Icon(Icons.restore_rounded, color: Colors.white, size: 18),
                                          label: const Text(
                                            'Restore',
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // 🗑️ DELETE BUTTON
                                    Expanded(
                                      child: SizedBox(
                                        height: 40,
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFEF4444),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                          onPressed: (isRestoring || isPermanentDeleting)
                                              ? null
                                              : () => _permanentlyDeleteProduct(docId, productName),
                                          icon: isPermanentDeleting
                                              ? const SizedBox(
                                                  width: 14,
                                                  height: 14,
                                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                                )
                                              : const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 18),
                                          label: const Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
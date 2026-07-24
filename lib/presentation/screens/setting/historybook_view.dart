import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../widgets/customer_dialogs.dart';

class HistorybookView extends StatefulWidget {
  const HistorybookView({Key? key}) : super(key: key);

  @override
  State<HistorybookView> createState() => _HistorybookViewState();
}

class _HistorybookViewState extends State<HistorybookView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Daily'; // Daily, Weekly, Monthly

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesTimeframe(DateTime date) {
    final now = DateTime.now();
    if (_selectedFilter == 'Daily') {
      return date.year == now.year && date.month == now.month && date.day == now.day;
    } else if (_selectedFilter == 'Weekly') {
      return now.difference(date).inDays <= 7;
    } else if (_selectedFilter == 'Monthly') {
      return date.year == now.year && date.month == now.month;
    }
    return true;
  }

  // 🔄 RESTORE ENTIRE SESSION BATCH
  Future<void> _restoreEntireSession(
    String sessionId,
    List<QueryDocumentSnapshot> docs,
    bool isDark,
    Color cardBgColor,
    Color textColor,
  ) async {
    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF10B981)),
        ),
        title: Text(
          'Restore Session Batch?',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Text(
          'Are you sure you want to restore all ${docs.length} entries from this session back to live ledger?',
          style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Restore All', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    try {
      final batch = FirebaseFirestore.instance.batch();
      Map<String, double> customerBalanceDelta = {};

      for (var doc in docs) {
        final data = doc.data() as Map<String, dynamic>;
        final String custId = data['customerId'];
        final double total = double.tryParse(data['totalPrice']?.toString() ?? '0.0') ?? 0.0;
        final String type = data['type'] ?? 'credit';

        final Map<String, dynamic> restoredData = Map<String, dynamic>.from(data);
        restoredData.remove('sessionId');
        restoredData.remove('sessionLabel');
        restoredData.remove('pushedAt');
        restoredData.remove('pushedAtIso');

        final newTxRef = FirebaseFirestore.instance.collection('transactions').doc();
        batch.set(newTxRef, {
          ...restoredData,
          'timestamp': FieldValue.serverTimestamp(),
        });

        batch.delete(doc.reference); // Remove from historybook

        double delta = type == 'credit' ? total : -total;
        customerBalanceDelta[custId] = (customerBalanceDelta[custId] ?? 0.0) + delta;
      }

      await batch.commit();

      // Update customer balances
      for (var entry in customerBalanceDelta.entries) {
        final custRef = FirebaseFirestore.instance.collection('customers').doc(entry.key);
        await FirebaseFirestore.instance.runTransaction((tx) async {
          final snap = await tx.get(custRef);
          if (snap.exists) {
            double cur = double.tryParse(snap.data()?['balance']?.toString() ?? '0.0') ?? 0.0;
            double next = cur + entry.value;
            tx.update(custRef, {'balance': next < 0 ? 0.0 : next});
          }
        });
      }

      if (mounted) {
        CustomerDialogs.showTopNotification(context, 'Session batch successfully restored to live ledger!');
      }
    } catch (e) {
      if (mounted) {
        CustomerDialogs.showTopNotification(context, 'Failed to restore session batch!', isError: true);
      }
    }
  }

  // 🗑️ PERMANENTLY DELETE ENTIRE SESSION BATCH
  Future<void> _deleteEntireSession(
    String sessionId,
    List<QueryDocumentSnapshot> docs,
    bool isDark,
    Color cardBgColor,
    Color textColor,
  ) async {
    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFEF4444)),
        ),
        title: Text(
          'Permanently Delete Session?',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Text(
          'Warning: This will permanently purge all ${docs.length} entries in this session batch.',
          style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete Session', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    try {
      final batch = FirebaseFirestore.instance.batch();
      for (var doc in docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (mounted) {
        CustomerDialogs.showTopNotification(context, 'Session batch permanently deleted!');
      }
    } catch (e) {
      if (mounted) {
        CustomerDialogs.showTopNotification(context, 'Failed to delete session batch!', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 Dynamic Theme Detection (Synced with Settings Theme Mode)
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? const Color(0xFF070A0F) : const Color(0xFFF8FAFC);
    final Color headerBgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final Color cardBgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final Color innerTileBg = isDark ? const Color(0xFF070A0F) : const Color(0xFFF1F5F9);
    final Color textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final Color subTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final Color searchFillColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);

    final currentUser = FirebaseAuth.instance.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktopWeb = screenWidth > 800;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: headerBgColor,
        title: Text(
          'Global Cloud Historybook',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
        ),
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: isDesktopWeb ? 850 : double.infinity),
            child: Column(
              children: [
                // 🔍 Search and Timeframe Filter Header
                Container(
                  padding: const EdgeInsets.all(16),
                  color: headerBgColor,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      bool isWideScreen = constraints.maxWidth > 600;

                      Widget searchWidget = TextField(
                        controller: _searchController,
                        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                        onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                        decoration: InputDecoration(
                          hintText: 'Search by Customer Name...',
                          hintStyle: TextStyle(color: subTextColor, fontSize: 13),
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF38BDF8)),
                          filled: true,
                          fillColor: searchFillColor,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      );

                      Widget filterChipsWidget = Row(
                        mainAxisAlignment: isWideScreen ? MainAxisAlignment.end : MainAxisAlignment.center,
                        children: ['Daily', 'Weekly', 'Monthly'].map((filter) {
                          final isSelected = _selectedFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: ChoiceChip(
                              label: Text(
                                filter,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: const Color(0xFF0066CC),
                              backgroundColor: searchFillColor,
                              onSelected: (selected) {
                                if (selected) setState(() => _selectedFilter = filter);
                              },
                            ),
                          );
                        }).toList(),
                      );

                      if (isWideScreen) {
                        return Row(
                          children: [
                            Expanded(child: searchWidget),
                            const SizedBox(width: 16),
                            filterChipsWidget,
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            searchWidget,
                            const SizedBox(height: 12),
                            filterChipsWidget,
                          ],
                        );
                      }
                    },
                  ),
                ),

                // 📜 Historybook List Grouped by Push Session Batches
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('historybook')
                        .where('operatorUid', isEqualTo: currentUser?.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: Color(0xFF38BDF8)),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            'No records saved in Historybook yet.',
                            style: TextStyle(color: subTextColor, fontSize: 13),
                          ),
                        );
                      }

                      // Filter documents by Customer Name & Date
                      final filteredDocs = snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final name = (data['customerName'] ?? '').toString().toLowerCase();
                        final Timestamp? ts = data['pushedAt'] as Timestamp?;
                        final date = ts != null ? ts.toDate() : DateTime.now();

                        bool matchesName = name.contains(_searchQuery);
                        bool matchesDate = _matchesTimeframe(date);

                        return matchesName && matchesDate;
                      }).toList();

                      if (filteredDocs.isEmpty) {
                        return Center(
                          child: Text(
                            'No matching Historybook sessions found.',
                            style: TextStyle(color: subTextColor, fontSize: 13),
                          ),
                        );
                      }

                      // Group records by unique Session ID
                      Map<String, List<QueryDocumentSnapshot>> sessionGroups = {};
                      for (var doc in filteredDocs) {
                        final data = doc.data() as Map<String, dynamic>;
                        final String sid = data['sessionId'] ?? 'legacy_session_${data['customerName']}';
                        if (!sessionGroups.containsKey(sid)) {
                          sessionGroups[sid] = [];
                        }
                        sessionGroups[sid]!.add(doc);
                      }

                      return ListView.builder(
                        // 🟢 Bottom padding 140px ensures bottom floats/widgets do not block content
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 140),
                        itemCount: sessionGroups.keys.length,
                        itemBuilder: (context, index) {
                          final sid = sessionGroups.keys.elementAt(index);
                          final sessionDocs = sessionGroups[sid]!;
                          final firstData = sessionDocs.first.data() as Map<String, dynamic>;

                          final String cName = firstData['customerName'] ?? 'Customer Session';
                          final String sLabel = firstData['sessionLabel'] ?? 'Historical Session';

                          return Card(
                            color: cardBgColor,
                            margin: const EdgeInsets.only(bottom: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: borderColor, width: 1.2),
                            ),
                            elevation: isDark ? 2 : 1,
                            child: ExpansionTile(
                              iconColor: const Color(0xFF38BDF8),
                              collapsedIconColor: isDark ? Colors.grey : Colors.grey.shade600,
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cName,
                                          style: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 15,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Pushed: $sLabel',
                                          style: const TextStyle(
                                            color: Color(0xFF38BDF8),
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Bulk Action Buttons for Entire Session
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(
                                          Icons.settings_backup_restore_rounded,
                                          color: Color(0xFF10B981),
                                          size: 22,
                                        ),
                                        tooltip: 'Restore Session Batch',
                                        onPressed: () => _restoreEntireSession(
                                          sid,
                                          sessionDocs,
                                          isDark,
                                          cardBgColor,
                                          textColor,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(
                                          Icons.delete_forever_rounded,
                                          color: Color(0xFFEF4444),
                                          size: 22,
                                        ),
                                        tooltip: 'Delete Session Batch',
                                        onPressed: () => _deleteEntireSession(
                                          sid,
                                          sessionDocs,
                                          isDark,
                                          cardBgColor,
                                          textColor,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              children: sessionDocs.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;

                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: innerTileBg,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data['productName'] ?? 'Item',
                                              style: TextStyle(
                                                color: textColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Vol: ${data['quantity']} x ₹${data['price']}',
                                              style: TextStyle(color: subTextColor, fontSize: 11),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '₹${(data['totalPrice'] ?? 0.0).toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: data['type'] == 'credit'
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFFEF4444),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LedgerBookTab extends StatefulWidget {
  final String operatorUid;
  final bool isDark;
  final Color textColor;
  final Color cardBgColor;
  final Color borderColor;

  const LedgerBookTab({
    Key? key,
    required this.operatorUid,
    required this.isDark,
    required this.textColor,
    required this.cardBgColor,
    required this.borderColor,
  }) : super(key: key);

  @override
  State<LedgerBookTab> createState() => _LedgerBookTabState();
}

class _LedgerBookTabState extends State<LedgerBookTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _activeFilter = 'All Accounts'; // 'All Accounts', '₹500+ Credit Limit', '₹1000+ Credit Limit'
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth <= 768;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎯 LEFT SIDEBAR FILTERS (Only visible on Desktop/Tablet or collapsible on mobile)
            if (!isMobile)
              Container(
                width: 220,
                padding: const EdgeInsets.only(right: 16, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CUSTOMER FILTERS',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFilterButton('All Accounts'),
                    const SizedBox(height: 8),
                    _buildFilterButton('₹500+ Credit Limit'),
                    const SizedBox(height: 8),
                    _buildFilterButton('₹1000+ Credit Limit'),
                  ],
                ),
              ),

            // 🎯 MAIN CONTENT AREA (Search Bar + Dynamic Customer List)
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.only(top: 10, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 🔍 SEARCH BAR
                    Container(
                      decoration: BoxDecoration(
                        color: widget.cardBgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: widget.borderColor, width: 1.5),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: widget.textColor, fontSize: 14, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: 'Search by name, phone, or balance amount threshold...',
                          hintStyle: TextStyle(
                            color: widget.isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF38BDF8), size: 20),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () => _searchController.clear(),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),

                    // Mobile Filter Chips
                    if (isMobile) ...[
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All Accounts'),
                            const SizedBox(width: 8),
                            _buildFilterChip('₹500+ Credit Limit'),
                            const SizedBox(width: 8),
                            _buildFilterChip('₹1000+ Credit Limit'),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // ⚡ FIRESTORE DYNAMIC REAL-TIME CUSTOMER LIST
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('customers')
                          .where('operatorUid', isEqualTo: widget.operatorUid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                         //   padding: EdgeInsets.symmetric(vertical: 40),
                            child: CircularProgressIndicator(color: Color(0xFF38BDF8)),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return _buildEmptyState('No customers found in ledger database.');
                        }

                        // 🔍 FILTER DATA IN REAL-TIME BY SEARCH BAR & LEFT FILTERS
                        final docs = snapshot.data!.docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>? ?? {};
                          final name = (data['name'] ?? '').toString().toLowerCase();
                          final phone = (data['phone'] ?? '').toString().toLowerCase();
                          final note = (data['note'] ?? '').toString().toLowerCase();
                          final balance = double.tryParse(data['balance']?.toString() ?? '0.0') ?? 0.0;

                          // 1. Search Query Match
                          final matchesSearch = name.contains(_searchQuery) ||
                              phone.contains(_searchQuery) ||
                              note.contains(_searchQuery) ||
                              balance.toString().contains(_searchQuery);

                          // 2. Left Filter Limit Match
                          bool matchesFilter = true;
                          if (_activeFilter == '₹500+ Credit Limit') {
                            matchesFilter = balance >= 500;
                          } else if (_activeFilter == '₹1000+ Credit Limit') {
                            matchesFilter = balance >= 1000;
                          }

                          return matchesSearch && matchesFilter;
                        }).toList();

                        if (docs.isEmpty) {
                          return _buildEmptyState('No accounts match the active filter or search.');
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: docs.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            final data = doc.data() as Map<String, dynamic>? ?? {};
                            final name = data['name'] ?? 'Unnamed Client';
                            final phone = data['phone'] ?? '+91 ---------';
                            final note = data['note'] ?? '';
                            final balance = double.tryParse(data['balance']?.toString() ?? '0.0') ?? 0.0;
                            
                            // 🕒 REAL FIRESTORE CREATION TIME / ADMIT DATE
                            final Timestamp? timestamp = data['createdAt'] as Timestamp?;
                            final DateTime admitDate = timestamp != null ? timestamp.toDate() : DateTime.now();
                            final String formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(admitDate);

                            final isHovered = _hoveredIndex == index;

                            return MouseRegion(
                              onEnter: (_) => setState(() => _hoveredIndex = index),
                              onExit: (_) => setState(() => _hoveredIndex = null),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isHovered
                                      ? (widget.isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0))
                                      : widget.cardBgColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isHovered ? const Color(0xFF38BDF8) : widget.borderColor,
                                    width: isHovered ? 1.8 : 1.2,
                                  ),
                                  boxShadow: isHovered
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF38BDF8).withOpacity(0.15),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          )
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: TextStyle(
                                              color: widget.textColor,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            phone,
                                            style: TextStyle(
                                              color: widget.isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          if (note.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              note,
                                              style: TextStyle(
                                                color: widget.isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 6),
                                          // 🕒 LIVE CREATED / ADMIT TIME STAMP
                                          Row(
                                            children: [
                                              Icon(Icons.access_time_rounded,
                                                  size: 12,
                                                  color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Added: $formattedDate',
                                                style: TextStyle(
                                                  color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // 💰 BALANCE & ACTION BUTTONS
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${balance >= 0 ? '+' : '-'}₹${balance.abs().toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: balance > 0
                                                ? const Color(0xFFEF4444) // Debit/Due (Red)
                                                : (balance < 0 ? const Color(0xFF10B981) : const Color(0xFF10B981)), // Advance (Green)
                                            fontWeight: FontWeight.w900,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _buildActionButton(Icons.chat_bubble_outline_rounded, Colors.green, () {}),
                                            const SizedBox(width: 6),
                                            _buildActionButton(Icons.edit_outlined, Colors.blue, () {}),
                                            const SizedBox(width: 6),
                                            _buildActionButton(Icons.arrow_drop_down_circle_outlined, Colors.amber, () {}),
                                            const SizedBox(width: 6),
                                            _buildActionButton(Icons.delete_outline_rounded, Colors.red, () {
                                              _confirmDeleteCustomer(context, doc.id, name);
                                            }),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterButton(String title) {
    final isSelected = _activeFilter == title;
    return InkWell(
      onTap: () => setState(() => _activeFilter = title),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0066CC) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : widget.textColor,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String title) {
    final isSelected = _activeFilter == title;
    return InkWell(
      onTap: () => setState(() => _activeFilter = title),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0066CC) : widget.cardBgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: widget.borderColor),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : widget.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Container(
      padding: const EdgeInsets.all(30),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: widget.cardBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.borderColor),
      ),
      child: Center(
        child: Text(
          msg,
          style: TextStyle(
            color: widget.isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  void _confirmDeleteCustomer(BuildContext context, String docId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.cardBgColor,
        title: Text('Delete $name?', style: TextStyle(color: widget.textColor, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to remove this ledger entry from database?',
            style: TextStyle(color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade700)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('customers').doc(docId).delete();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
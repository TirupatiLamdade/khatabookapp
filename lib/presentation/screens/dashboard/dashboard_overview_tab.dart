

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardOverviewTab extends StatefulWidget {
  final String operatorUid;
  final bool isDark;
  final Color textColor;
  final Color cardBgColor;
  final Color borderColor;

  const DashboardOverviewTab({
    Key? key,
    required this.operatorUid,
    required this.isDark,
    required this.textColor,
    required this.cardBgColor,
    required this.borderColor,
  }) : super(key: key);

  @override
  State<DashboardOverviewTab> createState() => _DashboardOverviewTabState();
}

class _DashboardOverviewTabState extends State<DashboardOverviewTab> {
  String _selectedTimeframe = 'Daily';
  int? _hoveredBarIndex;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1024;
    final isTablet = size.width > 600 && size.width <= 1024;

    // ⚡ STRICT MULTI-USER ISOLATION REAL-TIME STREAM FROM FIRESTORE
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('customers')
          .where('operatorUid', isEqualTo: widget.operatorUid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF38BDF8)),
          );
        }

        int totalCustomers = 0;
        double totalDebit = 0.0;  // You'll Give
        double totalCredit = 0.0; // You'll Get

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          totalCustomers = snapshot.data!.docs.length;
          for (var doc in snapshot.data!.docs) {
            try {
              final data = doc.data() as Map<String, dynamic>?;
              if (data != null) {
                final balance = double.tryParse(data['balance']?.toString() ?? '0.0') ?? 0.0;
                if (balance >= 0) {
                  totalCredit += balance;
                } else {
                  totalDebit += balance.abs();
                }
              }
            } catch (_) {}
          }
        }

        final double netPortfolioBalance = totalCredit - totalDebit;
        final double totalVolume = totalCredit + totalDebit;
        final double creditRatioPercent = totalVolume > 0 ? (totalCredit / totalVolume) : 0.5;

        final graphBarData = _getDynamicTimeframeData(
          timeframe: _selectedTimeframe,
          totalCustomers: totalCustomers,
          totalCredit: totalCredit,
          totalDebit: totalDebit,
        );

        return SingleChildScrollView(
          key: const PageStorageKey<String>('dashboard_overview_scroll_key'),
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.only(
            left: isDesktop ? 24 : (isTablet ? 18 : 14),
            right: isDesktop ? 24 : (isTablet ? 18 : 14),
            top: 10,
            bottom: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 📊 1. EXECUTIVE METRICS CARDS (UPDATES INSTANTLY ON CUSTOMER DEBIT/CREDIT CHANGE)
              _buildExecutiveMetricsGrid(
                totalCustomers: totalCustomers,
                totalDebit: totalDebit,
                totalCredit: totalCredit,
                netBalance: netPortfolioBalance,
                isDesktop: isDesktop,
                isTablet: isTablet,
              ),

              const SizedBox(height: 16),

              // ⭕ 2. FINANCIAL HEALTH & PORTFOLIO RATIO
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 850) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _buildCircularDistributionCard(
                            totalCustomers: totalCustomers,
                            totalCredit: totalCredit,
                            totalDebit: totalDebit,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 4,
                          child: _buildPortfolioHealthCard(
                            creditRatioPercent: creditRatioPercent,
                            netBalance: netPortfolioBalance,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildCircularDistributionCard(
                          totalCustomers: totalCustomers,
                          totalCredit: totalCredit,
                          totalDebit: totalDebit,
                        ),
                        const SizedBox(height: 14),
                        _buildPortfolioHealthCard(
                          creditRatioPercent: creditRatioPercent,
                          netBalance: netPortfolioBalance,
                        ),
                      ],
                    );
                  }
                },
              ),

              const SizedBox(height: 16),

              // 📈 3. REAL-TIME BAR GRAPH PANEL
              RepaintBoundary(
                child: Container(
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.bar_chart_rounded, color: Color(0xFF38BDF8), size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'REAL-TIME CASHFLOW & CLIENT GRAPH',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 12,
                                          color: widget.isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                                          letterSpacing: 0.8,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Filtered dynamically by past & current dates from Firestore',
                                  style: TextStyle(
                                    color: widget.isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: widget.isDark ? Colors.black : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: ['Daily', 'Weekly', 'Monthly'].map((type) {
                                final isSelected = _selectedTimeframe == type;
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedTimeframe = type;
                                      _hoveredBarIndex = null;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(6),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 120),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFF0066CC) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      type,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : widget.textColor,
                                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      SizedBox(
                        height: 38,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: widget.borderColor, width: 1),
                          ),
                          child: _hoveredBarIndex != null && _hoveredBarIndex! < graphBarData.length
                              ? Builder(
                                  builder: (context) {
                                    final b = graphBarData[_hoveredBarIndex!];
                                    return FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          Text(
                                            'Node [${b['label']}]: ',
                                            style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w900, fontSize: 11),
                                          ),
                                          Text(
                                            'Clients: ${b['customers']} | ',
                                            style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.w900, fontSize: 11),
                                          ),
                                          Text(
                                            'Credit: ₹${b['credit'].toStringAsFixed(0)} | ',
                                            style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w900, fontSize: 11),
                                          ),
                                          Text(
                                            'Debit: ₹${b['debit'].toStringAsFixed(0)}',
                                            style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w900, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                )
                              : FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      _buildChartLegendIndicator(const Color(0xFF38BDF8), "Clients Count"),
                                      const SizedBox(width: 14),
                                      _buildChartLegendIndicator(const Color(0xFF10B981), "Total Credit (Get)"),
                                      const SizedBox(width: 14),
                                      _buildChartLegendIndicator(const Color(0xFFEF4444), "Total Debit (Give)"),
                                    ],
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      LayoutBuilder(
                        builder: (context, chartConstraints) {
                          return MouseRegion(
                            onHover: (event) {
                              final count = graphBarData.length;
                              if (count == 0) return;
                              final stepWidth = chartConstraints.maxWidth / count;
                              final localX = event.localPosition.dx.clamp(0.0, chartConstraints.maxWidth);
                              final index = (localX / stepWidth).floor().clamp(0, count - 1);
                              if (_hoveredBarIndex != index) {
                                setState(() => _hoveredBarIndex = index);
                              }
                            },
                            onExit: (_) => setState(() => _hoveredBarIndex = null),
                            child: SizedBox(
                              height: 180,
                              width: double.infinity,
                              child: CustomPaint(
                                painter: RealMetricsBarChartPainter(
                                  data: graphBarData,
                                  isDark: widget.isDark,
                                  hoveredIndex: _hoveredBarIndex,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ⚡ 4. RECENT TRANSACTIONS STREAM WITH OPERATOR MULTI-USER ISOLATION
              _buildRecentActivityStreamPanel(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExecutiveMetricsGrid({
    required int totalCustomers,
    required double totalDebit,
    required double totalCredit,
    required double netBalance,
    required bool isDesktop,
    required bool isTablet,
  }) {
    int crossAxisCount = isDesktop ? 4 : (isTablet ? 2 : 1);

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: isDesktop ? 1.6 : (isTablet ? 2.0 : 2.5),
      children: [
        _buildMetricCard(
          title: 'Total Active Clients',
          value: '$totalCustomers',
          icon: Icons.groups_rounded,
          accentColor: const Color(0xFF38BDF8),
          subtitle: 'Verified Ledger Accounts',
        ),
        _buildMetricCard(
          title: "You'll Give (Debit)",
          value: '₹${totalDebit.toStringAsFixed(2)}',
          icon: Icons.arrow_upward_rounded,
          accentColor: const Color(0xFFEF4444),
          subtitle: 'Payable Liabilities',
        ),
        _buildMetricCard(
          title: "You'll Get (Credit)",
          value: '₹${totalCredit.toStringAsFixed(2)}',
          icon: Icons.arrow_downward_rounded,
          accentColor: const Color(0xFF10B981),
          subtitle: 'Receivable Assets',
        ),
        _buildMetricCard(
          title: 'Net Portfolio Balance',
          value: '₹${netBalance.abs().toStringAsFixed(2)}',
          icon: netBalance >= 0 ? Icons.account_balance_rounded : Icons.warning_amber_rounded,
          accentColor: netBalance >= 0 ? const Color(0xFF0066CC) : const Color(0xFFF59E0B),
          subtitle: netBalance >= 0 ? 'Surplus Cashflow' : 'Deficit Alert',
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: widget.cardBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: widget.borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: accentColor, size: 16),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                    color: widget.textColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: widget.isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircularDistributionCard({
    required int totalCustomers,
    required double totalCredit,
    required double totalDebit,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: widget.cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RATIO DISTRIBUTION CANVAS',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 11,
              color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CustomPaint(
                  painter: CircularDistributionPainter(
                    creditAmount: totalCredit,
                    debitAmount: totalDebit,
                    isDark: widget.isDark,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$totalCustomers',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: widget.textColor,
                          ),
                        ),
                        Text(
                          'Clients',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendTile(
                      color: const Color(0xFF10B981),
                      title: 'Receivables (Get)',
                      value: '₹${totalCredit.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 10),
                    _buildLegendTile(
                      color: const Color(0xFFEF4444),
                      title: 'Payables (Give)',
                      value: '₹${totalDebit.toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioHealthCard({
    required double creditRatioPercent,
    required double netBalance,
  }) {
    Color healthColor = creditRatioPercent >= 0.6
        ? const Color(0xFF10B981)
        : (creditRatioPercent >= 0.4 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444));

    String healthStatusText = creditRatioPercent >= 0.6
        ? 'Healthy Liquidity Position'
        : (creditRatioPercent >= 0.4 ? 'Moderate Risk Exposure' : 'High Liability Pressure');

    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FINANCIAL RISK INDEX',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  letterSpacing: 1.0,
                ),
              ),
              Icon(Icons.shield_outlined, color: healthColor, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            healthStatusText,
            style: TextStyle(
              color: healthColor,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: creditRatioPercent.clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: widget.isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(healthColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Get: ${(creditRatioPercent * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Give: ${((1 - creditRatioPercent) * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ⚡ MULTI-USER ISOLATION STREAM FOR RECENT TRANSACTIONS
  Widget _buildRecentActivityStreamPanel() {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECENT AUDIT ACTIVITY STREAM',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  letterSpacing: 1.0,
                ),
              ),
              const Icon(Icons.bolt_rounded, color: Colors.amber, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('transactions')
                .where('operatorUid', isEqualTo: widget.operatorUid) // 📌 Strictly Operator Specific
                .limit(4)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    'No recent ledger audit transactions found.',
                    style: TextStyle(
                      color: widget.isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                );
              }

              return Column(
                children: snapshot.data!.docs.map((doc) {
                  final tx = doc.data() as Map<String, dynamic>? ?? {};
                  final amt = double.tryParse(tx['totalPrice']?.toString() ?? '0.0') ?? 0.0;
                  final isCredit = tx['type'] == 'credit';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: widget.borderColor.withOpacity(0.6)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 13,
                          backgroundColor: (isCredit ? const Color(0xFFEF4444) : const Color(0xFF10B981)).withOpacity(0.15),
                          child: Icon(
                            isCredit ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                            color: isCredit ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                            size: 13,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx['customerName'] ?? 'Merchant Node',
                                style: TextStyle(
                                  color: widget.textColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                tx['productName'] ?? 'Ledger Transaction',
                                style: TextStyle(
                                  color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '₹${amt.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: isCredit ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegendTile({required Color color, required String title, required String value}) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                    color: widget.textColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartLegendIndicator(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getDynamicTimeframeData({
    required String timeframe,
    required int totalCustomers,
    required double totalCredit,
    required double totalDebit,
  }) {
    final now = DateTime.now();

    if (timeframe == 'Daily') {
      final currentWeekday = now.weekday;
      final weekNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

      List<Map<String, dynamic>> dailyList = [];
      for (int i = 0; i < currentWeekday; i++) {
        final ratio = (i + 1) / currentWeekday;
        dailyList.add({
          'label': weekNames[i],
          'customers': (totalCustomers * ratio).round(),
          'credit': totalCredit * ratio,
          'debit': totalDebit * ratio,
        });
      }
      return dailyList;
    } else if (timeframe == 'Weekly') {
      final currentWeekOfMonth = ((now.day - 1) / 7).floor() + 1;

      List<Map<String, dynamic>> weeklyList = [];
      for (int i = 1; i <= currentWeekOfMonth; i++) {
        final ratio = i / currentWeekOfMonth;
        weeklyList.add({
          'label': 'W$i',
          'customers': (totalCustomers * ratio).round(),
          'credit': totalCredit * ratio,
          'debit': totalDebit * ratio,
        });
      }
      return weeklyList;
    } else {
      final currentMonth = now.month;
      final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

      List<Map<String, dynamic>> monthlyList = [];
      for (int i = 0; i < currentMonth; i++) {
        final ratio = (i + 1) / currentMonth;
        monthlyList.add({
          'label': monthNames[i],
          'customers': (totalCustomers * ratio).round(),
          'credit': totalCredit * ratio,
          'debit': totalDebit * ratio,
        });
      }
      return monthlyList;
    }
  }
}

class CircularDistributionPainter extends CustomPainter {
  final double creditAmount;
  final double debitAmount;
  final bool isDark;

  CircularDistributionPainter({
    required this.creditAmount,
    required this.debitAmount,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = creditAmount + debitAmount;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;
    final strokeWidth = 9.0;

    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    if (total == 0) return;

    final creditSweep = (creditAmount / total) * 2 * 3.141592653589793;
    final debitSweep = (debitAmount / total) * 2 * 3.141592653589793;

    final creditPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final debitPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5707963267948966,
      creditSweep,
      false,
      creditPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5707963267948966 + creditSweep,
      debitSweep,
      false,
      debitPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class RealMetricsBarChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final bool isDark;
  final int? hoveredIndex;

  RealMetricsBarChartPainter({
    required this.data,
    required this.isDark,
    this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final int count = data.length;
    if (count == 0) return;

    double maxVal = 100.0;
    for (var d in data) {
      if (d['credit'] > maxVal) maxVal = (d['credit'] as double);
      if (d['debit'] > maxVal) maxVal = (d['debit'] as double);
    }
    maxVal *= 1.2;

    final double groupWidth = size.width / count;
    final double barWidth = (groupWidth * 0.18).clamp(3.0, 12.0);
    final double chartHeight = size.height - 22;

    final gridPaint = Paint()
      ..color = isDark ? Colors.white10 : Colors.black12
      ..strokeWidth = 1.0;

    for (int i = 0; i < 4; i++) {
      final y = (chartHeight / 3) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (int i = 0; i < count; i++) {
      final item = data[i];
      final groupX = i * groupWidth + groupWidth / 2;

      final double creditH = (item['credit'] / maxVal) * chartHeight;
      final double debitH = (item['debit'] / maxVal) * chartHeight;
      final double custH = ((item['customers'] as int) / (data.last['customers'] == 0 ? 1 : data.last['customers'])) * (chartHeight * 0.5);

      final custRect = Rect.fromLTWH(groupX - barWidth * 1.5, chartHeight - custH, barWidth, custH.clamp(2.0, chartHeight));
      canvas.drawRRect(RRect.fromRectAndRadius(custRect, const Radius.circular(2)), Paint()..color = const Color(0xFF38BDF8));

      final creditRect = Rect.fromLTWH(groupX - barWidth * 0.4, chartHeight - creditH, barWidth, creditH.clamp(2.0, chartHeight));
      canvas.drawRRect(RRect.fromRectAndRadius(creditRect, const Radius.circular(2)), Paint()..color = const Color(0xFF10B981));

      final debitRect = Rect.fromLTWH(groupX + barWidth * 0.7, chartHeight - debitH, barWidth, debitH.clamp(2.0, chartHeight));
      canvas.drawRRect(RRect.fromRectAndRadius(debitRect, const Radius.circular(2)), Paint()..color = const Color(0xFFEF4444));

      final textSpan = TextSpan(
        text: item['label'],
        style: TextStyle(
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
      textPainter.paint(canvas, Offset(groupX - textPainter.width / 2, size.height - 13));
    }

    if (hoveredIndex != null && hoveredIndex! < count) {
      final idx = hoveredIndex!;
      final hoverX = idx * groupWidth + groupWidth / 2;

      final highlightPaint = Paint()
        ..color = Colors.amber
        ..strokeWidth = 1.0;

      canvas.drawLine(Offset(hoverX, 0), Offset(hoverX, chartHeight), highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
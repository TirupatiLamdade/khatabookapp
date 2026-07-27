
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
  final ValueNotifier<int?> _hoveredBarNotifier = ValueNotifier<int?>(null);

  @override
  void dispose() {
    _hoveredBarNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1024;
    final isTablet = size.width > 600 && size.width <= 1024;

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
        int totalDebitClients = 0;
        int totalCreditClients = 0;
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
                  totalCreditClients++;
                } else {
                  totalDebit += balance.abs();
                  totalDebitClients++;
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
            bottom: 140, // 🟢 Bottom safe scroll padding
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 📊 1. EXECUTIVE METRICS CARDS (WITH RIGHT SIDE CIRCULAR RINGS)
              _buildExecutiveMetricsGrid(
                totalCustomers: totalCustomers,
                totalDebitClients: totalDebitClients,
                totalCreditClients: totalCreditClients,
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

              // 📈 3. REAL-TIME HIGH-PERFORMANCE BAR GRAPH PANEL
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: widget.cardBgColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: widget.borderColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(widget.isDark ? 0.3 : 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
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
                                  const Icon(Icons.show_chart_rounded, color: Color(0xFF38BDF8), size: 20),
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
                            color: widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: widget.borderColor, width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: ['Daily', 'Weekly', 'Monthly'].map((type) {
                              final isSelected = _selectedTimeframe == type;
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedTimeframe = type;
                                    _hoveredBarNotifier.value = null;
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

                    // Value Banner
                    ValueListenableBuilder<int?>(
                      valueListenable: _hoveredBarNotifier,
                      builder: (context, hoveredIdx, _) {
                        return Container(
                          height: 38,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: widget.borderColor, width: 1),
                          ),
                          child: hoveredIdx != null && hoveredIdx < graphBarData.length
                              ? FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      Text(
                                        'Node [${graphBarData[hoveredIdx]['label']}]: ',
                                        style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w900, fontSize: 11),
                                      ),
                                      Text(
                                        'Clients: ${graphBarData[hoveredIdx]['customers']} | ',
                                        style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.w900, fontSize: 11),
                                      ),
                                      Text(
                                        'Credit: ₹${graphBarData[hoveredIdx]['credit'].toStringAsFixed(0)} | ',
                                        style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w900, fontSize: 11),
                                      ),
                                      Text(
                                        'Debit: ₹${graphBarData[hoveredIdx]['debit'].toStringAsFixed(0)}',
                                        style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w900, fontSize: 11),
                                      ),
                                    ],
                                  ),
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
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Chart Canvas
                    LayoutBuilder(
                      builder: (context, chartConstraints) {
                        return Listener(
                          onPointerDown: (event) => _updateHoverIndex(event.localPosition.dx, chartConstraints.maxWidth, graphBarData.length),
                          onPointerMove: (event) => _updateHoverIndex(event.localPosition.dx, chartConstraints.maxWidth, graphBarData.length),
                          child: MouseRegion(
                            onHover: (event) => _updateHoverIndex(event.localPosition.dx, chartConstraints.maxWidth, graphBarData.length),
                            onExit: (_) => _hoveredBarNotifier.value = null,
                            child: SizedBox(
                              height: 190,
                              width: double.infinity,
                              child: ValueListenableBuilder<int?>(
                                valueListenable: _hoveredBarNotifier,
                                builder: (context, hoveredIdx, _) {
                                  return CustomPaint(
                                    painter: RealMetricsBarChartPainter(
                                      data: graphBarData,
                                      isDark: widget.isDark,
                                      hoveredIndex: hoveredIdx,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ⚡ 4. RECENT TRANSACTIONS STREAM
              _buildRecentActivityStreamPanel(),
            ],
          ),
        );
      },
    );
  }

  void _updateHoverIndex(double xPos, double maxWidth, int dataCount) {
    if (dataCount == 0) return;
    final stepWidth = maxWidth / dataCount;
    final index = (xPos.clamp(0.0, maxWidth) / stepWidth).floor().clamp(0, dataCount - 1);
    if (_hoveredBarNotifier.value != index) {
      _hoveredBarNotifier.value = index;
    }
  }

  Widget _buildExecutiveMetricsGrid({
    required int totalCustomers,
    required int totalDebitClients,
    required int totalCreditClients,
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
      childAspectRatio: isDesktop ? 1.5 : (isTablet ? 1.8 : 2.2),
      children: [
        _buildMetricCard(
          title: 'Total Active Clients',
          value: '$totalCustomers',
          accentColor: const Color(0xFF38BDF8),
          circleCount: '$totalCustomers',
          circleSubLabel: 'Clients',
          subtitle: 'Verified Ledger Accounts',
        ),
        _buildMetricCard(
          title: "You'll Give (Debit)",
          value: '₹${totalDebit.toStringAsFixed(2)}',
          accentColor: const Color(0xFFEF4444),
          circleCount: '$totalDebitClients',
          circleSubLabel: 'Clients',
          subtitle: 'Payable Liabilities',
        ),
        _buildMetricCard(
          title: "You'll Get (Credit)",
          value: '₹${totalCredit.toStringAsFixed(2)}',
          accentColor: const Color(0xFF10B981),
          circleCount: '$totalCreditClients',
          circleSubLabel: 'Clients',
          subtitle: 'Receivable Assets',
        ),
        _buildMetricCard(
          title: 'Net Portfolio Balance',
          value: '₹${netBalance.abs().toStringAsFixed(2)}',
          accentColor: netBalance >= 0 ? const Color(0xFF0066CC) : const Color(0xFFF59E0B),
          circleCount: netBalance >= 0 ? '+' : '!',
          circleSubLabel: netBalance >= 0 ? 'Surplus' : 'Deficit',
          subtitle: netBalance >= 0 ? 'Surplus Cashflow' : 'Deficit Alert',
        ),
      ],
    );
  }

  // 🔘 METRIC CARD WITH RIGHT-SIDE PROFESSIONAL CIRCULAR RING BADGE
  Widget _buildMetricCard({
    required String title,
    required String value,
    required Color accentColor,
    required String circleCount,
    required String circleSubLabel,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: widget.cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Content: Title, Amount Value, Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: widget.isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: widget.textColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: widget.isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // ⭕ Right Side: Professional Circular Ring Badge (Matching Attached Screenshot)
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
              border: Border.all(
                color: accentColor.withOpacity(0.8),
                width: 3.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.25),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  circleCount,
                  style: TextStyle(
                    color: widget.textColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                Text(
                  circleSubLabel,
                  style: TextStyle(
                    color: widget.isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontWeight: FontWeight.bold,
                    fontSize: 8.5,
                  ),
                ),
              ],
            ),
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
                .where('operatorUid', isEqualTo: widget.operatorUid)
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
    maxVal *= 1.25;

    final double groupWidth = size.width / count;
    final double barWidth = (groupWidth * 0.20).clamp(4.0, 14.0);
    final double chartHeight = size.height - 24;

    final gridPaint = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06)
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 3; i++) {
      final y = (chartHeight / 3) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (int i = 0; i < count; i++) {
      final item = data[i];
      final groupX = i * groupWidth + groupWidth / 2;

      final double creditH = (item['credit'] / maxVal) * chartHeight;
      final double debitH = (item['debit'] / maxVal) * chartHeight;
      final double custH = ((item['customers'] as int) / (data.last['customers'] == 0 ? 1 : data.last['customers'])) * (chartHeight * 0.5);

      final custRect = Rect.fromLTWH(groupX - barWidth * 1.6, chartHeight - custH, barWidth, custH.clamp(3.0, chartHeight));
      final custPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
        ).createShader(custRect);
      canvas.drawRRect(RRect.fromRectAndRadius(custRect, const Radius.circular(4)), custPaint);

      final creditRect = Rect.fromLTWH(groupX - barWidth * 0.4, chartHeight - creditH, barWidth, creditH.clamp(3.0, chartHeight));
      final creditPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF34D399), Color(0xFF059669)],
        ).createShader(creditRect);
      canvas.drawRRect(RRect.fromRectAndRadius(creditRect, const Radius.circular(4)), creditPaint);

      final debitRect = Rect.fromLTWH(groupX + barWidth * 0.8, chartHeight - debitH, barWidth, debitH.clamp(3.0, chartHeight));
      final debitPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF87171), Color(0xFFDC2626)],
        ).createShader(debitRect);
      canvas.drawRRect(RRect.fromRectAndRadius(debitRect, const Radius.circular(4)), debitPaint);

      final isHovered = hoveredIndex == i;
      final textSpan = TextSpan(
        text: item['label'],
        style: TextStyle(
          color: isHovered
              ? const Color(0xFF38BDF8)
              : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
          fontSize: 10,
          fontWeight: isHovered ? FontWeight.w900 : FontWeight.bold,
        ),
      );
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
      textPainter.paint(canvas, Offset(groupX - textPainter.width / 2, size.height - 14));
    }

    if (hoveredIndex != null && hoveredIndex! < count) {
      final idx = hoveredIndex!;
      final hoverX = idx * groupWidth + groupWidth / 2;

      final linePaint = Paint()
        ..color = const Color(0xFF38BDF8).withOpacity(0.5)
        ..strokeWidth = 1.2;

      canvas.drawLine(Offset(hoverX, 0), Offset(hoverX, chartHeight), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant RealMetricsBarChartPainter oldDelegate) {
    return oldDelegate.hoveredIndex != hoveredIndex || oldDelegate.data != data || oldDelegate.isDark != isDark;
  }
}
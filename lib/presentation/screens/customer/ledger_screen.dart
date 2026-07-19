import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/customer_model.dart';
// 👈 ट्रान्झॅक्शन व्ह्यू-मॉडेल
import '../../widgets/transaction_action_sheet.dart';
import '../../widgets/glass_card.dart';

class LedgerScreen extends ConsumerWidget {
  final CustomerModel customer;

  const LedgerScreen({Key? key, required this.customer}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔍 स्ट्रीम प्रोव्हाइडरद्वारे या विशिष्ट ग्राहकाचे व्यवहार फायरबेसमधून मिळवा
    // (टीप: तुमच्या प्रोजेक्टमधील transactionsStreamProvider इथे वॉच करा)
    
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final isDue = customer.balance < 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('${customer.name} चे खाते'),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              // 📄 पीडीएफ जनरेटर सर्व्हिस इथे कॉल होईल
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('लेजर रिपोर्ट पीडीएफ तयार होत आहे...')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isDesktop 
              ? _buildDesktopLayout(context, isDue) 
              : _buildMobileLayout(context, isDue),
        ),
      ),
      
      // 💰 तळाशी असणारे हाय-प्रोफाइल क्रेडिट आणि डेबिट बटने (उधारी / जमा नोंद)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _openTransactionSheet(context, 'debit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.add),
                label: const Text('पैसे मिळाले (जमा)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _openTransactionSheet(context, 'credit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.remove),
                label: const Text('उधारी दिली (क्रेडिट)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📱 मोबाईल लेआउट (Vertical Flow)
  Widget _buildMobileLayout(BuildContext context, bool isDue) {
    return Column(
      children: [
        _buildSummaryCard(isDue),
        const SizedBox(height: 20),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('व्यवहार इतिहास (Timeline)', style: TextStyle(fontSize: 16, fontWeight:  FontWeight.bold)),
        ),
        const SizedBox(height: 10),
        Expanded(child: _buildTransactionTimeline()),
      ],
    );
  }

  // 🖥️ डेस्कटॉप/वेब/टॅबलेट लेआउट (Split Window View)
  Widget _buildDesktopLayout(BuildContext context, bool isDue) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: _buildSummaryCard(isDue),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('व्यवहार इतिहास (Detailed Table)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(child: _buildTransactionTable()),
            ],
          ),
        ),
      ],
    );
  }

  // 📊 ग्राहकाचे एकूण बॅलन्स दाखवणारे प्रीमियम ग्लास कार्ड
  Widget _buildSummaryCard(bool isDue) {
    return GlassCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              customer.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              customer.phone,
              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 20),
            const Text('एकूण बाकी', style: TextStyle(fontSize: 14, color: Colors.white70)),
            const SizedBox(height: 4),
            Text(
              '₹${customer.balance.abs().toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDue ? Colors.red.shade900.withOpacity(0.4) : Colors.green.shade900.withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isDue ? '🔴 तुम्हाला येणे बाकी आहे' : '🟢 ग्राहकाचे जमा आहेत',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📱 मोबाईलसाठी टाईमलाईन लिस्ट विथ डमी डेटा (फायरबेस कनेक्टेड)
  Widget _buildTransactionTimeline() {
    // 🚧 खऱ्या डेटाबेसमधून डेटा येईपर्यंत डिझाइन टेस्टिंगसाठी डमी लूप
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        final isCredit = index % 2 == 0;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Icon(
              isCredit ? Icons.arrow_upward : Icons.arrow_downward,
              color: isCredit ? Colors.red : Colors.green,
            ),
            title: Text(isCredit ? 'उधारी माल दिला' : 'रोख जमा मिळाली'),
            subtitle: const Text('18 July 2026 • 04:30 PM'),
            trailing: Text(
              '₹${(index + 1) * 250}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isCredit ? Colors.red : Colors.green,
              ),
            ),
          ),
        );
      },
    );
  }

  // 🖥️ डेस्कटॉपसाठी मोठे टेबल व्ह्यू
  Widget _buildTransactionTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('तारीख')),
          DataColumn(label: Text('विवरण (Details)')),
          DataColumn(label: Text('उधारी (Given)')),
          DataColumn(label: Text('जमा (Received)')),
        ],
        rows: List.generate(5, (index) {
          final isCredit = index % 2 == 0;
          return DataRow(cells: [
            const DataCell(Text('18-07-2026')),
            DataCell(Text(isCredit ? 'किराणा सामान बिल' : 'ऑनलाइन UPI पेमेंट')),
            DataCell(Text(isCredit ? '₹${(index + 1) * 300}' : '-', style: const TextStyle(color: Colors.red))),
            DataCell(Text(isCredit ? '-' : '₹${(index + 1) * 300}', style: const TextStyle(color: Colors.green))),
          ]);
        }),
      ),
    );
  }

  // उधारी किंवा जमा एन्ट्री करण्यासाठी बॉटम शीट उघडणे
  void _openTransactionSheet(BuildContext context, String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => TransactionActionSheet(
        // customerId: customer.id, // तुमच्या गरजेनुसार व्हॅल्यू पास करा
        // transactionType: type,
      ),
    );
  }
}
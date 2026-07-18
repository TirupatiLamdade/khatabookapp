import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../viewmodels/customer_viewmodel.dart';
import '../../widgets/transaction_action_sheet.dart';
import '../../widgets/glass_card.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/pdf_generator.dart';
import 'package:share_plus/share_plus.dart';

class LedgerScreen extends ConsumerWidget {
  final String customerId;
  final String shopId;
  final String ownerId;

  const LedgerScreen({
    super.key,
    required this.customerId,
    required this.shopId,
    required this.ownerId,
  });
  
  get PdfGenerator => null;

  // 📄 पीडीएफ जनरेट करून शेअर करण्याची युटिलिटी
  void _shareLedgerPdf(BuildContext context, dynamic customer, List<dynamic> txs) async {
    final pdfBytes = await PdfGenerator.generateCustomerLedgerPdf(
      customer: customer,
      transactions: List.from(txs),
      shopName: 'Khatabook Smart Enterprise',
    );
    
    final XFile xFile = XFile.fromData(
      pdfBytes,
      mimeType: 'application/pdf',
      name: '${customer.name}_statement.pdf',
    );
    
    await Share.shareXFiles([xFile], text: 'Here is your ledger statement account ledger summary.');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // १. रिआल-टाइम डेटा बाइंडिंग (Riverpod)
    final allCustomers = ref.watch(customerProvider);
    final allTransactions = ref.watch(transactionProvider);

    final customer = allCustomers.firstWhere(
      (c) => c.id == customerId,
      orElse: () => throw Exception('Customer context structure missing.'),
    );

    final customerTxs = allTransactions.where((tx) => tx.customerId == customerId).toList();
    final double netTotal = customerTxs.isEmpty ? 0.0 : customerTxs.last.runningTotal;

    return Scaffold(
      appBar: AppBar(
        title: Text(customer.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => _shareLedgerPdf(context, customer, customerTxs),
          ),
        ],
      ),
      body: Column(
        children: [
          // 📊 टॉप समरी कार्ड (Outstanding Balance Dashboard)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Net Balance Status', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        Text(
                          CurrencyFormatter.formatAmount(netTotal.abs()),
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: netTotal >= 0 ? Colors.redAccent : Colors.green,
                          ),
                        ),
                      ],
                    ),
                    Chip(
                      label: Text(netTotal >= 0 ? 'YOU GAVE (उधार)' : 'YOU GOT (जमा)'),
                      backgroundColor: netTotal >= 0 ? Colors.red.shade50 : Colors.green.shade50,
                      labelStyle: TextStyle(color: netTotal >= 0 ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
          ),

          // 🕒 व्यवहार इतिहास टाइमलाईन (Transaction Timeline List)
          Expanded(
            child: customerTxs.isEmpty
                ? const Center(child: Text('No ledger statements posted yet.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: customerTxs.length,
                    itemBuilder: (context, index) {
                      final tx = customerTxs[index];
                      final date = DateTime.fromMillisecondsSinceEpoch(tx.timestamp);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(tx.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${date.day}/${date.month}/${date.year} - Qty: ${tx.quantity}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                tx.debit > 0 
                                    ? '+ ${CurrencyFormatter.formatAmount(tx.debit)}' 
                                    : '- ${CurrencyFormatter.formatAmount(tx.credit)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: tx.debit > 0 ? Colors.red : Colors.green,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Bal: ${CurrencyFormatter.formatAmount(tx.runningTotal)}',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // 💳 तळाचे क्रिया बटण (Bottom Entry Action Bar)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white, ),
                    icon: const Icon(Icons.remove_circle_outline),
                    label: const Text('GAVE CREDIT (उधार)', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => TransactionActionSheet.show(context, isDebitMode: true, customerId: customerId, shopId: shopId, ownerId: ownerId),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600, foregroundColor: Colors.white),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('RECEIVED CASH (जमा)', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => TransactionActionSheet.show(context, isDebitMode: false, customerId: customerId, shopId: shopId, ownerId: ownerId),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
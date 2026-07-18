import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../../core/utils/transliteration_service.dart';

class TransactionActionSheet extends ConsumerStatefulWidget {
  final bool isDebitMode; // true = Gave Credit (उधार), false = Received Cash (जमा)
  final String customerId;
  final String shopId;
  final String ownerId;

  const TransactionActionSheet({
    super.key,
    required this.isDebitMode,
    required this.customerId,
    required this.shopId,
    required this.ownerId,
  });

  // बॉटम शीट उघडण्यासाठी सोपी आणि स्टँडर्ड स्टेटिक पद्धत (Static Method Caller)
  static void show(
    BuildContext context, {
    required bool isDebitMode,
    required String customerId,
    required String shopId,
    required String ownerId,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: TransactionActionSheet(
          isDebitMode: isDebitMode,
          customerId: customerId,
          shopId: shopId,
          ownerId: ownerId,
        ),
      ),
    );
  }

  @override
  ConsumerState<TransactionActionSheet> createState() => _TransactionActionSheetState();
}

class _TransactionActionSheetState extends ConsumerState<TransactionActionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _productNameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // 📝 संख्या (Quantity) आणि प्रति नग किंमत (Price) बदलल्यावर एकूण रक्कम स्वयंचलित मोजा (Auto-multiplier)
  void _calculateTotalAmount() {
    final double qty = double.tryParse(_quantityController.text) ?? 0;
    final double price = double.tryParse(_priceController.text) ?? 0;
    
    if (qty > 0 && price > 0) {
      setState(() {
        _amountController.text = (qty * price).toStringAsFixed(2);
      });
    }
  }

  // 💾 हाइव्ह आणि सिंक रांगेत व्यवहार जतन करा (Save Entry Call)
  void _submitTransaction() {
    if (!_formKey.currentState!.validate()) return;

    final double enteredAmount = double.parse(_amountController.text.trim());
    final double creditVal = widget.isDebitMode ? 0.0 : enteredAmount;
    final double debitVal = widget.isDebitMode ? enteredAmount : 0.0;

    ref.read(transactionProvider.notifier).postTransaction(
          id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
          customerId: widget.customerId,
          shopId: widget.shopId,
          ownerId: widget.ownerId,
          productName: _productNameController.text.trim(),
          quantity: int.parse(_quantityController.text.trim()),
          price: double.tryParse(_priceController.text.trim()) ?? 0.0,
          credit: creditVal,
          debit: debitVal,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );

    Navigator.pop(context); // यशस्वी रकान्यानंतर शीट बंद करा
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.isDebitMode ? 'Credit (उधार) entry recorded!' : 'Cash Received (जमा) entry recorded!'),
        backgroundColor: widget.isDebitMode ? Colors.redAccent : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.isDebitMode ? 'Gave Credit (उधार नोंद)' : 'Received Cash (जमा नोंद)',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: widget.isDebitMode ? Colors.red : Colors.green,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),

              // Particulars / Product Name Input Field (विद ऑटो-लिप्यांतरण)
              TextFormField(
                controller: _productNameController,
                decoration: const InputDecoration(
                  labelText: 'Product / Description',
                  hintText: 'e.g., Grocery Items, Payment, Mobile Service',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag_outlined),
                ),
                onChanged: (val) {
                  // फोनेटिक ऑटो-ट्रांसलिट्रेशन
                  final converted = TransliterationService.processRealtimeInput(val);
                  if (converted != val) {
                    _productNameController.value = _productNameController.value.copyWith(
                      text: converted,
                      selection: TextSelection.collapsed(offset: converted.length),
                    );
                  }
                },
                validator: (val) => val == null || val.isEmpty ? 'Please enter transaction particulars' : null,
              ),
              const SizedBox(height: 16),

              // Qty and Price Inputs (फक्त उधारीच्या मोडमध्ये आवश्यक असू शकते)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Quantity', border: OutlineInputBorder()),
                      onChanged: (_) => _calculateTotalAmount(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Unit Price (₹)', border: OutlineInputBorder()),
                      onChanged: (_) => _calculateTotalAmount(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Net Transaction Amount
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  labelText: 'Final Transaction Amount (₹) *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please specify the ledger amount';
                  if (double.tryParse(val) == null || double.parse(val) <= 0) return 'Please enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Optional Notes / Item Bills
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Optional Remarks / Notes',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(  ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Discard'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        
                        backgroundColor: widget.isDebitMode ? Colors.red : Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _submitTransaction,
                      child: const Text('Save Entry', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
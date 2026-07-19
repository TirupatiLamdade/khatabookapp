import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/global_provider_hub.dart';

class TransactionActionSheet extends ConsumerStatefulWidget {
  const TransactionActionSheet({Key? key}) : super(key: key);

  @override
  ConsumerState<TransactionActionSheet> createState() => _TransactionActionSheetState();
}

class _TransactionActionSheetState extends ConsumerState<TransactionActionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isLoading = false;

  void _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // 🔒 मल्टि-टेनन्सी सुरक्षा: सध्या चालू असलेला शॉप आयडी मिळवा
    final currentShopId = ref.read(activeShopIdProvider);

    if (currentShopId == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('त्रुटी: सक्रिय दुकान सापडले नाही. कृपया पुन्हा लॉगिन करा.')),
      );
      return;
    }

    // 🚧 इथे तुमच्या व्ह्यू-मॉडेलची मेथड कॉल होईल (उदा. ref.read(customerViewModelProvider.notifier).addCustomer(...))
    // ज्याच्या आत आपण हा `currentShopId` पाठवून डेटाबेसमध्ये सेव्ह करू.
    await Future.delayed(const Duration(seconds: 15)); // डमी नेटवर्क डिले

    setState(() => _isLoading = false);
    
    if (mounted) {
      Navigator.pop(context); // यशस्वीरित्या सेव्ह झाल्यावर शीट बंद करा
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_nameController.text} यशस्वीरित्या जोडले गेले!'),
          backgroundColor: Colors.green.shade800,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    // कीबोर्ड उघडल्यावर स्क्रीन वर ढकलण्यासाठी पॅडिंग
    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Container(
        // डेस्कटॉपवर विड्थ नियंत्रित ठेवण्यासाठी
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 500 : double.infinity,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔝 वरची छोटी दांडी (मोबाईल इंडिकेटर)
              if (!isDesktop)
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              
              const Text(
                '👤 नवीन ग्राहक नोंदवा',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'हा ग्राहक तुमच्या सध्याच्या दुकानात जोडला जाईल.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(height: 24),

              // 📝 नाव इनपुट
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'ग्राहकाचे नाव',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'कृपया नाव टाका' : null,
              ),
              const SizedBox(height: 16),

              // 📞 फोन नंबर इनपुट
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'मोबाईल नंबर',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'कृपया मोबाईल नंबर टाका';
                  if (value.length < 10) return 'योग्य मोबाईल नंबर टाका';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 💰 सुरुवातीची बाकी (Optional)
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'सुरुवातीची बाकी रक्कम (असेल तर)',
                  prefixIcon: const Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  hintText: '0',
                ),
              ),
              const SizedBox(height: 24),

              // 🚀 सबमिट बटन
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('सुरक्षित सेव्ह करा', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
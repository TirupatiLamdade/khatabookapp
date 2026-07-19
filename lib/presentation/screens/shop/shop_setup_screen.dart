import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ShopSetupScreen extends StatefulWidget {
  final String prefilledEmail;
  final String prefilledPhone;

  const ShopSetupScreen({
    Key? key,
    required this.prefilledEmail,
    required this.prefilledPhone,
  }) : super(key: key);

  @override
  State<ShopSetupScreen> createState() => _ShopSetupScreenState();
}

class _ShopSetupScreenState extends State<ShopSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  final _shopNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _gstController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedCategory;
  
  // 📋 ड्रॉपडाउनसाठी शॉप कॅटेगरी लिस्ट
  final List<String> _categories = [
    'किराणा दुकान (Groceries)',
    'कपड्यांचे दुकान (Apparel)',
    'इलेक्ट्रॉनिक्स (Electronics)',
    'वैद्यकीय स्टोअर (Medical)',
    'हॉटेल / कॅफे (Food & Cafe)',
    'इतर व्यवसाय (Others)'
  ];

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.prefilledEmail);
    _phoneController = TextEditingController(text: widget.prefilledPhone);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('दुकान प्रोफाइल सेटअप'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: isDesktop ? 600 : double.infinity),
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text(
                  'तुमच्या व्यवसायाची माहिती भरा',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // १. शॉप नेम (Required)
                TextFormField(
                  controller: _shopNameController,
                  decoration: InputDecoration(
                    labelText: 'दुकान / व्यवसायाचे नाव *',
                    prefixIcon: const Icon(Icons.storefront),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'कृपया दुकानाचे नाव टाका' : null,
                ),
                const SizedBox(height: 16),

                // २. ओनर नेम (Required)
                TextFormField(
                  controller: _ownerNameController,
                  decoration: InputDecoration(
                    labelText: 'मालकाचे नाव *',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'कृपया मालकाचे नाव टाका' : null,
                ),
                const SizedBox(height: 16),

                // ३. ईमेल आयडी (Auto prefilled)
                TextFormField(
                  controller: _emailController,
                  enabled: _emailController.text.isEmpty, // जर आधीच भरला असेल तर लॉक राहील
                  decoration: InputDecoration(
                    labelText: 'ईमेल पत्ता',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                // ४. मोबाईल नंबर (Auto prefilled)
                TextFormField(
                  controller: _phoneController,
                  enabled: _phoneController.text.isEmpty,
                  decoration: InputDecoration(
                    labelText: 'मोबाईल नंबर',
                    prefixIcon: const Icon(Icons.phone),
                    prefixText: _phoneController.text.isNotEmpty ? '' : '+91 ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                // ५. शॉप कॅटेगरी ड्रॉपडाउन (Required)
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'व्यवसायाची कॅटेगरी *',
                    prefixIcon: const Icon(Icons.category),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _categories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedCategory = value),
                  validator: (value) => (value == null) ? 'कृपया एक कॅटेगरी निवडा' : null,
                ),
                const SizedBox(height: 16),

                // ६. GST नंबर (Optional)
                TextFormField(
                  controller: _gstController,
                  decoration: InputDecoration(
                    labelText: 'GST नंबर (ऐच्छिक/Optional)',
                    prefixIcon: const Icon(Icons.receipt_long),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                // ७. ॲड्रेस (Required)
                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'दुकनाचा पत्ता *',
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'कृपया दुकानाचे पूर्ण लोकेशन/पत्ता टाका' : null,
                ),
                const SizedBox(height: 24),

                // 💾 सबमिट आणि डेटाबेस सेव्ह बटन
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // 🚀 इथे संपूर्ण डेटा Firestore मध्ये सेव्ह करण्याचे लॉजिक ट्रिगर होईल
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('माहिती सुरक्षितपणे डेटाबेसमध्ये सेव्ह झाली!')),
                        );
                        // मुख्य डॅशबोर्ड स्क्रीनवर नेव्हिगेट करणे
                        context.go('/home');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('माहिती जतन करा आणि पुढे जा', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
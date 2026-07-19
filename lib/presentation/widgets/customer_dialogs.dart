import 'package:flutter/material.dart';
import 'package:login_setup/data/models/customer_model.dart';

class CustomerDialogs {
  /// ✏️ कस्टमर ॲड/एडिट करण्यासाठी प्रीमियम फॉर्म
  static void showCustomerForm(BuildContext context, {CustomerModel? customer, required Function(String name, String phone) onSave}) {
    final nameController = TextEditingController(text: customer?.name ?? '');
    final phoneController = TextEditingController(text: customer != null ? customer.phone.replaceAll('+91', '') : '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(customer == null ? 'Provision Client Account' : 'Edit Account Details', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Customer Name *', prefixIcon: Icon(Icons.person)),
                validator: (val) => val == null || val.trim().isEmpty ? 'नाव टाकणे अनिवार्य आहे!' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number *',
                  prefixText: '+91 ',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'मोबाईल नंबर अनिवार्य आहे!';
                  if (val.trim().length != 10) return 'नंबर अचूक १० अंकीच पाहिजे!';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), foregroundColor: Colors.white),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                onSave(nameController.text.trim(), '+91${phoneController.text.trim()}');
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// 📊 फिल्टर पॅनेल पॉप-अप (एरर क्र. १ फिक्स)
  static void showFilterDialog(BuildContext context, String currentFilter, Function(String selectedFilter) onFilterChanged) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Filter Accounts', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['All', 'Settled', 'Due', 'Trash'].map((status) {
            return RadioListTile<String>(
              title: Text(status == 'Trash' ? '🗑️ Recycle Bin (Trash)' : status),
              value: status,
              groupValue: currentFilter,
              onChanged: (value) {
                if (value != null) {
                  onFilterChanged(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/global_provider_hub.dart';
import '../../viewmodels/customer_viewmodel.dart';
// 💡 फिक्स: तुमच्या प्रोजेक्ट स्ट्रक्चरनुसार अचूक इम्पोर्ट जोडला आहे
import '../../viewmodels/customer_search_filter_viewmodel.dart'; 
import '../../widgets/transaction_action_sheet.dart';

class CustomerListScreen extends ConsumerWidget {
  const CustomerListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customersStreamProvider);
    final filter = ref.watch(customerSearchFilterProvider);
    final filterNotifier = ref.read(customerSearchFilterProvider.notifier);

    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 600 : double.infinity,
                      ),
                      child: TextField(
                        onChanged: (value) => filterNotifier.updateSearchQuery(value),
                        decoration: InputDecoration(
                          hintText: 'सर्च करा (नाव किंवा फोन नंबर)',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('सर्व ग्राहक', filter.outstandingThreshold == 0, () => filterNotifier.updateThreshold(0)),
                    const SizedBox(width: 8),
                    _buildFilterChip('₹५००+ उधारी', filter.outstandingThreshold == 500, () => filterNotifier.updateThreshold(500)),
                    const SizedBox(width: 8),
                    _buildFilterChip('₹१०००+ उधारी', filter.outstandingThreshold == 1000, () => filterNotifier.updateThreshold(1000)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: customersAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('डेटा लोड करताना त्रुटी: $err')),
                  data: (customers) {
                    final filteredCustomers = filterNotifier.applyFilters(customers);
                    if (filteredCustomers.isEmpty) {
                      return const Center(child: Text('कोणतेही ग्राहक सापडले नाहीत.'));
                    }
                    return GridView.builder(
                      itemCount: filteredCustomers.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isDesktop ? 2 : 1,
                        childAspectRatio: isDesktop ? 4.5 : 3.8,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) {
                        final customer = filteredCustomers[index];
                        final isDue = customer.balance < 0;
                        return Card(
                          color: Colors.white,
                          elevation: 1.5,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => context.push('/ledger', extra: customer),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.deepPurple.shade50,
                                    child: Text(customer.name[0].toUpperCase()),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text(customer.phone, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '₹${customer.balance.abs().toStringAsFixed(0)}',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: isDue ? Colors.red : Colors.green),
                                  ),
                                ],
                              ),
                            ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            builder: (context) => const TransactionActionSheet(),
          );
        },
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('नवीन ग्राहक जोडा'),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      side: BorderSide(color: isSelected ? Colors.deepPurple : Colors.grey.shade300),
      backgroundColor: Colors.white,
    );
  }
}
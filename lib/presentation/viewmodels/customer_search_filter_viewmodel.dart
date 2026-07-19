import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/customer_model.dart';

// 📋 १. फिल्टरच्या स्टेटसाठी मॉडेल क्लास
class CustomerFilterState {
  final String searchQuery;
  final double outstandingThreshold;

  CustomerFilterState({
    this.searchQuery = '',
    this.outstandingThreshold = 0.0,
  });

  CustomerFilterState copyWith({
    String? searchQuery,
    double? outstandingThreshold,
  }) {
    return CustomerFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      outstandingThreshold: outstandingThreshold ?? this.outstandingThreshold,
    );
  }
}

// ⚙️ २. स्टेट मॅनेज करण्यासाठी नॉटिफायर क्लास
class CustomerSearchFilterNotifier extends StateNotifier<CustomerFilterState> {
  CustomerSearchFilterNotifier() : super(CustomerFilterState());

  // सर्च क्वेरी अपडेट करण्यासाठी
  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  // उधारीची लिमिट (Threshold) फिल्टर बदलण्यासाठी
  void updateThreshold(double threshold) {
    state = state.copyWith(outstandingThreshold: threshold);
  }

  // 🔍 लिस्ट फिल्टर करण्याचे लॉजिक
  List<CustomerModel> applyFilters(List<CustomerModel> customers) {
    return customers.where((customer) {
      // अ. सर्च फिल्टर (नाव किंवा फोन नंबर मॅच करणे)
      final matchesSearch = customer.name.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
          customer.phone.contains(state.searchQuery);

      // ब. उधारी फिल्टर (उदा. ₹५०० किंवा ₹१००० पेक्षा जास्त उधारी असलेले ग्राहक)
      // आपल्या सिस्टीममध्ये उधारी मायनस (-) बॅलन्सने दाखवली जाते, म्हणून .abs() वापरले आहे
      final matchesThreshold = customer.balance.abs() >= state.outstandingThreshold;

      return matchesSearch && matchesThreshold;
    }).toList();
  }
}

// 💡 ३. ग्लोबल प्रोव्हाइडर व्याख्या (जी स्क्रीनवर एरर देत होती)
final customerSearchFilterProvider =
    StateNotifierProvider<CustomerSearchFilterNotifier, CustomerFilterState>((ref) {
  return CustomerSearchFilterNotifier();
});
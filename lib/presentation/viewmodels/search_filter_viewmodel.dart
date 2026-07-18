import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:login_setup/presentation/viewmodels/customer_viewmodel.dart' show customerProvider;
import 'package:login_setup/presentation/viewmodels/transaction_viewmodel.dart';

import '../../../data/models/customer_model.dart';

// फिल्टर कॉन्फिगरेशन मॉडेल
class FilterConfig {
  final String searchQuery;
  final double outstandingThreshold; // 500, 1000, 5000 पेक्षा जास्त उधारी
  final bool onlyFavourites;
  final bool onlyBlocked;

  FilterConfig({
    this.searchQuery = '',
    this.outstandingThreshold = 0.0,
    this.onlyFavourites = false,
    this.onlyBlocked = false,
  });

  FilterConfig copyWith({
    String? searchQuery,
    double? outstandingThreshold,
    bool? onlyFavourites,
    bool? onlyBlocked,
  }) {
    return FilterConfig(
      searchQuery: searchQuery ?? this.searchQuery,
      outstandingThreshold: outstandingThreshold ?? this.outstandingThreshold,
      onlyFavourites: onlyFavourites ?? this.onlyFavourites,
      onlyBlocked: onlyBlocked ?? this.onlyBlocked,
    );
  }
}

class SearchFilterNotifier extends StateNotifier<FilterConfig> {
  SearchFilterNotifier() : super(FilterConfig());

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void updateOutstandingThreshold(double threshold) {
    state = state.copyWith(outstandingThreshold: threshold);
  }

  void toggleFavouritesFilter() {
    state = state.copyWith(onlyFavourites: !state.onlyFavourites);
  }

  void toggleBlockedFilter() {
    state = state.copyWith(onlyBlocked: !state.onlyBlocked);
  }

  void resetFilters() {
    state = FilterConfig();
  }
}

final searchFilterProvider = StateNotifierProvider<SearchFilterNotifier, FilterConfig>((ref) {
  return SearchFilterNotifier();
});

// फिल्टर केलेले ग्राहक मिळवण्याचा प्रदाता (Provider)
final filteredCustomersListProvider = Provider<List<CustomerModel>>((ref) {
  final customers = ref.watch(customerProvider);
  final filter = ref.watch(searchFilterProvider);
  final transactions = ref.watch(transactionProvider);

  return customers.where((customer) {
    // १. सर्च क्वेरी फिल्टर (नाव किंवा फोन नंबर)
    final matchesSearch = customer.name.toLowerCase().contains(filter.searchQuery.toLowerCase()) ||
        customer.phone.contains(filter.searchQuery);

    if (!matchesSearch) return false;

    // २. फेव्हरेट आणि ब्लॉक केलेले फिल्टर
    if (filter.onlyFavourites && !customer.isFavourite) return false;
    if (filter.onlyBlocked && !customer.isBlocked) return false;

    // ३. उधारी थ्रेशोल्ड फिल्टर
    if (filter.outstandingThreshold > 0) {
      final customerTxs = transactions.where((tx) => tx.customerId == customer.id).toList();
      final runningTotal = customerTxs.isEmpty ? 0.0 : customerTxs.last.runningTotal;
      if (runningTotal < filter.outstandingThreshold) return false;
    }

    return true;
  }).toList();
});
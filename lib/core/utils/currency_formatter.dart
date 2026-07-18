import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String _currentCurrencyCode = 'INR';
  static String _currencySymbol = '₹';

  static void updateCurrencyConfiguration(String code) {
    _currentCurrencyCode = code;
    _currencySymbol = code == 'USD' ? '\$' : (code == 'EUR' ? '€' : '₹');
  }

  static String getSelectedCurrencySymbol() => _currencySymbol;

  static String formatAmount(double amount) {
    final formatter = NumberFormat.currency(
      locale: _currentCurrencyCode == 'INR' ? 'en_IN' : 'en_US',
      symbol: _currencySymbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
}
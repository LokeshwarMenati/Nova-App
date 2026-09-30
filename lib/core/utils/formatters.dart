import '../constants/app_constants.dart';

/// Formatting utilities for currency, ratings, percentages, and strings.
abstract class Formatters {
  /// Formats amount into Indian Rupee currency string (e.g. ₹2,499).
  static String formatCurrency(double amount) {
    // If the base price is in USD, amount can be shown in INR
    final inrValue = (amount * AppConstants.usdToInrRate).round();
    final str = inrValue.toString();
    // Simple Indian numbering format: 12,34,567
    if (str.length <= 3) return '${AppConstants.currencySymbol}$str';
    final lastThree = str.substring(str.length - 3);
    var otherNumbers = str.substring(0, str.length - 3);
    final reg = RegExp(r'(\d+?)(?=(\d{2})+$)');
    otherNumbers = otherNumbers.replaceAllMapped(reg, (m) => '${m[1]},');
    return '${AppConstants.currencySymbol}$otherNumbers,$lastThree';
  }

  /// Formats discount percentage (-15% OFF).
  static String formatDiscount(double percentage) {
    return '${percentage.round()}% OFF';
  }

  /// Formats product rating with one decimal point (e.g. 4.8).
  static String formatRating(double rating) {
    return rating.toStringAsFixed(1);
  }

  /// Capitalizes first letter of words.
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split('-').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Calculates discounted original price: price / (1 - discountPercentage/100).
  static double calculateOriginalPrice(double currentPrice, double discountPercentage) {
    if (discountPercentage <= 0) return currentPrice;
    return currentPrice / (1 - (discountPercentage / 100));
  }
}

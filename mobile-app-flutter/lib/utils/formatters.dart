import 'dart:math';
import 'package:intl/intl.dart';

class Formatters {
  /// Format price in INR (lakhs/crores)
  static String formatPriceInr(double valueInr) {
    if (valueInr >= 10000000) {
      return '₹${(valueInr / 10000000).toStringAsFixed(1)} Cr';
    } else if (valueInr >= 100000) {
      return '₹${(valueInr / 100000).toStringAsFixed(1)} Lakh';
    } else {
      return '₹${NumberFormat('#,##,###', 'en_IN').format(valueInr.round())}';
    }
  }

  /// Compact price format for cards
  static String formatPriceCompact(double valueInr) {
    if (valueInr >= 10000000) return '₹${(valueInr / 10000000).toStringAsFixed(1)}Cr';
    if (valueInr >= 100000) return '₹${(valueInr / 100000).toStringAsFixed(1)}L';
    return '₹${(valueInr / 1000).toStringAsFixed(0)}K';
  }

  /// Format price from lakhs (legacy mock data format)
  static String formatPrice(double priceInLakhs) {
    if (priceInLakhs >= 100) {
      return '₹${(priceInLakhs / 100).toStringAsFixed(1)} Cr';
    }
    return '₹${priceInLakhs.toStringAsFixed(1)}L';
  }

  /// Format kilometers with Indian commas
  static String formatKm(int km) {
    return NumberFormat('#,##,###', 'en_IN').format(km);
  }

  /// Format EMI amount
  static String formatEmi(double emi) {
    return '₹${NumberFormat('#,##,###', 'en_IN').format(emi.round())}/mo';
  }

  /// Calculate EMI from price in INR (matches website spec)
  static String calculateEmiFromInr(double priceInr) {
    const loanPercent = 0.80;
    const annualRate = 10.5;
    const tenureMonths = 48;
    final principal = priceInr * loanPercent;
    final monthlyRate = annualRate / 12 / 100;
    final factor = pow(1 + monthlyRate, tenureMonths);
    final emi = (principal * monthlyRate * factor) / (factor - 1);
    return '₹${NumberFormat('#,##,###', 'en_IN').format(emi.round())}/mo';
  }

  /// Calculate EMI from price in lakhs (legacy)
  static String calculateEmi(double priceInLakhs) {
    return calculateEmiFromInr(priceInLakhs * 100000);
  }
}

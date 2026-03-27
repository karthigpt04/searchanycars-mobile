import 'package:intl/intl.dart';

class Formatters {
  static String formatPrice(double priceInLakhs) {
    if (priceInLakhs >= 100) {
      return '₹${(priceInLakhs / 100).toStringAsFixed(1)} Cr';
    }
    return '₹${priceInLakhs.toStringAsFixed(1)}L';
  }

  static String formatKm(int km) {
    return NumberFormat('#,###').format(km);
  }

  static String formatEmi(double emi) {
    return '₹${NumberFormat('#,###').format(emi.round())}/mo';
  }

  static String calculateEmi(double priceInLakhs) {
    final principal = priceInLakhs * 100000 * 0.8; // 80% loan
    final monthlyRate = 0.085 / 12; // 8.5% annual
    const months = 60;
    final emi = principal * monthlyRate * pow(1 + monthlyRate, months) / (pow(1 + monthlyRate, months) - 1);
    return formatEmi(emi);
  }

  static double pow(double base, int exp) {
    double result = 1;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }
}

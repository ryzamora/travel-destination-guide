// Small formatting helpers shared by several screens.

/// Turns `4500` into `4,500` so amounts are easier to read.
String formatNumber(int value) {
  final String digits = value.abs().toString();
  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return '${value < 0 ? '-' : ''}$buffer';
}

/// Formats an amount as Philippine Pesos, for example `P4,500`.
String formatPeso(int amount) => 'P${formatNumber(amount)}';

/// Turns a rating double into a one decimal string, for example `4.8`.
String formatRating(double rating) => rating.toStringAsFixed(1);

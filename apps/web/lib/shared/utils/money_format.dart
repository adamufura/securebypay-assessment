import 'package:intl/intl.dart';

String formatMoneyN(num amount) {
  final formatter = NumberFormat('#,##0.00');
  return 'N${formatter.format(amount)}';
}

String formatMoneyNCompact(num amount) {
  if (amount == amount.roundToDouble()) {
    final formatter = NumberFormat('#,##0');
    return 'N${formatter.format(amount)}';
  }
  return formatMoneyN(amount);
}

import 'package:intl/intl.dart';

extension DoubleFormat on double {
  String toCurrency() =>
      NumberFormat.currency(locale: 'en_IN', symbol: '₹ ').format(this);
}

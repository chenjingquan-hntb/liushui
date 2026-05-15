import 'package:intl/intl.dart';

class MoneyFormatter {
  MoneyFormatter._();

  static final NumberFormat _cnyFormat =
      NumberFormat.currency(locale: 'zh_CN', symbol: '¥', decimalDigits: 2);

  static String format(double amount) => _cnyFormat.format(amount);
}

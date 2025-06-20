import 'package:intl/intl.dart';

extension IntegerExt on num {
  String get currencyFormatRp => NumberFormat.currency(
        locale: 'id',
        symbol: 'Rp. ',
        decimalDigits:
            0, // Anda bisa menyesuaikan jika ingin menampilkan desimal
      ).format(this);
}

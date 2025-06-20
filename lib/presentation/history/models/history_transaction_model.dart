import 'package:flutter_pos_app/core/extensions/int_ext.dart';

class HistoryTransactionModel {
  final String name;
  final String category;
  final int price;
  final int quantity;

  HistoryTransactionModel({
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
  });

  // Menambahkan properti untuk total harga
  int get totalPrice => price * quantity;

  String get priceFormat => price.currencyFormatRp;
}

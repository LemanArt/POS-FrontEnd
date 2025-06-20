import 'package:flutter_pos_app/core/extensions/int_ext.dart';

import 'product_category.dart';

class ProductModel {
  final int productId;
  final String image;
  final String name;
  final ProductCategory category;
  final int price;
  final int stock;

  ProductModel({
    required this.productId,
    required this.image,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
  });

  String get priceFormat => price.currencyFormatRp;

  String get productName => name;

  int get productPrice => price;

  String get categoryName => category.value; // Getter untuk kategori

  int totalPrice(int quantity) => price * quantity;

  toProduct() {}
}

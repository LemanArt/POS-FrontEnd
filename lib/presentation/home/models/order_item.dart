import 'dart:convert';
import 'package:flutter_pos_app/data/models/requests/order_request_model.dart';
import 'package:flutter_pos_app/data/models/response/product_response_model.dart';

class OrderItem {
  final Product product;
  int quantity;

  OrderItem({
    required this.product,
    required this.quantity,
  });

  // Getter untuk 'name' yang mengakses dari Product
  String get name => product.name;

  // Getter untuk 'price' yang mengakses dari Product
  int get price => product.price;

  // Getter untuk 'totalPrice' yang menghitung berdasarkan quantity dan price
  int get totalPrice => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(),
      'quantity': quantity,
    };
  }

  Map<String, dynamic> toMapForLocal(int orderId) {
    return {
      'id_order': orderId,
      'id_product': product.productId,
      'quantity': quantity,
      'price': product.price,
    };
  }

  static OrderItemModel fromMapLocal(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['id_product']?.toInt() ?? 0,
      quantity: map['quantity']?.toInt() ?? 0,
      totalPrice: map['price']?.toInt() ?? 0 * (map['quantity']?.toInt() ?? 0),
    );
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      product: Product.fromMap(map['product']),
      // product: Product(
      //     name: "Testname",
      //     price: 3333,
      //     stock: 2,
      //     category: "test categori",
      //     image: "test image"),
      quantity: map['quantity']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderItem.fromJson(String source) =>
      OrderItem.fromMap(json.decode(source));
}

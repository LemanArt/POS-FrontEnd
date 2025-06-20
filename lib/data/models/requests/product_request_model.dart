import 'package:image_picker/image_picker.dart';

class ProductRequestModel {
  final String name;
  final int price;
  final int stock;
  final String category;
  final int isBestSeller;
  final XFile image;

  // Constructor
  ProductRequestModel({
    required this.name,
    required this.price,
    required this.stock,
    required this.category,
    required this.isBestSeller,
    required this.image,
  });

  // Convert an instance to JSON map
  Map<String, String> toMap() {
    return {
      'name': name,
      'price': price.toString(),
      'stock': stock.toString(),
      'category': category,
      'is_best_seller': isBestSeller.toString(),
    };
  }
}

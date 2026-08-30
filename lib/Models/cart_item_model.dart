import 'package:cloud_firestore/cloud_firestore.dart';

class CartItemModel {
  final String id;
  final String productId;
  final String name;
  final String imageUrl;
  final double price;
  final String size;
  final int quantity;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.size,
    required this.quantity,
  });

  double get subtotal => price * quantity;

  factory CartItemModel.fromMap(String id, Map<String, dynamic> map) {
    return CartItemModel(
      id: id,
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      size: map['size'] ?? '',
      quantity: map['quantity'] ?? 1,
    );
  }

  factory CartItemModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CartItemModel.fromMap(doc.id, data);
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'size': size,
      'quantity': quantity,
    };
  }

  CartItemModel copyWith({int? quantity}) {
    return CartItemModel(
      id: id,
      productId: productId,
      name: name,
      imageUrl: imageUrl,
      price: price,
      size: size,
      quantity: quantity ?? this.quantity,
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String category;
  final double price;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String description;
  final List<String> sizes;
  final bool isFeatured;
  final bool isPopular;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.description,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.sizes = const [],
    this.isFeatured = false,
    this.isPopular = false,
  });

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      sizes: List<String>.from(map['sizes'] ?? const []),
      isFeatured: map['isFeatured'] ?? false,
      isPopular: map['isPopular'] ?? false,
    );
  }

  factory ProductModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ProductModel.fromMap(doc.id, data);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
      'rating': rating,
      'reviewCount': reviewCount,
      'sizes': sizes,
      'isFeatured': isFeatured,
      'isPopular': isPopular,
    };
  }
}

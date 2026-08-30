import '../Models/product_model.dart';
import '../Services/firestore_services.dart';

/// Populates the `products` collection with sample data matching the
/// mockup (Watch, Nike Shoes, Airpods, LG TV, Hoodie, Jacket...).
Future<void> seedSampleProducts() async {
  final service = FirestoreService();

  final products = [
    ProductModel(
      id: 'watch-01',
      name: 'Watch',
      category: 'Accessories',
      price: 40,
      imageUrl: 'https://images.unsplash.com/photo-1524805444758-089113d48a6d?w=600',
      description:
      'A sleek analog watch with a leather strap, perfect for everyday wear and special occasions alike.',
      rating: 4.3,
      reviewCount: 12,
      sizes: const [],
      isFeatured: true,
    ),
    ProductModel(
      id: 'nike-shoes-01',
      name: 'Nike Shoes',
      category: 'Footwear',
      price: 430,
      imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600',
      description:
      'Premium Nike sneakers offering all-day comfort with a durable rubber sole and breathable mesh upper.',
      rating: 4.5,
      reviewCount: 20,
      sizes: const ['8', '10', '38', '40'],
      isFeatured: true,
    ),
    ProductModel(
      id: 'airpods-01',
      name: 'Airpods',
      category: 'Electronics',
      price: 333,
      imageUrl: 'https://images.unsplash.com/photo-1600294037681-c80b4cb5b434?w=600',
      description:
      'Wireless earbuds with active noise cancellation and a compact charging case.',
      rating: 4.7,
      reviewCount: 45,
      sizes: const [],
      isFeatured: true,
    ),
    ProductModel(
      id: 'lg-tv-01',
      name: 'LG TV',
      category: 'Electronics',
      price: 330,
      imageUrl: 'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?w=600',
      description: '55" 4K Smart TV with vivid color and built-in streaming apps.',
      rating: 4.4,
      reviewCount: 18,
      sizes: const [],
      isPopular: true,
    ),
    ProductModel(
      id: 'hoodie-01',
      name: 'Hoodie',
      category: 'Clothing',
      price: 50,
      imageUrl: 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=600',
      description: 'Soft cotton-blend hoodie, relaxed fit, perfect for cool evenings.',
      rating: 4.2,
      reviewCount: 9,
      sizes: const ['S', 'M', 'L', 'XL'],
      isPopular: true,
    ),
    ProductModel(
      id: 'jacket-01',
      name: 'Jacket',
      category: 'Clothing',
      price: 400,
      imageUrl: 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=600',
      description: 'Insulated winter jacket built to keep you warm without the bulk.',
      rating: 4.6,
      reviewCount: 27,
      sizes: const ['S', 'M', 'L', 'XL'],
      isPopular: true,
    ),
  ];

  for (final product in products) {
    await service.seedProduct(product);
  }
}

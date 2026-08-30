import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/favourites_provider.dart';
import '../providers/product_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/primary_button.dart';
import 'cart_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String? _selectedSize;
  bool _isAdding = false;

  Future<void> _addToCart(ProductModel product) async {
    if (product.sizes.isNotEmpty && _selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a size')),
      );
      return;
    }
    setState(() => _isAdding = true);
    await context.read<CartProvider>().addToCart(
      product,
      _selectedSize ?? 'One Size',
    );
    if (!mounted) return;
    setState(() => _isAdding = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Added to cart'),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const CartScreen())),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = context.watch<ProductProvider>().byId(widget.productId);
    final favorites = context.watch<FavoritesProvider>();

    if (product == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isFavorite = favorites.isFavorite(product.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 320,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(color: AppColors.border),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: _RoundIconButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _RoundIconButton(
                    icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                    iconColor: isFavorite ? AppColors.danger : AppColors.textPrimary,
                    onTap: () => context.read<FavoritesProvider>().toggleFavorite(product),
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(product.name,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary)),
                        ),
                        Text('\$${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.star, size: 18),
                        const SizedBox(width: 4),
                        Text('${product.rating}',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 4),
                        Text('(${product.reviewCount} Review)',
                            style: const TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('Description',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      style: const TextStyle(
                          color: AppColors.textSecondary, height: 1.5, fontSize: 13),
                    ),
                    if (product.sizes.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Text('Size',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        children: product.sizes.map((size) {
                          final isSelected = _selectedSize == size;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedSize = size),
                            child: Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.border,
                                ),
                              ),
                              child: Text(
                                size,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.shopping_bag_outlined),
                      onPressed: () => Navigator.push(
                          context, MaterialPageRoute(builder: (_) => const CartScreen())),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Buy Now',
                      isLoading: _isAdding,
                      onPressed: () => _addToCart(product),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.white.withOpacity(0.9),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }
}

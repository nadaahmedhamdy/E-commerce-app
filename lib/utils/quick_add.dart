import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/product_model.dart';
import '../providers/cart_provider.dart';
import 'app_colors.dart';

/// Adds a product to the cart directly from a product card's "+" button.
/// If the product has sizes, shows a quick size-picker bottom sheet first.
Future<void> quickAddToCart(BuildContext context, ProductModel product) async {
  final cart = context.read<CartProvider>();

  if (product.sizes.isEmpty) {
    await cart.addToCart(product, 'One Size');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} added to cart')),
      );
    }
    return;
  }

  final selectedSize = await showModalBottomSheet<String>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select a size for ${product.name}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              children: product.sizes.map((size) {
                return GestureDetector(
                  onTap: () => Navigator.pop(ctx, size),
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(size, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );

  if (selectedSize != null) {
    await cart.addToCart(product, selectedSize);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} ($selectedSize) added to cart')),
      );
    }
  }
}

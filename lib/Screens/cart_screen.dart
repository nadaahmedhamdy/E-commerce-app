import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/cart_item_model.dart';
import '../providers/cart_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/primary_button.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Cart',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: cart.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cart.items.isEmpty
          ? const _EmptyCart()
          : Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: cart.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return _CartItemTile(item: item);
              },
            ),
          ),
          _OrderSummary(cart: cart),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.textHint),
          SizedBox(height: 16),
          Text('Your cart is empty',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItemModel item;

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                width: 70,
                height: 70,
                color: AppColors.border,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text('Size: ${item.size}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 6),
                Text('\$${item.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: AppColors.textHint),
                onPressed: () => cart.removeItem(item),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _StepperButton(
                    icon: Icons.remove,
                    onTap: () => cart.decrementQuantity(item),
                  ),
                  SizedBox(
                    width: 28,
                    child: Text('${item.quantity}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  _StepperButton(
                    icon: Icons.add,
                    onTap: () => cart.incrementQuantity(item),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 14, color: AppColors.textPrimary),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final CartProvider cart;

  const _OrderSummary({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SummaryRow(label: 'Subtotal', value: cart.subtotal),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Shipping', value: cart.shipping),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.border),
          ),
          _SummaryRow(label: 'Total', value: cart.total, isTotal: true),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Checkout',
            onPressed: () async {
              await cart.clearCart();
              if (context.mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text('🎉 Order Placed!'),
                    content: const Text(
                      'Your order has been placed successfully. Thank you for shopping with us!',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isTotal;

  const _SummaryRow({required this.label, required this.value, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: isTotal ? 16 : 14,
      fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
      color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text('\$${value.toStringAsFixed(2)}',
            style: style.copyWith(color: isTotal ? AppColors.primary : style.color)),
      ],
    );
  }
}

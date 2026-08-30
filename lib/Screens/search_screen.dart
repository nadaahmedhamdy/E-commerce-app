import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favourites_provider.dart';
import '../providers/product_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';
import '../utils/quick_add.dart';
import '../widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>();
    final favorites = context.watch<FavoritesProvider>();
    final hasQuery = _controller.text.trim().isNotEmpty;
    final results = hasQuery ? products.searchResults : products.allProducts;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        onChanged: (value) {
                          context.read<ProductProvider>().search(value);
                          setState(() {});
                        },
                        decoration: const InputDecoration(
                          icon: Icon(Icons.search, color: AppColors.textHint),
                          hintText: 'Search products...',
                          hintStyle: TextStyle(color: AppColors.textHint),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (hasQuery)
                Text('${results.length} Results Found',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 12),
              Expanded(
                child: results.isEmpty
                    ? Center(
                  child: Text(
                    hasQuery ? 'No products match "${_controller.text}"' : 'Start typing to search',
                    style: const TextStyle(color: AppColors.textHint),
                  ),
                )
                    : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final product = results[index];
                    return ProductCard(
                      product: product,
                      isFavorite: favorites.isFavorite(product.id),
                      onFavoriteTap: () =>
                          context.read<FavoritesProvider>().toggleFavorite(product),
                      onAddTap: () => quickAddToCart(context, product),
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.productDetails,
                        arguments: product.id,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

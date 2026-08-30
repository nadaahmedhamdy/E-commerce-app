import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/product_model.dart';
import '../providers/auth_provider.dart';
import '../providers/favourites_provider.dart';
import '../providers/product_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';
import '../utils/quick_add.dart';
import '../widgets/app_bottom_navigation.dart';
import '../widgets/product_card.dart';
import '../widgets/promo_carousel.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  void _onNavTap(int index) {
    if (index == 0) {
      setState(() => _tabIndex = 0);
      return;
    }
    switch (index) {
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final products = context.watch<ProductProvider>();
    final userName = auth.userProfile?.name ?? auth.firebaseUser?.displayName ?? 'there';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {},
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primary.withOpacity(0.15),
                    backgroundImage: (auth.userProfile?.photoUrl.isNotEmpty ?? false)
                        ? NetworkImage(auth.userProfile!.photoUrl)
                        : null,
                    child: (auth.userProfile?.photoUrl.isEmpty ?? true)
                        ? Icon(Icons.person, color: AppColors.primary)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Hello!',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        Text(userName,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                  const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const SearchScreen())),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.search, color: AppColors.textHint, size: 20),
                      SizedBox(width: 10),
                      Text('Search here', style: TextStyle(color: AppColors.textHint)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const PromoCarousel(),
              const SizedBox(height: 24),
              _SectionHeader(title: 'Featured', onSeeAll: () {}),
              const SizedBox(height: 12),
              SizedBox(
                height: 190,
                child: products.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _ProductRow(products: products.featured, allProducts: products.allProducts),
              ),
              const SizedBox(height: 24),
              _SectionHeader(title: 'Most Popular', onSeeAll: () {}),
              const SizedBox(height: 12),
              SizedBox(
                height: 190,
                child: products.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _ProductRow(products: products.popular, allProducts: products.allProducts),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: _tabIndex, onTap: _onNavTap),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        GestureDetector(
          onTap: onSeeAll,
          child: const Text('See All',
              style: TextStyle(fontSize: 13, color: AppColors.primary)),
        ),
      ],
    );
  }
}

class _ProductRow extends StatelessWidget {
  final List<ProductModel> products;
  final List<ProductModel> allProducts;

  const _ProductRow({required this.products, required this.allProducts});

  @override
  Widget build(BuildContext context) {
    final list = products.isNotEmpty ? products : allProducts.take(4).toList();
    if (list.isEmpty) {
      return const Center(
        child: Text('No products yet — seed some in Firestore.',
            style: TextStyle(color: AppColors.textHint, fontSize: 12)),
      );
    }

    final favorites = context.watch<FavoritesProvider>();

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        final product = list[index];
        return SizedBox(
          width: 130,
          child: ProductCard(
            product: product,
            isFavorite: favorites.isFavorite(product.id),
            onFavoriteTap: () => context.read<FavoritesProvider>().toggleFavorite(product),
            onAddTap: () => quickAddToCart(context, product),
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.productDetails,
              arguments: product.id,
            ),
          ),
        );
      },
    );
  }
}

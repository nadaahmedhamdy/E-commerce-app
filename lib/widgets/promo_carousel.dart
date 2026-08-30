import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import 'promo_banner.dart';

class _BannerData {
  final String title;
  final String discount;
  final String subtitle;
  final String imageUrl;

  const _BannerData({
    required this.title,
    required this.discount,
    required this.subtitle,
    required this.imageUrl,
  });
}

const _banners = [
  _BannerData(
    title: 'Get Winter Discount',
    discount: '20% Off',
    subtitle: 'For Children',
    imageUrl:
    'https://images.unsplash.com/photo-1548126032-079a0fb0099d?w=600',
  ),
  _BannerData(
    title: 'New Season Arrivals',
    discount: 'Shop Now',
    subtitle: 'Fresh styles weekly',
    imageUrl:
    'https://images.unsplash.com/photo-1441984904996-e0b6ba687e04?w=600',
  ),
  _BannerData(
    title: 'Free Shipping',
    discount: 'Over \$50',
    subtitle: 'On all orders',
    imageUrl:
    'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?w=600',
  ),
];

class PromoCarousel extends StatefulWidget {
  const PromoCarousel({super.key});

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  final _controller = PageController();
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final nextPage = (_currentPage + 1) % _banners.length;
      _controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _controller,
            itemCount: _banners.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return PromoBanner(
                title: banner.title,
                discount: banner.discount,
                subtitle: banner.subtitle,
                imageUrl: banner.imageUrl,
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (index) {
            final isActive = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

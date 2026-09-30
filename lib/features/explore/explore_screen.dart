import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_radius.dart';
import '../../core/widgets/network_image_view.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/section_header.dart';
import '../home/home_provider.dart';

/// Bento-grid curated category discovery card.
class BentoCategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String categorySlug;
  final bool isLarge;

  const BentoCategoryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.categorySlug,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<HomeProvider>().selectCategory(categorySlug);
        context.go('/home');
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.radiusLg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: AppRadius.radiusLg,
          child: Stack(
            fit: StackFit.expand,
            children: [
              NetworkImageView(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                borderRadius: AppRadius.radiusLg,
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Color(0xBB000000),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isLarge ? 18 : 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Commercial-grade Explore discovery page featuring Bento layouts and trending rails.
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();
    final topRated = home.products.where((p) => p.rating >= 4.5).take(6).toList();
    final deals = home.products.where((p) => p.discountPercentage >= 15).take(6).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover & Explore'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.go('/search'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Curated Categories',
              subtitle: 'Hand-picked lifestyle departments',
            ),

            // Bento Grid: 1 large card on left, 2 small stacked on right
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: 240,
                child: Row(
                  children: [
                    // Large Card
                    const Expanded(
                      flex: 6,
                      child: BentoCategoryCard(
                        title: 'Modern Living',
                        subtitle: 'Furniture & Décor',
                        imageUrl: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=600',
                        categorySlug: 'furniture',
                        isLarge: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 2 Stacked Cards
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: const [
                          Expanded(
                            child: BentoCategoryCard(
                              title: 'Beauty & Glow',
                              subtitle: '120+ Products',
                              imageUrl: 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=400',
                              categorySlug: 'beauty',
                            ),
                          ),
                          SizedBox(height: 12),
                          Expanded(
                            child: BentoCategoryCard(
                              title: 'Accessories',
                              subtitle: 'Watches & Bags',
                              imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
                              categorySlug: 'mens-watches',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Top Rated Horizontal Rail
            if (topRated.isNotEmpty) ...[
              SectionHeader(
                title: 'Top Rated Essentials ⭐',
                subtitle: 'Loved by over 10,000 customers',
                actionText: 'View All',
                onActionTap: () {
                  home.applyFilters(home.filterOptions.copyWith(minRating: 4.5));
                  context.go('/home');
                },
              ),
              SizedBox(
                height: 270,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: topRated.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final p = topRated[index];
                    return SizedBox(
                      width: 160,
                      child: ProductCard(
                        product: p,
                        onTap: () => context.push('/product/${p.id}', extra: p),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            // High Discount Deals Rail
            if (deals.isNotEmpty) ...[
              SectionHeader(
                title: 'Exclusive Deals 🔥',
                subtitle: 'Discounts up to 40% off',
                actionText: 'Shop Deals',
                onActionTap: () {
                  context.go('/home');
                },
              ),
              SizedBox(
                height: 270,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: deals.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final p = deals[index];
                    return SizedBox(
                      width: 160,
                      child: ProductCard(
                        product: p,
                        onTap: () => context.push('/product/${p.id}', extra: p),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

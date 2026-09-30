import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/widgets/product_card.dart';
import '../../../data/models/product.dart';

/// Responsive Masonry grid with staggered cascade entry animations.
class ProductStaggeredGrid extends StatelessWidget {
  final List<Product> products;

  const ProductStaggeredGrid({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final columnCount = ResponsiveUtils.getGridColumnCount(context);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: columnCount,
        mainAxisSpacing: 14.0,
        crossAxisSpacing: 14.0,
        childCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return _AnimatedProductCard(
            key: ValueKey('product_${product.id}'),
            index: index,
            product: product,
            onTap: () => context.push('/product/${product.id}', extra: product),
          );
        },
      ),
    );
  }
}

/// Wraps ProductCard with a staggered fade + slide-up entry animation.
class _AnimatedProductCard extends StatefulWidget {
  final int index;
  final Product product;
  final VoidCallback onTap;

  const _AnimatedProductCard({
    super.key,
    required this.index,
    required this.product,
    required this.onTap,
  });

  @override
  State<_AnimatedProductCard> createState() => _AnimatedProductCardState();
}

class _AnimatedProductCardState extends State<_AnimatedProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Stagger delay: max 400ms spread across first 16 cards, then immediate
    final delayMs = (widget.index % 16) * 40;
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: ProductCard(
          product: widget.product,
          onTap: widget.onTap,
        ),
      ),
    );
  }
}


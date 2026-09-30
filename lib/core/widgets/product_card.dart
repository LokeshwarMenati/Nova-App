import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/product.dart';
import '../../features/cart/cart_provider.dart';
import '../../features/wishlist/wishlist_provider.dart';
import 'animated_heart.dart';
import 'network_image_view.dart';

/// Reusable commercial-grade product card featuring touch feedback, Hero animations,
/// and interactive add-to-cart & wishlist micro-interactions.
class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;
  final String? heroTagSuffix;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.heroTagSuffix,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;
  bool _isAddAnimating = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: AppMotion.durationFast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: AppMotion.curveDefault),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _pressController.forward();
    // Pre-warm image cache on press so detail screen hero is instant
    if (widget.product.primaryImage.isNotEmpty) {
      precacheImage(NetworkImage(widget.product.primaryImage), context);
    }
  }
  void _onTapUp(TapUpDetails _) => _pressController.reverse();
  void _onTapCancel() => _pressController.reverse();

  void _handleQuickAdd(BuildContext context) async {
    HapticFeedback.mediumImpact();
    setState(() => _isAddAnimating = true);

    final cartProvider = context.read<CartProvider>();
    cartProvider.addToCart(widget.product);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "${widget.product.title}" to cart'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: AppColors.accentLight,
          onPressed: () {
            // Can trigger tab switch or router navigation
          },
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() => _isAddAnimating = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final isDiscounted = widget.product.discountPercentage > 5;
    final hasHighRating = widget.product.rating >= 4.0;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: AppRadius.radiusLg,
            border: Border.all(color: border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 30 : 10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image container with Overlays
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1.05,
                    child: Hero(
                      tag: widget.heroTagSuffix != null
                          ? 'product_image_${widget.product.id}_${widget.heroTagSuffix}'
                          : 'product_image_${widget.product.id}',
                      child: NetworkImageView(
                        imageUrl: widget.product.primaryImage,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Discount Badge
                  if (isDiscounted)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: AppRadius.radiusSm,
                        ),
                        child: Text(
                          Formatters.formatDiscount(widget.product.discountPercentage),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                  // Wishlist Heart Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer<WishlistProvider>(
                      builder: (context, wishlist, _) {
                        final isLiked = wishlist.isInWishlist(widget.product.id);
                        return Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(80),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: AnimatedHeartButton(
                              isLiked: isLiked,
                              size: 18,
                              onToggle: (_) => wishlist.toggleWishlist(widget.product),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Low stock pill
                  if (widget.product.isLowStock)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withAlpha(220),
                          borderRadius: AppRadius.radiusXs,
                        ),
                        child: const Text(
                          'LOW STOCK',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Product Info
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand & Rating row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.product.displayBrand.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                            ),
                          ),
                        ),
                        if (hasHighRating)
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
                              const SizedBox(width: 2),
                              Text(
                                Formatters.formatRating(widget.product.rating),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Title
                    Text(
                      widget.product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Price & Quick Add Button row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Formatters.formatCurrency(widget.product.price),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.primaryLight : AppColors.primary,
                              ),
                            ),
                            if (isDiscounted)
                              Text(
                                Formatters.formatCurrency(widget.product.originalPrice),
                                style: AppTypography.priceOriginal(context),
                              ),
                          ],
                        ),

                        // Animated Quick Add button
                        AnimatedContainer(
                          duration: AppMotion.durationFast,
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: _isAddAnimating
                                ? AppColors.secondary
                                : (isDark ? AppColors.primaryLight : AppColors.primary),
                            shape: BoxShape.circle,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _handleQuickAdd(context),
                              customBorder: const CircleBorder(),
                              child: Center(
                                child: AnimatedSwitcher(
                                  duration: AppMotion.durationFast,
                                  child: Icon(
                                    _isAddAnimating ? Icons.check_rounded : Icons.add_rounded,
                                    key: ValueKey(_isAddAnimating),
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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

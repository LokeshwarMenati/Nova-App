import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/animated_heart.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/network_image_view.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';
import '../cart/cart_provider.dart';
import '../home/home_provider.dart';
import '../profile/profile_provider.dart';
import '../wishlist/wishlist_provider.dart';

/// Commercial-grade Product Detail screen with gallery, pinch-to-zoom,
/// full product specifications, customer reviews, and sticky purchase bar.
class ProductDetailScreen extends StatefulWidget {
  final int productId;
  final Product? initialProduct;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.initialProduct,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  bool _isLoading = true;
  int _selectedImageIndex = 0;
  int _quantity = 1;
  late PageController _galleryController;

  @override
  void initState() {
    super.initState();
    _galleryController = PageController();
    if (widget.initialProduct != null) {
      _product = widget.initialProduct;
      _isLoading = false;
      // Pre-warm image cache so the detail hero shows instantly
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.initialProduct!.primaryImage.isNotEmpty) {
          precacheImage(
            NetworkImage(widget.initialProduct!.primaryImage),
            context,
          );
        }
      });
    }
    _loadProduct();
  }

  @override
  void dispose() {
    _galleryController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    final repo = context.read<ProductRepository>();
    final product = await repo.getProductById(widget.productId);
    if (!mounted) return;

    setState(() {
      _product = product;
      _isLoading = false;
    });

    // Record product view for local recommendations
    context.read<ProfileProvider>().recordProductView(widget.productId);
  }

  void _handleAddToCart() {
    if (_product == null) return;
    HapticFeedback.mediumImpact();

    context.read<CartProvider>().addToCart(
      _product!,
      quantity: _quantity,
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $_quantity "${_product!.title}" to your cart'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: AppColors.accentLight,
          onPressed: () => context.go('/cart'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading || _product == null) {
      return Scaffold(
        appBar: AppBar(elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final product = _product!;
    final images = product.images.isNotEmpty ? product.images : [product.primaryImage];
    final home = context.watch<HomeProvider>();
    final similarProducts = home.products
        .where((p) => p.category == product.category && p.id != product.id)
        .take(5)
        .toList();

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App bar with back & wishlist actions
          SliverAppBar(
            pinned: true,
            expandedHeight: 380,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: isDark ? Colors.black54 : Colors.white.withAlpha(220),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, size: 20),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  },
                ),
              ),
            ),
            actions: [
              Consumer<WishlistProvider>(
                builder: (context, wishlist, _) {
                  final isLiked = wishlist.isInWishlist(product.id);
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: isDark ? Colors.black54 : Colors.white.withAlpha(220),
                      child: AnimatedHeartButton(
                        isLiked: isLiked,
                        size: 20,
                        onToggle: (_) => wishlist.toggleWishlist(product),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Interactive Gallery PageView with pinch-to-zoom
                  Hero(
                    tag: 'product_image_${product.id}',
                    child: PageView.builder(
                      controller: _galleryController,
                      itemCount: images.length,
                      onPageChanged: (i) => setState(() => _selectedImageIndex = i),
                      itemBuilder: (context, index) {
                        return InteractiveViewer(
                          maxScale: 3.0,
                          child: NetworkImageView(
                            imageUrl: images[index],
                            fit: BoxFit.cover,
                            borderRadius: BorderRadius.zero,
                          ),
                        );
                      },
                    ),
                  ),

                  // Image counter pill
                  if (images.length > 1)
                    Positioned(
                      bottom: 16,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(150),
                          borderRadius: AppRadius.radiusFull,
                        ),
                        child: Text(
                          '${_selectedImageIndex + 1} / ${images.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Content body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnails row if multiple images
                  if (images.length > 1) ...[
                    SizedBox(
                      height: 56,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: images.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final isSelected = index == _selectedImageIndex;
                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedImageIndex = index);
                              _galleryController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: AppRadius.radiusSm,
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: AppRadius.radiusSm,
                                child: NetworkImageView(
                                  imageUrl: images[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Brand & Rating row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.displayBrand.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: isDark ? AppColors.primaryLight : AppColors.primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                          borderRadius: AppRadius.radiusSm,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 16, color: AppColors.warning),
                            const SizedBox(width: 4),
                            Text(
                              Formatters.formatRating(product.rating),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${product.reviews.length} reviews)',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Product Title
                  Text(
                    product.title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      height: 1.3,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Pricing & Discount row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        Formatters.formatCurrency(product.price),
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.primaryLight : AppColors.primary,
                        ),
                      ),
                      if (product.discountPercentage > 0) ...[
                        const SizedBox(width: 10),
                        Text(
                          Formatters.formatCurrency(product.originalPrice),
                          style: const TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: AppRadius.radiusXs,
                          ),
                          child: Text(
                            Formatters.formatDiscount(product.discountPercentage),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'About this item',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Highlights / Specs grid
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                      borderRadius: AppRadius.radiusMd,
                    ),
                    child: Column(
                      children: [
                        _buildSpecRow('Availability', product.availabilityStatus, isDark),
                        const Divider(height: 16),
                        _buildSpecRow('Shipping', product.shippingInformation, isDark),
                        const Divider(height: 16),
                        _buildSpecRow('Warranty', product.warrantyInformation, isDark),
                        const Divider(height: 16),
                        _buildSpecRow('Return Policy', product.returnPolicy, isDark),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Customer Reviews
                  if (product.reviews.isNotEmpty) ...[
                    Text(
                      'Verified Reviews (${product.reviews.length})',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...product.reviews.take(3).map((review) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                          borderRadius: AppRadius.radiusMd,
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  review.reviewerName,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
                                    const SizedBox(width: 2),
                                    Text(
                                      review.rating.toString(),
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              review.comment,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                  ],

                  // Similar Products Rail
                  if (similarProducts.isNotEmpty) ...[
                    const SectionHeader(
                      title: 'Similar Items',
                      subtitle: 'You might also like these styles',
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 260,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: similarProducts.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final item = similarProducts[index];
                          return SizedBox(
                            width: 160,
                            child: ProductCard(
                              product: item,
                              onTap: () => context.push('/product/${item.id}', extra: item),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 80), // Bottom bar clearance
                ],
              ),
            ),
          ),
        ],
      ),

      // Sticky Bottom Action Bar (Quantity + Add to Cart)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Quantity Counter
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 16),
                      onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                    ),
                    Text(
                      '$_quantity',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 16),
                      onPressed: () => setState(() => _quantity++),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Add to Cart Button
              Expanded(
                child: AppButton(
                  text: 'Add to Cart — ${Formatters.formatCurrency(product.price * _quantity)}',
                  icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                  onPressed: _handleAddToCart,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/product_card.dart';
import 'wishlist_provider.dart';

/// Wishlist screen displaying saved products with smooth removal and direct cart transfer.
class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final columnCount = ResponsiveUtils.getGridColumnCount(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          wishlist.count > 0 ? 'Wishlist (${wishlist.count})' : 'Wishlist',
        ),
      ),
      body: wishlist.isEmpty
          ? EmptyState(
              icon: Icons.favorite_border_rounded,
              title: 'Your Wishlist is Empty',
              subtitle: 'Save items you love by tapping the heart icon on any product card.',
              buttonText: 'Discover Products',
              onButtonPressed: () => context.go('/home'),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columnCount,
                childAspectRatio: 0.65,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
              ),
              itemCount: wishlist.items.length,
              itemBuilder: (context, index) {
                final product = wishlist.items[index];
                return ProductCard(
                  key: ValueKey('wishlist_${product.id}'),
                  product: product,
                  onTap: () => context.push('/product/${product.id}', extra: product),
                );
              },
            ),
    );
  }
}

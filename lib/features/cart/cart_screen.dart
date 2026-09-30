import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/empty_state.dart';
import '../orders/order_provider.dart';
import 'cart_provider.dart';
import 'widgets/cart_item_tile.dart';
import 'widgets/cart_summary_card.dart';
import 'widgets/checkout_success_sheet.dart';

/// CartScreen provides a complete shopping cart management experience.
///
/// Features:
/// - Swipe-to-delete with SnackBar Undo capability
/// - Dynamic quantity stepper controls with automatic subtotal recalculation
/// - Promo code input with instant validation ('NOVA10' gives 10% discount)
/// - Subtotal, discount, shipping (free over $50), and tax computation
/// - Animated checkout flow culminating in [CheckoutSuccessSheet]
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isCheckingOut = false;

  void _handleCheckout(BuildContext context, CartProvider cartProvider) async {
    setState(() => _isCheckingOut = true);

    // Simulate payment processing / server handshake
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;
    setState(() => _isCheckingOut = false);

    final totalPaid = cartProvider.finalTotal;

    // Create real persistent order before clearing cart
    final orderProvider = context.read<OrderProvider>();
    final newOrder = await orderProvider.createOrderFromCart(
      cartItems: cartProvider.items,
      subtotal: cartProvider.subtotal,
      discount: cartProvider.promoDiscountAmount,
      shippingFee: cartProvider.shippingFee,
      tax: cartProvider.estimatedTax,
      total: totalPaid,
    );

    // Clear cart in state
    cartProvider.clearCart();

    // Show celebratory checkout success modal with order details access
    CheckoutSuccessSheet.show(context, totalPaid, order: newOrder);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Shopping Bag (${cart.itemCount})',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            actions: [
              if (cart.items.isNotEmpty)
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Clear Cart?'),
                        content: const Text('Are you sure you want to remove all items from your bag?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              cart.clearCart();
                              Navigator.pop(ctx);
                            },
                            child: const Text('Clear All', style: TextStyle(color: AppColors.error)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text(
                    'Clear',
                    style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          body: cart.items.isEmpty
              ? EmptyState(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Your bag is empty',
                  subtitle: 'Looks like you haven\'t added any items to your shopping bag yet.',
                  buttonText: 'Start Shopping',
                  onButtonPressed: () => context.go('/home'),
                )
              : CustomScrollView(
                  slivers: [
                    // Promo banner threshold indicator
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.sm,
                          AppSpacing.md,
                          AppSpacing.xs,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: cart.subtotal >= AppConstants.freeShippingThreshold
                              ? AppColors.emerald.withOpacity(0.12)
                              : AppColors.primaryViolet.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: cart.subtotal >= AppConstants.freeShippingThreshold
                                ? AppColors.emerald.withOpacity(0.3)
                                : AppColors.primaryViolet.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              cart.subtotal >= AppConstants.freeShippingThreshold
                                  ? Icons.check_circle_outline
                                  : Icons.local_shipping_outlined,
                              size: 20,
                              color: cart.subtotal >= AppConstants.freeShippingThreshold
                                  ? AppColors.emerald
                                  : AppColors.primaryViolet,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                cart.subtotal >= AppConstants.freeShippingThreshold
                                    ? '🎉 You have unlocked FREE Express Delivery!'
                                    : 'Add  more for FREE Express Delivery',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: cart.subtotal >= AppConstants.freeShippingThreshold
                                      ? AppColors.emerald
                                      : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // List of Cart Items
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = cart.items[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: CartItemTile(
                                item: item,
                                index: index,
                                onQuantityChanged: (newQty) => cart.updateQuantity(index, newQty),
                                onRemove: () {
                                  final removed = cart.removeFromCart(index);
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${removed.product.title} removed from bag'),
                                      action: SnackBarAction(
                                        label: 'UNDO',
                                        textColor: AppColors.accentCoral,
                                        onPressed: () {
                                          cart.restoreItem(index, removed);
                                        },
                                      ),
                                      duration: const Duration(seconds: 4),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          childCount: cart.items.length,
                        ),
                      ),
                    ),

                    // Order Summary & Checkout Card
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xxl),
                        child: CartSummaryCard(
                          isCheckingOut: _isCheckingOut,
                          onCheckout: () => _handleCheckout(context, cart),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

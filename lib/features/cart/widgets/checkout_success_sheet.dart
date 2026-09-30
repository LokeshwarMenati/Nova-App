import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/models/order_model.dart';
import '../../orders/widgets/order_detail_sheet.dart';

/// Commercial-grade Checkout Success bottom sheet modal with check micro-animation
/// and immediate access to view the newly created order details.
class CheckoutSuccessSheet extends StatefulWidget {
  final double totalAmount;
  final OrderModel? order;

  const CheckoutSuccessSheet({
    super.key,
    required this.totalAmount,
    this.order,
  });

  static Future<void> show(BuildContext context, double totalAmount, {OrderModel? order}) {
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => CheckoutSuccessSheet(
        totalAmount: totalAmount,
        order: order,
      ),
    );
  }

  @override
  State<CheckoutSuccessSheet> createState() => _CheckoutSuccessSheetState();
}

class _CheckoutSuccessSheetState extends State<CheckoutSuccessSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkController;
  late Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _checkScale = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );
    _checkController.forward();
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final orderId = widget.order?.id ?? '#NOVA-84920';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: AppRadius.topSheetRadius,
      ),
      padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated check circle
          ScaleTransition(
            scale: _checkScale,
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'Order Placed Successfully!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle & Order Number
          Text(
            'Thank you for shopping with NOVA.\nYour confirmation order $orderId is confirmed.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Details summary box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
              borderRadius: AppRadius.radiusMd,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Delivery Address', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 2),
                    Text(
                      widget.order?.deliveryAddress ?? 'Kochi, Kerala, India',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Estimated Delivery', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 2),
                    const Text(
                      '2 Business Days',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.success),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // View Order Details CTA
          if (widget.order != null) ...[
            AppButton(
              text: 'View Placed Order Items',
              onPressed: () {
                Navigator.of(context).pop();
                OrderDetailSheet.show(context, widget.order!);
              },
            ),
            const SizedBox(height: 12),
          ],

          // Continue shopping CTA
          AppButton(
            text: 'Continue Shopping',
            isOutlined: widget.order != null,
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/home');
            },
          ),
        ],
      ),
    );
  }
}

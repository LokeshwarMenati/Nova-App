import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../cart_provider.dart';

/// Price summary card with promo code validation and free shipping progress.
class CartSummaryCard extends StatefulWidget {
  final VoidCallback onCheckout;
  final bool isCheckingOut;

  const CartSummaryCard({
    super.key,
    required this.onCheckout,
    this.isCheckingOut = false,
  });

  @override
  State<CartSummaryCard> createState() => _CartSummaryCardState();
}

class _CartSummaryCardState extends State<CartSummaryCard> {
  final TextEditingController _promoController = TextEditingController();
  String? _promoMessage;
  bool _isPromoSuccess = false;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _applyPromo() {
    final cart = context.read<CartProvider>();
    final success = cart.applyPromoCode(_promoController.text);
    setState(() {
      _isPromoSuccess = success;
      _promoMessage = success
          ? '10% NOVA discount applied!'
          : 'Invalid promo code. Try "NOVA10".';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cart = context.watch<CartProvider>();

    final freeShippingDelta = AppConstants.freeShippingThreshold - cart.subtotal;
    final freeShippingProgress = (cart.subtotal / AppConstants.freeShippingThreshold).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Free Shipping Progress
          Row(
            children: [
              Icon(
                freeShippingDelta <= 0 ? Icons.check_circle_rounded : Icons.local_shipping_outlined,
                size: 18,
                color: freeShippingDelta <= 0 ? AppColors.success : (isDark ? AppColors.primaryLight : AppColors.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  freeShippingDelta <= 0
                      ? 'Congratulations! You qualified for Free Delivery.'
                      : 'Add ${Formatters.formatCurrency(freeShippingDelta)} more for FREE shipping',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: freeShippingDelta <= 0 ? AppColors.success : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: freeShippingProgress,
              minHeight: 5,
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(
                freeShippingDelta <= 0 ? AppColors.success : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Promo Code input row
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                    borderRadius: AppRadius.radiusMd,
                  ),
                  child: TextField(
                    controller: _promoController,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    decoration: const InputDecoration(
                      hintText: 'Enter code (e.g. NOVA10)',
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: _applyPromo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
          if (_promoMessage != null) ...[
            const SizedBox(height: 6),
            Text(
              _promoMessage!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _isPromoSuccess ? AppColors.success : AppColors.error,
              ),
            ),
          ],
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Subtotal Row
          _buildPriceLine('Subtotal', Formatters.formatCurrency(cart.subtotal), isDark),
          const SizedBox(height: 8),

          // Promo Discount Row
          if (cart.promoDiscountAmount > 0) ...[
            _buildPriceLine(
              'NOVA10 Promo (10%)',
              '-${Formatters.formatCurrency(cart.promoDiscountAmount)}',
              isDark,
              isHighlight: true,
            ),
            const SizedBox(height: 8),
          ],

          // Shipping Fee Row
          _buildPriceLine(
            'Estimated Delivery',
            cart.shippingFee == 0 ? 'FREE' : Formatters.formatCurrency(cart.shippingFee),
            isDark,
            isGreen: cart.shippingFee == 0,
          ),
          const SizedBox(height: 8),

          // Estimated Tax Row
          _buildPriceLine('Estimated Tax (8%)', Formatters.formatCurrency(cart.estimatedTax), isDark),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Final Total Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              Text(
                Formatters.formatCurrency(cart.finalTotal),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Checkout Button
          AppButton(
            text: 'Proceed to Checkout',
            isLoading: widget.isCheckingOut,
            onPressed: widget.onCheckout,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceLine(
    String label,
    String value,
    bool isDark, {
    bool isHighlight = false,
    bool isGreen = false,
  }) {
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isGreen
                ? AppColors.success
                : isHighlight
                    ? AppColors.accent
                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          ),
        ),
      ],
    );
  }
}

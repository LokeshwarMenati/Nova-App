import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// Reusable shimmer placeholder box respecting Light/Dark theme.
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final ShapeBorder? shape;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final base = isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBaseLight;
    final highlight = isDark ? AppColors.shimmerHighlightDark : AppColors.shimmerHighlightLight;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        width: width,
        height: height,
        decoration: shape != null
            ? ShapeDecoration(shape: shape!, color: Colors.white)
            : BoxDecoration(
                color: Colors.white,
                borderRadius: borderRadius ?? AppRadius.radiusSm,
              ),
      ),
    );
  }
}

/// Shimmer skeleton replicating the layout of a NOVA product card.
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          const AspectRatio(
            aspectRatio: 1.0,
            child: ShimmerBox(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand pill
                const ShimmerBox(width: 50, height: 12),
                const SizedBox(height: 8),
                // Title line 1
                const ShimmerBox(width: double.infinity, height: 14),
                const SizedBox(height: 4),
                // Title line 2
                const ShimmerBox(width: 80, height: 14),
                const SizedBox(height: 12),
                // Price & Add button row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    ShimmerBox(width: 60, height: 18),
                    ShimmerBox(width: 32, height: 32, borderRadius: AppRadius.radiusSm),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

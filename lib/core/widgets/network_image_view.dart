import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import 'shimmer_box.dart';

/// Web-safe network image view that bypasses CORS issues on Flutter Web.
///
/// On **Web**: uses [Image.network] with shimmer loading and branded error fallback.
/// URL transformer adds Unsplash CDN params that enable CORS-safe delivery.
class NetworkImageView extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final int memCacheWidth;

  const NetworkImageView({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.memCacheWidth = 400,
  });

  /// Transforms image URLs for CORS-safe delivery on Flutter Web.
  String _resolveUrl(String url) {
    if (!kIsWeb || url.isEmpty) return url;

    // Unsplash: CDN params enable proper CORS headers
    if (url.contains('images.unsplash.com') && !url.contains('auto=format')) {
      final uri = Uri.tryParse(url);
      if (uri != null) {
        final params = Map<String, String>.from(uri.queryParameters);
        params['auto'] = 'format';
        params['fit'] = 'crop';
        params['q'] = '80';
        if (!params.containsKey('w')) params['w'] = '$memCacheWidth';
        return uri.replace(queryParameters: params).toString();
      }
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? AppRadius.radiusMd;

    if (imageUrl.isEmpty) {
      return _buildFallback(isDark, radius);
    }

    final resolvedUrl = _resolveUrl(imageUrl);

    return ClipRRect(
      borderRadius: radius,
      child: Image.network(
        resolvedUrl,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: memCacheWidth,
        filterQuality: FilterQuality.medium,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return ShimmerBox(width: width, height: height, borderRadius: radius);
        },
        errorBuilder: (context, error, stackTrace) => _buildFallback(isDark, radius),
      ),
    );
  }

  Widget _buildFallback(bool isDark, BorderRadius radius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF232135), const Color(0xFF1B192A)]
              : [const Color(0xFFF3F4F6), const Color(0xFFE5E7EB)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              size: (height != null && height! < 60) ? 20 : 28,
            ),
            if (height == null || height! >= 90) ...[
              const SizedBox(height: 4),
              Text(
                'NOVA',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


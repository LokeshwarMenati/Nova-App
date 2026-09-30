import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import 'app_button.dart';

/// Reusable network/API failure view with Retry action.
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool isCompact;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isCompact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha(20),
          borderRadius: AppRadius.radiusMd,
          border: Border.all(color: AppColors.error.withAlpha(60)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 13, color: AppColors.error, fontWeight: FontWeight.w500),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: onRetry,
                child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.error.withAlpha(25),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 38,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Connection Issue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 160,
                child: AppButton(
                  text: 'Try Again',
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18, color: Colors.white),
                  borderRadius: AppRadius.radiusFull,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

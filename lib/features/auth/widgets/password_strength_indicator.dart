import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';

/// Segmented password strength bar with animated color transitions.
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final score = Validators.calculatePasswordStrength(password);
    final label = Validators.getPasswordStrengthLabel(score);

    Color color;
    if (score < 0.3) {
      color = AppColors.error;
    } else if (score < 0.7) {
      color = AppColors.warning;
    } else if (score < 0.9) {
      color = AppColors.info;
    } else {
      color = AppColors.success;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(4, (index) {
              final active = score >= ((index + 1) * 0.25);
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index < 3 ? 6.0 : 0.0),
                  decoration: BoxDecoration(
                    color: active ? color : Colors.grey.withAlpha(50),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Strength: $label',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const Text(
                'Min 6 chars (letters + numbers)',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

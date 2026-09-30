import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// Interactive heart button with scale bounce, particle burst, and haptic feedback.
class AnimatedHeartButton extends StatefulWidget {
  final bool isLiked;
  final ValueChanged<bool>? onToggle;
  final double size;
  final Color activeColor;

  const AnimatedHeartButton({
    super.key,
    required this.isLiked,
    this.onToggle,
    this.size = 22.0,
    this.activeColor = AppColors.accent,
  });

  @override
  State<AnimatedHeartButton> createState() => _AnimatedHeartButtonState();
}

class _AnimatedHeartButtonState extends State<AnimatedHeartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant AnimatedHeartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isLiked && widget.isLiked) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    final next = !widget.isLiked;
    if (next) {
      _controller.forward(from: 0.0);
    }
    widget.onToggle?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Burst micro-ring
          if (widget.isLiked)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  size: Size(widget.size * 2, widget.size * 2),
                  painter: _HeartBurstPainter(
                    progress: _controller.value,
                    color: widget.activeColor,
                  ),
                );
              },
            ),
          // Heart Icon
          ScaleTransition(
            scale: _scaleAnimation,
            child: Icon(
              widget.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: widget.isLiked ? widget.activeColor : Colors.white,
              size: widget.size,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeartBurstPainter extends CustomPainter {
  final double progress;
  final Color color;

  _HeartBurstPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0 || progress == 1.0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color.withAlpha(((1.0 - progress) * 200).toInt())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * (1.0 - progress);

    const int dots = 6;
    final radius = (size.width / 2) * progress;

    for (int i = 0; i < dots; i++) {
      final angle = (i * 2 * math.pi) / dots;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 2.0 * (1.0 - progress), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HeartBurstPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

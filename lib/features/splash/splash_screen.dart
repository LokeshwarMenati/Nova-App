import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../auth/auth_provider.dart';

/// Animated splash screen featuring sequenced logo entrance, gradient glow, and auth routing.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _taglineSlide;
  late Animation<double> _taglineFade;
  late Animation<double> _glowScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // 1. Logo fade in (0% -> 40%)
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // 2. Logo scale 0.75 -> 1.0 (0% -> 50%)
    _logoScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: AppMotion.curveSpring),
      ),
    );

    // 3. Subtle background glow (20% -> 70%)
    _glowScale = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeInOut),
      ),
    );

    // 4. Tagline slide upward & fade (45% -> 85%)
    _taglineSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.85, curve: AppMotion.curveDefault),
      ),
    );
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.8, curve: Curves.easeIn),
      ),
    );

    _controller.forward().then((_) => _onAnimationComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onAnimationComplete() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();

    if (auth.isAuthenticated) {
      // Returning authenticated user — go straight to home
      context.go('/home');
    } else {
      // Auto-login as guest for instant access — no login wall
      await auth.continueAsGuest();
      if (mounted) context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgGradient = isDark
        ? const RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Color(0xFF1F1C38),
              Color(0xFF0C0E14),
            ],
          )
        : const RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Color(0xFFF3EFFF),
              Color(0xFFF8F9FE),
            ],
          );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Pulsing ambient glow
                Transform.scale(
                  scale: _glowScale.value,
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withAlpha(isDark ? 50 : 35),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Main Content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Logo
                    FadeTransition(
                      opacity: _logoFade,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: _buildLogoBadge(isDark),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // App Name
                    FadeTransition(
                      opacity: _logoFade,
                      child: Text(
                        AppConstants.appName,
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 4.0,
                          color: isDark ? Colors.white : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Tagline sliding upward
                    Transform.translate(
                      offset: Offset(0, _taglineSlide.value),
                      child: FadeTransition(
                        opacity: _taglineFade,
                        child: Text(
                          AppConstants.appTagline,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogoBadge(bool isDark) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(isDark ? 120 : 90),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(44, 44),
          painter: _NovaEmblemPainter(),
        ),
      ),
    );
  }
}

/// Custom vector emblem for NOVA (A stylized geometric starburst/diamond).
class _NovaEmblemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // Four-point geometric star with soft curves
    path.moveTo(w * 0.5, 0);
    path.quadraticBezierTo(w * 0.5, h * 0.35, w, h * 0.5);
    path.quadraticBezierTo(w * 0.65, h * 0.5, w * 0.5, h);
    path.quadraticBezierTo(w * 0.5, h * 0.65, 0, h * 0.5);
    path.quadraticBezierTo(w * 0.35, h * 0.5, w * 0.5, 0);
    path.close();

    canvas.drawPath(path, paint);

    // Accent spark
    final accentPaint = Paint()
      ..color = AppColors.accentLight
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.72, h * 0.28), 3.5, accentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

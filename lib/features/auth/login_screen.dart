import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import 'auth_provider.dart';
import 'widgets/auth_header.dart';

/// Commercial-grade Login screen with inline validation, error-shake animation,
/// guest mode, and responsive two-column layout on wide viewports.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailPhoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _emailPhoneError;
  String? _passwordError;
  String? _generalError;

  // Shake animation for login failure feedback
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      if (auth.registeredAccount?['email'] != null && _emailPhoneController.text.isEmpty) {
        setState(() {
          _emailPhoneController.text = auth.registeredAccount!['email']!;
        });
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _emailPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shakeController.forward(from: 0.0);
  }

  Future<void> _handleLogin() async {
    setState(() {
      _emailPhoneError = Validators.validateEmailOrPhone(_emailPhoneController.text);
      _passwordError = Validators.validatePassword(_passwordController.text);
      _generalError = null;
    });

    if (_emailPhoneError != null || _passwordError != null) {
      _triggerShake();
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      emailOrPhone: _emailPhoneController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      context.go('/home');
    } else {
      _triggerShake();
      setState(() {
        _generalError = authProvider.errorMessage ?? 'Authentication failed.';
      });
    }
  }

  Future<void> _handleGuest() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.continueAsGuest();
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isWide = !ResponsiveUtils.isMobile(context);

    final formContent = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 32.0),
          child: AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              // Mathematical sine-wave shake offset
              final offset = math.sin(_shakeAnimation.value * math.pi * 4) * 8 * (1.0 - _shakeAnimation.value);
              return Transform.translate(
                offset: Offset(offset, 0),
                child: child,
              );
            },
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthHeader(
                    title: 'Welcome Back',
                    subtitle: 'Sign in to access your curated lifestyle recommendations.',
                  ),
                  const SizedBox(height: 32),

                  // General error banner if present
                  if (_generalError != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withAlpha(20),
                        borderRadius: AppRadius.radiusMd,
                        border: Border.all(color: AppColors.error.withAlpha(70)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _generalError!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Email or Phone input
                  AppTextField(
                    controller: _emailPhoneController,
                    label: 'Email or Mobile Number',
                    hint: 'name@example.com or 10-digit phone',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    errorText: _emailPhoneError,
                    onChanged: (val) {
                      if (_emailPhoneError != null) {
                        setState(() => _emailPhoneError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 18),

                  // Password input
                  AppTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: '••••••••',
                    isPassword: true,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    errorText: _passwordError,
                    onChanged: (val) {
                      if (_passwordError != null) {
                        setState(() => _passwordError = null);
                      }
                    },
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleLogin(),
                  ),

                  // Forgot Password hint
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Test demo: Use any valid format credentials or Nova2026'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.primaryLight : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Login Button
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return AppButton(
                        text: 'Sign In to NOVA',
                        isLoading: auth.isLoading,
                        onPressed: _handleLogin,
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Continue as Guest Button
                  AppButton(
                    text: 'Continue as Guest',
                    isOutlined: true,
                    onPressed: _handleGuest,
                  ),
                  const SizedBox(height: 28),

                  // Sign up prompt
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'New to NOVA? ',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/signup'),
                        child: Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.primaryLight : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: isWide
            ? Row(
                children: [
                  // Left Branding Panel for Tablet / Desktop
                  Expanded(
                    flex: 5,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(48.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(80),
                                borderRadius: AppRadius.radiusFull,
                              ),
                              child: const Text(
                                'PREMIUM LIFESTYLE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              AppConstants.appName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4.0,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              AppConstants.appTagline,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 20,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Right Form Panel
                  Expanded(
                    flex: 6,
                    child: formContent,
                  ),
                ],
              )
            : formContent,
      ),
    );
  }
}

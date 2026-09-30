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
import 'widgets/password_strength_indicator.dart';

/// Sign Up screen with full form validation, real-time password strength, and terms agreement.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmError;
  String? _generalError;
  bool _agreeToTerms = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty ? 'Full name is required' : null;
      _emailError = Validators.validateEmail(_emailController.text);
      _phoneError = Validators.validatePhone(_phoneController.text);
      _passwordError = Validators.validatePassword(_passwordController.text);
      _confirmError = Validators.validateConfirmPassword(
        _confirmPasswordController.text,
        _passwordController.text,
      );
      _generalError = null;
    });

    if (!_agreeToTerms) {
      setState(() => _generalError = 'Please agree to the Terms & Privacy Policy to proceed.');
      return;
    }

    if (_nameError != null ||
        _emailError != null ||
        _phoneError != null ||
        _passwordError != null ||
        _confirmError != null) {
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.signUp(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created! Please sign in with your credentials.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/login');
    } else {
      setState(() {
        _generalError = auth.errorMessage ?? 'Registration failed.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isWide = !ResponsiveUtils.isMobile(context);

    final formContent = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthHeader(
                title: 'Join NOVA',
                subtitle: 'Create your account for personalized lifestyle shopping.',
              ),
              const SizedBox(height: 28),

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
                const SizedBox(height: 18),
              ],

              // Full Name
              AppTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Alex Morgan',
                prefixIcon: const Icon(Icons.badge_outlined),
                errorText: _nameError,
              ),
              const SizedBox(height: 16),

              // Email Address
              AppTextField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'alex@example.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.mail_outline_rounded),
                errorText: _emailError,
              ),
              const SizedBox(height: 16),

              // Mobile Phone
              AppTextField(
                controller: _phoneController,
                label: 'Mobile Phone',
                hint: '9876543210 (10 digits)',
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_iphone_outlined),
                errorText: _phoneError,
              ),
              const SizedBox(height: 16),

              // Password
              AppTextField(
                controller: _passwordController,
                label: 'Password',
                hint: '••••••••',
                isPassword: true,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                errorText: _passwordError,
                onChanged: (_) => setState(() {}),
              ),

              // Password Strength
              PasswordStrengthIndicator(password: _passwordController.text),
              const SizedBox(height: 16),

              // Confirm Password
              AppTextField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                hint: '••••••••',
                isPassword: true,
                prefixIcon: const Icon(Icons.check_circle_outline_rounded),
                errorText: _confirmError,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleSignUp(),
              ),
              const SizedBox(height: 14),

              // Terms Agreement
              Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    activeColor: isDark ? AppColors.primaryLight : AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) => setState(() => _agreeToTerms = val ?? true),
                  ),
                  Expanded(
                    child: Text(
                      'I agree to the NOVA Terms of Service & Privacy Policy',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Register Button
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return AppButton(
                    text: 'Complete Registration',
                    isLoading: auth.isLoading,
                    onPressed: _handleSignUp,
                  );
                },
              ),
              const SizedBox(height: 24),

              // Back to Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text(
                      'Sign In',
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
    );

    return Scaffold(
      body: SafeArea(
        child: isWide
            ? Row(
                children: [
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
                            Text(
                              AppConstants.appName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4.0,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Join over 100,000 discerning shoppers exploring bespoke lifestyle products.',
                              style: TextStyle(color: Colors.white70, fontSize: 18, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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

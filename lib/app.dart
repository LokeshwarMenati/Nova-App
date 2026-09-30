import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/models/product.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/product_detail/product_detail_screen.dart';
import 'features/profile/profile_provider.dart';
import 'features/search/search_screen.dart';
import 'features/shell/main_shell_screen.dart';
import 'features/splash/splash_screen.dart';

/// App-wide GoRouter configuration with auth-state redirection and premium transitions.
GoRouter _createRouter(AuthProvider auth) => GoRouter(
  initialLocation: '/splash',
  refreshListenable: auth,
  redirect: (context, state) {
    final loc = state.matchedLocation;
    final isAuthRoute = loc == '/login' || loc == '/signup' || loc == '/splash';
    final hasSession = auth.currentUser != null;

    if (!hasSession && !isAuthRoute) {
      return '/login';
    }

    if (auth.isAuthenticated && (loc == '/login' || loc == '/signup')) {
      return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SplashScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 450),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutExpo);
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
                  .animate(curved),
              child: child,
            ),
          );
        },
      ),
    ),
    GoRoute(
      path: '/signup',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SignUpScreen(),
        transitionDuration: const Duration(milliseconds: 450),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutExpo);
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .animate(curved),
              child: child,
            ),
          );
        },
      ),
    ),
    // Main persistent navigation shells
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const MainShellScreen(initialIndex: 0),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(opacity: curved, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/explore',
      builder: (context, state) => const MainShellScreen(initialIndex: 1),
    ),
    GoRoute(
      path: '/wishlist',
      builder: (context, state) => const MainShellScreen(initialIndex: 2),
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const MainShellScreen(initialIndex: 3),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const MainShellScreen(initialIndex: 4),
    ),
    // Search screen — blur-fade transition
    GoRoute(
      path: '/search',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const SearchScreen(),
          transitionDuration: const Duration(milliseconds: 350),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, -0.04), end: Offset.zero)
                    .animate(curved),
                child: child,
              ),
            );
          },
        );
      },
    ),
    // Product Detail — cinematic scale + slide + fade
    GoRoute(
      path: '/product/:id',
      pageBuilder: (context, state) {
        final idStr = state.pathParameters['id'] ?? '0';
        final productId = int.tryParse(idStr) ?? 0;
        final product = state.extra as Product?;

        return CustomTransitionPage(
          key: state.pageKey,
          child: ProductDetailScreen(
            productId: productId,
            initialProduct: product,
          ),
          transitionDuration: const Duration(milliseconds: 450),
          reverseTransitionDuration: const Duration(milliseconds: 350),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutExpo);
            final reverseCurved = CurvedAnimation(
              parent: secondaryAnimation,
              curve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
              child: FadeTransition(
                opacity: Tween<double>(begin: 1.0, end: 0.92).animate(reverseCurved),
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0.0, 0.06), end: Offset.zero)
                      .animate(curved),
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.97, end: 1.0).animate(curved),
                    child: child,
                  ),
                ),
              ),
            );
          },
        );
      },
    ),
  ],
);

/// Root Application Widget configuring Theme, MultiProvider, and GoRouter.
class NovaApp extends StatefulWidget {
  const NovaApp({super.key});

  @override
  State<NovaApp> createState() => _NovaAppState();
}

class _NovaAppState extends State<NovaApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _router = _createRouter(auth);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profile, _) {
        return MaterialApp.router(
          title: 'NOVA',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: profile.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          routerConfig: _router,
        );
      },
    );
  }
}

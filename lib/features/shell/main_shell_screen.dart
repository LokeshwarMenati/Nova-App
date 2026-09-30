import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/animated_cart_badge.dart';
import '../cart/cart_provider.dart';
import '../cart/cart_screen.dart';
import '../explore/explore_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../wishlist/wishlist_screen.dart';

/// MainShellScreen serves as the top-level persistent navigation shell.
///
/// Features:
/// - Uses [IndexedStack] to preserve the scroll position, cached data, and state
///   of each tab (Home, Explore, Wishlist, Cart, Profile) without disposing them.
/// - Adaptive layout: [NavigationBar] on mobile phones, switching smoothly to
///   [NavigationRail] on tablets/desktops (width >= 900).
/// - Dynamic bouncing cart badge via [AnimatedCartBadge] showing realtime bag count.
class MainShellScreen extends StatefulWidget {
  final int initialIndex;

  const MainShellScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    WishlistScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(covariant MainShellScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != _currentIndex) {
      setState(() => _currentIndex = widget.initialIndex);
    }
  }

  void _onDestinationSelected(int index) {
    if (index != _currentIndex) {
      setState(() => _currentIndex = index);
      switch (index) {
        case 0:
          context.go('/home');
          break;
        case 1:
          context.go('/explore');
          break;
        case 2:
          context.go('/wishlist');
          break;
        case 3:
          context.go('/cart');
          break;
        case 4:
          context.go('/profile');
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktopOrTablet = width >= 900;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cartCount = context.watch<CartProvider>().itemCount;

    if (isDesktopOrTablet) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'N',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home, color: AppColors.primaryViolet),
                  label: const Text('Home'),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore, color: AppColors.primaryViolet),
                  label: const Text('Explore'),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.favorite_border),
                  selectedIcon: Icon(Icons.favorite, color: AppColors.accentCoral),
                  label: const Text('Wishlist'),
                ),
                NavigationRailDestination(
                  icon: AnimatedCartBadge(
                    count: cartCount,
                    child: const Icon(Icons.shopping_bag_outlined),
                  ),
                  selectedIcon: AnimatedCartBadge(
                    count: cartCount,
                    child: Icon(Icons.shopping_bag, color: AppColors.primaryViolet),
                  ),
                  label: const Text('Cart'),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person, color: AppColors.primaryViolet),
                  label: const Text('Profile'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        elevation: 8,
        height: 68,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        indicatorColor: AppColors.primaryViolet.withOpacity(0.15),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.primaryViolet),
            label: 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore, color: AppColors.primaryViolet),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite, color: AppColors.accentCoral),
            label: 'Wishlist',
          ),
          NavigationDestination(
            icon: AnimatedCartBadge(
              count: cartCount,
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            selectedIcon: AnimatedCartBadge(
              count: cartCount,
              child: Icon(Icons.shopping_bag, color: AppColors.primaryViolet),
            ),
            label: 'Cart',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.primaryViolet),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/product_card.dart';
import '../auth/auth_provider.dart';
import '../orders/order_provider.dart';
import '../orders/widgets/order_detail_sheet.dart';
import 'profile_provider.dart';

/// ProfileScreen provides the user account management, preferences, and activity history.
///
/// Features:
/// - User profile display (Avatar, Name, Email, Role/Status badge)
/// - Interactive Dark Mode toggle with smooth theme transition
/// - Recently Viewed Products horizontal carousel
/// - Order history and customer care navigation actions
/// - Clean logout workflow with confirmation dialog and state reset
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out of NOVA? Your local bag and wishlist will remain saved on this device.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final profile = context.watch<ProfileProvider>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Account',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log Out',
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primaryViolet.withOpacity(0.15),
                    backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl) : null,
                    child: user?.avatarUrl == null
                        ? Text(
                            user?.name.substring(0, 1).toUpperCase() ?? 'U',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: AppColors.primaryViolet,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Guest Shopper',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? 'guest@nova.lifestyle',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: (user?.isGuest ?? true)
                                ? AppColors.accentCoral.withOpacity(0.12)
                                : AppColors.emerald.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            (user?.isGuest ?? true) ? 'GUEST ACCOUNT' : 'VIP MEMBER',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: (user?.isGuest ?? true) ? AppColors.accentCoral : AppColors.emerald,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // App Settings & Preferences
            Text(
              'App Preferences',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      color: AppColors.primaryViolet,
                    ),
                    title: const Text('Dark Mode'),
                    subtitle: Text(
                      isDark ? 'Comfortable night reading palette' : 'Vibrant day shopping theme',
                      style: theme.textTheme.bodySmall,
                    ),
                    value: profile.isDarkMode,
                    activeColor: AppColors.primaryViolet,
                    onChanged: (val) => profile.toggleTheme(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.notifications_none, color: AppColors.primaryViolet),
                    title: const Text('Push Notifications'),
                    subtitle: const Text('Order updates, deals & flash sales'),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (ctx) => Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryViolet.withOpacity(0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.notifications_active_rounded, color: AppColors.primaryViolet, size: 24),
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    'Notification Preferences',
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Order & Shipping Alerts'),
                                subtitle: const Text('Realtime updates on dispatch and parcel delivery'),
                                value: true,
                                activeColor: AppColors.primaryViolet,
                                onChanged: (v) {},
                              ),
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Flash Sales & Promo Codes'),
                                subtitle: const Text('Exclusive member discounts and seasonal edits'),
                                value: true,
                                activeColor: AppColors.primaryViolet,
                                onChanged: (v) {},
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryViolet,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Save Preferences'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Order History & Help
            Text(
              'Orders & Support',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.receipt_long_outlined, color: AppColors.primaryViolet),
                    title: const Text('My Orders'),
                    subtitle: const Text('Track active parcels and view past orders'),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (ctx) => DraggableScrollableSheet(
                          expand: false,
                          initialChildSize: 0.6,
                          maxChildSize: 0.85,
                          minChildSize: 0.4,
                          builder: (_, scrollCtl) => ListView(
                            controller: scrollCtl,
                            padding: const EdgeInsets.all(24),
                            children: [
                              Center(
                                child: Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Order History',
                                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Consumer<OrderProvider>(
                                    builder: (context, orderProv, _) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.emerald.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '${orderProv.orderCount} Orders',
                                          style: const TextStyle(color: AppColors.emerald, fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Consumer<OrderProvider>(
                                builder: (context, orderProv, _) {
                                  final orders = orderProv.orders;
                                  if (orders.isEmpty) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 24),
                                      child: Center(
                                        child: Text('No orders placed yet.', style: TextStyle(color: Colors.grey)),
                                      ),
                                    );
                                  }

                                  return Column(
                                    children: orders.map((order) {
                                      final isDelivered = order.isDelivered;
                                      final isDispatched = order.isDispatched;
                                      final statusColor = isDelivered
                                          ? AppColors.emerald
                                          : (isDispatched ? Colors.blue : AppColors.primaryViolet);

                                      final itemSummary = order.items.map((i) => '${i.title} × ${i.quantity}').join(', ');

                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        decoration: BoxDecoration(
                                          color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                          ),
                                        ),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(16),
                                          onTap: () {
                                            Navigator.pop(ctx);
                                            OrderDetailSheet.show(context, order);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                      decoration: BoxDecoration(
                                                        color: statusColor.withValues(alpha: 0.15),
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: Text(
                                                        order.status.toUpperCase(),
                                                        style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w800),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  order.estimatedDelivery,
                                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  '$itemSummary • ${Formatters.formatCurrency(order.total)}',
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    Icon(Icons.touch_app_outlined, size: 13, color: isDark ? AppColors.primaryLight : AppColors.primary),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      'Tap to view items & cost breakdown',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w700,
                                                        color: isDark ? AppColors.primaryLight : AppColors.primary,
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    Icon(Icons.chevron_right, size: 16, color: isDark ? AppColors.primaryLight : AppColors.primary),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.headset_mic_outlined, color: AppColors.primaryViolet),
                    title: const Text('24/7 Concierge Support'),
                    subtitle: const Text('Talk to our styling & support specialists'),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: Row(
                            children: [
                              Icon(Icons.headset_mic_rounded, color: AppColors.primaryViolet),
                              const SizedBox(width: 10),
                              const Text('NOVA Concierge'),
                            ],
                          ),
                          content: const Text(
                            'Our priority styling and logistics team is available around the clock.\n\n'
                            '• Email: support@nova.lifestyle\n'
                            '• Toll Free: +91 1800 200 NOVA\n'
                            '• Operating Hours: 24 Hours / 7 Days a week',
                            style: TextStyle(height: 1.5),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Close'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryViolet,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Connecting to live styling agent...')),
                                );
                              },
                              child: const Text('Start Chat'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Recently Viewed Products Section
            if (profile.recentlyViewed.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recently Viewed',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => profile.clearRecentlyViewed(),
                    child: const Text('Clear', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              SizedBox(
                height: 270,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: profile.recentlyViewed.length,
                  separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final product = profile.recentlyViewed[index];
                    return SizedBox(
                      width: 170,
                      child: ProductCard(
                        product: product,
                        heroTagSuffix: 'profile_recent',
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // App Version & Credits
            Center(
              child: Column(
                children: [
                  Text(
                    'NOVA Lifestyle Shopping v1.0.0',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Engineered for White Matrix Technical Assessment',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: isDark ? AppColors.darkTextSecondary.withOpacity(0.6) : AppColors.lightTextSecondary.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© 2024 All Rights Reserved by Lokeshwar Menati',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}


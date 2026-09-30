import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/network_image_view.dart';
import '../../auth/auth_provider.dart';
import '../home_provider.dart';

/// Top header greeting displaying personalized user info, location tag, and notifications.
class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Only watch the fields we actually render — prevents rebuild on every product load
    final user = context.select<AuthProvider, dynamic>((a) => a.currentUser);
    final isOffline = context.select<HomeProvider, bool>((h) => h.isOfflineFallbackActive);
    final userName = user != null && user.name.isNotEmpty && !user.isGuest ? user.name : 'Explorer';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Offline fallback banner if active
          if (isOffline) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.info.withAlpha(25),
                borderRadius: AppRadius.radiusSm,
                border: Border.all(color: AppColors.info.withAlpha(70)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.offline_bolt_rounded, size: 14, color: AppColors.info),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Offline Demo Mode Active — Using high-fidelity cached catalog',
                      style: TextStyle(fontSize: 11, color: AppColors.info, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],

          Row(
            children: [
              // Avatar with gradient halo
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
                child: ClipOval(
                  child: Container(
                    width: 44,
                    height: 44,
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    child: (user?.avatarUrl != null && user!.avatarUrl.isNotEmpty)
                        ? NetworkImageView(
                            imageUrl: user.avatarUrl,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: Text(
                              userName.isNotEmpty ? userName[0].toUpperCase() : 'N',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Greeting & Location
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, $userName 👋',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: isDark ? AppColors.primaryLight : AppColors.primary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Kochi, India',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Notification Icon Button
              InkWell(
                borderRadius: BorderRadius.circular(21),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Notifications',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '1 NEW',
                                  style: TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryViolet.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.local_offer_rounded, color: AppColors.primaryViolet, size: 20),
                            ),
                            title: const Text('Exclusive 10% Off!'),
                            subtitle: const Text('Use promo code NOVA10 in your bag to claim your discount.'),
                            trailing: const Text('Just now', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ),
                          const Divider(),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.emerald.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.local_shipping_rounded, color: AppColors.emerald, size: 20),
                            ),
                            title: const Text('Order Dispatched'),
                            subtitle: const Text('NOVA Smart Chronograph #NOVA-92841 is in transit.'),
                            trailing: const Text('2h ago', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 22,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                      Positioned(
                        top: 10,
                        right: 11,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

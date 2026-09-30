import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/shimmer_box.dart';
import '../../data/models/filter_options.dart';
import '../../data/models/product.dart';
import '../../data/models/category.dart';
import '../search/widgets/filter_bottom_sheet.dart';
import 'home_provider.dart';
import 'widgets/category_selector.dart';
import 'widgets/for_you_section.dart';
import 'widgets/hero_carousel.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/product_staggered_grid.dart';
import 'widgets/sticky_search_bar.dart';

/// Commercial-grade Home screen showcasing promotional hero campaigns,
/// categories, personalized recommendations, and a high-performance infinite scrolling grid.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;
  bool _isLoadingMoreThrottled = false; // Debounce flag to prevent scroll spam

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    // Debounced infinite scrolling: only fire once per crossing threshold
    final threshold = _scrollController.position.maxScrollExtent - 400;
    if (_scrollController.position.pixels >= threshold && !_isLoadingMoreThrottled) {
      _isLoadingMoreThrottled = true;
      context.read<HomeProvider>().loadMoreProducts().then((_) {
        // Reset the throttle after the call completes
        if (mounted) _isLoadingMoreThrottled = false;
      });
    }

    // Toggle Back-To-Top button visibility (only setState when actually changed)
    final shouldShow = _scrollController.position.pixels > 600;
    if (shouldShow != _showBackToTop) {
      setState(() => _showBackToTop = shouldShow);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      floatingActionButton: AnimatedSlide(
        duration: AppMotion.durationNormal,
        curve: AppMotion.curveDefault,
        offset: _showBackToTop ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: AppMotion.durationNormal,
          opacity: _showBackToTop ? 1.0 : 0.0,
          child: FloatingActionButton.small(
            onPressed: _scrollToTop,
            backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 4,
            child: const Icon(Icons.arrow_upward_rounded),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        // Full-screen error check: only this Consumer is needed for initial error
        child: Selector<HomeProvider, ({FeedStatus status, String? errorMessage})>(
          selector: (_, h) => (status: h.status, errorMessage: h.errorMessage),
          builder: (context, state, _) {
            if (state.status == FeedStatus.error) {
              return ErrorView(
                message: state.errorMessage ?? 'Unable to connect to NOVA servers.',
                onRetry: () => context.read<HomeProvider>().refreshFeed(),
              );
            }
            return _buildScrollView(context, isDark);
          },
        ),
      ),
    );
  }

  Widget _buildScrollView(BuildContext context, bool isDark) {
    return RefreshIndicator(
      onRefresh: () => context.read<HomeProvider>().refreshFeed(),
      color: isDark ? AppColors.primaryLight : AppColors.primary,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          // 1. Personalized Greeting AppBar (watches AuthProvider, isolate rebuild)
          const SliverToBoxAdapter(child: HomeAppBar()),

          // 2. Sticky Search Field — tap-only, no provider watch needed here
          const SliverToBoxAdapter(child: StickySearchBar()),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // 3. Promotional Hero Carousel — static data, no rebuild needed
          SliverToBoxAdapter(
            child: Selector<HomeProvider, List<PromoCampaign>>(
              selector: (_, h) => h.campaigns,
              builder: (context, campaigns, _) => HeroCarousel(
                campaigns: campaigns,
                onCampaignTap: (slug) => context.read<HomeProvider>().selectCategory(slug),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // 4. Horizontal Categories Selector
          SliverToBoxAdapter(
            child: Selector<HomeProvider, ({List<ProductCategory> categories, String selectedSlug})>(
              selector: (_, h) => (categories: h.categories, selectedSlug: h.selectedCategorySlug),
              builder: (context, data, _) => CategorySelector(
                categories: data.categories,
                selectedSlug: data.selectedSlug,
                onSelect: (slug) => context.read<HomeProvider>().selectCategory(slug),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // 5. Personalized "For You" Section
          SliverToBoxAdapter(
            child: Selector<HomeProvider, List<Product>>(
              selector: (_, h) => h.forYouProducts,
              builder: (context, forYou, _) =>
                  forYou.isNotEmpty ? ForYouSection(products: forYou) : const SizedBox.shrink(),
            ),
          ),

          // 6. Section Header
          SliverToBoxAdapter(
            child: Selector<HomeProvider,
                ({String slug, int loaded, int total, FilterOptions filterOptions})>(
              selector: (_, h) => (
                slug: h.selectedCategorySlug,
                loaded: h.products.length,
                total: h.totalProducts,
                filterOptions: h.filterOptions,
              ),
              builder: (context, data, _) => SectionHeader(
                title: data.slug == 'all'
                    ? 'Explore Collection'
                    : '${data.slug.toUpperCase()} Collection',
                subtitle: '${data.loaded} of ${data.total} items loaded',
                actionText: 'Filter',
                onActionTap: () {
                  FilterBottomSheet.show(
                    context: context,
                    initialOptions: data.filterOptions,
                    onApply: (newOptions) =>
                        context.read<HomeProvider>().applyFilters(newOptions),
                  );
                },
              ),
            ),
          ),

          // 7. Products Grid or Initial Shimmer — only rebuilds on product list changes
          Selector<HomeProvider, ({bool isInitialLoading, List<Product> products})>(
            selector: (_, h) =>
                (isInitialLoading: h.isInitialLoading, products: h.products),
            builder: (context, data, _) {
              if (data.isInitialLoading) {
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const ProductCardSkeleton(),
                      childCount: 6,
                    ),
                  ),
                );
              }
              return ProductStaggeredGrid(products: data.products);
            },
          ),

          // 8. Infinite Scrolling Footer
          SliverToBoxAdapter(
            child: Selector<HomeProvider, ({bool isLoadingMore, bool hasMore, int productCount})>(
              selector: (_, h) => (
                isLoadingMore: h.isLoadingMore,
                hasMore: h.hasMore,
                productCount: h.products.length,
              ),
              builder: (context, data, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: AppMotion.durationNormal,
                    child: data.isLoadingMore
                        ? Row(
                            key: const ValueKey('loading'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isDark ? AppColors.primaryLight : AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Loading curated products...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          )
                        : !data.hasMore && data.productCount > 0
                            ? Container(
                                key: const ValueKey('caught_up'),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white10 : Colors.black.withAlpha(8),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "You're all caught up ✨",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                              )
                            : const SizedBox(key: ValueKey('empty'), height: 20),
                  ),
                ),
              ),
            ),
          ),
          // 9. Copyright Footer
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0, top: 4.0),
              child: Column(
                children: [
                  Divider(
                    color: isDark ? Colors.white12 : Colors.black12,
                    indent: 40,
                    endIndent: 40,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'NOVA Lifestyle Shopping',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppConstants.copyright,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

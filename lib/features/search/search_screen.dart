import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/shimmer_box.dart';
import 'search_provider.dart';
import 'widgets/filter_bottom_sheet.dart';
import 'widgets/search_history_chips.dart';

/// Full-featured Search Screen with 400ms debounce, history, filters, and paginated infinite scroll.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 300;
    if (_scrollController.position.pixels >= threshold) {
      context.read<SearchProvider>().loadMoreSearchResults();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onQuerySubmitted(String query) {
    if (query.trim().isNotEmpty) {
      context.read<SearchProvider>().executeSearch(query);
    }
  }

  void _onChipSelected(String query) {
    _searchController.text = query;
    context.read<SearchProvider>().executeSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final search = context.watch<SearchProvider>();
    final columnCount = ResponsiveUtils.getGridColumnCount(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        titleSpacing: 0,
        title: Container(
          height: 44,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
            borderRadius: AppRadius.radiusMd,
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: (val) => search.onQueryChanged(val),
            onSubmitted: _onQuerySubmitted,
            textInputAction: TextInputAction.search,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Search products, categories...',
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 20,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        search.clearSearch();
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              border: InputBorder.none,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () {
              FilterBottomSheet.show(
                context: context,
                initialOptions: search.filterOptions,
                onApply: (opts) => search.applyFilters(opts),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Builder(
        builder: (context) {
          // Idle state -> show recent history & trending chips
          if (search.status == SearchStatus.idle && _searchController.text.isEmpty) {
            return SearchHistoryChips(
              recentSearches: search.recentSearches,
              trendingSearches: search.trendingSearches,
              onSelectSearch: _onChipSelected,
              onClearRecent: () => search.clearHistory(),
            );
          }

          // Initial loading shimmer
          if (search.isLoading) {
            return GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columnCount,
                childAspectRatio: 0.65,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
              ),
              itemCount: 6,
              itemBuilder: (context, index) => const ProductCardSkeleton(),
            );
          }

          // Error state
          if (search.status == SearchStatus.error && search.results.isEmpty) {
            return ErrorView(
              message: search.errorMessage ?? 'Search failed. Please check network.',
              onRetry: () => search.executeSearch(_searchController.text),
            );
          }

          // Empty results state
          if (search.status == SearchStatus.success && search.results.isEmpty) {
            return EmptyState(
              icon: Icons.search_off_rounded,
              title: 'No Matching Items Found',
              subtitle: 'We couldn\'t find any products for "${search.query}". Try searching for categories like "shoes", "beauty", or "smartphones".',
            );
          }

          // Results list with infinite scrolling
          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Showing ${search.results.length} of ${search.totalResults} results for "${search.query}"',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columnCount,
                    childAspectRatio: 0.65,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = search.results[index];
                      return ProductCard(
                        product: product,
                        onTap: () => context.push('/product/${product.id}', extra: product),
                      );
                    },
                    childCount: search.results.length,
                  ),
                ),
              ),
              if (search.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/colors.dart';
import '../models/listing.dart';
import '../providers/app_provider.dart';
import '../providers/config_provider.dart';
import '../utils/listing_helpers.dart';
import '../widgets/car/car_list_item.dart';
import '../widgets/filter/filter_panel.dart';
import '../widgets/ui/skeleton_loader.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late TextEditingController _searchController;
  Timer? _debounceTimer;
  bool _sortMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(searchProvider).query,
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      ref.read(searchProvider.notifier).setQuery(value);
    });
  }

  String _sortLabel(String sortBy) {
    switch (sortBy) {
      case 'priceAsc':
        return 'Price: Low to High';
      case 'priceDesc':
        return 'Price: High to Low';
      default:
        return 'Latest';
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final searchResults = ref.watch(searchResultsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(top: topPadding + 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // a) Search header row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => context.go('/home'),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Icon(
                            LucideIcons.chevronLeft,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Search field
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                          cursorColor: AppColors.gold,
                          decoration: InputDecoration(
                            hintText: 'Search cars...',
                            hintStyle: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: AppColors.textMuted,
                            ),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 14, right: 10),
                              child: Icon(
                                LucideIcons.search,
                                size: 20,
                                color: AppColors.gold,
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 44,
                              minHeight: 20,
                            ),
                            filled: true,
                            fillColor: AppColors.bgCard,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: AppColors.border,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: AppColors.gold.withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Filter button
                    GestureDetector(
                      onTap: () => _showFilterPanel(context),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border, width: 1),
                        ),
                        child: Stack(
                          children: [
                            const Center(
                              child: Icon(LucideIcons.sliders, size: 20, color: AppColors.gold),
                            ),
                            // Badge showing active filter count
                            if (ref.watch(searchProvider).activeFilterCount > 0)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: AppColors.gold,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${ref.watch(searchProvider).activeFilterCount}',
                                      style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.bg),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // b) Filter chips row — loaded from categoriesProvider
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  height: 40,
                  child: categoriesAsync.when(
                    data: (categories) {
                      final chips = [
                        'All',
                        ...categories.map((c) => c.name),
                      ];
                      return ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemCount: chips.length,
                        itemBuilder: (context, index) {
                          final chip = chips[index];
                          final isActive = searchState.activeFilter == chip;

                          return GestureDetector(
                            onTap: () {
                              ref
                                  .read(searchProvider.notifier)
                                  .setFilter(chip);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.gold
                                    : AppColors.bgCard,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isActive
                                      ? AppColors.gold
                                      : AppColors.borderLight,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  chip,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isActive
                                        ? AppColors.bg
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemCount: 6,
                      itemBuilder: (_, _) => const SkeletonLoader(
                        width: 80,
                        height: 40,
                        borderRadius: 12,
                      ),
                    ),
                    error: (_, _) => _buildFallbackChips(searchState),
                  ),
                ),
              ),

              // c) Results count + sort row
              Padding(
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 16,
                  bottom: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: searchResults.when(
                        data: (listings) => Text(
                          '${listings.length} cars found',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        loading: () => Text(
                          'Searching...',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        error: (_, _) => Text(
                          'Error loading results',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                    ),
                    // Sort dropdown
                    GestureDetector(
                      onTap: () {
                        setState(() => _sortMenuOpen = !_sortMenuOpen);
                        _showSortMenu(context, searchState.sortBy);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.borderLight,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.arrowUpDown,
                              size: 14,
                              color: AppColors.gold.withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _sortLabel(searchState.sortBy),
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // d) Results list
              Expanded(
                child: searchResults.when(
                  data: (listings) => _buildResultsList(listings),
                  loading: () => _buildLoadingSkeletons(),
                  error: (error, _) => _buildErrorState(error),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsList(List<Listing> listings) {
    if (listings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons.searchX,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'No cars found',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search or filter',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: 100,
      ),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        final listing = listings[index];
        final car = listingToCar(listing);
        return CarListItem(
          car: car,
          onTap: () => context.push('/car/${listing.id}'),
        )
            .animate()
            .fadeIn(
              delay: Duration(milliseconds: index.clamp(0, 10) * 80),
              duration: const Duration(milliseconds: 400),
            )
            .slideY(
              begin: 0.1,
              end: 0,
              delay: Duration(milliseconds: index.clamp(0, 10) * 80),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
            );
      },
    );
  }

  Widget _buildLoadingSkeletons() {
    return ListView.builder(
      padding: const EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: 100,
      ),
      itemCount: 6,
      itemBuilder: (_, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SkeletonLoader(
            width: double.infinity,
            height: 115,
            borderRadius: 18,
          ),
        );
      },
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.wifiOff,
            size: 48,
            color: AppColors.textMuted.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to load results',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check your connection and try again',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => ref.invalidate(searchResultsProvider),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Fallback chips when categories fail to load
  Widget _buildFallbackChips(SearchState searchState) {
    final chips = ['All', 'SUV', 'Sedan', 'Hatchback', 'MUV', 'Luxury'];
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      separatorBuilder: (_, _) => const SizedBox(width: 10),
      itemCount: chips.length,
      itemBuilder: (context, index) {
        final chip = chips[index];
        final isActive = searchState.activeFilter == chip;

        return GestureDetector(
          onTap: () {
            ref.read(searchProvider.notifier).setFilter(chip);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isActive ? AppColors.gold : AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive ? AppColors.gold : AppColors.borderLight,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                chip,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive ? AppColors.bg : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFilterPanel(BuildContext context) {
    final currentState = ref.read(searchProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterPanel(
        initialFilters: currentState.toAdvancedFilterMap(),
        onApply: (filters) {
          ref.read(searchProvider.notifier).setAdvancedFilters(filters);
          Navigator.pop(context);
        },
        onReset: () {
          ref.read(searchProvider.notifier).clearAdvancedFilters();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showSortMenu(BuildContext context, String currentSort) {
    final options = [
      {'value': 'default', 'label': 'Latest'},
      {'value': 'priceAsc', 'label': 'Price: Low to High'},
      {'value': 'priceDesc', 'label': 'Price: High to Low'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sort By',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              ...options.map((option) {
                final isSelected = currentSort == option['value'];
                return GestureDetector(
                  onTap: () {
                    ref
                        .read(searchProvider.notifier)
                        .setSortBy(option['value']!);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            option['label']!,
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight:
                                  isSelected ? FontWeight.w700 : FontWeight.w400,
                              color: isSelected
                                  ? AppColors.gold
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            LucideIcons.check,
                            size: 18,
                            color: AppColors.gold,
                          ),
                      ],
                    ),
                  ),
                );
              }),
              SizedBox(
                height: MediaQuery.of(context).padding.bottom + 16,
              ),
            ],
          ),
        );
      },
    ).then((_) {
      if (mounted) setState(() => _sortMenuOpen = false);
    });
  }
}

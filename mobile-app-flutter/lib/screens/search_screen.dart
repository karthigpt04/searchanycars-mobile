import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/colors.dart';
import '../models/mock_data.dart';
import '../providers/app_provider.dart';
import '../widgets/car/car_list_item.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(searchProvider).query,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final filteredCars = ref.watch(filteredCarsProvider);
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
                          onChanged: (value) {
                            ref
                                .read(searchProvider.notifier)
                                .setQuery(value);
                          },
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
                                color: AppColors.gold.withValues(alpha:0.4),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // b) Filter chips row
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemCount: MockData.filterChips.length,
                    itemBuilder: (context, index) {
                      final chip = MockData.filterChips[index];
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
                  ),
                ),
              ),

              // c) Results count
              Padding(
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 16,
                  bottom: 8,
                ),
                child: Text(
                  '${filteredCars.length} cars found',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ),

              // d) Results list
              Expanded(
                child: filteredCars.isEmpty
                    ? Center(
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
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(
                          left: 24,
                          right: 24,
                          bottom: 100,
                        ),
                        itemCount: filteredCars.length,
                        itemBuilder: (context, index) {
                          final car = filteredCars[index];
                          return CarListItem(
                            car: car,
                            onTap: () => context.push('/car/${car.id}'),
                          )
                              .animate()
                              .fadeIn(
                                delay: Duration(milliseconds: index * 80),
                                duration: const Duration(milliseconds: 400),
                              )
                              .slideY(
                                begin: 0.1,
                                end: 0,
                                delay: Duration(milliseconds: index * 80),
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOut,
                              );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/colors.dart';
import '../providers/app_provider.dart';
import '../models/car.dart';
import '../models/mock_data.dart';

class CompareScreen extends ConsumerWidget {
  const CompareScreen({super.key});

  Color _parseHex(String hex) {
    hex = hex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compareCars = ref.watch(compareCarsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: compareCars.isEmpty
            ? _buildEmptyState(context, ref)
            : _buildComparisonView(context, ref, compareCars),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '\u2696\uFE0F',
            style: TextStyle(fontSize: 56),
          ),
          const SizedBox(height: 16),
          Text(
            'Compare Cars',
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 280,
            child: Text(
              'Select 2-3 cars to compare specs, prices, and features side by side',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => _showCarPicker(context, ref),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.gold, AppColors.goldLight, AppColors.gold],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha:0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Text(
                'Choose Cars',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.bg,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonView(
      BuildContext context, WidgetRef ref, List<Car> cars) {
    final specs = _getComparisonSpecs(cars);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Compare',
                  style: GoogleFonts.dmSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (cars.length < 3)
                GestureDetector(
                  onTap: () => _showCarPicker(context, ref),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha:0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.plus, size: 14, color: AppColors.gold),
                        const SizedBox(width: 4),
                        Text(
                          'Add Car',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => ref.read(compareCarsProvider.notifier).clear(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Clear',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Car columns header (horizontal scroll)
        SizedBox(
          height: 180,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: cars.asMap().entries.map((entry) {
                final index = entry.key;
                final car = entry.value;
                final carColor = _parseHex(car.color);
                return Container(
                  width: 140,
                  margin: EdgeInsets.only(right: index < cars.length - 1 ? 12 : 0),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      // Thumbnail
                      Container(
                        width: double.infinity,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              carColor.withValues(alpha:0.3),
                              AppColors.bgCard,
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Text(
                                car.brand[0],
                                style: GoogleFonts.dmSans(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: carColor.withValues(alpha:0.3),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => ref
                                    .read(compareCarsProvider.notifier)
                                    .removeCar(car.id),
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: AppColors.bg.withValues(alpha:0.8),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    LucideIcons.x,
                                    size: 12,
                                    color: AppColors.danger,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        car.name,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\u20B9${car.price}',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(
                      duration: 400.ms,
                      delay: Duration(milliseconds: index * 100),
                    );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Comparison table
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
            itemCount: specs.length,
            itemBuilder: (context, index) {
              final spec = specs[index];
              return _buildComparisonRow(
                spec['label'] as String,
                (spec['values'] as List<String>),
                spec['bestIndex'] as int?,
              ).animate().fadeIn(
                    duration: 300.ms,
                    delay: Duration(milliseconds: 200 + index * 60),
                  );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonRow(
      String label, List<String> values, int? bestIndex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: values.asMap().entries.map((entry) {
              final i = entry.key;
              final value = entry.value;
              final isBest = bestIndex == i;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < values.length - 1 ? 8 : 0),
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: BoxDecoration(
                    color: isBest
                        ? AppColors.gold.withValues(alpha:0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isBest
                        ? Border.all(color: AppColors.gold.withValues(alpha:0.2))
                        : null,
                  ),
                  child: Text(
                    value,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: isBest ? FontWeight.w700 : FontWeight.w500,
                      color:
                          isBest ? AppColors.gold : AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getComparisonSpecs(List<Car> cars) {
    // Helper to find the best (lowest numeric) index for price-like fields
    int? findLowestPrice(List<String> prices) {
      double? best;
      int? bestIdx;
      for (int i = 0; i < prices.length; i++) {
        final cleaned = prices[i].replaceAll(RegExp(r'[^\d.]'), '');
        final val = double.tryParse(cleaned);
        if (val != null && (best == null || val < best)) {
          best = val;
          bestIdx = i;
        }
      }
      return bestIdx;
    }

    int? findHighest(List<String> values) {
      double? best;
      int? bestIdx;
      for (int i = 0; i < values.length; i++) {
        final cleaned = values[i].replaceAll(RegExp(r'[^\d.]'), '');
        final val = double.tryParse(cleaned);
        if (val != null && (best == null || val > best)) {
          best = val;
          bestIdx = i;
        }
      }
      return bestIdx;
    }

    int? findLowestKm(List<String> kms) {
      double? best;
      int? bestIdx;
      for (int i = 0; i < kms.length; i++) {
        final cleaned = kms[i].replaceAll(RegExp(r'[^\d]'), '');
        final val = double.tryParse(cleaned);
        if (val != null && (best == null || val < best)) {
          best = val;
          bestIdx = i;
        }
      }
      return bestIdx;
    }

    final years = cars.map((c) => c.year.toString()).toList();
    final kms = cars.map((c) => '${c.km} km').toList();
    final fuels = cars.map((c) => c.fuel).toList();
    final transmissions = cars.map((c) => c.transmission).toList();
    final owners = cars.map((c) => c.owner).toList();
    final cities = cars.map((c) => c.city).toList();
    final ratings = cars.map((c) => c.rating.toString()).toList();
    final emis = cars.map((c) => c.emi).toList();
    final prices = cars.map((c) => '\u20B9${c.price}').toList();

    return [
      {'label': 'PRICE', 'values': prices, 'bestIndex': findLowestPrice(prices)},
      {'label': 'YEAR', 'values': years, 'bestIndex': findHighest(years)},
      {'label': 'KILOMETRES', 'values': kms, 'bestIndex': findLowestKm(kms)},
      {'label': 'FUEL TYPE', 'values': fuels, 'bestIndex': null},
      {'label': 'TRANSMISSION', 'values': transmissions, 'bestIndex': null},
      {'label': 'OWNER', 'values': owners, 'bestIndex': null},
      {'label': 'CITY', 'values': cities, 'bestIndex': null},
      {'label': 'RATING', 'values': ratings, 'bestIndex': findHighest(ratings)},
      {'label': 'EMI', 'values': emis, 'bestIndex': findLowestPrice(emis)},
    ];
  }

  void _showCarPicker(BuildContext context, WidgetRef ref) {
    final allCars = MockData.cars;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final currentCompare = ref.watch(compareCarsProvider);
            return Container(
              padding: const EdgeInsets.all(24),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textMuted,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select a Car',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose up to ${3 - currentCompare.length} more',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: allCars.length,
                      itemBuilder: (context, index) {
                        final car = allCars[index];
                        final isSelected =
                            currentCompare.any((c) => c.id == car.id);
                        return GestureDetector(
                          onTap: () {
                            if (isSelected) {
                              ref
                                  .read(compareCarsProvider.notifier)
                                  .removeCar(car.id);
                            } else if (currentCompare.length < 3) {
                              ref
                                  .read(compareCarsProvider.notifier)
                                  .addCar(car);
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.gold.withValues(alpha:0.08)
                                  : AppColors.bg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.gold.withValues(alpha:0.3)
                                    : AppColors.borderLight,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        car.name,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${car.year} \u2022 ${car.km} km \u2022 \u20B9${car.price}',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  isSelected
                                      ? LucideIcons.checkCircle2
                                      : LucideIcons.circle,
                                  size: 22,
                                  color: isSelected
                                      ? AppColors.gold
                                      : AppColors.textMuted,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (currentCompare.length >= 2)
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.gold,
                                AppColors.goldLight,
                                AppColors.gold
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            'Compare ${currentCompare.length} Cars',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.bg,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

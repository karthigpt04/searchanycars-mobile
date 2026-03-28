import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../constants/colors.dart';

class FilterPanel extends StatefulWidget {
  final Map<String, dynamic> initialFilters;
  final void Function(Map<String, dynamic> filters) onApply;
  final VoidCallback onReset;

  const FilterPanel({
    super.key,
    required this.initialFilters,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  late TextEditingController _priceMinController;
  late TextEditingController _priceMaxController;
  late TextEditingController _yearMinController;
  late TextEditingController _yearMaxController;

  String? _selectedFuelType;
  String? _selectedTransmission;
  String? _selectedOwnership;
  double? _maxKm;

  // Track which price preset is active (null = custom input)
  String? _activePricePreset;
  // Track which year preset is active
  String? _activeYearPreset;
  // Track which km preset is active
  String? _activeKmPreset;

  @override
  void initState() {
    super.initState();

    // Initialize price fields (convert INR back to lakhs for display)
    final priceMinInr = widget.initialFilters['priceMin'] as double?;
    final priceMaxInr = widget.initialFilters['priceMax'] as double?;
    _priceMinController = TextEditingController(
      text: priceMinInr != null ? (priceMinInr / 100000).toStringAsFixed(0) : '',
    );
    _priceMaxController = TextEditingController(
      text: priceMaxInr != null ? (priceMaxInr / 100000).toStringAsFixed(0) : '',
    );

    // Initialize year fields
    final yearMin = widget.initialFilters['yearMin'] as int?;
    final yearMax = widget.initialFilters['yearMax'] as int?;
    _yearMinController = TextEditingController(
      text: yearMin?.toString() ?? '',
    );
    _yearMaxController = TextEditingController(
      text: yearMax?.toString() ?? '',
    );

    _selectedFuelType = widget.initialFilters['fuelType'] as String?;
    _selectedTransmission = widget.initialFilters['transmissionType'] as String?;
    _selectedOwnership = widget.initialFilters['ownershipType'] as String?;
    _maxKm = widget.initialFilters['maxKm'] as double?;

    // Detect active presets from initial values
    _activePricePreset = _detectPricePreset(priceMinInr, priceMaxInr);
    _activeYearPreset = _detectYearPreset(yearMin);
    _activeKmPreset = _detectKmPreset(_maxKm);
  }

  @override
  void dispose() {
    _priceMinController.dispose();
    _priceMaxController.dispose();
    _yearMinController.dispose();
    _yearMaxController.dispose();
    super.dispose();
  }

  String? _detectPricePreset(double? minInr, double? maxInr) {
    if (minInr == null && maxInr != null && maxInr == 500000) return 'Under 5L';
    if (minInr == 500000 && maxInr == 1000000) return '5-10L';
    if (minInr == 1000000 && maxInr == 2000000) return '10-20L';
    if (minInr == 2000000 && maxInr == 5000000) return '20-50L';
    if (minInr == 5000000 && maxInr == null) return '50L+';
    return null;
  }

  String? _detectYearPreset(int? yearMin) {
    if (yearMin == 2024) return '2024+';
    if (yearMin == 2022) return '2022+';
    if (yearMin == 2020) return '2020+';
    if (yearMin == 2018) return '2018+';
    return null;
  }

  String? _detectKmPreset(double? maxKm) {
    if (maxKm == 10000) return 'Under 10K';
    if (maxKm == 30000) return 'Under 30K';
    if (maxKm == 50000) return 'Under 50K';
    if (maxKm == 75000) return 'Under 75K';
    if (maxKm == 100000) return 'Under 1L';
    return null;
  }

  int get _activeFilterCount {
    int count = 0;
    if (_priceMinController.text.isNotEmpty || _priceMaxController.text.isNotEmpty) count++;
    if (_selectedFuelType != null) count++;
    if (_selectedTransmission != null) count++;
    if (_yearMinController.text.isNotEmpty || _yearMaxController.text.isNotEmpty) count++;
    if (_selectedOwnership != null) count++;
    if (_maxKm != null) count++;
    return count;
  }

  void _resetAll() {
    setState(() {
      _priceMinController.clear();
      _priceMaxController.clear();
      _yearMinController.clear();
      _yearMaxController.clear();
      _selectedFuelType = null;
      _selectedTransmission = null;
      _selectedOwnership = null;
      _maxKm = null;
      _activePricePreset = null;
      _activeYearPreset = null;
      _activeKmPreset = null;
    });
    widget.onReset();
  }

  void _applyFilters() {
    final filters = <String, dynamic>{};

    // Price (convert lakhs to INR)
    final minLakhs = double.tryParse(_priceMinController.text);
    final maxLakhs = double.tryParse(_priceMaxController.text);
    if (minLakhs != null) filters['priceMin'] = minLakhs * 100000;
    if (maxLakhs != null) filters['priceMax'] = maxLakhs * 100000;

    // Fuel type
    if (_selectedFuelType != null) filters['fuelType'] = _selectedFuelType;

    // Transmission
    if (_selectedTransmission != null) filters['transmissionType'] = _selectedTransmission;

    // Year range
    final yearMin = int.tryParse(_yearMinController.text);
    final yearMax = int.tryParse(_yearMaxController.text);
    if (yearMin != null) filters['yearMin'] = yearMin;
    if (yearMax != null) filters['yearMax'] = yearMax;

    // Ownership
    if (_selectedOwnership != null) filters['ownershipType'] = _selectedOwnership;

    // Max km
    if (_maxKm != null) filters['maxKm'] = _maxKm;

    widget.onApply(filters);
  }

  void _selectPricePreset(String preset) {
    setState(() {
      if (_activePricePreset == preset) {
        // Deselect
        _activePricePreset = null;
        _priceMinController.clear();
        _priceMaxController.clear();
        return;
      }
      _activePricePreset = preset;
      switch (preset) {
        case 'Under 5L':
          _priceMinController.clear();
          _priceMaxController.text = '5';
        case '5-10L':
          _priceMinController.text = '5';
          _priceMaxController.text = '10';
        case '10-20L':
          _priceMinController.text = '10';
          _priceMaxController.text = '20';
        case '20-50L':
          _priceMinController.text = '20';
          _priceMaxController.text = '50';
        case '50L+':
          _priceMinController.text = '50';
          _priceMaxController.clear();
      }
    });
  }

  void _selectYearPreset(String preset) {
    setState(() {
      if (_activeYearPreset == preset) {
        _activeYearPreset = null;
        _yearMinController.clear();
        _yearMaxController.clear();
        return;
      }
      _activeYearPreset = preset;
      switch (preset) {
        case '2024+':
          _yearMinController.text = '2024';
          _yearMaxController.clear();
        case '2022+':
          _yearMinController.text = '2022';
          _yearMaxController.clear();
        case '2020+':
          _yearMinController.text = '2020';
          _yearMaxController.clear();
        case '2018+':
          _yearMinController.text = '2018';
          _yearMaxController.clear();
      }
    });
  }

  void _selectKmPreset(String preset) {
    setState(() {
      if (_activeKmPreset == preset) {
        _activeKmPreset = null;
        _maxKm = null;
        return;
      }
      _activeKmPreset = preset;
      switch (preset) {
        case 'Under 10K':
          _maxKm = 10000;
        case 'Under 30K':
          _maxKm = 30000;
        case 'Under 50K':
          _maxKm = 50000;
        case 'Under 75K':
          _maxKm = 75000;
        case 'Under 1L':
          _maxKm = 100000;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title row
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Row(
              children: [
                Text(
                  'Filters',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (_activeFilterCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Center(
                      child: Text(
                        '$_activeFilterCount',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.bg,
                        ),
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.bgCardHover,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(LucideIcons.x, size: 18, color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Price Range
                  _buildSectionTitle('Price Range'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _priceMinController,
                          hint: 'Min (Lakhs)',
                          onChanged: (_) => setState(() => _activePricePreset = null),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'to',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _buildTextField(
                          controller: _priceMaxController,
                          hint: 'Max (Lakhs)',
                          onChanged: (_) => setState(() => _activePricePreset = null),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildPresetChips(
                    ['Under 5L', '5-10L', '10-20L', '20-50L', '50L+'],
                    _activePricePreset,
                    _selectPricePreset,
                  ),

                  const SizedBox(height: 24),

                  // 2. Fuel Type
                  _buildSectionTitle('Fuel Type'),
                  const SizedBox(height: 12),
                  _buildChoiceChips(
                    ['Petrol', 'Diesel', 'CNG', 'Electric', 'Hybrid'],
                    _selectedFuelType,
                    (value) => setState(() {
                      _selectedFuelType = _selectedFuelType == value ? null : value;
                    }),
                  ),

                  const SizedBox(height: 24),

                  // 3. Transmission
                  _buildSectionTitle('Transmission'),
                  const SizedBox(height: 12),
                  _buildChoiceChips(
                    ['Manual', 'Automatic', 'CVT', 'AMT'],
                    _selectedTransmission,
                    (value) => setState(() {
                      _selectedTransmission = _selectedTransmission == value ? null : value;
                    }),
                  ),

                  const SizedBox(height: 24),

                  // 4. Year Range
                  _buildSectionTitle('Year Range'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _yearMinController,
                          hint: 'From Year',
                          onChanged: (_) => setState(() => _activeYearPreset = null),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'to',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _buildTextField(
                          controller: _yearMaxController,
                          hint: 'To Year',
                          onChanged: (_) => setState(() => _activeYearPreset = null),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildPresetChips(
                    ['2024+', '2022+', '2020+', '2018+'],
                    _activeYearPreset,
                    _selectYearPreset,
                  ),

                  const SizedBox(height: 24),

                  // 5. Ownership
                  _buildSectionTitle('Ownership'),
                  const SizedBox(height: 12),
                  _buildChoiceChips(
                    ['1st Owner', '2nd Owner', '3rd Owner', '4th+'],
                    _ownershipToDisplay(_selectedOwnership),
                    (value) => setState(() {
                      final mapped = _ownershipFromDisplay(value);
                      _selectedOwnership = _selectedOwnership == mapped ? null : mapped;
                    }),
                  ),

                  const SizedBox(height: 24),

                  // 6. Max Kilometers
                  _buildSectionTitle('Max Kilometers'),
                  const SizedBox(height: 12),
                  _buildPresetChips(
                    ['Under 10K', 'Under 30K', 'Under 50K', 'Under 75K', 'Under 1L'],
                    _activeKmPreset,
                    _selectKmPreset,
                  ),

                  // Extra bottom spacing
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Bottom action bar
          Container(
            padding: EdgeInsets.fromLTRB(24, 16, 24, bottomPadding + 16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              border: const Border(
                top: BorderSide(color: AppColors.borderLight, width: 1),
              ),
            ),
            child: Row(
              children: [
                // Reset button
                GestureDetector(
                  onTap: _resetAll,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.bgCardHover,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.borderLight, width: 1),
                    ),
                    child: Text(
                      'Reset All',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Apply button
                Expanded(
                  child: GestureDetector(
                    onTap: _applyFilters,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.gold, AppColors.goldLight, AppColors.gold],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.check, size: 18, color: AppColors.bg),
                            const SizedBox(width: 8),
                            Text(
                              'Apply Filters',
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.bg,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Builders ---

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    ValueChanged<String>? onChanged,
  }) {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: GoogleFonts.dmSans(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        cursorColor: AppColors.gold,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.dmSans(
            fontSize: 13,
            color: AppColors.textMuted,
          ),
          filled: true,
          fillColor: AppColors.bgCardHover,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.gold.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPresetChips(
    List<String> presets,
    String? activePreset,
    ValueChanged<String> onSelect,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: presets.map((preset) {
        final isActive = activePreset == preset;
        return GestureDetector(
          onTap: () => onSelect(preset),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? AppColors.gold : AppColors.bgCardHover,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive ? AppColors.gold : AppColors.borderLight,
                width: 1,
              ),
            ),
            child: Text(
              preset,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? AppColors.bg : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChoiceChips(
    List<String> options,
    String? selected,
    ValueChanged<String> onSelect,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isActive = selected == option;
        return GestureDetector(
          onTap: () => onSelect(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: isActive ? AppColors.gold : AppColors.bgCardHover,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive ? AppColors.gold : AppColors.borderLight,
                width: 1,
              ),
            ),
            child: Text(
              option,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? AppColors.bg : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // --- Ownership display ↔ API value mapping ---

  String? _ownershipToDisplay(String? apiValue) {
    switch (apiValue) {
      case 'First':
        return '1st Owner';
      case 'Second':
        return '2nd Owner';
      case 'Third':
        return '3rd Owner';
      case 'Fourth+':
        return '4th+';
      default:
        return null;
    }
  }

  String _ownershipFromDisplay(String displayValue) {
    switch (displayValue) {
      case '1st Owner':
        return 'First';
      case '2nd Owner':
        return 'Second';
      case '3rd Owner':
        return 'Third';
      case '4th+':
        return 'Fourth+';
      default:
        return displayValue;
    }
  }
}

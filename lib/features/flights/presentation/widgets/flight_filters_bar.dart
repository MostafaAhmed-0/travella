import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/app_translations.dart';
import '../../data/models/flight_models.dart';

class FlightFiltersSidebar extends StatelessWidget {
  final FlightFilterState filters;
  final Set<String> availableAirlines;
  final double minPrice;
  final double maxPrice;
  final ValueChanged<FlightFilterState> onFiltersChanged;
  final VoidCallback onReset;

  const FlightFiltersSidebar({
    super.key,
    required this.filters,
    required this.availableAirlines,
    required this.minPrice,
    required this.maxPrice,
    required this.onFiltersChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header: Title & Reset ─────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.tune_rounded, color: AppColors.navyDark, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isArabic ? 'تصفية النتائج' : 'Filter Flights',
                    style: AppTextStyles.h4.copyWith(color: AppColors.navyDark),
                  ),
                ],
              ),
              if (filters.hasActiveFilters)
                TextButton(
                  onPressed: onReset,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.errorRed,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  child: Text(
                    isArabic ? 'مسح الكل' : 'Reset All',
                    style: AppTextStyles.labelSM.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.borderLight),
          const SizedBox(height: 16),

          // ── 1. Stops Filter ───────────────────────────────────────────────
          _buildFilterTitle(context.tr('filter_stops'), Icons.alt_route_rounded),
          const SizedBox(height: 10),
          _buildStopsOptions(context),
          const SizedBox(height: 20),
          const Divider(color: AppColors.borderLight),
          const SizedBox(height: 16),

          // ── 2. Airlines Filter ────────────────────────────────────────────
          _buildFilterTitle(context.tr('filter_airlines'), Icons.airlines_rounded),
          const SizedBox(height: 10),
          _buildAirlinesOptions(context),
          const SizedBox(height: 20),
          const Divider(color: AppColors.borderLight),
          const SizedBox(height: 16),

          // ── 3. Departure Time Filter ──────────────────────────────────────
          _buildFilterTitle(context.tr('filter_departure_time'), Icons.flight_takeoff_rounded),
          const SizedBox(height: 10),
          _buildTimeSlotChips(
            selected: filters.departureSlot,
            onChanged: (slot) => onFiltersChanged(filters.copyWith(departureSlot: slot)),
            isArabic: isArabic,
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.borderLight),
          const SizedBox(height: 16),

          // ── 4. Arrival Time Filter ────────────────────────────────────────
          _buildFilterTitle(context.tr('filter_arrival_time'), Icons.flight_land_rounded),
          const SizedBox(height: 10),
          _buildTimeSlotChips(
            selected: filters.arrivalSlot,
            onChanged: (slot) => onFiltersChanged(filters.copyWith(arrivalSlot: slot)),
            isArabic: isArabic,
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.borderLight),
          const SizedBox(height: 16),

          // ── 5. Price Range Slider ─────────────────────────────────────────
          _buildFilterTitle(
            '${context.tr('filter_price_range')}: up to \$${filters.maxPrice.toInt()}',
            Icons.payments_outlined,
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.royalBlue,
              inactiveTrackColor: AppColors.gray200,
              thumbColor: AppColors.navyDark,
              overlayColor: AppColors.royalBlue.withValues(alpha: 0.15),
              valueIndicatorColor: AppColors.navyDark,
            ),
            child: Slider(
              value: filters.maxPrice.clamp(100.0, 3000.0),
              min: 100.0,
              max: 3000.0,
              divisions: 29,
              label: '\$${filters.maxPrice.toInt()}',
              onChanged: (val) {
                onFiltersChanged(filters.copyWith(maxPrice: val));
              },
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.borderLight),
          const SizedBox(height: 16),

          // ── 6. Flight Duration ────────────────────────────────────────────
          _buildFilterTitle(
            '${context.tr('filter_duration')}: up to ${filters.maxDurationHours.toInt()}h',
            Icons.timer_outlined,
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.gold,
              inactiveTrackColor: AppColors.gray200,
              thumbColor: AppColors.goldDark,
              overlayColor: AppColors.gold.withValues(alpha: 0.15),
            ),
            child: Slider(
              value: filters.maxDurationHours.clamp(2.0, 24.0),
              min: 2.0,
              max: 24.0,
              divisions: 22,
              label: '${filters.maxDurationHours.toInt()} hours',
              onChanged: (val) {
                onFiltersChanged(filters.copyWith(maxDurationHours: val));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTitle(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.royalBlue),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.labelLG.copyWith(
              color: AppColors.navyDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStopsOptions(BuildContext context) {
    final isArabic = context.isArabic;
    final options = [
      (FlightStopsFilter.any, isArabic ? 'الكل' : 'Any Stops'),
      (FlightStopsFilter.nonStop, isArabic ? 'مباشر (بدون توقف)' : 'Non-stop Direct'),
      (FlightStopsFilter.oneStop, isArabic ? 'توقف واحد' : '1 Stop'),
      (FlightStopsFilter.twoPlusStops, isArabic ? 'توقفان فأكثر' : '2+ Stops'),
    ];

    return Column(
      children: options.map((opt) {
        final isSelected = filters.stops == opt.$1;
        return RadioListTile<FlightStopsFilter>(
          value: opt.$1,
          groupValue: filters.stops,
          dense: true,
          contentPadding: EdgeInsets.zero,
          activeColor: AppColors.royalBlue,
          title: Text(
            opt.$2,
            style: AppTextStyles.bodyMD.copyWith(
              color: isSelected ? AppColors.navyDark : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          onChanged: (val) {
            if (val != null) {
              onFiltersChanged(filters.copyWith(stops: val));
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildAirlinesOptions(BuildContext context) {
    final all = availableAirlines.isNotEmpty
        ? availableAirlines
        : {'Emirates', 'Qatar Airways', 'EgyptAir', 'Turkish Airlines', 'Saudia'};

    return Column(
      children: all.map((airline) {
        final isSelected = filters.selectedAirlines.contains(airline);
        return CheckboxListTile(
          value: isSelected,
          dense: true,
          contentPadding: EdgeInsets.zero,
          activeColor: AppColors.royalBlue,
          title: Text(
            airline,
            style: AppTextStyles.bodyMD.copyWith(
              color: isSelected ? AppColors.navyDark : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          onChanged: (val) {
            final set = Set<String>.from(filters.selectedAirlines);
            if (val == true) {
              set.add(airline);
            } else {
              set.remove(airline);
            }
            onFiltersChanged(filters.copyWith(selectedAirlines: set));
          },
        );
      }).toList(),
    );
  }

  Widget _buildTimeSlotChips({
    required FlightTimeSlot selected,
    required ValueChanged<FlightTimeSlot> onChanged,
    required bool isArabic,
  }) {
    final slots = [
      (FlightTimeSlot.any, isArabic ? 'أي وقت' : 'Any Time'),
      (FlightTimeSlot.earlyMorning, isArabic ? 'فجر (00-06)' : 'Night (00-06)'),
      (FlightTimeSlot.morning, isArabic ? 'صباح (06-12)' : 'Morning (06-12)'),
      (FlightTimeSlot.afternoon, isArabic ? 'ظهر (12-18)' : 'Afternoon (12-18)'),
      (FlightTimeSlot.evening, isArabic ? 'مساء (18-24)' : 'Evening (18-24)'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: slots.map((s) {
        final isSel = selected == s.$1;
        return FilterChip(
          label: Text(s.$2),
          selected: isSel,
          onSelected: (_) => onChanged(s.$1),
          selectedColor: AppColors.navy,
          checkmarkColor: AppColors.white,
          labelStyle: TextStyle(
            color: isSel ? AppColors.white : AppColors.navyDark,
            fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
            fontSize: 12,
          ),
          backgroundColor: AppColors.surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: isSel ? AppColors.navy : AppColors.borderLight),
          ),
        );
      }).toList(),
    );
  }
}

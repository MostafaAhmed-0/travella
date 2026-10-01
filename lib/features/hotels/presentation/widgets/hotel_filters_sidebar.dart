import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/localization/app_translations.dart';
import '../cubit/hotels_state.dart';

class HotelFiltersSidebar extends StatelessWidget {
  final HotelsState state;
  final ValueChanged<String> onDestinationChanged;
  final void Function(double min, double max) onPriceRangeChanged;
  final ValueChanged<int> onToggleStarRating;
  final ValueChanged<String> onToggleAmenity;
  final ValueChanged<HotelSortOption> onSortByChanged;
  final VoidCallback onResetFilters;
  final bool isCompact;

  const HotelFiltersSidebar({
    super.key,
    required this.state,
    required this.onDestinationChanged,
    required this.onPriceRangeChanged,
    required this.onToggleStarRating,
    required this.onToggleAmenity,
    required this.onSortByChanged,
    required this.onResetFilters,
    this.isCompact = false,
  });

  static const List<String> availableAmenities = [
    'Wi-Fi',
    'Swimming Pool',
    'Spa',
    'Breakfast',
    'Gym',
    'Parking',
    'All Inclusive',
  ];

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;
    final activeFilters = state.totalActiveFiltersCount;

    return Container(
      padding: EdgeInsets.all(isCompact ? 16 : 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: isCompact
            ? null
            : [
                BoxShadow(
                  color: AppColors.navyDark.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with Active Count & Reset
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.tune_rounded, color: AppColors.navyDark, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isArabic ? 'تصفية النتائج' : 'Filter Hotels',
                    style: AppTextStyles.h4.copyWith(
                      fontSize: 16,
                      color: AppColors.navyDark,
                    ),
                  ),
                  if (activeFilters > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.royalBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$activeFilters',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (activeFilters > 0)
                TextButton(
                  onPressed: onResetFilters,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    isArabic ? 'إعادة ضبط' : 'Reset All',
                    style: const TextStyle(
                      color: AppColors.royalBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: AppColors.borderLight, height: 1),
          const SizedBox(height: 18),

          // 1. Sort By
          _buildSectionHeader(isArabic ? 'ترتيب النتائج' : 'Sort By'),
          const SizedBox(height: 10),
          _buildSortDropdown(isArabic),
          const SizedBox(height: 20),
          const Divider(color: AppColors.borderLight, height: 1),
          const SizedBox(height: 20),

          // 2. Star Rating (3, 4, 5 Stars)
          _buildSectionHeader(isArabic ? 'تصنيف النجوم' : 'Star Rating'),
          const SizedBox(height: 10),
          _buildStarRatingFilters(isArabic),
          const SizedBox(height: 20),
          const Divider(color: AppColors.borderLight, height: 1),
          const SizedBox(height: 20),

          // 3. Price Range Slider
          _buildSectionHeader(isArabic ? 'نطاق السعر / ليلة' : 'Price Range / Night'),
          const SizedBox(height: 8),
          _buildPriceRangeSlider(isArabic),
          const SizedBox(height: 20),
          const Divider(color: AppColors.borderLight, height: 1),
          const SizedBox(height: 20),

          // 4. Amenities Checkboxes / Chips
          _buildSectionHeader(isArabic ? 'المرافق والخدمات' : 'Amenities'),
          const SizedBox(height: 10),
          _buildAmenitiesFilters(isArabic),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.labelLG.copyWith(
        color: AppColors.navyDark,
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
    );
  }

  Widget _buildSortDropdown(bool isArabic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<HotelSortOption>(
          value: state.sortBy,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.royalBlue),
          items: [
            DropdownMenuItem(
              value: HotelSortOption.recommended,
              child: Text(isArabic ? 'الموصى به' : 'Recommended', style: AppTextStyles.bodySM),
            ),
            DropdownMenuItem(
              value: HotelSortOption.priceLowToHigh,
              child: Text(isArabic ? 'السعر: من الأقل للأعلى' : 'Price: Low to High', style: AppTextStyles.bodySM),
            ),
            DropdownMenuItem(
              value: HotelSortOption.priceHighToLow,
              child: Text(isArabic ? 'السعر: من الأعلى للأقل' : 'Price: High to Low', style: AppTextStyles.bodySM),
            ),
            DropdownMenuItem(
              value: HotelSortOption.rating,
              child: Text(isArabic ? 'التقييم: الأعلى تقييماً' : 'Rating: Highest Rated', style: AppTextStyles.bodySM),
            ),
          ],
          onChanged: (val) {
            if (val != null) onSortByChanged(val);
          },
        ),
      ),
    );
  }

  Widget _buildStarRatingFilters(bool isArabic) {
    final starsOptions = [5, 4, 3];

    return Column(
      children: starsOptions.map((stars) {
        final isSelected = state.selectedStars.contains(stars);
        return InkWell(
          onTap: () => onToggleStarRating(stars),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: isSelected,
                    activeColor: AppColors.royalBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (_) => onToggleStarRating(stars),
                  ),
                ),
                const SizedBox(width: 10),
                Row(
                  children: List.generate(
                    stars,
                    (i) => const Icon(Icons.star_rounded, color: AppColors.gold, size: 16),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isArabic ? '$stars نجوم' : '$stars Stars',
                  style: AppTextStyles.bodySM.copyWith(
                    color: isSelected ? AppColors.navyDark : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceRangeSlider(bool isArabic) {
    final currentMin = (state.activeMinPrice ?? state.minPrice).clamp(state.minPrice, state.maxPrice);
    final currentMax = (state.activeMaxPrice ?? state.maxPrice).clamp(currentMin, state.maxPrice);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$${currentMin.toInt()}',
              style: AppTextStyles.labelMD.copyWith(
                color: AppColors.royalBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '\$${currentMax.toInt()}',
              style: AppTextStyles.labelMD.copyWith(
                color: AppColors.royalBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        if (state.maxPrice > state.minPrice)
          RangeSlider(
            values: RangeValues(currentMin, currentMax),
            min: state.minPrice,
            max: state.maxPrice,
            activeColor: AppColors.royalBlue,
            inactiveColor: AppColors.surfaceLight,
            onChanged: (values) {
              onPriceRangeChanged(values.start, values.end);
            },
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '\$${state.minPrice.toInt()}',
              style: AppTextStyles.labelMD.copyWith(color: AppColors.gray500),
            ),
          ),
      ],
    );
  }

  Widget _buildAmenitiesFilters(bool isArabic) {
    return Column(
      children: availableAmenities.map((amenity) {
        final isSelected = state.selectedAmenities.contains(amenity);
        final localizedAmenity = _localizeAmenity(amenity, isArabic);
        final icon = _amenityIcon(amenity);

        return InkWell(
          onTap: () => onToggleAmenity(amenity),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: isSelected,
                    activeColor: AppColors.royalBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (_) => onToggleAmenity(amenity),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(icon, size: 16, color: isSelected ? AppColors.royalBlue : AppColors.gray500),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    localizedAmenity,
                    style: AppTextStyles.bodySM.copyWith(
                      color: isSelected ? AppColors.navyDark : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _localizeAmenity(String amenity, bool isArabic) {
    if (!isArabic) return amenity;
    switch (amenity) {
      case 'Wi-Fi':
        return 'واي فاي مجاني';
      case 'Swimming Pool':
        return 'حمام سباحة';
      case 'Spa':
        return 'سبا ومساج';
      case 'Breakfast':
        return 'إفطار فاخر مشمول';
      case 'Gym':
        return 'نادي رياضي ومعدات';
      case 'Parking':
        return 'موقف سيارات مجاني';
      case 'All Inclusive':
        return 'شامل كلياً (All Inclusive)';
      default:
        return amenity;
    }
  }

  IconData _amenityIcon(String amenity) {
    switch (amenity) {
      case 'Wi-Fi':
        return Icons.wifi_rounded;
      case 'Swimming Pool':
        return Icons.pool_rounded;
      case 'Spa':
        return Icons.spa_rounded;
      case 'Breakfast':
        return Icons.restaurant_rounded;
      case 'Gym':
        return Icons.fitness_center_rounded;
      case 'Parking':
        return Icons.local_parking_rounded;
      case 'All Inclusive':
        return Icons.all_inclusive_rounded;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }
}

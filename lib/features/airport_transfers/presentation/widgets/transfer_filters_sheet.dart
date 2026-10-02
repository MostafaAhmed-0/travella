import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/localization/app_translations.dart';
import '../cubit/transfers_cubit.dart';
import '../cubit/transfers_state.dart';

class TransferFiltersSheet extends StatelessWidget {
  final TransfersState state;
  final TransfersCubit cubit;

  const TransferFiltersSheet({
    super.key,
    required this.state,
    required this.cubit,
  });

  static Future<void> show(BuildContext context, TransfersState state, TransfersCubit cubit) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TransferFiltersSheet(state: state, cubit: cubit),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune_rounded, color: AppColors.navyDark, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      isArabic ? 'تصفية وترتيب السيارات' : 'Filter & Sort Vehicles',
                      style: AppTextStyles.h6.copyWith(color: AppColors.navyDark),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    cubit.updateVehicleTypeFilter('all');
                    cubit.updateMaxPrice(500);
                    cubit.updateSortBy('price_asc');
                  },
                  child: Text(
                    isArabic ? 'إعادة ضبط' : 'Reset',
                    style: const TextStyle(color: AppColors.goldDark, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Filter Controls
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // 1. Vehicle Type
                Text(
                  isArabic ? 'نوع وفئة السيارة' : 'Vehicle Category',
                  style: AppTextStyles.bodyMD.copyWith(fontWeight: FontWeight.bold, color: AppColors.navyDark),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTypeChip(context, 'all', context.tr('transfers_filter_all')),
                    _buildTypeChip(context, 'sedan', context.tr('transfers_filter_sedan')),
                    _buildTypeChip(context, 'suv', context.tr('transfers_filter_suv')),
                    _buildTypeChip(context, 'van', context.tr('transfers_filter_van')),
                    _buildTypeChip(context, 'minibus', context.tr('transfers_filter_minibus')),
                  ],
                ),
                const SizedBox(height: 24),

                // 2. Sort By
                Text(
                  isArabic ? 'الترتيب حسب' : 'Sort By',
                  style: AppTextStyles.bodyMD.copyWith(fontWeight: FontWeight.bold, color: AppColors.navyDark),
                ),
                const SizedBox(height: 12),
                _buildSortOption(
                  context,
                  id: 'price_asc',
                  label: isArabic ? 'السعر: من الأقل للأعلى' : 'Price: Low to High',
                  icon: Icons.arrow_upward_rounded,
                ),
                _buildSortOption(
                  context,
                  id: 'price_desc',
                  label: isArabic ? 'السعر: من الأعلى للأقل' : 'Price: High to Low',
                  icon: Icons.arrow_downward_rounded,
                ),
                _buildSortOption(
                  context,
                  id: 'capacity_desc',
                  label: isArabic ? 'السعة: الأعلى استيعاباً' : 'Capacity: Largest Fleet',
                  icon: Icons.people_alt_rounded,
                ),
                const SizedBox(height: 24),

                // 3. Max Price Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isArabic ? 'الحد الأقصى للسعر' : 'Max Price Limit',
                      style: AppTextStyles.bodyMD.copyWith(fontWeight: FontWeight.bold, color: AppColors.navyDark),
                    ),
                    Text(
                      '\$${state.maxPrice.toStringAsFixed(0)}',
                      style: AppTextStyles.h6.copyWith(color: AppColors.goldDark, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Slider(
                  value: state.maxPrice,
                  min: 30,
                  max: 500,
                  divisions: 47,
                  activeColor: AppColors.gold,
                  inactiveColor: AppColors.gray200,
                  onChanged: (val) => cubit.updateMaxPrice(val),
                ),
              ],
            ),
          ),

          // Apply Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: TravellaButton(
              label: isArabic ? 'عرض النتائج' : 'Apply Filters',
              variant: TravellaButtonVariant.gold,
              size: TravellaButtonSize.lg,
              fullWidth: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(BuildContext context, String id, String label) {
    final isSelected = state.selectedVehicleType.toLowerCase() == id.toLowerCase();
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => cubit.updateVehicleTypeFilter(id),
      selectedColor: AppColors.gold.withValues(alpha: 0.2),
      checkmarkColor: AppColors.navyDark,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.navyDark : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? AppColors.gold : AppColors.gray300,
        ),
      ),
    );
  }

  Widget _buildSortOption(BuildContext context, {required String id, required String label, required IconData icon}) {
    final isSelected = state.sortBy == id;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: isSelected ? AppColors.goldDark : AppColors.gray500, size: 20),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.navyDark : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.gold, size: 20) : null,
      onTap: () => cubit.updateSortBy(id),
    );
  }
}

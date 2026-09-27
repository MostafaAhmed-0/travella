import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/admin_stats_cubit.dart';

/// 1. Bookings Over Time Chart
class BookingsOverTimeChart extends StatefulWidget {
  final List<MonthlyBookingData> data;

  const BookingsOverTimeChart({super.key, required this.data});

  @override
  State<BookingsOverTimeChart> createState() => _BookingsOverTimeChartState();
}

class _BookingsOverTimeChartState extends State<BookingsOverTimeChart> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return Container(
        height: 240,
        alignment: Alignment.center,
        child: const Text('No booking trends available.', style: TextStyle(color: AppColors.gray500)),
      );
    }

    final maxCount = widget.data.map((e) => e.count).reduce((a, b) => a > b ? a : b);
    final ceiling = maxCount > 0 ? (maxCount * 1.25).ceil() : 50;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bookings Over Time', style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('Monthly reservation volume and revenue trend', style: AppTextStyles.bodyXS.copyWith(color: AppColors.gray500)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.royalBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.royalBlue, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text('Reservations', style: AppTextStyles.caption.copyWith(color: AppColors.royalBlue, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(widget.data.length, (index) {
                final item = widget.data[index];
                final isHovered = _hoveredIndex == index;
                final heightFraction = (item.count / ceiling).clamp(0.08, 1.0);

                return Expanded(
                  child: MouseRegion(
                    onEnter: (_) => setState(() => _hoveredIndex = index),
                    onExit: (_) => setState(() => _hoveredIndex = null),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Tooltip on hover
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 150),
                          opacity: isHovered ? 1.0 : 0.0,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.navyDark,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${item.count} (${item.revenue.toInt()}\$)',
                              style: const TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        // Animated Bar
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: heightFraction,
                              child: Container(
                                width: 28,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: isHovered
                                        ? [AppColors.gold, AppColors.goldDark]
                                        : [AppColors.royalBlueLight, AppColors.navy],
                                  ),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                  boxShadow: isHovered
                                      ? [
                                          BoxShadow(
                                            color: AppColors.gold.withValues(alpha: 0.4),
                                            blurRadius: 10,
                                            offset: const Offset(0, -2),
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item.month,
                          style: AppTextStyles.caption.copyWith(
                            color: isHovered ? AppColors.navy : AppColors.gray600,
                            fontWeight: isHovered ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// 2. Popular Destinations Chart
class PopularDestinationsChart extends StatelessWidget {
  final List<DestinationPopularityData> data;

  const PopularDestinationsChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Popular Destinations', style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold)),
              const Icon(Icons.public_rounded, color: AppColors.gold, size: 20),
            ],
          ),
          const SizedBox(height: 4),
          Text('Top destinations booked by travelers', style: AppTextStyles.bodyXS.copyWith(color: AppColors.gray500)),
          const SizedBox(height: 20),
          if (data.isEmpty)
            Container(
              height: 160,
              alignment: Alignment.center,
              child: const Text('No destination data available.', style: TextStyle(color: AppColors.gray500)),
            )
          else
            Column(
              children: List.generate(data.length, (i) {
                final item = data[i];
                final colors = [
                  AppColors.gold,
                  AppColors.royalBlue,
                  AppColors.navyLight,
                  AppColors.coral,
                  AppColors.success,
                ];
                final color = colors[i % colors.length];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.destination,
                              style: AppTextStyles.bodySM.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            '${item.toursCount} Tours',
                            style: AppTextStyles.bodyXS.copyWith(color: AppColors.gray600),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${item.percentage.toStringAsFixed(0)}%',
                            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: color),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (item.percentage / 100).clamp(0.05, 1.0),
                          backgroundColor: AppColors.gray200,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}

/// 3. Tour Categories Breakdown Chart
class TourCategoriesChart extends StatelessWidget {
  final List<CategoryDistributionData> data;

  const TourCategoriesChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = {
      'Domestic Tours': AppColors.navy,
      'International Tours': AppColors.royalBlue,
      'Hajj Packages': AppColors.goldDark,
      'Umrah Packages': AppColors.gold,
    };

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tour Categories', style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold)),
              const Icon(Icons.pie_chart_rounded, color: AppColors.royalBlue, size: 20),
            ],
          ),
          const SizedBox(height: 4),
          Text('Inventory split across package types', style: AppTextStyles.bodyXS.copyWith(color: AppColors.gray500)),
          const SizedBox(height: 20),
          if (data.isEmpty)
            Container(
              height: 160,
              alignment: Alignment.center,
              child: const Text('No tour category data available.', style: TextStyle(color: AppColors.gray500)),
            )
          else ...[
            // Stacked distribution bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 14,
                child: Row(
                  children: data.map((item) {
                    final color = colors[item.category] ?? AppColors.royalBlue;
                    final flex = (item.percentage * 10).round().clamp(1, 1000);
                    return Expanded(
                      flex: flex,
                      child: Container(color: color),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Legend list
            Column(
              children: data.map((item) {
                final color = colors[item.category] ?? AppColors.royalBlue;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(item.category, style: AppTextStyles.bodySM),
                      ),
                      Text(
                        '${item.count} items',
                        style: AppTextStyles.bodyXS.copyWith(color: AppColors.gray500),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${item.percentage.toStringAsFixed(1)}%',
                        style: AppTextStyles.bodySM.copyWith(fontWeight: FontWeight.bold, color: AppColors.navyDark),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common_widgets.dart';

/// Admin dashboard placeholder
class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard', style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text('Welcome back, Admin', style: AppTextStyles.bodyMD),
          const SizedBox(height: 32),
          // Stats grid
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.6,
            children: const [
              _DashboardStatCard(
                title: 'Total Bookings',
                value: '248',
                icon: Icons.calendar_month_rounded,
                color: AppColors.royalBlue,
              ),
              _DashboardStatCard(
                title: 'Active Tours',
                value: '36',
                icon: Icons.flight_takeoff_rounded,
                color: AppColors.navy,
              ),
              _DashboardStatCard(
                title: 'Total Revenue',
                value: '\$128K',
                icon: Icons.attach_money_rounded,
                color: AppColors.gold,
              ),
              _DashboardStatCard(
                title: 'Happy Clients',
                value: '1,420',
                icon: Icons.people_alt_rounded,
                color: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 32),
          TravellaCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recent Bookings', style: AppTextStyles.h5),
                const SizedBox(height: 16),
                Text(
                  'Booking management will be implemented in a future phase.',
                  style: AppTextStyles.bodyMD,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _DashboardStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TravellaCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: AppTextStyles.h3),
                Text(title, style: AppTextStyles.bodyXS),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

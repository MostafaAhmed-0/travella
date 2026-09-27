import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routing/app_routes.dart';

/// Admin shell with sidebar navigation
class AdminShellPage extends StatelessWidget {
  final Widget child;
  const AdminShellPage({super.key, required this.child});

  static const _menuItems = [
    ('Dashboard', Icons.dashboard_rounded, AppRoutes.adminDashboardName),
    ('Tours', Icons.flight_rounded, AppRoutes.adminToursName),
    ('Destinations', Icons.place_rounded, AppRoutes.adminDestinationsName),
    ('Hotels', Icons.hotel_rounded, AppRoutes.adminHotelsName),
    ('Visa Services', Icons.article_rounded, AppRoutes.adminVisaName),
    ('Gallery', Icons.photo_library_rounded, AppRoutes.adminGalleryName),
    ('Bookings', Icons.calendar_month_rounded, AppRoutes.adminBookingsName),
    ('Blog', Icons.edit_note_rounded, AppRoutes.adminBlogName),
    ('Testimonials', Icons.reviews_rounded, AppRoutes.adminTestimonialsName),
    ('Settings', Icons.settings_rounded, AppRoutes.adminSettingsName),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 240,
            color: AppColors.navy,
            child: Column(
              children: [
                // Brand
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.flight_takeoff_rounded,
                          color: AppColors.navy,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Admin Panel',
                        style: AppTextStyles.h6.copyWith(color: AppColors.white),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.gray700, height: 1),
                const SizedBox(height: 16),
                // Nav items
                Expanded(
                  child: ListView.builder(
                    itemCount: _menuItems.length,
                    itemBuilder: (context, i) {
                      final item = _menuItems[i];
                      return _AdminNavItem(
                        label: item.$1,
                        icon: item.$2,
                        routeName: item.$3,
                      );
                    },
                  ),
                ),
                const Divider(color: AppColors.gray700, height: 1),
                // View site link
                ListTile(
                  leading: const Icon(Icons.open_in_new_rounded, color: AppColors.gold, size: 20),
                  title: Text(
                    'View Site',
                    style: AppTextStyles.bodySM.copyWith(color: AppColors.gold),
                  ),
                  onTap: () => context.goNamed(AppRoutes.homeName),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          // Main content
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _AdminNavItem extends StatefulWidget {
  final String label;
  final IconData icon;
  final String routeName;

  const _AdminNavItem({
    required this.label,
    required this.icon,
    required this.routeName,
  });

  @override
  State<_AdminNavItem> createState() => _AdminNavItemState();
}

class _AdminNavItemState extends State<_AdminNavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).name;
    final isActive = currentRoute == widget.routeName;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.royalBlueFaded
              : _hovered
                  ? AppColors.white.withValues(alpha: 0.05)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isActive
              ? Border.all(color: AppColors.royalBlue.withValues(alpha: 0.3))
              : null,
        ),
        child: ListTile(
          dense: true,
          leading: Icon(
            widget.icon,
            color: isActive
                ? AppColors.gold
                : AppColors.gray400,
            size: 20,
          ),
          title: Text(
            widget.label,
            style: AppTextStyles.bodySM.copyWith(
              color: isActive ? AppColors.white : AppColors.gray300,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          onTap: () => context.goNamed(widget.routeName),
        ),
      ),
    );
  }
}

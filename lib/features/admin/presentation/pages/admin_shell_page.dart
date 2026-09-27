import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

/// Admin shell with sidebar navigation, user role badge, and sign-out functionality
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
    final authState = context.watch<AuthCubit>().state;
    final profile = authState is Authenticated ? authState.profile : null;

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: AppColors.navy,
            child: Column(
              children: [
                // Brand
                Container(
                  padding: const EdgeInsets.all(20),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Travella Admin',
                            style: AppTextStyles.h6.copyWith(color: AppColors.white),
                          ),
                          Text(
                            'Supabase Backend',
                            style: AppTextStyles.caption.copyWith(color: AppColors.gold, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.gray700, height: 1),

                // Authenticated Profile Card
                if (profile != null)
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.navyMedium,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.gold.withValues(alpha: 0.2),
                          child: Text(
                            (profile.fullName?.isNotEmpty == true
                                    ? profile.fullName![0]
                                    : profile.email[0])
                                .toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.fullName ?? profile.email.split('@').first,
                                style: AppTextStyles.bodySM.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: profile.isAdmin
                                          ? AppColors.gold.withValues(alpha: 0.2)
                                          : AppColors.royalBlue.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      profile.role.toDbString().toUpperCase(),
                                      style: TextStyle(
                                        color: profile.isAdmin ? AppColors.gold : AppColors.royalBlueLight,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

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

                // View site & Sign out actions
                ListTile(
                  leading: const Icon(Icons.open_in_new_rounded, color: AppColors.gray300, size: 20),
                  title: Text(
                    'View Website',
                    style: AppTextStyles.bodySM.copyWith(color: AppColors.gray300),
                  ),
                  onTap: () => context.goNamed(AppRoutes.homeName),
                ),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                  title: Text(
                    'Sign Out',
                    style: AppTextStyles.bodySM.copyWith(color: AppColors.error),
                  ),
                  onTap: () async {
                    await context.read<AuthCubit>().logout();
                    if (context.mounted) {
                      context.goNamed(AppRoutes.loginName);
                    }
                  },
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

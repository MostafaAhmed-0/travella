import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import 'admin_dialogs.dart';

class AdminSidebar extends StatelessWidget {
  final VoidCallback? onItemTapped;

  const AdminSidebar({super.key, this.onItemTapped});

  static const _menuItems = [
    ('Dashboard', Icons.dashboard_rounded, AppRoutes.adminDashboardName, null),
    ('Tours', Icons.flight_takeoff_rounded, AppRoutes.adminToursName, null),
    ('Destinations', Icons.place_rounded, AppRoutes.adminDestinationsName, null),
    ('Hotels', Icons.hotel_rounded, AppRoutes.adminHotelsName, null),
    ('Visa Services', Icons.article_rounded, AppRoutes.adminVisaName, null),
    ('Hajj & Umrah', Icons.mosque_rounded, AppRoutes.adminHajjUmrahName, null),
    ('Gallery', Icons.photo_library_rounded, AppRoutes.adminGalleryName, null),
    ('Blogs', Icons.edit_note_rounded, AppRoutes.adminBlogName, null),
    ('Testimonials', Icons.reviews_rounded, AppRoutes.adminTestimonialsName, null),
    ('Partners', Icons.handshake_rounded, AppRoutes.adminPartnersName, null),
    ('Bookings', Icons.calendar_month_rounded, AppRoutes.adminBookingsName, 'New'),
    ('Customers', Icons.people_alt_rounded, AppRoutes.adminCustomersName, null),
    ('Settings', Icons.settings_rounded, AppRoutes.adminSettingsName, null),
  ];

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final profile = authState is Authenticated ? authState.profile : null;

    return Container(
      width: 260,
      color: AppColors.navy,
      child: Column(
        children: [
          // Logo & Branding
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.flight_takeoff_rounded,
                    color: AppColors.navy,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TRAVELLA',
                      style: AppTextStyles.h6.copyWith(
                        color: AppColors.white,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'ADMIN DASHBOARD',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gold,
                        fontSize: 9,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.gray700, height: 1),

          // Authenticated User Pill
          if (profile != null)
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.navyMedium,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.gold.withValues(alpha: 0.2),
                    child: Text(
                      (profile.fullName?.isNotEmpty == true
                              ? profile.fullName![0]
                              : profile.email[0])
                          .toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
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
                        Text(
                          profile.role.toDbString().toUpperCase(),
                          style: TextStyle(
                            color: profile.isAdmin ? AppColors.gold : AppColors.royalBlueLight,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Nav Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: _menuItems.length,
              itemBuilder: (context, i) {
                final item = _menuItems[i];
                return _SidebarNavItem(
                  label: item.$1,
                  icon: item.$2,
                  routeName: item.$3,
                  badge: item.$4,
                  onTap: onItemTapped,
                );
              },
            ),
          ),

          const Divider(color: AppColors.gray700, height: 1),

          // Bottom Quick Actions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.gray300,
                      side: BorderSide(color: AppColors.white.withValues(alpha: 0.15)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => context.goNamed(AppRoutes.homeName),
                    icon: const Icon(Icons.open_in_new_rounded, size: 14),
                    label: const Text('Website', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.error.withValues(alpha: 0.15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  tooltip: 'Sign Out',
                  icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                  onPressed: () async {
                    final confirm = await showAdminConfirmDialog(
                      context: context,
                      title: 'Sign Out',
                      message: 'Are you sure you want to log out of the Admin Dashboard?',
                      confirmLabel: 'Log Out',
                      icon: Icons.logout_rounded,
                    );
                    if (confirm == true && context.mounted) {
                      await context.read<AuthCubit>().logout();
                      if (context.mounted) {
                        context.goNamed(AppRoutes.loginName);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarNavItem extends StatefulWidget {
  final String label;
  final IconData icon;
  final String routeName;
  final String? badge;
  final VoidCallback? onTap;

  const _SidebarNavItem({
    required this.label,
    required this.icon,
    required this.routeName,
    this.badge,
    this.onTap,
  });

  @override
  State<_SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<_SidebarNavItem> {
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
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.royalBlueFaded
              : _hovered
                  ? AppColors.white.withValues(alpha: 0.06)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isActive
              ? Border.all(color: AppColors.gold.withValues(alpha: 0.4))
              : null,
        ),
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          leading: Icon(
            widget.icon,
            color: isActive ? AppColors.gold : AppColors.gray400,
            size: 20,
          ),
          title: Text(
            widget.label,
            style: AppTextStyles.bodySM.copyWith(
              color: isActive ? AppColors.white : AppColors.gray300,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          trailing: widget.badge != null
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.coral,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.badge!,
                    style: const TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                )
              : null,
          onTap: () {
            widget.onTap?.call();
            context.goNamed(widget.routeName);
          },
        ),
      ),
    );
  }
}

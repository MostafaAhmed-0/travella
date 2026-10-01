import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/localization/app_locales.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import 'admin_dialogs.dart';

class AdminTopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onToggleMenu;

  const AdminTopBar({
    super.key,
    required this.title,
    this.onToggleMenu,
  });

  void _showProfileDialog(BuildContext context, Authenticated authState) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.gold.withValues(alpha: 0.2),
                child: Text(
                  (authState.profile.fullName?.isNotEmpty == true
                          ? authState.profile.fullName![0]
                          : authState.profile.email[0])
                      .toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                authState.profile.fullName ?? 'Travella Administrator',
                style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                authState.profile.email,
                style: AppTextStyles.bodySM.copyWith(color: AppColors.gray600),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: authState.isAdmin
                      ? AppColors.gold.withValues(alpha: 0.2)
                      : AppColors.royalBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      size: 14,
                      color: authState.isAdmin ? AppColors.goldDark : AppColors.royalBlue,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      authState.profile.role.toDbString().toUpperCase(),
                      style: TextStyle(
                        color: authState.isAdmin ? AppColors.goldDark : AppColors.royalBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              ListTile(
                dense: true,
                leading: const Icon(Icons.security_rounded, color: AppColors.royalBlue),
                title: const Text('Access Level'),
                trailing: Text(
                  authState.isAdmin ? 'Full CMS Admin' : 'Staff Editor',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.cloud_done_rounded, color: AppColors.success),
                title: const Text('Backend Provider'),
                trailing: const Text('Supabase PostgreSQL', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.white,
                      ),
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        final confirm = await showAdminConfirmDialog(
                          context: context,
                          title: 'Sign Out Confirmation',
                          message: 'Are you sure you want to end your administrative session?',
                          confirmLabel: 'Sign Out',
                          icon: Icons.logout_rounded,
                        );
                        if (confirm == true && context.mounted) {
                          await context.read<AuthCubit>().logout();
                          if (context.mounted) {
                            context.goNamed(AppRoutes.loginName);
                          }
                        }
                      },
                      icon: const Icon(Icons.logout_rounded, size: 16),
                      label: const Text('Sign Out'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationsMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Admin Notifications', style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.royalBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('3 New', style: TextStyle(color: AppColors.royalBlue, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              _NotificationTile(
                icon: Icons.calendar_month_rounded,
                iconColor: AppColors.royalBlue,
                title: 'New Booking Received',
                subtitle: 'Ahmed Mansour booked Hurghada Red Sea Adventure',
                time: '10m ago',
              ),
              _NotificationTile(
                icon: Icons.star_rate_rounded,
                iconColor: AppColors.gold,
                title: '5-Star Review Added',
                subtitle: 'Fatima Al-Zahraa posted a testimonial for VIP Umrah',
                time: '1h ago',
              ),
              _NotificationTile(
                icon: Icons.sync_rounded,
                iconColor: AppColors.success,
                title: 'Database Synchronized',
                subtitle: 'Supabase real-time replication active',
                time: '3h ago',
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Dismiss All'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final profile = authState is Authenticated ? authState.profile : null;
    final isMobile = AppBreakpoints.isMobile(context);

    return Container(
      height: 70,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.gray200)),
      ),
      child: Row(
        children: [
          // Mobile menu trigger
          if (onToggleMenu != null)
            IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppColors.navy),
              onPressed: onToggleMenu,
              tooltip: 'Toggle Navigation',
            ),

          // Title & Breadcrumb
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: (isMobile ? AppTextStyles.labelLG : AppTextStyles.h5).copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.navyDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!isMobile)
                  Text(
                    'Travella CMS / $title',
                    style: AppTextStyles.caption.copyWith(color: AppColors.gray500, fontSize: 11),
                  ),
              ],
            ),
          ),

          // View Public Website Link
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.open_in_new_rounded, size: 20, color: AppColors.gray600),
              tooltip: 'Live Website',
              onPressed: () => context.goNamed(AppRoutes.homeName),
            )
          else
            TextButton.icon(
              onPressed: () => context.goNamed(AppRoutes.homeName),
              icon: const Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.gray600),
              label: const Text('Live Website', style: TextStyle(color: AppColors.gray700, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          const SizedBox(width: 4),

          // Language Switcher
          const LanguageSwitchButton(isDark: false),
          const SizedBox(width: 4),

          // Notifications Button
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none_rounded, color: AppColors.navy),
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.coral,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            tooltip: 'Notifications',
            onPressed: () => _showNotificationsMenu(context),
          ),
          const SizedBox(width: 4),

          // Admin User Profile & Sign Out
          if (authState is Authenticated)
            InkWell(
              onTap: () => _showProfileDialog(context, authState),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.gold.withValues(alpha: 0.2),
                      child: Text(
                        (profile?.fullName?.isNotEmpty == true
                                ? profile!.fullName![0]
                                : (profile?.email[0] ?? 'A'))
                            .toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (!isMobile) ...[
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            profile?.fullName ?? profile?.email.split('@').first ?? 'Admin',
                            style: AppTextStyles.bodySM.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: authState.isAdmin
                                  ? AppColors.gold.withValues(alpha: 0.2)
                                  : AppColors.royalBlue.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              profile?.role.toDbString().toUpperCase() ?? 'STAFF',
                              style: TextStyle(
                                color: authState.isAdmin ? AppColors.goldDark : AppColors.royalBlue,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_drop_down, color: AppColors.gray500),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;

  const _NotificationTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodySM.copyWith(fontWeight: FontWeight.bold)),
                Text(subtitle, style: AppTextStyles.bodyXS.copyWith(color: AppColors.gray600)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(time, style: AppTextStyles.caption.copyWith(color: AppColors.gray400, fontSize: 10)),
        ],
      ),
    );
  }
}

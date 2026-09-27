import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/common_widgets.dart';

/// Shared App Navbar for all public pages
class AppNavbar extends StatefulWidget {
  final String currentRoute;

  const AppNavbar({super.key, required this.currentRoute});

  @override
  State<AppNavbar> createState() => _AppNavbarState();
}

class _AppNavbarState extends State<AppNavbar> {
  bool _mobileMenuOpen = false;

  static const _navItems = [
    ('Home', AppRoutes.home, AppRoutes.homeName),
    ('Destinations', AppRoutes.destinations, AppRoutes.destinationsName),
    ('Domestic Tours', AppRoutes.domesticTours, AppRoutes.domesticToursName),
    ('International', AppRoutes.internationalTours, AppRoutes.internationalToursName),
    ('Visa Services', AppRoutes.visaServices, AppRoutes.visaServicesName),
    ('Hotels', AppRoutes.hotels, AppRoutes.hotelsName),
    ('Hajj & Umrah', AppRoutes.hajjUmrah, AppRoutes.hajjUmrahName),
    ('Gallery', AppRoutes.gallery, AppRoutes.galleryName),
    ('Blog', AppRoutes.blog, AppRoutes.blogName),
    ('Contact', AppRoutes.contact, AppRoutes.contactName),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 1024;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: AppColors.surfaceNavbar,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      height: 72,
      child: Row(
        children: [
          // Logo
          GestureDetector(
            onTap: () => context.goNamed(AppRoutes.homeName),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.flight_takeoff_rounded,
                    color: AppColors.navy,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TRAVELLA',
                      style: AppTextStyles.h6.copyWith(
                        color: AppColors.white,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'TOUR & TRAVEL',
                      style: AppTextStyles.labelSM.copyWith(
                        color: AppColors.gold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          if (!isMobile) ...[
            // Desktop nav items
            ..._navItems.take(7).map((item) => _NavItem(
                  label: item.$1,
                  isActive: widget.currentRoute == item.$2,
                  onTap: () => context.goNamed(item.$3),
                )),
            const SizedBox(width: 16),
            TravellaButton(
              label: 'Book Now',
              variant: TravellaButtonVariant.gold,
              size: TravellaButtonSize.sm,
              leadingIcon: Icons.calendar_month_rounded,
              onPressed: () => context.goNamed(AppRoutes.bookingName),
            ),
          ] else ...[
            // Mobile menu toggle
            IconButton(
              onPressed: () => setState(() => _mobileMenuOpen = !_mobileMenuOpen),
              icon: Icon(
                _mobileMenuOpen ? Icons.close_rounded : Icons.menu_rounded,
                color: AppColors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: AppTextStyles.navItem.copyWith(
                  color: widget.isActive || _hovered
                      ? AppColors.gold
                      : AppColors.textOnDark,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 2,
                width: widget.isActive || _hovered ? 20 : 0,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

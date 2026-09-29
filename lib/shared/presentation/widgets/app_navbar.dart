import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/common_widgets.dart';

/// Shared App Navbar for all public pages with responsive mobile drawer overlay
class AppNavbar extends StatefulWidget {
  final String currentRoute;

  const AppNavbar({super.key, required this.currentRoute});

  @override
  State<AppNavbar> createState() => _AppNavbarState();
}

class _AppNavbarState extends State<AppNavbar> {
  static const _navItems = [
    ('Home', AppRoutes.home, AppRoutes.homeName, Icons.home_rounded),
    ('Destinations', AppRoutes.destinations, AppRoutes.destinationsName, Icons.place_rounded),
    ('Domestic Tours', AppRoutes.domesticTours, AppRoutes.domesticToursName, Icons.landscape_rounded),
    ('International', AppRoutes.internationalTours, AppRoutes.internationalToursName, Icons.public_rounded),
    ('Visa Services', AppRoutes.visaServices, AppRoutes.visaServicesName, Icons.assignment_outlined),
    ('Hotels', AppRoutes.hotels, AppRoutes.hotelsName, Icons.hotel_rounded),
    ('Hajj & Umrah', AppRoutes.hajjUmrah, AppRoutes.hajjUmrahName, Icons.mosque_rounded),
    ('Gallery', AppRoutes.gallery, AppRoutes.galleryName, Icons.photo_library_outlined),
    ('Blog', AppRoutes.blog, AppRoutes.blogName, Icons.article_outlined),
    ('Contact', AppRoutes.contact, AppRoutes.contactName, Icons.contact_support_outlined),
  ];

  void _openMobileDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _MobileNavDrawer(
        currentRoute: widget.currentRoute,
        navItems: _navItems,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobileOrTablet = screenWidth < 1140;

    return Container(
      color: AppColors.surfaceNavbar,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth < 600 ? 16 : 28,
        vertical: 0,
      ),
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
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.flight_takeoff_rounded,
                    color: AppColors.navyDark,
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
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'TOUR & TRAVEL',
                      style: AppTextStyles.labelSM.copyWith(
                        color: AppColors.gold,
                        letterSpacing: 1.5,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),

          if (!isMobileOrTablet) ...[
            // Desktop nav items
            ..._navItems.take(8).map((item) => _NavItem(
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
            // Mobile/Tablet Quick Book & Menu Toggle
            TravellaButton(
              label: 'Book Now',
              variant: TravellaButtonVariant.gold,
              size: TravellaButtonSize.sm,
              onPressed: () => context.goNamed(AppRoutes.bookingName),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _openMobileDrawer(context),
              icon: const Icon(
                Icons.menu_rounded,
                color: AppColors.white,
                size: 28,
              ),
              tooltip: 'Navigation Menu',
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: AppTextStyles.navItem.copyWith(
                  color: widget.isActive || _hovered
                      ? AppColors.gold
                      : AppColors.textOnDark,
                  fontSize: 13,
                  fontWeight: widget.isActive ? FontWeight.bold : FontWeight.w500,
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

class _MobileNavDrawer extends StatelessWidget {
  final String currentRoute;
  final List<(String, String, String, IconData)> navItems;

  const _MobileNavDrawer({
    required this.currentRoute,
    required this.navItems,
  });

  Future<void> _openWhatsApp() async {
    final uri = Uri.parse('https://wa.me/201000000000?text=Hello%20Travella!');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    return Container(
      height: height * 0.82,
      decoration: const BoxDecoration(
        color: AppColors.navyDark,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Drawer handle & Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.flight_takeoff_rounded,
                          color: AppColors.navyDark,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'TRAVELLA MENU',
                        style: AppTextStyles.h6.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: AppColors.white),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.navyMedium, height: 1),

            // Scrollable Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  ...navItems.map((item) {
                    final isCurrent = currentRoute == item.$2;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: ListTile(
                        dense: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        tileColor: isCurrent
                            ? AppColors.royalBlue.withValues(alpha: 0.3)
                            : Colors.transparent,
                        leading: Icon(
                          item.$4,
                          color: isCurrent ? AppColors.gold : AppColors.gray400,
                          size: 20,
                        ),
                        title: Text(
                          item.$1,
                          style: TextStyle(
                            color: isCurrent ? AppColors.gold : AppColors.white,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: isCurrent ? AppColors.gold : AppColors.gray600,
                          size: 18,
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          context.goNamed(item.$3);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Footer Quick Action Buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TravellaButton(
                    label: 'Book a Tour / Custom Itinerary',
                    variant: TravellaButtonVariant.gold,
                    fullWidth: true,
                    leadingIcon: Icons.calendar_month_rounded,
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.goNamed(AppRoutes.bookingName);
                    },
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _openWhatsApp,
                    icon: const Icon(Icons.chat_bubble_rounded, color: Color(0xFF25D366), size: 18),
                    label: const Text(
                      'Chat on WhatsApp',
                      style: TextStyle(color: Color(0xFF25D366), fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 46),
                      side: BorderSide(color: const Color(0xFF25D366).withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

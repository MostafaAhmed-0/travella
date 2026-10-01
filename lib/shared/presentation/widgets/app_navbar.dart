import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/localization/app_locales.dart';
import '../../../../core/localization/app_translations.dart';

/// Shared App Navbar for all public pages with bilingual support & responsive drawer
class AppNavbar extends StatefulWidget {
  final String currentRoute;

  const AppNavbar({super.key, required this.currentRoute});

  @override
  State<AppNavbar> createState() => _AppNavbarState();
}

class _AppNavbarState extends State<AppNavbar> {
  void _openMobileDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _MobileNavDrawer(
        currentRoute: widget.currentRoute,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobileOrTablet = screenWidth < 1200;

    final navItems = [
      (context.tr('nav_home'), AppRoutes.home, AppRoutes.homeName, Icons.home_rounded),
      (context.tr('nav_flights'), AppRoutes.flights, AppRoutes.flightsName, Icons.flight_takeoff_rounded),
      (context.tr('nav_destinations'), AppRoutes.destinations, AppRoutes.destinationsName, Icons.place_rounded),
      (context.tr('nav_domestic_tours'), AppRoutes.domesticTours, AppRoutes.domesticToursName, Icons.landscape_rounded),
      (context.tr('nav_international_tours'), AppRoutes.internationalTours, AppRoutes.internationalToursName, Icons.public_rounded),
      (context.tr('nav_visa_services'), AppRoutes.visaServices, AppRoutes.visaServicesName, Icons.assignment_outlined),
      (context.tr('nav_hotels'), AppRoutes.hotels, AppRoutes.hotelsName, Icons.hotel_rounded),
      (context.tr('nav_hajj_umrah'), AppRoutes.hajjUmrah, AppRoutes.hajjUmrahName, Icons.mosque_rounded),
      (context.tr('nav_gallery'), AppRoutes.gallery, AppRoutes.galleryName, Icons.photo_library_outlined),
      (context.tr('nav_blog'), AppRoutes.blog, AppRoutes.blogName, Icons.article_outlined),
      (context.tr('nav_contact'), AppRoutes.contact, AppRoutes.contactName, Icons.contact_support_outlined),
    ];

    final isVerySmallMobile = screenWidth < 400;

    return Container(
      color: AppColors.surfaceNavbar,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth < 600 ? (screenWidth < 360 ? 10 : 16) : 28,
        vertical: 0,
      ),
      height: 72,
      child: Row(
        children: [
          // Logo
          GestureDetector(
            onTap: () => context.goNamed(AppRoutes.homeName),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: screenWidth < 360 ? 32 : 38,
                  height: screenWidth < 360 ? 32 : 38,
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
                  child: Icon(
                    Icons.flight_takeoff_rounded,
                    color: AppColors.navyDark,
                    size: screenWidth < 360 ? 18 : 22,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('app_name'),
                      style: AppTextStyles.h6.copyWith(
                        color: AppColors.white,
                        letterSpacing: context.isArabic ? 0.0 : 1.5,
                        fontWeight: FontWeight.w800,
                        fontSize: screenWidth < 360 ? 14 : 16,
                      ),
                    ),
                    Text(
                      context.tr('app_tagline'),
                      style: AppTextStyles.labelSM.copyWith(
                        color: AppColors.gold,
                        letterSpacing: context.isArabic ? 0.0 : 1.5,
                        fontSize: screenWidth < 360 ? 8 : 9,
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
            ...navItems.take(8).map((item) => _NavItem(
                  label: item.$1,
                  isActive: widget.currentRoute == item.$2,
                  onTap: () => context.goNamed(item.$3),
                )),
            const SizedBox(width: 12),
            // Language Switcher Button
            const LanguageSwitchButton(isDark: true),
            const SizedBox(width: 12),
            // Book Now CTA
            TravellaButton(
              label: context.tr('nav_book_now'),
              variant: TravellaButtonVariant.gold,
              size: TravellaButtonSize.sm,
              leadingIcon: Icons.calendar_month_rounded,
              onPressed: () => context.goNamed(AppRoutes.bookingName),
            ),
          ] else ...[
            // Mobile/Tablet Quick Actions: Language Switcher + Book Now + Menu Icon
            const LanguageSwitchButton(isDark: true, isCompact: true),
            if (!isVerySmallMobile) ...[
              const SizedBox(width: 8),
              TravellaButton(
                label: context.tr('nav_book_now'),
                variant: TravellaButtonVariant.gold,
                size: TravellaButtonSize.sm,
                onPressed: () => context.goNamed(AppRoutes.bookingName),
              ),
            ],
            const SizedBox(width: 4),
            IconButton(
              onPressed: () => _openMobileDrawer(context),
              icon: const Icon(
                Icons.menu_rounded,
                color: AppColors.white,
                size: 26,
              ),
              tooltip: context.tr('nav_menu'),
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

  const _MobileNavDrawer({
    required this.currentRoute,
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

    final navItems = [
      (context.tr('nav_home'), AppRoutes.home, AppRoutes.homeName, Icons.home_rounded),
      (context.tr('nav_flights'), AppRoutes.flights, AppRoutes.flightsName, Icons.flight_takeoff_rounded),
      (context.tr('nav_destinations'), AppRoutes.destinations, AppRoutes.destinationsName, Icons.place_rounded),
      (context.tr('nav_domestic_tours'), AppRoutes.domesticTours, AppRoutes.domesticToursName, Icons.landscape_rounded),
      (context.tr('nav_international_tours'), AppRoutes.internationalTours, AppRoutes.internationalToursName, Icons.public_rounded),
      (context.tr('nav_visa_services'), AppRoutes.visaServices, AppRoutes.visaServicesName, Icons.assignment_outlined),
      (context.tr('nav_hotels'), AppRoutes.hotels, AppRoutes.hotelsName, Icons.hotel_rounded),
      (context.tr('nav_hajj_umrah'), AppRoutes.hajjUmrah, AppRoutes.hajjUmrahName, Icons.mosque_rounded),
      (context.tr('nav_gallery'), AppRoutes.gallery, AppRoutes.galleryName, Icons.photo_library_outlined),
      (context.tr('nav_blog'), AppRoutes.blog, AppRoutes.blogName, Icons.article_outlined),
      (context.tr('nav_contact'), AppRoutes.contact, AppRoutes.contactName, Icons.contact_support_outlined),
    ];

    return Container(
      height: height * 0.84,
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
                        '${context.tr('app_name')} ${context.tr('nav_menu')}',
                        style: AppTextStyles.h6.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const LanguageSwitchButton(isDark: true, isCompact: true),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, color: AppColors.white),
                      ),
                    ],
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
                    label: context.tr('nav_book_now'),
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
                    label: Text(
                      context.tr('whatsapp_btn_label'),
                      style: const TextStyle(color: Color(0xFF25D366), fontWeight: FontWeight.bold),
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

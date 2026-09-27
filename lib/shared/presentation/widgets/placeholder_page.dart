import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/animations/animation_widgets.dart';
import 'app_navbar.dart';
import 'app_footer.dart';

/// Reusable placeholder page for features not yet implemented
class PlaceholderPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String currentRoute;

  const PlaceholderPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final hPad = AppBreakpoints.horizontalPadding(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          AppNavbar(currentRoute: currentRoute),
          // Page header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 80),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.navyDark, AppColors.navy],
              ),
            ),
            child: MaxWidthContainer(
              child: SlideInOnScroll(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionBadge(
                      text: 'Coming Soon',
                      color: AppColors.gold.withValues(alpha: 0.15),
                      textColor: AppColors.gold,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: AppTextStyles.h1.copyWith(color: AppColors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyLG.copyWith(
                        color: AppColors.textOnDarkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Body placeholder
          Expanded(
            child: Center(
              child: ScaleInOnScroll(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.royalBlueFaded,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 48, color: AppColors.royalBlue),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'This page is coming soon',
                      style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We\'re building something amazing. Check back soon!',
                      style: AppTextStyles.bodyMD,
                    ),
                    const SizedBox(height: 32),
                    TravellaButton(
                      label: 'Back to Home',
                      leadingIcon: Icons.arrow_back_rounded,
                      onPressed: () => context.goNamed(AppRoutes.homeName),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const AppFooter(),
        ],
      ),
    );
  }
}

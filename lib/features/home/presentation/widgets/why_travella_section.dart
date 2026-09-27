import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/animations/animation_widgets.dart';

class WhyTravellaSection extends StatelessWidget {
  const WhyTravellaSection({super.key});

  static const _features = [
    (
      icon: Icons.flash_on_rounded,
      title: 'Easy Instant Booking',
      desc: 'Seamless end-to-end digital reservation with transparent pricing and no hidden costs.',
      accent: AppColors.royalBlue,
    ),
    (
      icon: Icons.verified_user_rounded,
      title: 'Visa Assistance',
      desc: 'Full consular documentation support, biometric appointment booking, and 98% approval rate.',
      accent: AppColors.gold,
    ),
    (
      icon: Icons.hotel_rounded,
      title: 'Premium 5-Star Hotels',
      desc: 'Handpicked luxury resorts and boutique hotels with VIP room upgrades and exclusive perks.',
      accent: AppColors.royalBlue,
    ),
    (
      icon: Icons.tune_rounded,
      title: 'Customized Itineraries',
      desc: 'Tailor-made itineraries crafted by personal travel advisors to match your exact desires.',
      accent: AppColors.gold,
    ),
    (
      icon: Icons.support_agent_rounded,
      title: '24/7 VIP Concierge',
      desc: 'Round-the-clock dedicated assistance before, during, and after your trip wherever you are.',
      accent: AppColors.royalBlue,
    ),
    (
      icon: Icons.workspace_premium_rounded,
      title: 'Certified Travel Experts',
      desc: 'Over 12 years of tourism excellence, IATA certification, and global destination knowledge.',
      accent: AppColors.gold,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final hPad = AppBreakpoints.horizontalPadding(context);
    final isMobile = AppBreakpoints.isMobile(context);
    final columns = isMobile ? 1 : (AppBreakpoints.isTablet(context) ? 2 : 3);

    return Container(
      color: AppColors.surfaceLight,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: isMobile ? 60 : 100),
      child: MaxWidthContainer(
        child: Column(
          children: [
            SlideInOnScroll(
              child: const SectionHeader(
                badge: 'The Travella Standard',
                title: 'Why Travel With Travella?',
                subtitle: 'We combine luxury aesthetics with flawless logistics to deliver unforgettable world-class journeys.',
                alignment: CrossAxisAlignment.center,
              ),
            ),
            const SizedBox(height: 56),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisExtent: isMobile ? 220 : 250,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
              ),
              itemCount: _features.length,
              itemBuilder: (context, i) {
                final item = _features[i];
                return ScaleInOnScroll(
                  delay: Duration(milliseconds: i * 80),
                  child: _FeatureCard(
                    icon: item.icon,
                    title: item.title,
                    description: item.desc,
                    accentColor: item.accent,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0.0, _isHovered ? -8.0 : 0.0, 0.0),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered
                ? widget.accentColor.withValues(alpha: 0.6)
                : AppColors.borderLight,
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? widget.accentColor.withValues(alpha: 0.14)
                  : AppColors.navy.withValues(alpha: 0.04),
              blurRadius: _isHovered ? 32 : 16,
              offset: Offset(0, _isHovered ? 16 : 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: _isHovered ? widget.accentColor : widget.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: widget.accentColor.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        )
                      ]
                    : null,
              ),
              child: Icon(
                widget.icon,
                color: _isHovered ? AppColors.white : widget.accentColor,
                size: 26,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.title,
              style: AppTextStyles.h5.copyWith(color: AppColors.navyDark),
            ),
            const SizedBox(height: 10),
            Text(
              widget.description,
              style: AppTextStyles.bodyMD.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/animations/animation_widgets.dart';
import '../../../../core/localization/app_translations.dart';

class WhyTravellaSection extends StatelessWidget {
  const WhyTravellaSection({super.key});

  @override
  Widget build(BuildContext context) {
    final hPad = AppBreakpoints.horizontalPadding(context);
    final isMobile = AppBreakpoints.isMobile(context);
    final columns = isMobile ? 1 : (AppBreakpoints.isTablet(context) ? 2 : 3);

    final features = [
      (
        icon: Icons.auto_awesome_rounded,
        title: context.tr('feature_1_title'),
        desc: context.tr('feature_1_desc'),
        accent: AppColors.royalBlue,
      ),
      (
        icon: Icons.support_agent_rounded,
        title: context.tr('feature_2_title'),
        desc: context.tr('feature_2_desc'),
        accent: AppColors.gold,
      ),
      (
        icon: Icons.verified_rounded,
        title: context.tr('feature_3_title'),
        desc: context.tr('feature_3_desc'),
        accent: AppColors.royalBlue,
      ),
      (
        icon: Icons.airplane_ticket_rounded,
        title: context.tr('feature_4_title'),
        desc: context.tr('feature_4_desc'),
        accent: AppColors.gold,
      ),
      (
        icon: Icons.hotel_rounded,
        title: context.isArabic ? 'فنادق ومنتجعات 5 نجوم' : 'Premium 5-Star Hotels',
        desc: context.isArabic
            ? 'خيارات إقامة مختارة بعناية وترقيات مجانية لكبار الشخصيات.'
            : 'Handpicked luxury resorts and boutique hotels with VIP room upgrades and exclusive perks.',
        accent: AppColors.royalBlue,
      ),
      (
        icon: Icons.workspace_premium_rounded,
        title: context.isArabic ? 'خبراء سياحيون معتمدون' : 'Certified Travel Experts',
        desc: context.isArabic
            ? 'أكثر من 12 عاماً من الريادة والتميز السياحي واعتمادات IATA الدولية.'
            : 'Over 12 years of tourism excellence, IATA certification, and global destination knowledge.',
        accent: AppColors.gold,
      ),
    ];

    return Container(
      color: AppColors.surfaceLight,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: isMobile ? 60 : 100),
      child: MaxWidthContainer(
        child: Column(
          children: [
            SlideInOnScroll(
              child: SectionHeader(
                badge: context.tr('why_badge'),
                title: context.tr('why_title'),
                subtitle: context.tr('why_subtitle'),
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
              itemCount: features.length,
              itemBuilder: (context, i) {
                final item = features[i];
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
                  ? widget.accentColor.withValues(alpha: 0.15)
                  : AppColors.navy.withValues(alpha: 0.04),
              blurRadius: _isHovered ? 28 : 12,
              offset: Offset(0, _isHovered ? 12 : 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                widget.icon,
                color: widget.accentColor,
                size: 26,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              widget.title,
              style: AppTextStyles.h5.copyWith(color: AppColors.navyDark),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                widget.description,
                style: AppTextStyles.bodySM.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

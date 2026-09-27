import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/animations/animation_widgets.dart';

class CustomizedTripSection extends StatelessWidget {
  const CustomizedTripSection({super.key});

  static const _steps = [
    (
      num: '01',
      title: 'Tell Us Your Plan',
      desc: 'Share your dream destination, travel dates, preferred pace, party size, and travel style.',
      icon: Icons.chat_outlined,
    ),
    (
      num: '02',
      title: 'We Design Your Itinerary',
      desc: 'Our certified destination specialists craft a bespoke day-by-day plan with handpicked hotels and private tours.',
      icon: Icons.map_outlined,
    ),
    (
      num: '03',
      title: 'You Review & Approve',
      desc: 'Fine-tune every excursion and accommodation until the itinerary matches your exact vision.',
      icon: Icons.thumb_up_alt_outlined,
    ),
    (
      num: '04',
      title: 'Start Your Journey',
      desc: 'Relax and embark with complete peace of mind, backed by our 24/7 dedicated VIP concierge.',
      icon: Icons.flight_takeoff_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final hPad = AppBreakpoints.horizontalPadding(context);
    final isMobile = AppBreakpoints.isMobile(context);

    return Container(
      color: AppColors.surfaceLight,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: isMobile ? 60 : 100),
      child: MaxWidthContainer(
        child: Column(
          children: [
            SlideInOnScroll(
              child: const SectionHeader(
                badge: 'Tailor-Made Journeys',
                title: 'Your Trip. Your Way.',
                subtitle: 'Every traveler is unique. We craft personalized bespoke travel experiences from scratch to match your exact desires.',
                alignment: CrossAxisAlignment.center,
              ),
            ),
            const SizedBox(height: 56),

            // Timeline Steps
            if (isMobile)
              _buildMobileTimeline()
            else
              _buildDesktopTimeline(),

            const SizedBox(height: 56),

            // CTA Action trigger
            SlideInOnScroll(
              child: Container(
                padding: EdgeInsets.all(isMobile ? 24 : 36),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.navyDark, AppColors.royalBlueDark],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.royalBlueDark.withValues(alpha: 0.25),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ready for a Custom Itinerary?',
                            style: AppTextStyles.h3.copyWith(color: AppColors.white),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Speak directly with our senior travel designers and receive a custom itinerary proposal within 24 hours.',
                            style: AppTextStyles.bodyLG.copyWith(color: AppColors.textOnDarkMuted),
                          ),
                        ],
                      ),
                    ),
                    if (!isMobile) const SizedBox(width: 24),
                    if (!isMobile)
                      TravellaButton(
                        label: 'Request Custom Plan',
                        variant: TravellaButtonVariant.gold,
                        size: TravellaButtonSize.lg,
                        leadingIcon: Icons.auto_awesome_rounded,
                        onPressed: () => _showCustomPlanDialog(context),
                      ),
                  ],
                ),
              ),
            ),

            if (isMobile) ...[
              const SizedBox(height: 16),
              TravellaButton(
                label: 'Request Custom Plan',
                variant: TravellaButtonVariant.gold,
                fullWidth: true,
                size: TravellaButtonSize.lg,
                leadingIcon: Icons.auto_awesome_rounded,
                onPressed: () => _showCustomPlanDialog(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopTimeline() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_steps.length, (index) {
        final step = _steps[index];
        final isLast = index == _steps.length - 1;

        return Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ScaleInOnScroll(
                  delay: Duration(milliseconds: index * 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.navy,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.royalBlue.withValues(alpha: 0.2),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                step.num,
                                style: AppTextStyles.h4.copyWith(color: AppColors.gold),
                              ),
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                height: 2,
                                margin: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.gold,
                                      AppColors.gold.withValues(alpha: 0.2),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(step.title, style: AppTextStyles.h5),
                      const SizedBox(height: 8),
                      Text(
                        step.desc,
                        style: AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMobileTimeline() {
    return Column(
      children: List.generate(_steps.length, (index) {
        final step = _steps[index];
        final isLast = index == _steps.length - 1;

        return ScaleInOnScroll(
          delay: Duration(milliseconds: index * 100),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        step.num,
                        style: AppTextStyles.h5.copyWith(color: AppColors.gold),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 70,
                      color: AppColors.borderLight,
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(step.title, style: AppTextStyles.h5),
                      const SizedBox(height: 6),
                      Text(
                        step.desc,
                        style: AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showCustomPlanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.navyMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Request Your Custom Plan',
          style: AppTextStyles.h4.copyWith(color: AppColors.white),
        ),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Let us know your dream destination, duration, and preferences. Our travel designer will reach out with a personalized proposal.',
                style: AppTextStyles.bodyMD.copyWith(color: AppColors.textOnDarkMuted),
              ),
              const SizedBox(height: 20),
              TextField(
                style: const TextStyle(color: AppColors.white),
                decoration: InputDecoration(
                  hintText: 'Where would you like to travel?',
                  filled: true,
                  fillColor: AppColors.navyDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                style: const TextStyle(color: AppColors.white),
                decoration: InputDecoration(
                  hintText: 'Your Name & Phone / WhatsApp',
                  filled: true,
                  fillColor: AppColors.navyDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTextStyles.labelMD.copyWith(color: AppColors.gray400)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you! A Travella travel designer will contact you shortly.'),
                  backgroundColor: AppColors.royalBlue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.navyDark,
            ),
            child: const Text('Submit Request'),
          ),
        ],
      ),
    );
  }
}

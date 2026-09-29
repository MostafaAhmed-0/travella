import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/animations/animation_widgets.dart';
import '../../../../core/localization/app_translations.dart';

class FinalCtaSection extends StatelessWidget {
  const FinalCtaSection({super.key});

  @override
  Widget build(BuildContext context) {
    final hPad = AppBreakpoints.horizontalPadding(context);
    final isMobile = AppBreakpoints.isMobile(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: isMobile ? 80 : 120),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF071224),
            AppColors.navyDark,
            AppColors.royalBlueDark,
            AppColors.navy,
          ],
        ),
      ),
      child: MaxWidthContainer(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Decorative background glowing circle
            Positioned(
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.royalBlue.withValues(alpha: 0.12),
                ),
              ),
            ),

            SlideInOnScroll(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SectionBadge(
                    text: context.tr('cta_badge'),
                    color: AppColors.gold.withValues(alpha: 0.15),
                    textColor: AppColors.gold,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    context.tr('cta_title'),
                    style: (isMobile ? AppTextStyles.h1 : AppTextStyles.displayLG).copyWith(
                      color: AppColors.white,
                      height: 1.18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    context.tr('cta_subtitle'),
                    style: AppTextStyles.bodyXL.copyWith(
                      color: AppColors.textOnDarkMuted,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Action Buttons
                  Wrap(
                    spacing: 20,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      TravellaButton(
                        label: context.tr('cta_plan_trip'),
                        variant: TravellaButtonVariant.gold,
                        size: TravellaButtonSize.lg,
                        trailingIcon: Icons.arrow_forward_rounded,
                        onPressed: () => context.goNamed(AppRoutes.bookingName),
                      ),
                      TravellaButton(
                        label: context.tr('cta_contact_expert'),
                        variant: TravellaButtonVariant.secondary,
                        size: TravellaButtonSize.lg,
                        leadingIcon: Icons.support_agent_rounded,
                        onPressed: () => context.goNamed(AppRoutes.contactName),
                      ),
                    ],
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

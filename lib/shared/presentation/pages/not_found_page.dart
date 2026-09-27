import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/animations/animation_widgets.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDark,
      body: Center(
        child: ScaleInOnScroll(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '404',
                style: AppTextStyles.displayXL.copyWith(
                  color: AppColors.gold,
                  fontSize: 120,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Page Not Found',
                style: AppTextStyles.h2.copyWith(color: AppColors.white),
              ),
              const SizedBox(height: 12),
              Text(
                'The page you\'re looking for doesn\'t exist or has been moved.',
                style: AppTextStyles.bodyLG.copyWith(color: AppColors.textOnDarkMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TravellaButton(
                label: 'Back to Home',
                variant: TravellaButtonVariant.gold,
                leadingIcon: Icons.arrow_back_rounded,
                onPressed: () => context.goNamed(AppRoutes.homeName),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/animations/animation_widgets.dart';
import '../../../../core/localization/app_translations.dart';
import 'hero_flight_animation.dart';
import 'travel_planner_bar.dart';

class HomeHeroSection extends StatefulWidget {
  const HomeHeroSection({super.key});

  @override
  State<HomeHeroSection> createState() => _HomeHeroSectionState();
}

class _HomeHeroSectionState extends State<HomeHeroSection> {
  // Destination carousel background list
  static const _bgImages = [
    'https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?auto=format&fit=crop&w=1920&q=85', // Istanbul
    'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=1920&q=85', // Paris
    'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?auto=format&fit=crop&w=1920&q=85', // Dubai
    'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?auto=format&fit=crop&w=1920&q=85', // Maldives
    'https://images.unsplash.com/photo-1539650116574-8efeb43e2750?auto=format&fit=crop&w=1920&q=85', // Sharm
  ];

  int _currentBgIndex = 0;

  @override
  Widget build(BuildContext context) {
    final hPad = AppBreakpoints.horizontalPadding(context);
    final isDesktop = AppBreakpoints.isDesktop(context);
    final isMobile = AppBreakpoints.isMobile(context);
    final screenHeight = AppBreakpoints.screenHeight(context);

    // Hero height calculated to ensure full immersion and room for floating planner
    final heroHeight = math.max(
      isMobile ? 740.0 : 860.0,
      isDesktop ? screenHeight * 0.95 : screenHeight * 0.9,
    );

    return SizedBox(
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── 1. Cinematic Background Image & Gradient ─────────────────────
          Container(
            height: heroHeight,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.navyDark,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Photo with smooth fade
                AnimatedSwitcher(
                  duration: const Duration(seconds: 1),
                  child: Image.network(
                    _bgImages[_currentBgIndex],
                    key: ValueKey(_currentBgIndex),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.navyDark,
                    ),
                  ),
                ),

                // Multi-Layer Cinematic Vignette & Gradient Overlay
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xEB071224),
                        const Color(0xCC0B1929),
                        const Color(0x991E5AA8),
                        const Color(0xF0071224),
                      ],
                      stops: const [0.0, 0.4, 0.75, 1.0],
                    ),
                  ),
                ),

                // Subtle animated gold ambient aura
                Positioned(
                  right: -100,
                  top: 100,
                  child: Container(
                    width: 500,
                    height: 500,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gold.withValues(alpha: 0.08),
                    ),
                  ),
                ),

                // Content inside Hero
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: hPad,
                      vertical: isMobile ? 40 : 60,
                    ),
                    child: MaxWidthContainer(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Left Text & CTAs
                          Expanded(
                            flex: 6,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Brand Tag / Logo inspiration
                                FadeInOnScroll(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.navyDark.withValues(alpha: 0.8),
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                        color: AppColors.gold.withValues(alpha: 0.5),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.gold.withValues(alpha: 0.15),
                                          blurRadius: 16,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.flight_takeoff_rounded, color: AppColors.gold, size: 16),
                                        const SizedBox(width: 8),
                                        Text(
                                          context.tr('hero_badge'),
                                          style: AppTextStyles.overline.copyWith(
                                            color: AppColors.gold,
                                            letterSpacing: context.isArabic ? 0.0 : 2.2,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Main Tagline
                                FadeInOnScroll(
                                  delay: const Duration(milliseconds: 150),
                                  child: Text(
                                    '${context.tr('hero_title_line1')}\n${context.tr('hero_title_line2')}',
                                    style: (isMobile
                                            ? AppTextStyles.displayMD
                                            : isDesktop
                                                ? AppTextStyles.displayXL
                                                : AppTextStyles.displayLG)
                                        .copyWith(
                                      color: AppColors.white,
                                      height: 1.12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: context.isArabic ? 0.0 : -1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Subtitle / Proposition
                                FadeInOnScroll(
                                  delay: const Duration(milliseconds: 250),
                                  child: Text(
                                    context.tr('hero_subtitle'),
                                    style: (isMobile ? AppTextStyles.bodyMD : AppTextStyles.bodyXL).copyWith(
                                      color: AppColors.textOnDarkMuted,
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Staggered CTA Buttons
                                FadeInOnScroll(
                                  delay: const Duration(milliseconds: 350),
                                  child: Wrap(
                                    spacing: 16,
                                    runSpacing: 14,
                                    children: [
                                      TravellaButton(
                                        label: context.tr('hero_explore_btn'),
                                        variant: TravellaButtonVariant.gold,
                                        size: TravellaButtonSize.lg,
                                        trailingIcon: Icons.arrow_forward_rounded,
                                        onPressed: () => context.goNamed(AppRoutes.destinationsName),
                                      ),
                                      TravellaButton(
                                        label: context.tr('hero_plan_btn'),
                                        variant: TravellaButtonVariant.secondary,
                                        size: TravellaButtonSize.lg,
                                        leadingIcon: Icons.auto_awesome_rounded,
                                        onPressed: () => context.goNamed(AppRoutes.bookingName),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Right Logo-Inspired Flight Animation (Desktop & Tablet)
                          if (!isMobile) ...[
                            const SizedBox(width: 32),
                            Expanded(
                              flex: 5,
                              child: Center(
                                child: HeroFlightAnimation(
                                  size: isDesktop ? 420 : 320,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // Destination quick switcher dots at bottom right
                Positioned(
                  bottom: isMobile ? 24 : 40,
                  right: hPad,
                  child: Row(
                    children: List.generate(_bgImages.length, (i) {
                      final isSel = _currentBgIndex == i;
                      return InkWell(
                        onTap: () => setState(() => _currentBgIndex = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(left: 8),
                          width: isSel ? 28 : 8,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isSel ? AppColors.gold : AppColors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          // ── 2. Floating Travel Planner Bar ───────────────────────────────
          Positioned(
            left: hPad,
            right: hPad,
            bottom: -60,
            child: MaxWidthContainer(
              child: SlideInOnScroll(
                delay: const Duration(milliseconds: 400),
                child: const TravelPlannerBar(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

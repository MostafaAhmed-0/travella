import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/animations/animation_widgets.dart';
import '../../../../data/models/tour_model.dart';
import '../../../../data/repositories/tour_repository.dart';

class DomesticToursSection extends StatefulWidget {
  const DomesticToursSection({super.key});

  @override
  State<DomesticToursSection> createState() => _DomesticToursSectionState();
}

class _DomesticToursSectionState extends State<DomesticToursSection> {
  final TourRepository _repository = TourRepository();
  List<TourModel> _tours = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTours();
  }

  Future<void> _loadTours() async {
    final list = await _repository.getDomesticTours();
    if (mounted) {
      setState(() {
        _tours = list;
        _isLoading = false;
      });
    }
  }

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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: SectionHeader(
                      badge: 'Discover Egypt',
                      title: 'Egypt’s Timeless Wonders',
                      subtitle: 'From the Red Sea’s coral reefs and Siwa’s mystical salt lakes to luxury Nile cruises.',
                    ),
                  ),
                  if (!isMobile)
                    TravellaButton(
                      label: 'All Domestic Tours',
                      variant: TravellaButtonVariant.secondary,
                      trailingIcon: Icons.arrow_forward_rounded,
                      onPressed: () => context.goNamed(AppRoutes.domesticToursName),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(color: AppColors.royalBlue),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisExtent: isMobile ? 440 : 470,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                itemCount: _tours.length,
                itemBuilder: (context, i) {
                  return ScaleInOnScroll(
                    delay: Duration(milliseconds: (i % 3) * 100),
                    child: _TourCard(tour: _tours[i]),
                  );
                },
              ),
            if (isMobile) ...[
              const SizedBox(height: 32),
              TravellaButton(
                label: 'Explore All Egypt Tours',
                variant: TravellaButtonVariant.secondary,
                fullWidth: true,
                trailingIcon: Icons.arrow_forward_rounded,
                onPressed: () => context.goNamed(AppRoutes.domesticToursName),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TourCard extends StatefulWidget {
  final TourModel tour;
  const _TourCard({required this.tour});

  @override
  State<_TourCard> createState() => _TourCardState();
}

class _TourCardState extends State<_TourCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final tour = widget.tour;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0.0, _isHovered ? -8.0 : 0.0, 0.0),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered ? AppColors.royalBlue.withValues(alpha: 0.4) : AppColors.borderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? AppColors.royalBlue.withValues(alpha: 0.15)
                  : AppColors.navy.withValues(alpha: 0.05),
              blurRadius: _isHovered ? 32 : 16,
              offset: Offset(0, _isHovered ? 14 : 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image with Badge ──────────────────────────────────────────
              SizedBox(
                height: 200,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AnimatedScale(
                      scale: _isHovered ? 1.05 : 1.0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      child: Image.network(
                        tour.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.navyMedium,
                          child: const Icon(Icons.image_not_supported_outlined, color: AppColors.gray400),
                        ),
                      ),
                    ),
                    // Gradient overlay
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.35),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.4),
                          ],
                        ),
                      ),
                    ),
                    // Badges
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.navyDark.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.white.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.schedule_rounded, size: 13, color: AppColors.gold),
                            const SizedBox(width: 4),
                            Text(
                              tour.durationDays,
                              style: AppTextStyles.labelSM.copyWith(color: AppColors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (tour.badge != null)
                      Positioned(
                        top: 14,
                        right: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tour.badge!,
                            style: AppTextStyles.labelSM.copyWith(
                              color: AppColors.navyDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Details ───────────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location & Rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.place_rounded, size: 14, color: AppColors.royalBlue),
                              const SizedBox(width: 4),
                              Text(
                                '${tour.destination}, ${tour.country}',
                                style: AppTextStyles.labelSM.copyWith(
                                  color: AppColors.royalBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 16, color: AppColors.gold),
                              const SizedBox(width: 2),
                              Text(
                                '${tour.rating} (${tour.reviewsCount})',
                                style: AppTextStyles.labelSM.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Title
                      Text(
                        tour.title,
                        style: AppTextStyles.h5.copyWith(color: AppColors.navyDark),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Description
                      Text(
                        tour.description,
                        style: AppTextStyles.bodySM.copyWith(color: AppColors.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const Spacer(),
                      const Divider(color: AppColors.borderLight, height: 16),

                      // Price & CTA
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'STARTING PRICE',
                                style: AppTextStyles.overline.copyWith(
                                  color: AppColors.textLightMuted,
                                  fontSize: 9,
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '\$${tour.price.toInt()}',
                                    style: AppTextStyles.h4.copyWith(
                                      color: AppColors.royalBlueDark,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  if (tour.originalPrice != null) ...[
                                    const SizedBox(width: 6),
                                    Text(
                                      '\$${tour.originalPrice!.toInt()}',
                                      style: AppTextStyles.bodySM.copyWith(
                                        color: AppColors.gray400,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () => context.goNamed(AppRoutes.bookingName),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isHovered ? AppColors.gold : AppColors.navy,
                              foregroundColor: _isHovered ? AppColors.navyDark : AppColors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            child: Text(
                              'Book Tour',
                              style: AppTextStyles.labelMD.copyWith(
                                color: _isHovered ? AppColors.navyDark : AppColors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

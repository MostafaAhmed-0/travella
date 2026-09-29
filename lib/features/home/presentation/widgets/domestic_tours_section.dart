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

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTours();
  }

  Future<void> _loadTours() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _repository.getDomesticTours(activeOnly: true);
      if (mounted) {
        setState(() {
          _tours = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
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
            else if (_errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.errorRed, size: 40),
                      const SizedBox(height: 12),
                      Text('Failed to load domestic tours', style: AppTextStyles.h5),
                      const SizedBox(height: 12),
                      TravellaButton(
                        label: 'Retry',
                        variant: TravellaButtonVariant.primary,
                        onPressed: _loadTours,
                      ),
                    ],
                  ),
                ),
              )
            else if (_tours.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: Column(
                    children: [
                      Icon(Icons.travel_explore_rounded, color: AppColors.gray400, size: 48),
                      SizedBox(height: 12),
                      Text('No tours available at the moment.', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
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
      child: GestureDetector(
        onTap: () => context.goNamed(
          AppRoutes.tourDetailsName,
          pathParameters: {'id': tour.id},
        ),
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
                      if (tour.badge != null && tour.badge!.isNotEmpty)
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
                                  '${tour.destination.isNotEmpty ? tour.destination : "Egypt"}, ${tour.country.isNotEmpty ? tour.country : "Egypt"}',
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
                                      '${tour.currency} ${tour.price.toInt()}',
                                      style: AppTextStyles.h4.copyWith(
                                        color: AppColors.royalBlueDark,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    if (tour.originalPrice != null && tour.originalPrice! > tour.price) ...[
                                      const SizedBox(width: 6),
                                      Text(
                                        '${tour.currency} ${tour.originalPrice!.toInt()}',
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
                            Row(
                              children: [
                                OutlinedButton(
                                  onPressed: () => context.goNamed(
                                    AppRoutes.tourDetailsName,
                                    pathParameters: {'id': tour.id},
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.navyDark,
                                    side: const BorderSide(color: AppColors.borderLight),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () => context.goNamed(
                                    AppRoutes.bookingWithTourIdName,
                                    pathParameters: {'tourId': tour.id},
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isHovered ? AppColors.gold : AppColors.royalBlue,
                                    foregroundColor: _isHovered ? AppColors.navyDark : AppColors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Book Now',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
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
      ),
    );
  }
}


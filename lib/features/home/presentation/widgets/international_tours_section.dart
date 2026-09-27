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

class InternationalToursSection extends StatefulWidget {
  const InternationalToursSection({super.key});

  @override
  State<InternationalToursSection> createState() =>
      _InternationalToursSectionState();
}

class _InternationalToursSectionState extends State<InternationalToursSection> {
  final TourRepository _repository = const TourRepository();
  final ScrollController _scrollController = ScrollController();
  List<TourModel> _tours = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTours();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadTours() async {
    final list = await _repository.getInternationalTours();
    if (mounted) {
      setState(() {
        _tours = list;
        _isLoading = false;
      });
    }
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      (_scrollController.offset - 360).clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      (_scrollController.offset + 360).clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hPad = AppBreakpoints.horizontalPadding(context);
    final isMobile = AppBreakpoints.isMobile(context);

    return Container(
      color: AppColors.navyDark,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 60 : 100),
      child: Column(
        children: [
          // ── Header & Carousel Nav Buttons ────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: MaxWidthContainer(
              child: SlideInOnScroll(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: SectionHeader(
                        badge: 'Global Adventures',
                        title: 'Travel Beyond Borders',
                        subtitle: 'Curated international itineraries combining luxury hotels, guided experiences, and seamless transfers.',
                        onDark: true,
                      ),
                    ),
                    if (!isMobile)
                      Row(
                        children: [
                          _CarouselNavBtn(
                            icon: Icons.chevron_left_rounded,
                            onTap: _scrollLeft,
                          ),
                          const SizedBox(width: 12),
                          _CarouselNavBtn(
                            icon: Icons.chevron_right_rounded,
                            onTap: _scrollRight,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),

          // ── Horizontal Carousel ──────────────────────────────────────────
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(color: AppColors.gold),
              ),
            )
          else
            SizedBox(
              height: 460,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: hPad),
                itemCount: _tours.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: SizedBox(
                      width: isMobile ? 300 : 340,
                      child: _InternationalTourCard(tour: _tours[i]),
                    ),
                  );
                },
              ),
            ),

          if (isMobile) ...[
            const SizedBox(height: 28),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: TravellaButton(
                label: 'View All International Tours',
                variant: TravellaButtonVariant.gold,
                fullWidth: true,
                trailingIcon: Icons.arrow_forward_rounded,
                onPressed: () => context.goNamed(AppRoutes.internationalToursName),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CarouselNavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CarouselNavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.navyMedium,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.15)),
        ),
        child: Icon(icon, color: AppColors.white, size: 26),
      ),
    );
  }
}

class _InternationalTourCard extends StatefulWidget {
  final TourModel tour;
  const _InternationalTourCard({required this.tour});

  @override
  State<_InternationalTourCard> createState() => _InternationalTourCardState();
}

class _InternationalTourCardState extends State<_InternationalTourCard> {
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
          color: AppColors.navyMedium,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _isHovered
                ? AppColors.gold.withValues(alpha: 0.7)
                : AppColors.white.withValues(alpha: 0.1),
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? AppColors.gold.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.25),
              blurRadius: _isHovered ? 32 : 16,
              offset: Offset(0, _isHovered ? 14 : 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image container
              SizedBox(
                height: 190,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AnimatedScale(
                      scale: _isHovered ? 1.06 : 1.0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      child: Image.network(
                        tour.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.navyDark,
                          child: const Icon(Icons.image_not_supported_outlined, color: AppColors.gray400),
                        ),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.4),
                            Colors.transparent,
                            AppColors.navyMedium,
                          ],
                          stops: const [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                    // Destination tag
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
                        child: Text(
                          '${tour.destination}, ${tour.country}',
                          style: AppTextStyles.labelSM.copyWith(color: AppColors.goldLight),
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

              // Body content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rating & Duration
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.schedule_rounded, size: 14, color: AppColors.textOnDarkMuted),
                              const SizedBox(width: 4),
                              Text(
                                tour.durationDays,
                                style: AppTextStyles.labelSM.copyWith(color: AppColors.textOnDarkMuted),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 16, color: AppColors.gold),
                              const SizedBox(width: 3),
                              Text(
                                '${tour.rating}',
                                style: AppTextStyles.labelSM.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Title
                      Text(
                        tour.title,
                        style: AppTextStyles.h5.copyWith(color: AppColors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Description
                      Text(
                        tour.description,
                        style: AppTextStyles.bodySM.copyWith(color: AppColors.textOnDarkMuted),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const Spacer(),
                      const Divider(color: AppColors.dividerDark, height: 16),

                      // Price & Action
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PRICE PER PERSON',
                                style: AppTextStyles.overline.copyWith(
                                  color: AppColors.goldLight,
                                  fontSize: 9,
                                ),
                              ),
                              Text(
                                '\$${tour.price.toInt()}',
                                style: AppTextStyles.h4.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () => context.goNamed(AppRoutes.bookingName),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gold,
                              foregroundColor: AppColors.navyDark,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            child: Text(
                              'Book Now',
                              style: AppTextStyles.labelMD.copyWith(
                                color: AppColors.navyDark,
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

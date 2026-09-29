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

class HajjUmrahSection extends StatefulWidget {
  const HajjUmrahSection({super.key});

  @override
  State<HajjUmrahSection> createState() => _HajjUmrahSectionState();
}

class _HajjUmrahSectionState extends State<HajjUmrahSection> {
  final TourRepository _repository = TourRepository();
  List<TourModel> _packages = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _repository.getHajjUmrahTours(activeOnly: true);
      if (mounted) {
        setState(() {
          _packages = list.take(3).toList();
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
      color: AppColors.navyDark,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: isMobile ? 60 : 100),
      child: MaxWidthContainer(
        child: Column(
          children: [
            SlideInOnScroll(
              child: const SectionHeader(
                badge: 'Hajj & Umrah Services',
                title: 'Spiritual Journeys, Carefully Arranged',
                subtitle: '5-star accommodations directly facing the Holy Haram, VIP private transportation, and comprehensive religious guidance.',
                alignment: CrossAxisAlignment.center,
                onDark: true,
              ),
            ),
            const SizedBox(height: 56),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
              )
            else if (_errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.gold, size: 40),
                      const SizedBox(height: 12),
                      Text('Failed to load pilgrimage packages', style: AppTextStyles.h5.copyWith(color: AppColors.white)),
                      const SizedBox(height: 12),
                      TravellaButton(
                        label: 'Retry',
                        variant: TravellaButtonVariant.gold,
                        onPressed: _loadPackages,
                      ),
                    ],
                  ),
                ),
              )
            else if (_packages.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: Column(
                    children: [
                      Icon(Icons.mosque_outlined, color: AppColors.gray400, size: 48),
                      SizedBox(height: 12),
                      Text('No Hajj & Umrah packages available at the moment.', style: TextStyle(color: AppColors.textOnDarkMuted)),
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
                  mainAxisExtent: isMobile ? 540 : 560,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                itemCount: _packages.length,
                itemBuilder: (context, i) {
                  return ScaleInOnScroll(
                    delay: Duration(milliseconds: i * 100),
                    child: _HajjUmrahCard(tour: _packages[i]),
                  );
                },
              ),

            const SizedBox(height: 48),
            SlideInOnScroll(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.navyMedium,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 24),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        'Accredited by the Ministry of Hajj & Umrah • Licensed Electronic Visa Portal',
                        style: AppTextStyles.bodyMD.copyWith(color: AppColors.goldLight),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HajjUmrahCard extends StatefulWidget {
  final TourModel tour;
  const _HajjUmrahCard({required this.tour});

  @override
  State<_HajjUmrahCard> createState() => _HajjUmrahCardState();
}

class _HajjUmrahCardState extends State<_HajjUmrahCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final tour = widget.tour;

    return GestureDetector(
      onTap: () => context.goNamed(
        AppRoutes.tourDetailsName,
        pathParameters: {'id': tour.id},
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
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
                  ? AppColors.gold
                  : AppColors.gold.withValues(alpha: 0.25),
              width: _isHovered ? 2.0 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? AppColors.gold.withValues(alpha: 0.22)
                    : Colors.black.withValues(alpha: 0.3),
                blurRadius: _isHovered ? 36 : 16,
                offset: Offset(0, _isHovered ? 14 : 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Banner
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AnimatedScale(
                        scale: _isHovered ? 1.05 : 1.0,
                        duration: const Duration(milliseconds: 400),
                        child: Image.network(
                          tour.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.navyDark,
                            child: const Icon(Icons.mosque_rounded, color: AppColors.gold),
                          ),
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.3),
                              Colors.transparent,
                              AppColors.navyMedium,
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 14,
                        left: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.navyDark.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            tour.type.name.toUpperCase(),
                            style: AppTextStyles.labelSM.copyWith(color: AppColors.gold),
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

                // Package Details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tour.title,
                          style: AppTextStyles.h4.copyWith(color: AppColors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tour.description,
                          style: AppTextStyles.bodySM.copyWith(color: AppColors.textOnDarkMuted),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),

                        // Destination and duration
                        Row(
                          children: [
                            const Icon(Icons.place_rounded, color: AppColors.gold, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '${tour.destination}, ${tour.country}',
                              style: AppTextStyles.labelSM.copyWith(color: AppColors.white),
                            ),
                            const Spacer(),
                            const Icon(Icons.schedule_rounded, color: AppColors.goldLight, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              tour.durationDays,
                              style: AppTextStyles.labelSM.copyWith(color: AppColors.goldLight),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        if (tour.included.isNotEmpty) ...[
                          Text(
                            'Key Inclusions:',
                            style: AppTextStyles.labelSM.copyWith(color: AppColors.goldLight),
                          ),
                          const SizedBox(height: 6),
                          ...tour.included.take(3).map((inc) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: AppColors.gold, size: 14),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      inc,
                                      style: AppTextStyles.bodySM.copyWith(color: AppColors.white),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],

                        const Spacer(),
                        const Divider(color: AppColors.dividerDark, height: 16),

                        // Price & Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PACKAGE FROM',
                                  style: AppTextStyles.overline.copyWith(
                                    color: AppColors.goldLight,
                                    fontSize: 9,
                                  ),
                                ),
                                Text(
                                  '${tour.currency} ${tour.price.toInt()}',
                                  style: AppTextStyles.h4.copyWith(
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.w800,
                                  ),
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
                                    foregroundColor: AppColors.white,
                                    side: BorderSide(color: AppColors.white.withValues(alpha: 0.3)),
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
                                    backgroundColor: AppColors.gold,
                                    foregroundColor: AppColors.navyDark,
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

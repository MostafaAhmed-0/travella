import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../data/models/tour_model.dart';
import '../../../../data/repositories/tour_repository.dart';
import '../../../../shared/presentation/widgets/app_navbar.dart';
import '../../../../shared/presentation/widgets/app_footer.dart';

class TourDetailsPage extends StatefulWidget {
  final String tourId;

  const TourDetailsPage({
    super.key,
    required this.tourId,
  });

  @override
  State<TourDetailsPage> createState() => _TourDetailsPageState();
}

class _TourDetailsPageState extends State<TourDetailsPage> {
  final TourRepository _repository = TourRepository();
  TourModel? _tour;
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTourDetails();
  }

  @override
  void didUpdateWidget(covariant TourDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tourId != widget.tourId) {
      _loadTourDetails();
    }
  }

  Future<void> _loadTourDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tour = await _repository.getTourById(widget.tourId);
      if (mounted) {
        setState(() {
          _tour = tour;
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

  List<String> get _allImages {
    if (_tour == null) return [];
    final list = <String>[];
    if (_tour!.imageUrl.isNotEmpty) {
      list.add(_tour!.imageUrl);
    }
    for (final img in _tour!.tourImages) {
      if (img.imageUrl.isNotEmpty && !list.contains(img.imageUrl)) {
        list.add(img.imageUrl);
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final hPad = AppBreakpoints.horizontalPadding(context);
    final isMobile = AppBreakpoints.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: CustomScrollView(
        slivers: [
          // ── Navbar ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: AppNavbar(currentRoute: AppRoutes.domesticTours),
          ),

          // ── Content ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _buildBody(context, hPad, isMobile),
          ),

          // ── Footer ────────────────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: AppFooter(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, double hPad, bool isMobile) {
    if (_isLoading) {
      return Container(
        height: 600,
        alignment: Alignment.center,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.royalBlue),
            SizedBox(height: 20),
            Text(
              'Loading tour details...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        height: 500,
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.errorRed, size: 56),
            const SizedBox(height: 16),
            Text(
              'Failed to load tour',
              style: AppTextStyles.h4.copyWith(color: AppColors.navyDark),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TravellaButton(
              label: 'Retry',
              variant: TravellaButtonVariant.primary,
              onPressed: _loadTourDetails,
            ),
          ],
        ),
      );
    }

    if (_tour == null || !_tour!.active) {
      return Container(
        height: 500,
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.travel_explore_rounded, color: AppColors.gray400, size: 64),
            const SizedBox(height: 16),
            Text(
              'Tour Not Found',
              style: AppTextStyles.h4.copyWith(color: AppColors.navyDark),
            ),
            const SizedBox(height: 8),
            const Text(
              'This tour package is currently unavailable or inactive.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TravellaButton(
              label: 'Explore All Tours',
              variant: TravellaButtonVariant.primary,
              onPressed: () => context.goNamed(AppRoutes.homeName),
            ),
          ],
        ),
      );
    }

    final tour = _tour!;
    final images = _allImages;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: isMobile ? 32 : 56),
      child: MaxWidthContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Breadcrumb ──────────────────────────────────────────────────
            Row(
              children: [
                InkWell(
                  onTap: () => context.goNamed(AppRoutes.homeName),
                  child: Text('Home', style: AppTextStyles.labelSM.copyWith(color: AppColors.royalBlue)),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.gray400),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    if (tour.type == TourType.domestic) {
                      context.goNamed(AppRoutes.domesticToursName);
                    } else if (tour.type == TourType.international) {
                      context.goNamed(AppRoutes.internationalToursName);
                    } else {
                      context.goNamed(AppRoutes.hajjUmrahName);
                    }
                  },
                  child: Text(
                    tour.type == TourType.domestic
                        ? 'Domestic Tours'
                        : tour.type == TourType.international
                            ? 'International Tours'
                            : 'Hajj & Umrah',
                    style: AppTextStyles.labelSM.copyWith(color: AppColors.royalBlue),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.gray400),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tour.title,
                    style: AppTextStyles.labelSM.copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Title & Meta Info ──────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.royalBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tour.type.name.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.royalBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          if (tour.badge != null && tour.badge!.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tour.badge!,
                                style: const TextStyle(
                                  color: AppColors.goldDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tour.title,
                        style: isMobile ? AppTextStyles.h3 : AppTextStyles.h2,
                      ),
                      if (tour.titleAr != null && tour.titleAr!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          tour.titleAr!,
                          style: AppTextStyles.bodyLG.copyWith(color: AppColors.textSecondary),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 20,
                        runSpacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.place_rounded, size: 18, color: AppColors.royalBlue),
                              const SizedBox(width: 6),
                              Text(
                                '${tour.destination.isNotEmpty ? tour.destination : "Egypt"}, ${tour.country.isNotEmpty ? tour.country : "Egypt"}',
                                style: AppTextStyles.labelMD.copyWith(color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.schedule_rounded, size: 18, color: AppColors.gold),
                              const SizedBox(width: 6),
                              Text(
                                tour.duration,
                                style: AppTextStyles.labelMD.copyWith(color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, size: 18, color: AppColors.gold),
                              const SizedBox(width: 4),
                              Text(
                                '${tour.rating} (${tour.reviewsCount} reviews)',
                                style: AppTextStyles.labelMD.copyWith(
                                  color: AppColors.navyDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Image Gallery Section ──────────────────────────────────────
            _buildGallerySection(images, isMobile),
            const SizedBox(height: 40),

            // ── Main Content & Sticky Booking Card Grid ────────────────────
            if (isMobile)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBookingSidebarCard(tour),
                  const SizedBox(height: 32),
                  _buildTourOverviewAndTabs(tour),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: _buildTourOverviewAndTabs(tour),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    flex: 4,
                    child: _buildBookingSidebarCard(tour),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGallerySection(List<String> images, bool isMobile) {
    if (images.isEmpty) {
      return Container(
        height: 350,
        decoration: BoxDecoration(
          color: AppColors.navyMedium,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined, color: AppColors.gray400, size: 48),
        ),
      );
    }

    final activeUrl = images.length > _selectedImageIndex
        ? images[_selectedImageIndex]
        : images.first;

    return Column(
      children: [
        // Main Active Image
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: isMobile ? 260 : 460,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.navyDark,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  activeUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.navyMedium,
                    child: const Center(
                      child: Icon(Icons.photo_size_select_actual_outlined, color: AppColors.gray400, size: 48),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.photo_library_rounded, color: AppColors.white, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          '${_selectedImageIndex + 1} / ${images.length}',
                          style: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Thumbnails
        if (images.length > 1) ...[
          const SizedBox(height: 14),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedImageIndex;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () => setState(() => _selectedImageIndex = index),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.royalBlue : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          images[index],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: AppColors.gray200),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTourOverviewAndTabs(TourModel tour) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Description Card ──────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('About This Tour', style: AppTextStyles.h4),
              const SizedBox(height: 16),
              Text(
                tour.description,
                style: AppTextStyles.bodyLG.copyWith(color: AppColors.textPrimary, height: 1.6),
              ),
              if (tour.descriptionAr != null && tour.descriptionAr!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(color: AppColors.borderLight),
                const SizedBox(height: 16),
                Text(
                  tour.descriptionAr!,
                  style: AppTextStyles.bodyLG.copyWith(color: AppColors.textSecondary, height: 1.6),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 28),

        // ── Highlights ────────────────────────────────────────────────────
        if (tour.highlights.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: AppColors.gold, size: 24),
                    const SizedBox(width: 10),
                    Text('Tour Highlights', style: AppTextStyles.h4),
                  ],
                ),
                const SizedBox(height: 20),
                ...tour.highlights.map((h) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 3),
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.royalBlueFaded,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, size: 14, color: AppColors.royalBlue),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              h,
                              style: AppTextStyles.bodyMD.copyWith(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 28),
        ],

        // ── Itinerary Section ─────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.map_rounded, color: AppColors.royalBlue, size: 24),
                  const SizedBox(width: 10),
                  Text('Detailed Itinerary', style: AppTextStyles.h4),
                ],
              ),
              const SizedBox(height: 20),
              if (tour.itinerary.isEmpty) ...[
                // Default generated days if itinerary list is empty
                _buildDefaultItineraryDays(tour),
              ] else ...[
                ...tour.itinerary.map((step) => _buildItineraryStepCard(step)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 28),

        // ── Inclusions & Exclusions ───────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('What’s Included & Excluded', style: AppTextStyles.h4),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Included
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 20),
                            const SizedBox(width: 8),
                            Text('Included', style: AppTextStyles.labelLG.copyWith(color: AppColors.successGreen, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        if (tour.included.isEmpty)
                          const Text('• 5-Star Hotel Accommodations\n• Daily Breakfast & Dinners\n• Private Airport Transfers\n• Professional English/Arabic Tour Guide\n• Entrance fees to all scheduled sites', style: TextStyle(height: 1.7, color: AppColors.textPrimary))
                        else
                          ...tour.included.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.check_rounded, color: AppColors.successGreen, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(item, style: AppTextStyles.bodyMD)),
                                  ],
                                ),
                              )),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Excluded
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.cancel_rounded, color: AppColors.errorRed, size: 20),
                            const SizedBox(width: 8),
                            Text('Excluded', style: AppTextStyles.labelLG.copyWith(color: AppColors.errorRed, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        if (tour.excluded.isEmpty)
                          const Text('• International Flight Tickets (unless specified)\n• Personal expenses & souvenirs\n• Travel & Medical Insurance\n• Gratuities & tips for drivers/guides', style: TextStyle(height: 1.7, color: AppColors.textSecondary))
                        else
                          ...tour.excluded.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.close_rounded, color: AppColors.errorRed, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(item, style: AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary))),
                                  ],
                                ),
                              )),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultItineraryDays(TourModel tour) {
    return Column(
      children: [
        _buildItineraryStepCard(
          const TourItineraryItem(
            day: 1,
            title: 'Arrival & VIP Check-In',
            description: 'Meet & assist by our dedicated Travella representative upon arrival. Private transfer to your luxury accommodation and evening welcome orientation.',
          ),
        ),
        _buildItineraryStepCard(
          const TourItineraryItem(
            day: 2,
            title: 'Guided Signature Highlights Exploration',
            description: 'Full day private guided tour exploring the iconic historical landmarks, cultural hotspots, and scenic vistas with a dedicated expert.',
          ),
        ),
        _buildItineraryStepCard(
          const TourItineraryItem(
            day: 3,
            title: 'Exclusive Excursion & Leisure Experience',
            description: 'Specialized activity tailored to the destination: private yacht cruise, desert safari, or premium museum access with gourmet dining.',
          ),
        ),
        _buildItineraryStepCard(
          const TourItineraryItem(
            day: 4,
            title: 'Farewell & VIP Departure',
            description: 'Morning leisure time for shopping or relaxation. Private chauffeur transfer to the airport for your onward journey.',
          ),
        ),
      ],
    );
  }

  Widget _buildItineraryStepCard(TourItineraryItem step) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.navyDark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'DAY ${step.day}',
              style: const TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold, color: AppColors.navyDark),
                ),
                if (step.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    step.description,
                    style: AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary, height: 1.5),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingSidebarCard(TourModel tour) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price Header
          Text(
            'PRICE PER PERSON',
            style: AppTextStyles.overline.copyWith(color: AppColors.textSecondary, letterSpacing: 1.5),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${tour.currency} ${tour.price.toInt()}',
                style: AppTextStyles.h2.copyWith(color: AppColors.royalBlueDark, fontWeight: FontWeight.w900),
              ),
              if (tour.originalPrice != null && tour.originalPrice! > tour.price) ...[
                const SizedBox(width: 10),
                Text(
                  '${tour.currency} ${tour.originalPrice!.toInt()}',
                  style: AppTextStyles.bodyLG.copyWith(
                    color: AppColors.gray400,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Includes all taxes, service fees & private guide',
            style: TextStyle(color: AppColors.gray600, fontSize: 12),
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.borderLight),
          const SizedBox(height: 20),

          // Key Highlights summary
          _buildSidebarFeatureRow(Icons.schedule_rounded, 'Duration', tour.duration),
          const SizedBox(height: 12),
          _buildSidebarFeatureRow(Icons.place_rounded, 'Destination', tour.destination.isNotEmpty ? tour.destination : tour.country),
          const SizedBox(height: 12),
          _buildSidebarFeatureRow(Icons.verified_user_rounded, 'Booking', 'Instant Confirmation'),
          const SizedBox(height: 12),
          _buildSidebarFeatureRow(Icons.cancel_outlined, 'Cancellation', 'Free up to 7 days before'),
          const SizedBox(height: 24),

          // Book Now CTA
          TravellaButton(
            label: 'Book Now',
            variant: TravellaButtonVariant.primary,
            fullWidth: true,
            trailingIcon: Icons.arrow_forward_rounded,
            onPressed: () {
              context.goNamed(
                AppRoutes.bookingWithTourIdName,
                pathParameters: {'tourId': tour.id},
              );
            },
          ),
          const SizedBox(height: 12),

          // Inquire Button
          TravellaButton(
            label: 'Inquire / Custom Request',
            variant: TravellaButtonVariant.secondary,
            fullWidth: true,
            leadingIcon: Icons.chat_bubble_outline_rounded,
            onPressed: () => context.goNamed(AppRoutes.contactName),
          ),
          const SizedBox(height: 16),

          // Trust Badge
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.gray500),
                const SizedBox(width: 6),
                Text(
                  '256-bit Secure Reservation System',
                  style: AppTextStyles.caption.copyWith(color: AppColors.gray500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarFeatureRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.royalBlue),
        const SizedBox(width: 10),
        Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.navyDark),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/animations/animation_widgets.dart';
import '../../../../data/models/hotel_model.dart';
import '../../../../data/repositories/hotel_repository.dart';

class LuxuryHotelsSection extends StatefulWidget {
  const LuxuryHotelsSection({super.key});

  @override
  State<LuxuryHotelsSection> createState() => _LuxuryHotelsSectionState();
}

class _LuxuryHotelsSectionState extends State<LuxuryHotelsSection> {
  final HotelRepository _repository = HotelRepository();
  List<HotelModel> _hotels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHotels();
  }

  Future<void> _loadHotels() async {
    final list = await _repository.getFeaturedHotels();
    if (mounted) {
      setState(() {
        _hotels = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hPad = AppBreakpoints.horizontalPadding(context);
    final isMobile = AppBreakpoints.isMobile(context);
    final columns = isMobile ? 1 : 2;

    return Container(
      color: AppColors.white,
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
                      badge: 'Handpicked Luxury',
                      title: 'Stay Somewhere Amazing',
                      subtitle: 'World-renowned 5-star beachfront resorts, overwater villas, and historic palace sanctuaries.',
                    ),
                  ),
                  if (!isMobile)
                    TravellaButton(
                      label: 'Explore All Hotels',
                      variant: TravellaButtonVariant.secondary,
                      trailingIcon: Icons.arrow_forward_rounded,
                      onPressed: () => context.goNamed(AppRoutes.hotelsName),
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
                  mainAxisExtent: isMobile ? 480 : 360,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                itemCount: _hotels.length,
                itemBuilder: (context, i) {
                  return ScaleInOnScroll(
                    delay: Duration(milliseconds: i * 100),
                    child: _HotelCard(hotel: _hotels[i], isMobile: isMobile),
                  );
                },
              ),

            if (isMobile) ...[
              const SizedBox(height: 32),
              TravellaButton(
                label: 'Explore All Luxury Hotels',
                variant: TravellaButtonVariant.secondary,
                fullWidth: true,
                trailingIcon: Icons.arrow_forward_rounded,
                onPressed: () => context.goNamed(AppRoutes.hotelsName),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HotelCard extends StatefulWidget {
  final HotelModel hotel;
  final bool isMobile;
  const _HotelCard({required this.hotel, required this.isMobile});

  @override
  State<_HotelCard> createState() => _HotelCardState();
}

class _HotelCardState extends State<_HotelCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0.0, _isHovered ? -6.0 : 0.0, 0.0),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered ? AppColors.gold : AppColors.borderLight,
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? AppColors.navy.withValues(alpha: 0.12)
                  : AppColors.navy.withValues(alpha: 0.04),
              blurRadius: _isHovered ? 28 : 14,
              offset: Offset(0, _isHovered ? 12 : 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: widget.isMobile
              ? Column(
                  children: [
                    _buildImageSection(hotel),
                    Expanded(child: _buildInfoSection(hotel)),
                  ],
                )
              : Row(
                  children: [
                    Expanded(flex: 5, child: _buildImageSection(hotel)),
                    Expanded(flex: 6, child: _buildInfoSection(hotel)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildImageSection(HotelModel hotel) {
    return SizedBox(
      height: widget.isMobile ? 200 : double.infinity,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedScale(
            scale: _isHovered ? 1.06 : 1.0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            child: Image.network(
              hotel.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.navyMedium,
                child: const Icon(Icons.hotel_rounded, color: AppColors.gray400),
              ),
            ),
          ),
          if (hotel.badge != null)
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hotel.badge!,
                  style: AppTextStyles.labelSM.copyWith(
                    color: AppColors.navyDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(HotelModel hotel) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location & Star Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.place_rounded, size: 14, color: AppColors.royalBlue),
                  const SizedBox(width: 4),
                  Text(
                    '${hotel.city}, ${hotel.country}',
                    style: AppTextStyles.labelSM.copyWith(
                      color: AppColors.royalBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              RatingStars(rating: hotel.rating, size: 14),
            ],
          ),
          const SizedBox(height: 8),

          // Hotel Name
          Text(
            hotel.name,
            style: AppTextStyles.h4.copyWith(color: AppColors.navyDark),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            hotel.roomType,
            style: AppTextStyles.bodySM.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),

          // Amenities Tags
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: hotel.amenities.take(3).map((amenity) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  amenity,
                  style: AppTextStyles.labelSM.copyWith(
                    fontSize: 11,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
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
                    'STARTING FROM',
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
                        '\$${hotel.pricePerNight.toInt()}',
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.royalBlueDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        ' / night',
                        style: AppTextStyles.bodySM.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => context.goNamed(AppRoutes.hotelsName),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isHovered ? AppColors.gold : AppColors.navy,
                  foregroundColor: _isHovered ? AppColors.navyDark : AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: Text(
                  'Book Room',
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
    );
  }
}

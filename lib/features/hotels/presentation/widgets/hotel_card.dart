import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../data/models/hotel_model.dart';
import 'hotel_details_modal.dart';

class HotelCard extends StatefulWidget {
  final HotelModel hotel;
  final bool isMobile;
  final VoidCallback onBook;

  const HotelCard({
    super.key,
    required this.hotel,
    required this.isMobile,
    required this.onBook,
  });

  @override
  State<HotelCard> createState() => _HotelCardState();
}

class _HotelCardState extends State<HotelCard> {
  bool _isHovered = false;

  void _openDetails() {
    showDialog(
      context: context,
      builder: (ctx) => HotelDetailsModal(
        hotel: widget.hotel,
        onBook: widget.onBook,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;
    final isArabic = context.isArabic;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0.0, _isHovered ? -4.0 : 0.0, 0.0),
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
                  ? AppColors.navyDark.withValues(alpha: 0.12)
                  : AppColors.navyDark.withValues(alpha: 0.04),
              blurRadius: _isHovered ? 20 : 10,
              offset: Offset(0, _isHovered ? 8 : 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 580;

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 4,
                      child: _buildImageSection(hotel, isHorizontal: true),
                    ),
                    Expanded(
                      flex: 6,
                      child: _buildInfoSection(hotel, isArabic, isWide: true),
                    ),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildImageSection(hotel, isHorizontal: false),
                  Expanded(
                    child: _buildInfoSection(hotel, isArabic, isWide: false),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(HotelModel hotel, {required bool isHorizontal}) {
    return SizedBox(
      height: isHorizontal ? double.infinity : 190,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedScale(
            scale: _isHovered ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            child: Image.network(
              hotel.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.navyMedium,
                child: const Icon(Icons.hotel_rounded, color: AppColors.gray400, size: 40),
              ),
            ),
          ),
          // Gradient shadow overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.45),
                  ],
                ),
              ),
            ),
          ),
          // Badge
          if (hotel.badge != null && hotel.badge!.isNotEmpty)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: Text(
                  hotel.badge!,
                  style: AppTextStyles.labelSM.copyWith(
                    color: AppColors.navyDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          // Star rating on image
          Positioned(
            bottom: 10,
            left: 12,
            child: Row(
              children: List.generate(
                hotel.stars.clamp(1, 5),
                (i) => const Icon(Icons.star_rounded, color: AppColors.gold, size: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(HotelModel hotel, bool isArabic, {required bool isWide}) {
    final displayName = hotel.localizedName(isArabic);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location and Rating Score
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 13, color: AppColors.royalBlue),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${hotel.city}${hotel.country.isNotEmpty ? ', ${hotel.country}' : ''}',
                  style: AppTextStyles.labelSM.copyWith(
                    color: AppColors.royalBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.gold, size: 13),
                    const SizedBox(width: 3),
                    Text(
                      '${hotel.rating}',
                      style: AppTextStyles.labelSM.copyWith(
                        color: AppColors.navyDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Hotel Name
          Text(
            displayName,
            style: AppTextStyles.h4.copyWith(
              color: AppColors.navyDark,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),

          // Room Type
          Text(
            hotel.roomType,
            style: AppTextStyles.bodySM.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Available Amenities Badges
          if (hotel.amenities.isNotEmpty) ...[
            SizedBox(
              height: 26,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: hotel.amenities.take(3).length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, i) {
                  final amenity = hotel.amenities[i];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Center(
                      child: Text(
                        amenity,
                        style: AppTextStyles.labelSM.copyWith(
                          fontSize: 10,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          const Spacer(),
          const Divider(color: AppColors.borderLight, height: 16),

          // Price and Actions
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isArabic ? 'ابتداءً من' : 'STARTING FROM',
                      style: AppTextStyles.overline.copyWith(
                        color: AppColors.textLightMuted,
                        fontSize: 8.5,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: Text(
                            '${hotel.currency} ${hotel.price.toInt()}',
                            style: AppTextStyles.h4.copyWith(
                              color: AppColors.royalBlueDark,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          isArabic ? ' / ليلة' : ' / n',
                          style: AppTextStyles.bodySM.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(
                    onPressed: _openDetails,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.navyDark,
                      side: const BorderSide(color: AppColors.borderLight, width: 1.5),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      minimumSize: const Size(80, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      isArabic ? 'التفاصيل' : 'Details',
                      style: AppTextStyles.labelSM.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: widget.onBook,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isHovered ? AppColors.gold : AppColors.navy,
                      foregroundColor: _isHovered ? AppColors.navyDark : AppColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      minimumSize: const Size(80, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: Text(
                      isArabic ? 'احجز الآن' : 'Book Now',
                      style: AppTextStyles.labelSM.copyWith(
                        color: _isHovered ? AppColors.navyDark : AppColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../data/models/hotel_model.dart';

class HotelDetailsModal extends StatefulWidget {
  final HotelModel hotel;
  final VoidCallback onBook;

  const HotelDetailsModal({
    super.key,
    required this.hotel,
    required this.onBook,
  });

  @override
  State<HotelDetailsModal> createState() => _HotelDetailsModalState();
}

class _HotelDetailsModalState extends State<HotelDetailsModal> {
  int _selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;
    final isArabic = context.isArabic;
    final allImages = [
      if (hotel.imageUrl.isNotEmpty) hotel.imageUrl,
      ...hotel.galleryImages,
    ];

    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 760,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          children: [
            // Header with Close
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Row(
                              children: List.generate(
                                hotel.stars,
                                (i) => const Icon(
                                  Icons.star_rounded,
                                  color: AppColors.gold,
                                  size: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${hotel.rating} ★',
                                style: const TextStyle(
                                  color: AppColors.navyDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          hotel.localizedName(isArabic),
                          style: AppTextStyles.h3.copyWith(
                            fontSize: 22,
                            color: AppColors.navyDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: AppColors.royalBlue,
                              size: 15,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              hotel.location,
                              style: AppTextStyles.bodySM.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.gray500,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.borderLight, height: 1),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Image & Gallery
                    if (allImages.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.network(
                            allImages[_selectedImageIndex.clamp(
                              0,
                              allImages.length - 1,
                            )],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.surfaceLight,
                              child: const Icon(
                                Icons.hotel_rounded,
                                size: 48,
                                color: AppColors.gray400,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (allImages.length > 1) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 70,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: allImages.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, i) {
                              final isSelected = _selectedImageIndex == i;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedImageIndex = i),
                                child: Container(
                                  width: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.royalBlue
                                          : AppColors.borderLight,
                                      width: isSelected ? 2.5 : 1.0,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      allImages[i],
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Center(
                                            child: Icon(
                                              Icons.image_not_supported_rounded,
                                              size: 20,
                                            ),
                                          ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],

                    // Room Type & Description
                    Text(
                      isArabic ? 'عن هذا الفندق' : 'About This Hotel',
                      style: AppTextStyles.h4.copyWith(
                        fontSize: 16,
                        color: AppColors.navyDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hotel.description.isNotEmpty
                          ? hotel.description
                          : (isArabic
                                ? 'إقامة فاخرة تتميز بأرقى معايير الضيافة والخدمات الفندقية العالمية.'
                                : 'A world-class luxury sanctuary with dedicated VIP concierge, supreme dining, and exquisite rooms.'),
                      style: AppTextStyles.bodyMD.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Amenities Section
                    if (hotel.amenities.isNotEmpty) ...[
                      Text(
                        isArabic
                            ? 'المرافق والخدمات المتاحة'
                            : 'Featured Amenities',
                        style: AppTextStyles.h4.copyWith(
                          fontSize: 16,
                          color: AppColors.navyDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: hotel.amenities.map((amenity) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.royalBlue,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  amenity,
                                  style: AppTextStyles.labelMD.copyWith(
                                    color: AppColors.navyDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),

            // Footer with Price and Book Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: AppColors.surfaceLight,
                border: Border(top: BorderSide(color: AppColors.borderLight)),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isArabic ? 'ابتداءً من' : 'STARTING FROM',
                        style: AppTextStyles.overline.copyWith(
                          color: AppColors.textLightMuted,
                          fontSize: 10,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${hotel.currency} ${hotel.price.toInt()}',
                            style: AppTextStyles.h3.copyWith(
                              color: AppColors.royalBlueDark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            isArabic ? ' / ليلة' : ' / night',
                            style: AppTextStyles.bodySM.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          isArabic ? 'إغلاق' : 'Close',
                          style: const TextStyle(color: AppColors.gray600),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TravellaButton(
                        label: isArabic
                            ? 'حجز / طلب عرض سعر'
                            : 'Book / Request',
                        leadingIcon: Icons.calendar_month_rounded,
                        variant: TravellaButtonVariant.gold,
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onBook();
                        },
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

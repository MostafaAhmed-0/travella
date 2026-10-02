import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../data/models/airport_transfer_model.dart';

class TransferVehicleCard extends StatefulWidget {
  final TransferVehicleModel vehicle;
  final TransferType currentTransferType;
  final VoidCallback onBook;

  const TransferVehicleCard({
    super.key,
    required this.vehicle,
    required this.currentTransferType,
    required this.onBook,
  });

  @override
  State<TransferVehicleCard> createState() => _TransferVehicleCardState();
}

class _TransferVehicleCardState extends State<TransferVehicleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 960;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered ? AppColors.gold : AppColors.gray200,
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? AppColors.gold.withValues(alpha: 0.18)
                  : AppColors.navy.withValues(alpha: 0.06),
              blurRadius: _isHovered ? 24 : 12,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        child: isMobile
            ? _buildMobileLayout(isArabic)
            : _buildDesktopLayout(isArabic),
      ),
    );
  }

  Widget _buildDesktopLayout(bool isArabic) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Vehicle Image with Badge
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 190,
              height: 130,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildVehicleImage(),
                  Positioned(
                    top: 10,
                    left: isArabic ? null : 10,
                    right: isArabic ? 10 : null,
                    child: _buildCategoryBadge(isArabic),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 18),

          // Vehicle Details & Capacities
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.vehicle.getLocalizedName(isArabic),
                        style: AppTextStyles.h6.copyWith(
                          color: AppColors.navyDark,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildRoutePill(isArabic),
                  ],
                ),
                const SizedBox(height: 8),

                // Capacities & Duration Pills
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildInfoBadge(
                      icon: Icons.person_rounded,
                      label:
                          '${widget.vehicle.passengerCapacity} ${isArabic ? 'ركاب' : 'Seats'}',
                      color: AppColors.royalBlue,
                    ),
                    _buildInfoBadge(
                      icon: Icons.luggage_rounded,
                      label:
                          '${widget.vehicle.luggageCapacity} ${isArabic ? 'حقائب' : 'Bags'}',
                      color: AppColors.coral,
                    ),
                    _buildInfoBadge(
                      icon: Icons.timer_outlined,
                      label: widget.vehicle.estimatedDuration,
                      color: AppColors.goldDark,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Key Features Chips
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children:
                      (isArabic && widget.vehicle.featuresAr != null
                              ? widget.vehicle.featuresAr!
                              : widget.vehicle.features)
                          .take(3)
                          .map(
                            (feat) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.lightGray,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.success,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    feat,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Vertical divider
          Container(height: 110, width: 1, color: AppColors.gray200),
          const SizedBox(width: 16),

          // Price & Book CTA
          SizedBox(
            width: 175,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isArabic ? 'السعر الإجمالي الثابت' : 'All-Inclusive Fare',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      widget.vehicle.currency == 'USD'
                          ? '\$'
                          : widget.vehicle.currency,
                      style: AppTextStyles.h6.copyWith(
                        color: AppColors.navy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.vehicle.basePrice.toStringAsFixed(0),
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.navyDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                Text(
                  isArabic
                      ? 'يشمل الضرائب والانتظار'
                      : 'Taxes & wait time incl.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 10),
                TravellaButton(
                  label: context.tr('transfers_request_btn'),
                  variant: TravellaButtonVariant.gold,
                  size: TravellaButtonSize.sm,
                  fullWidth: true,
                  leadingIcon: Icons.calendar_today_rounded,
                  onPressed: widget.onBook,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image on top
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: SizedBox(
            height: 160,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildVehicleImage(),
                Positioned(
                  top: 12,
                  left: isArabic ? null : 12,
                  right: isArabic ? 12 : null,
                  child: _buildCategoryBadge(isArabic),
                ),
                Positioned(
                  bottom: 12,
                  right: isArabic ? null : 12,
                  left: isArabic ? 12 : null,
                  child: _buildRoutePill(isArabic),
                ),
              ],
            ),
          ),
        ),

        // Body
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.vehicle.getLocalizedName(isArabic),
                style: AppTextStyles.h6.copyWith(
                  color: AppColors.navyDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Capacity pills
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildInfoBadge(
                    icon: Icons.person_rounded,
                    label:
                        '${widget.vehicle.passengerCapacity} ${isArabic ? 'ركاب' : 'Seats'}',
                    color: AppColors.royalBlue,
                  ),
                  _buildInfoBadge(
                    icon: Icons.luggage_rounded,
                    label:
                        '${widget.vehicle.luggageCapacity} ${isArabic ? 'حقائب' : 'Bags'}',
                    color: AppColors.coral,
                  ),
                  _buildInfoBadge(
                    icon: Icons.timer_outlined,
                    label: widget.vehicle.estimatedDuration,
                    color: AppColors.goldDark,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Features
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children:
                    (isArabic && widget.vehicle.featuresAr != null
                            ? widget.vehicle.featuresAr!
                            : widget.vehicle.features)
                        .take(2)
                        .map(
                          (feat) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.lightGray,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '• $feat',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.gray200),
              const SizedBox(height: 12),

              // Bottom Price + CTA
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'السعر الثابت' : 'Fixed Fare',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '\$${widget.vehicle.basePrice.toStringAsFixed(0)}',
                            style: AppTextStyles.h4.copyWith(
                              color: AppColors.navyDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.vehicle.currency,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  TravellaButton(
                    label: context.tr('transfers_request_btn'),
                    variant: TravellaButtonVariant.gold,
                    size: TravellaButtonSize.sm,
                    leadingIcon: Icons.calendar_today_rounded,
                    onPressed: widget.onBook,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleImage() {
    if (widget.vehicle.imageUrl != null &&
        widget.vehicle.imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.vehicle.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          color: AppColors.navyMedium,
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.gold,
              ),
            ),
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          color: AppColors.navyMedium,
          child: const Icon(
            Icons.directions_car_rounded,
            color: AppColors.gold,
            size: 40,
          ),
        ),
      );
    }

    return Container(
      color: AppColors.navyMedium,
      child: const Icon(
        Icons.directions_car_rounded,
        color: AppColors.gold,
        size: 40,
      ),
    );
  }

  Widget _buildCategoryBadge(bool isArabic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.navyDark.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
      ),
      child: Text(
        widget.vehicle.getVehicleTypeDisplayAr(isArabic),
        style: const TextStyle(
          color: AppColors.gold,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildRoutePill(bool isArabic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.royalBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.royalBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.currentTransferType.icon,
            color: AppColors.royalBlue,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            widget.currentTransferType.getLocalizedLabel(isArabic),
            style: const TextStyle(
              color: AppColors.royalBlue,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/app_translations.dart';
import '../../data/models/flight_models.dart';

class FlightResultCard extends StatefulWidget {
  final FlightOffer offer;
  final bool isMobile;
  final VoidCallback onSelect;
  final VoidCallback? onViewDetails;

  const FlightResultCard({
    super.key,
    required this.offer,
    required this.isMobile,
    required this.onSelect,
    this.onViewDetails,
  });

  @override
  State<FlightResultCard> createState() => _FlightResultCardState();
}

class _FlightResultCardState extends State<FlightResultCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
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
                  ? AppColors.navy.withValues(alpha: 0.12)
                  : AppColors.navy.withValues(alpha: 0.04),
              blurRadius: _isHovered ? 24 : 12,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(widget.isMobile ? 18 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Row: Airline Logo, Name, Flight Number & Tags ──────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Airline Logo / Branded Emblem
                  _buildAirlineLogo(offer),
                  const SizedBox(width: 14),

                  // Airline name & flight number
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              offer.airlineName,
                              style: AppTextStyles.h4.copyWith(
                                color: AppColors.navyDark,
                                fontSize: widget.isMobile ? 16 : 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: Text(
                                offer.flightNumber,
                                style: AppTextStyles.labelSM.copyWith(
                                  color: AppColors.royalBlueDark,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${offer.aircraft} • ${offer.cabinClass}',
                          style: AppTextStyles.bodySM.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Badges / Tags
                  if (!widget.isMobile && offer.tags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: offer.tags.take(2).map((t) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            t,
                            style: AppTextStyles.labelSM.copyWith(
                              color: AppColors.goldDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: AppColors.borderLight),
              const SizedBox(height: 18),

              // ── Middle Itinerary Visualizer: Departure ➔ Route ➔ Arrival ───
              widget.isMobile
                  ? _buildMobileFlightTimes(offer, isArabic)
                  : _buildDesktopFlightTimes(offer, isArabic),

              const SizedBox(height: 18),
              const Divider(color: AppColors.borderLight),
              const SizedBox(height: 14),

              // ── Bottom Action Row: Baggage, Price & Select/Details CTA ──────
              _buildBottomActionRow(offer, isArabic),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAirlineLogo(FlightOffer offer) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: offer.brandingPrimaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: offer.brandingPrimaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Center(
        child: Text(
          offer.airlineCode,
          style: TextStyle(
            color: offer.brandingPrimaryColor,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopFlightTimes(FlightOffer offer, bool isArabic) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Departure
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                offer.departureTime,
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.navyDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    offer.departureAirportCode,
                    style: AppTextStyles.labelLG.copyWith(
                      color: AppColors.royalBlue,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      offer.departureCity,
                      style: AppTextStyles.bodySM.copyWith(color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Route Flight Visualizer
        Expanded(
          flex: 4,
          child: Column(
            children: [
              Text(
                offer.durationFormatted,
                style: AppTextStyles.labelSM.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 2,
                    color: AppColors.borderLight,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.royalBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.gold, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.flight_takeoff_rounded,
                          size: 14,
                          color: AppColors.navyDark,
                        ),
                      ),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: offer.isNonStop ? AppColors.successLight : AppColors.warningLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  offer.stopsLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: offer.isNonStop ? AppColors.successGreen : AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Arrival
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                offer.arrivalTime,
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.navyDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      offer.arrivalCity,
                      style: AppTextStyles.bodySM.copyWith(color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    offer.arrivalAirportCode,
                    style: AppTextStyles.labelLG.copyWith(
                      color: AppColors.royalBlue,
                      fontWeight: FontWeight.w800,
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

  Widget _buildMobileFlightTimes(FlightOffer offer, bool isArabic) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.departureTime,
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.navyDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${offer.departureAirportCode} • ${offer.departureCity}',
                  style: AppTextStyles.labelSM.copyWith(color: AppColors.royalBlue),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  offer.durationFormatted,
                  style: AppTextStyles.labelSM.copyWith(color: AppColors.textSecondary),
                ),
                const Icon(Icons.arrow_forward_rounded, color: AppColors.gold, size: 16),
                Text(
                  offer.stopsLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: offer.isNonStop ? AppColors.successGreen : AppColors.warning,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  offer.arrivalTime,
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.navyDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${offer.arrivalAirportCode} • ${offer.arrivalCity}',
                  style: AppTextStyles.labelSM.copyWith(color: AppColors.royalBlue),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomActionRow(FlightOffer offer, bool isArabic) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: [
        // Baggage & Amenities
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.luggage_outlined, size: 16, color: AppColors.royalBlue),
            const SizedBox(width: 6),
            Text(
              offer.baggageAllowance,
              style: AppTextStyles.bodySM.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            if (offer.hasWifi) ...[
              const SizedBox(width: 10),
              const Icon(Icons.wifi_rounded, size: 14, color: AppColors.gray400),
            ],
            if (offer.hasMeals) ...[
              const SizedBox(width: 6),
              const Icon(Icons.restaurant_rounded, size: 14, color: AppColors.gray400),
            ],
          ],
        ),

        // Price & Select CTA
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isArabic ? 'سعر المقعد التقديري' : 'ESTIMATED FARE',
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.textLightMuted,
                    fontSize: 9,
                  ),
                ),
                Text(
                  '${offer.currency} ${offer.price.toInt()}',
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.royalBlueDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            ElevatedButton(
              onPressed: widget.onSelect,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isHovered ? AppColors.gold : AppColors.navy,
                foregroundColor: _isHovered ? AppColors.navyDark : AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isArabic ? 'طلب حجز واستفسار' : 'Select / Inquire',
                    style: AppTextStyles.labelMD.copyWith(
                      color: _isHovered ? AppColors.navyDark : AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: _isHovered ? AppColors.navyDark : AppColors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/traveler_selector.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../data/models/airport_transfer_model.dart';
import '../cubit/transfers_cubit.dart';
import '../cubit/transfers_state.dart';

class TransferSearchSection extends StatefulWidget {
  final TransfersState state;
  final TransfersCubit cubit;

  const TransferSearchSection({
    super.key,
    required this.state,
    required this.cubit,
  });

  @override
  State<TransferSearchSection> createState() => _TransferSearchSectionState();
}

class _TransferSearchSectionState extends State<TransferSearchSection> {
  late TextEditingController _pickupController;
  late TextEditingController _dropoffController;

  static const List<String> _popularAirports = [
    'Cairo International Airport (CAI)',
    'Sphinx International Airport (SPX)',
    'Hurghada International Airport (HRG)',
    'Sharm El Sheikh International Airport (SSH)',
    'Luxor International Airport (LXR)',
    'Aswan International Airport (ASW)',
    'Borg El Arab Airport Alexandria (HBE)',
    'Istanbul Airport (IST)',
    'Dubai International Airport (DXB)',
    'Jeddah King Abdulaziz Airport (JED)',
  ];

  static const List<String> _popularDropoffs = [
    'Downtown Cairo & Tahrir Square',
    'Giza Pyramids & Grand Egyptian Museum Area',
    'New Cairo & Fifth Settlement',
    'Zamalek & Nile Island Hotels',
    'Nasr City & Heliopolis',
    '6th of October City & Sheikh Zayed',
    'Alexandria Seafront & Corniche Hotels',
    'Hurghada Resort Zone & El Gouna',
    'Sharm El Sheikh Naama Bay Hotels',
  ];

  @override
  void initState() {
    super.initState();
    _pickupController = TextEditingController(text: widget.state.pickupLocation);
    _dropoffController = TextEditingController(text: widget.state.dropoffLocation);
  }

  @override
  void didUpdateWidget(covariant TransferSearchSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.pickupLocation != widget.state.pickupLocation) {
      _pickupController.text = widget.state.pickupLocation;
    }
    if (oldWidget.state.dropoffLocation != widget.state.dropoffLocation) {
      _dropoffController.text = widget.state.dropoffLocation;
    }
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }

  void _swapLocations() {
    final temp = _pickupController.text;
    _pickupController.text = _dropoffController.text;
    _dropoffController.text = temp;
    widget.cubit.updateSearchLocations(
      pickup: _pickupController.text,
      dropoff: _dropoffController.text,
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.state.pickupDate.isBefore(now) ? now : widget.state.pickupDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.navy,
              onPrimary: AppColors.gold,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      widget.cubit.updateDateTime(date: picked, time: widget.state.pickupTime);
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay initial = const TimeOfDay(hour: 12, minute: 0);
    try {
      final parts = widget.state.pickupTime.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        int min = int.parse(parts[1].split(' ')[0]);
        if (widget.state.pickupTime.toUpperCase().contains('PM') && hour < 12) {
          hour += 12;
        } else if (widget.state.pickupTime.toUpperCase().contains('AM') && hour == 12) {
          hour = 0;
        }
        initial = TimeOfDay(hour: hour, minute: min);
      }
    } catch (_) {}

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.navy,
              onPrimary: AppColors.gold,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      final formattedTime = picked.format(context);
      widget.cubit.updateDateTime(date: widget.state.pickupDate, time: formattedTime);
    }
  }

  Future<void> _openPassengerSelector() async {
    final result = await showTravelerSelectorModal(
      context,
      initial: widget.state.passengers,
      showRooms: false,
      title: context.isArabic ? 'تحديد عدد الركاب والأطفال' : 'Configure Passengers & Child Ages',
    );

    if (result != null) {
      widget.cubit.updatePassengers(result);
    }
  }

  void _showLocationPicker({required bool isPickup}) {
    final list = isPickup ? _popularAirports : _popularDropoffs;
    final isArabic = context.isArabic;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.7,
          ),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Icon(
                      isPickup ? Icons.flight_land_rounded : Icons.location_on_rounded,
                      color: AppColors.navy,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isPickup
                          ? (isArabic ? 'اختر مكان الاستلام' : 'Select Pickup Point')
                          : (isArabic ? 'اختر مكان الوصول' : 'Select Drop-off Destination'),
                      style: AppTextStyles.h6.copyWith(color: AppColors.navy),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.lightGray),
                  itemBuilder: (ctx, i) {
                    final item = list[i];
                    return ListTile(
                      leading: Icon(
                        isPickup ? Icons.local_airport_rounded : Icons.hotel_rounded,
                        color: AppColors.gold,
                        size: 20,
                      ),
                      title: Text(
                        item,
                        style: AppTextStyles.bodySM.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.gray400),
                      onTap: () {
                        Navigator.pop(ctx);
                        if (isPickup) {
                          _pickupController.text = item;
                          widget.cubit.updateSearchLocations(
                            pickup: item,
                            dropoff: _dropoffController.text,
                          );
                        } else {
                          _dropoffController.text = item;
                          widget.cubit.updateSearchLocations(
                            pickup: _pickupController.text,
                            dropoff: item,
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 700 && screenWidth < 1024;
    final isArabic = context.isArabic;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.navyDark,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.35),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      padding: EdgeInsets.all(isDesktop ? 28 : (isTablet ? 22 : 16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Transfer Route Type Selector Tabs ──
          _buildTransferTypeTabs(isArabic),
          const SizedBox(height: 20),

          // ── Main Input Fields Matrix ──
          if (isDesktop)
            _buildDesktopLayout(isArabic)
          else if (isTablet)
            _buildTabletLayout(isArabic)
          else
            _buildMobileLayout(isArabic),
        ],
      ),
    );
  }

  Widget _buildTransferTypeTabs(bool isArabic) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: TransferType.values.map((type) {
          final isSelected = widget.state.transferType == type;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => widget.cubit.updateTransferType(type),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.gold : AppColors.navyMedium,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.gold : AppColors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      type.icon,
                      size: 18,
                      color: isSelected ? AppColors.navyDark : AppColors.textOnDarkMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      type.getLocalizedLabel(isArabic),
                      style: AppTextStyles.labelMD.copyWith(
                        color: isSelected ? AppColors.navyDark : AppColors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDesktopLayout(bool isArabic) {
    final dateFormat = DateFormat('EEE, MMM d, yyyy');

    return Column(
      children: [
        Row(
          children: [
            // Pickup
            Expanded(
              flex: 5,
              child: _buildInputTile(
                icon: Icons.flight_land_rounded,
                label: context.tr('transfers_pickup_loc'),
                controller: _pickupController,
                hint: 'e.g. Cairo Airport (CAI)',
                onTap: () => _showLocationPicker(isPickup: true),
                onChanged: (val) => widget.cubit.updateSearchLocations(pickup: val, dropoff: _dropoffController.text),
              ),
            ),
            const SizedBox(width: 8),
            // Swap button
            IconButton(
              onPressed: _swapLocations,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.navyMedium,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.swap_horiz_rounded, color: AppColors.gold, size: 20),
              ),
              tooltip: isArabic ? 'تبديل الأماكن' : 'Swap Locations',
            ),
            const SizedBox(width: 8),
            // Dropoff
            Expanded(
              flex: 5,
              child: _buildInputTile(
                icon: Icons.location_on_rounded,
                label: context.tr('transfers_dropoff_loc'),
                controller: _dropoffController,
                hint: 'e.g. Hotel, City, Address',
                onTap: () => _showLocationPicker(isPickup: false),
                onChanged: (val) => widget.cubit.updateSearchLocations(pickup: _pickupController.text, dropoff: val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            // Date
            Expanded(
              flex: 3,
              child: _buildClickableTile(
                icon: Icons.calendar_today_rounded,
                label: context.tr('transfers_pickup_date'),
                value: dateFormat.format(widget.state.pickupDate),
                onTap: _pickDate,
              ),
            ),
            const SizedBox(width: 12),
            // Time
            Expanded(
              flex: 2,
              child: _buildClickableTile(
                icon: Icons.access_time_rounded,
                label: context.tr('transfers_pickup_time'),
                value: widget.state.pickupTime,
                onTap: _pickTime,
              ),
            ),
            const SizedBox(width: 12),
            // Passengers
            Expanded(
              flex: 3,
              child: _buildClickableTile(
                icon: Icons.people_alt_rounded,
                label: context.tr('transfers_passengers'),
                value: widget.state.passengers.formattedSummary(isArabic: isArabic, includeRooms: false),
                onTap: _openPassengerSelector,
              ),
            ),
            const SizedBox(width: 12),
            // Luggage
            Expanded(
              flex: 2,
              child: _buildLuggageCounterTile(isArabic),
            ),
            const SizedBox(width: 16),
            // Search CTA
            SizedBox(
              height: 56,
              child: TravellaButton(
                label: context.tr('btn_search'),
                variant: TravellaButtonVariant.gold,
                size: TravellaButtonSize.lg,
                leadingIcon: Icons.search_rounded,
                onPressed: () {
                  widget.cubit.updateSearchLocations(
                    pickup: _pickupController.text,
                    dropoff: _dropoffController.text,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabletLayout(bool isArabic) {
    final dateFormat = DateFormat('EEE, MMM d');

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInputTile(
                icon: Icons.flight_land_rounded,
                label: context.tr('transfers_pickup_loc'),
                controller: _pickupController,
                hint: 'e.g. Cairo Airport (CAI)',
                onTap: () => _showLocationPicker(isPickup: true),
                onChanged: (val) => widget.cubit.updateSearchLocations(pickup: val, dropoff: _dropoffController.text),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _swapLocations,
              icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.gold),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildInputTile(
                icon: Icons.location_on_rounded,
                label: context.tr('transfers_dropoff_loc'),
                controller: _dropoffController,
                hint: 'e.g. Hotel, City, Address',
                onTap: () => _showLocationPicker(isPickup: false),
                onChanged: (val) => widget.cubit.updateSearchLocations(pickup: _pickupController.text, dropoff: val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildClickableTile(
                icon: Icons.calendar_today_rounded,
                label: context.tr('transfers_pickup_date'),
                value: dateFormat.format(widget.state.pickupDate),
                onTap: _pickDate,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildClickableTile(
                icon: Icons.access_time_rounded,
                label: context.tr('transfers_pickup_time'),
                value: widget.state.pickupTime,
                onTap: _pickTime,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildClickableTile(
                icon: Icons.people_alt_rounded,
                label: context.tr('transfers_passengers'),
                value: widget.state.passengers.formattedSummary(isArabic: isArabic, includeRooms: false),
                onTap: _openPassengerSelector,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: _buildLuggageCounterTile(isArabic),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TravellaButton(
          label: context.tr('btn_search'),
          variant: TravellaButtonVariant.gold,
          size: TravellaButtonSize.lg,
          fullWidth: true,
          leadingIcon: Icons.search_rounded,
          onPressed: () {
            widget.cubit.updateSearchLocations(
              pickup: _pickupController.text,
              dropoff: _dropoffController.text,
            );
          },
        ),
      ],
    );
  }

  Widget _buildMobileLayout(bool isArabic) {
    final dateFormat = DateFormat('EEE, MMM d, yyyy');

    return Column(
      children: [
        _buildInputTile(
          icon: Icons.flight_land_rounded,
          label: context.tr('transfers_pickup_loc'),
          controller: _pickupController,
          hint: 'e.g. Cairo Airport (CAI)',
          onTap: () => _showLocationPicker(isPickup: true),
          onChanged: (val) => widget.cubit.updateSearchLocations(pickup: val, dropoff: _dropoffController.text),
        ),
        Center(
          child: IconButton(
            onPressed: _swapLocations,
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.navyMedium,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
              ),
              child: const Icon(Icons.swap_vert_rounded, color: AppColors.gold, size: 18),
            ),
          ),
        ),
        _buildInputTile(
          icon: Icons.location_on_rounded,
          label: context.tr('transfers_dropoff_loc'),
          controller: _dropoffController,
          hint: 'e.g. Hotel, City, Address',
          onTap: () => _showLocationPicker(isPickup: false),
          onChanged: (val) => widget.cubit.updateSearchLocations(pickup: _pickupController.text, dropoff: val),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildClickableTile(
                icon: Icons.calendar_today_rounded,
                label: context.tr('transfers_pickup_date'),
                value: dateFormat.format(widget.state.pickupDate),
                onTap: _pickDate,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildClickableTile(
                icon: Icons.access_time_rounded,
                label: context.tr('transfers_pickup_time'),
                value: widget.state.pickupTime,
                onTap: _pickTime,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildClickableTile(
                icon: Icons.people_alt_rounded,
                label: context.tr('transfers_passengers'),
                value: widget.state.passengers.formattedSummary(isArabic: isArabic, includeRooms: false),
                onTap: _openPassengerSelector,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: _buildLuggageCounterTile(isArabic),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TravellaButton(
          label: context.tr('btn_search'),
          variant: TravellaButtonVariant.gold,
          size: TravellaButtonSize.lg,
          fullWidth: true,
          leadingIcon: Icons.search_rounded,
          onPressed: () {
            widget.cubit.updateSearchLocations(
              pickup: _pickupController.text,
              dropoff: _dropoffController.text,
            );
          },
        ),
      ],
    );
  }

  Widget _buildInputTile({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required String hint,
    required VoidCallback onTap,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navyMedium,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.gold, size: 14),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: AppTextStyles.labelSM.copyWith(
                  color: AppColors.gold,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.isArabic ? 'اقتراحات' : 'Browse',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.arrow_drop_down_rounded, color: AppColors.gold, size: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              cursorColor: AppColors.navy,
              style: AppTextStyles.bodySM.copyWith(
                color: AppColors.navyDark,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 6),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: hint,
                hintStyle: AppTextStyles.bodySM.copyWith(
                  color: AppColors.gray500,
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.navyMedium,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.gold, size: 14),
                const SizedBox(width: 6),
                Text(
                  label.toUpperCase(),
                  style: AppTextStyles.labelSM.copyWith(
                    color: AppColors.gold,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(
                value,
                style: AppTextStyles.bodySM.copyWith(
                  color: AppColors.navyDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLuggageCounterTile(bool isArabic) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navyMedium,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.luggage_rounded, color: AppColors.gold, size: 14),
              const SizedBox(width: 6),
              Text(
                (isArabic ? 'الحقائب' : 'Luggage').toUpperCase(),
                style: AppTextStyles.labelSM.copyWith(
                  color: AppColors.gold,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                  icon: const Icon(Icons.remove_circle_outline, color: AppColors.navyDark, size: 18),
                  onPressed: () {
                    if (widget.state.luggageCount > 0) {
                      widget.cubit.updateLuggage(widget.state.luggageCount - 1);
                    }
                  },
                ),
                Text(
                  '${widget.state.luggageCount} ${isArabic ? 'حقائب' : 'Bags'}',
                  style: AppTextStyles.bodySM.copyWith(
                    color: AppColors.navyDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                  icon: const Icon(Icons.add_circle_outline, color: AppColors.navyDark, size: 18),
                  onPressed: () {
                    widget.cubit.updateLuggage(widget.state.luggageCount + 1);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

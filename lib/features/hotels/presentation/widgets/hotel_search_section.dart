import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/traveler_selector.dart';
import '../../../../core/localization/app_translations.dart';

class HotelSearchSection extends StatefulWidget {
  final String initialDestination;
  final DateTime? initialCheckIn;
  final DateTime? initialCheckOut;
  final TravelerSelection initialTravelers;
  final void Function({
    required String destination,
    required DateTime checkIn,
    required DateTime checkOut,
    required TravelerSelection travelers,
  })
  onSearch;

  const HotelSearchSection({
    super.key,
    this.initialDestination = '',
    this.initialCheckIn,
    this.initialCheckOut,
    this.initialTravelers = const TravelerSelection(
      adults: 2,
      children: 0,
      childAges: [],
      rooms: 1,
    ),
    required this.onSearch,
  });

  @override
  State<HotelSearchSection> createState() => _HotelSearchSectionState();
}

class _HotelSearchSectionState extends State<HotelSearchSection> {
  late TextEditingController _destCtrl;
  late DateTime _checkIn;
  late DateTime _checkOut;
  late TravelerSelection _travelers;
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _destCtrl = TextEditingController(text: widget.initialDestination);
    final now = DateTime.now();
    _checkIn = widget.initialCheckIn ?? now.add(const Duration(days: 7));
    _checkOut = widget.initialCheckOut ?? _checkIn.add(const Duration(days: 5));
    _travelers = widget.initialTravelers;
  }

  @override
  void didUpdateWidget(covariant HotelSearchSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDestination != oldWidget.initialDestination &&
        widget.initialDestination != _destCtrl.text) {
      _destCtrl.text = widget.initialDestination;
    }
  }

  @override
  void dispose() {
    _destCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCheckInDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkIn,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.royalBlue,
            onPrimary: AppColors.white,
            surface: AppColors.white,
            onSurface: AppColors.navyDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _checkIn = picked;
        if (_checkOut.isBefore(_checkIn) ||
            _checkOut.isAtSameMomentAs(_checkIn)) {
          _checkOut = _checkIn.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _pickCheckOutDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkOut.isAfter(_checkIn)
          ? _checkOut
          : _checkIn.add(const Duration(days: 1)),
      firstDate: _checkIn.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.royalBlue,
            onPrimary: AppColors.white,
            surface: AppColors.white,
            onSurface: AppColors.navyDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _checkOut = picked;
      });
    }
  }

  Future<void> _pickTravelers() async {
    final result = await showTravelerSelectorModal(
      context,
      initial: _travelers,
      showRooms: true,
      title: context.isArabic
          ? 'تحديد النزلاء والغرف'
          : 'Select Guests & Rooms',
    );
    if (result != null) {
      setState(() {
        _travelers = result;
      });
    }
  }

  void _handleSearch() {
    widget.onSearch(
      destination: _destCtrl.text.trim(),
      checkIn: _checkIn,
      checkOut: _checkOut,
      travelers: _travelers,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;
    final isMobile = AppBreakpoints.isMobile(context);
    final isTablet = AppBreakpoints.isTablet(context);
    final nights = _checkOut.difference(_checkIn).inDays.clamp(1, 365);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyDark.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile)
            _buildMobileLayout(isArabic, nights)
          else if (isTablet)
            _buildTabletLayout(isArabic, nights)
          else
            _buildDesktopLayout(isArabic, nights),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(bool isArabic, int nights) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Destination field
        Expanded(flex: 3, child: _buildDestinationField(isArabic)),
        const SizedBox(width: 12),

        // Check-in date
        Expanded(
          flex: 2,
          child: _buildDateBox(
            label: isArabic ? 'تاريخ الوصول' : 'CHECK-IN',
            date: _dateFormat.format(_checkIn),
            icon: Icons.calendar_today_rounded,
            onTap: _pickCheckInDate,
          ),
        ),
        const SizedBox(width: 12),

        // Check-out date with nights pill
        Expanded(
          flex: 2,
          child: _buildDateBox(
            label: isArabic ? 'تاريخ المغادرة' : 'CHECK-OUT',
            date: _dateFormat.format(_checkOut),
            badge: '$nights ${isArabic ? 'ليالٍ' : 'nights'}',
            icon: Icons.event_available_rounded,
            onTap: _pickCheckOutDate,
          ),
        ),
        const SizedBox(width: 12),

        // Travelers & Rooms selector
        Expanded(flex: 3, child: _buildTravelersBox(isArabic)),
        const SizedBox(width: 16),

        // Search Button
        SizedBox(
          height: 56,
          child: TravellaButton(
            label: isArabic ? 'بحث عن الفنادق' : 'Search Hotels',
            leadingIcon: Icons.search_rounded,
            variant: TravellaButtonVariant.gold,
            size: TravellaButtonSize.lg,
            onPressed: _handleSearch,
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(bool isArabic, int nights) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildDestinationField(isArabic)),
            const SizedBox(width: 12),
            Expanded(child: _buildTravelersBox(isArabic)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _buildDateBox(
                label: isArabic ? 'تاريخ الوصول' : 'CHECK-IN',
                date: _dateFormat.format(_checkIn),
                icon: Icons.calendar_today_rounded,
                onTap: _pickCheckInDate,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateBox(
                label: isArabic ? 'تاريخ المغادرة' : 'CHECK-OUT',
                date: _dateFormat.format(_checkOut),
                badge: '$nights ${isArabic ? 'ليالٍ' : 'nights'}',
                icon: Icons.event_available_rounded,
                onTap: _pickCheckOutDate,
              ),
            ),
            const SizedBox(width: 14),
            SizedBox(
              height: 54,
              child: TravellaButton(
                label: isArabic ? 'بحث' : 'Search',
                leadingIcon: Icons.search_rounded,
                variant: TravellaButtonVariant.gold,
                onPressed: _handleSearch,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileLayout(bool isArabic, int nights) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDestinationField(isArabic),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateBox(
                label: isArabic ? 'الوصول' : 'CHECK-IN',
                date: _dateFormat.format(_checkIn),
                icon: Icons.calendar_today_rounded,
                onTap: _pickCheckInDate,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildDateBox(
                label: isArabic ? 'المغادرة' : 'CHECK-OUT',
                date: _dateFormat.format(_checkOut),
                badge: '$nights ${isArabic ? 'ليالٍ' : 'n'}',
                icon: Icons.event_available_rounded,
                onTap: _pickCheckOutDate,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTravelersBox(isArabic),
        const SizedBox(height: 16),
        TravellaButton(
          label: isArabic ? 'بحث عن الفنادق' : 'Search Hotels',
          leadingIcon: Icons.search_rounded,
          variant: TravellaButtonVariant.gold,
          size: TravellaButtonSize.lg,
          fullWidth: true,
          onPressed: _handleSearch,
        ),
      ],
    );
  }

  Widget _buildDestinationField(bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'الوجهة أو اسم الفندق' : 'DESTINATION / HOTEL',
          style: AppTextStyles.labelSM.copyWith(
            color: AppColors.textLightMuted,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _destCtrl,
          onSubmitted: (_) => _handleSearch(),
          decoration: InputDecoration(
            hintText: isArabic
                ? 'مثل: دبي، إسطنبول، باريس، ريتز كارلتون...'
                : 'e.g. Dubai, Istanbul, Paris, Ritz-Carlton...',
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.gray400),
            prefixIcon: const Icon(
              Icons.location_on_rounded,
              color: AppColors.royalBlue,
              size: 20,
            ),
            filled: true,
            fillColor: AppColors.surfaceLight,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.royalBlue,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateBox({
    required String label,
    required String date,
    String? badge,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSM.copyWith(
            color: AppColors.textLightMuted,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.royalBlue, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date,
                    style: AppTextStyles.labelMD.copyWith(
                      color: AppColors.navyDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.royalBlueFaded,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.royalBlue,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTravelersBox(bool isArabic) {
    final summary = _travelers.formattedSummary(
      isArabic: isArabic,
      includeRooms: true,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'النزلاء والغرف' : 'GUESTS & ROOMS',
          style: AppTextStyles.labelSM.copyWith(
            color: AppColors.textLightMuted,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: _pickTravelers,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.people_alt_rounded,
                  color: AppColors.royalBlue,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        summary,
                        style: AppTextStyles.labelMD.copyWith(
                          color: AppColors.navyDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_travelers.children > 0 &&
                          _travelers.childAges.isNotEmpty)
                        Text(
                          isArabic
                              ? 'أعمار الأطفال: ${_travelers.childAges.join(", ")}'
                              : 'Child Ages: ${_travelers.childAges.join(", ")}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.royalBlueDark,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.gray500,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

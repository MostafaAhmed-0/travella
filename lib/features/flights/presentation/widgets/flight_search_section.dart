import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/traveler_selector.dart';
import '../../../../core/localization/app_translations.dart';
import '../../data/models/flight_models.dart';

class FlightSearchSection extends StatefulWidget {
  final FlightSearchQuery initialQuery;
  final ValueChanged<FlightSearchQuery> onSearch;

  const FlightSearchSection({
    super.key,
    required this.initialQuery,
    required this.onSearch,
  });

  @override
  State<FlightSearchSection> createState() => _FlightSearchSectionState();
}

class _FlightSearchSectionState extends State<FlightSearchSection> {
  late TripType _tripType;
  late String _origin;
  late String _destination;
  late DateTime _departureDate;
  DateTime? _returnDate;
  late TravelerSelection _travelers;
  late String _cabinClass;

  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  final List<String> _popularAirports = [
    'Cairo (CAI)',
    'Istanbul (IST)',
    'Dubai (DXB)',
    'Riyadh (RUH)',
    'Jeddah (JED)',
    'Doha (DOH)',
    'London (LHR)',
    'Paris (CDG)',
    'Rome (FCO)',
    'Kuala Lumpur (KUL)',
    'Bangkok (BKK)',
    'New York (JFK)',
    'Frankfurt (FRA)',
    'Hurghada (HRG)',
    'Sharm El Sheikh (SSH)',
  ];

  @override
  void initState() {
    super.initState();
    _tripType = widget.initialQuery.tripType;
    _origin = widget.initialQuery.origin;
    _destination = widget.initialQuery.destination;
    _departureDate = widget.initialQuery.departureDate;
    _returnDate = widget.initialQuery.returnDate ??
        widget.initialQuery.departureDate.add(const Duration(days: 7));
    _travelers = TravelerSelection(
      adults: widget.initialQuery.adults,
      children: widget.initialQuery.children,
      childAges: widget.initialQuery.childAges,
    );
    _cabinClass = widget.initialQuery.cabinClass;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.gold, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMD.copyWith(color: AppColors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.navyDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.gold, width: 1),
        ),
      ),
    );
  }

  void _submitSearch() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_origin.trim().isEmpty || _destination.trim().isEmpty) {
      _showValidationError(context.tr('val_err_dest_empty'));
      return;
    }
    if (_origin.trim().toLowerCase() == _destination.trim().toLowerCase()) {
      _showValidationError(context.tr('val_err_same_origin_dest'));
      return;
    }
    if (_departureDate.isBefore(today)) {
      _showValidationError(context.tr('val_err_dep_past'));
      return;
    }
    if (_tripType == TripType.roundTrip && _returnDate != null && _returnDate!.isBefore(_departureDate)) {
      _showValidationError(context.tr('val_err_ret_before_dep'));
      return;
    }
    if (_travelers.children > 0 && _travelers.childAges.length < _travelers.children) {
      _showValidationError(context.tr('val_err_child_ages'));
      return;
    }

    final query = FlightSearchQuery(
      origin: _origin,
      destination: _destination,
      departureDate: _departureDate,
      returnDate: _tripType == TripType.roundTrip ? _returnDate : null,
      tripType: _tripType,
      adults: _travelers.adults,
      children: _travelers.children,
      childAges: _travelers.childAges,
      cabinClass: _cabinClass,
    );

    widget.onSearch(query);
  }

  void _swapAirports() {
    setState(() {
      final temp = _origin;
      _origin = _destination;
      _destination = temp;
    });
  }

  Future<void> _pickAirport({required bool isOrigin}) async {
    final isArabic = context.isArabic;
    final current = isOrigin ? _origin : _destination;
    final title = isOrigin
        ? (isArabic ? 'اختر مطار الإقلاع' : 'Select Departure Airport')
        : (isArabic ? 'اختر مطار الوصول' : 'Select Destination Airport');

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.75),
        decoration: const BoxDecoration(
          color: AppColors.navyDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.h4.copyWith(color: AppColors.white),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _popularAirports.length,
                itemBuilder: (context, idx) {
                  final airport = _popularAirports[idx];
                  final isSelected = airport == current;
                  return ListTile(
                    dense: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    tileColor: isSelected ? AppColors.royalBlue.withValues(alpha: 0.3) : null,
                    leading: Icon(
                      Icons.flight_takeoff_rounded,
                      color: isSelected ? AppColors.gold : AppColors.gray400,
                      size: 20,
                    ),
                    title: Text(
                      airport,
                      style: TextStyle(
                        color: isSelected ? AppColors.gold : AppColors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.gold, size: 20)
                        : null,
                    onTap: () => Navigator.pop(ctx, airport),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        if (isOrigin) {
          _origin = selected;
        } else {
          _destination = selected;
        }
      });
    }
  }

  Future<void> _pickDate({required bool isDeparture}) async {
    final now = DateTime.now();
    final firstDate = isDeparture ? now : _departureDate;
    final initial = isDeparture
        ? _departureDate
        : (_returnDate != null && _returnDate!.isAfter(_departureDate)
            ? _returnDate!
            : _departureDate.add(const Duration(days: 7)));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(firstDate) ? firstDate : initial,
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.navy,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.navyDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isDeparture) {
          _departureDate = picked;
          if (_returnDate != null && _returnDate!.isBefore(picked)) {
            _returnDate = picked.add(const Duration(days: 7));
          }
        } else {
          _returnDate = picked;
        }
      });
    }
  }

  Future<void> _openTravelersSelector() async {
    final res = await showTravelerSelectorModal(
      context,
      initial: _travelers,
      showRooms: false,
      title: context.isArabic ? 'المسافرون وأعمار الأطفال' : 'Travelers & Child Ages',
    );
    if (res != null) {
      setState(() => _travelers = res);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppBreakpoints.isDesktop(context);
    final isMobile = AppBreakpoints.isMobile(context);
    final isArabic = context.isArabic;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceNavbar.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 40,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: AppColors.royalBlue.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 18 : 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Controls: Trip Type & Cabin Class ───────────────────
              _buildTopControls(isMobile, isArabic),
              const SizedBox(height: 20),

              // ── Search Input Fields ───────────────────────────────────────
              if (isDesktop)
                _buildDesktopSearchFields(isArabic)
              else
                _buildMobileSearchFields(isArabic),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopControls(bool isMobile, bool isArabic) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: [
        // Trip Type Radios / Tabs (Round Trip vs One Way)
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.navyDark.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TripTypePill(
                label: context.tr('trip_round_trip'),
                icon: Icons.sync_alt_rounded,
                isSelected: _tripType == TripType.roundTrip,
                onTap: () => setState(() => _tripType = TripType.roundTrip),
              ),
              const SizedBox(width: 4),
              _TripTypePill(
                label: context.tr('trip_one_way'),
                icon: Icons.arrow_forward_rounded,
                isSelected: _tripType == TripType.oneWay,
                onTap: () => setState(() => _tripType = TripType.oneWay),
              ),
            ],
          ),
        ),

        // Cabin Class Selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.navyDark.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _cabinClass,
              dropdownColor: AppColors.navyDark,
              icon: const Icon(Icons.airline_seat_recline_extra_rounded, color: AppColors.gold, size: 18),
              style: AppTextStyles.labelMD.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
              items: ['Economy', 'Premium Economy', 'Business Class', 'First Class'].map((cls) {
                return DropdownMenuItem<String>(
                  value: cls,
                  child: Text(cls),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _cabinClass = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  // ── Desktop Layout ─────────────────────────────────────────────────────────
  Widget _buildDesktopSearchFields(bool isArabic) {
    final isRound = _tripType == TripType.roundTrip;

    return Row(
      children: [
        // From
        Expanded(
          flex: 4,
          child: _SearchFieldBox(
            label: context.tr('field_from'),
            value: _origin,
            icon: Icons.flight_takeoff_rounded,
            onTap: () => _pickAirport(isOrigin: true),
          ),
        ),
        const SizedBox(width: 6),

        // Swap button
        IconButton(
          onPressed: _swapAirports,
          icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.gold, size: 22),
          tooltip: isArabic ? 'تبديل الوجهات' : 'Swap Airports',
          style: IconButton.styleFrom(
            backgroundColor: AppColors.navyDark.withValues(alpha: 0.8),
            padding: const EdgeInsets.all(10),
          ),
        ),
        const SizedBox(width: 6),

        // To
        Expanded(
          flex: 4,
          child: _SearchFieldBox(
            label: context.tr('field_destination'),
            value: _destination,
            icon: Icons.place_rounded,
            onTap: () => _pickAirport(isOrigin: false),
          ),
        ),
        const SizedBox(width: 10),

        // Departure Date
        Expanded(
          flex: 3,
          child: _SearchFieldBox(
            label: context.tr('field_departure'),
            value: _dateFormat.format(_departureDate),
            icon: Icons.calendar_today_rounded,
            onTap: () => _pickDate(isDeparture: true),
          ),
        ),
        const SizedBox(width: 10),

        // Return Date (Disabled/Hidden when One Way is selected)
        if (isRound) ...[
          Expanded(
            flex: 3,
            child: _SearchFieldBox(
              label: context.tr('field_return'),
              value: _returnDate != null
                  ? _dateFormat.format(_returnDate!)
                  : (isArabic ? 'حدد التاريخ' : 'Select Date'),
              icon: Icons.event_repeat_rounded,
              onTap: () => _pickDate(isDeparture: false),
            ),
          ),
          const SizedBox(width: 10),
        ],

        // Travelers
        Expanded(
          flex: 4,
          child: _SearchFieldBox(
            label: context.tr('field_travelers'),
            value: _travelers.formattedSummary(isArabic: isArabic),
            icon: Icons.people_alt_rounded,
            onTap: _openTravelersSelector,
          ),
        ),
        const SizedBox(width: 16),

        // Search Flights Button
        _buildSearchButton(context.tr('flight_search_btn')),
      ],
    );
  }

  // ── Mobile / Tablet Layout ─────────────────────────────────────────────────
  Widget _buildMobileSearchFields(bool isMobile) {
    final isArabic = context.isArabic;
    final isRound = _tripType == TripType.roundTrip;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SearchFieldBox(
                label: context.tr('field_from'),
                value: _origin,
                icon: Icons.flight_takeoff_rounded,
                onTap: () => _pickAirport(isOrigin: true),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _swapAirports,
              icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.gold, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.navyDark.withValues(alpha: 0.8),
                padding: const EdgeInsets.all(8),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SearchFieldBox(
                label: context.tr('field_destination'),
                value: _destination,
                icon: Icons.place_rounded,
                onTap: () => _pickAirport(isOrigin: false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SearchFieldBox(
                label: context.tr('field_departure'),
                value: _dateFormat.format(_departureDate),
                icon: Icons.calendar_today_rounded,
                onTap: () => _pickDate(isDeparture: true),
              ),
            ),
            if (isRound) ...[
              const SizedBox(width: 10),
              Expanded(
                child: _SearchFieldBox(
                  label: context.tr('field_return'),
                  value: _returnDate != null
                      ? _dateFormat.format(_returnDate!)
                      : (isArabic ? 'حدد التاريخ' : 'Select Date'),
                  icon: Icons.event_repeat_rounded,
                  onTap: () => _pickDate(isDeparture: false),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        _SearchFieldBox(
          label: context.tr('field_travelers'),
          value: _travelers.formattedSummary(isArabic: isArabic),
          icon: Icons.people_alt_rounded,
          onTap: _openTravelersSelector,
        ),
        const SizedBox(height: 18),
        TravellaButton(
          label: context.tr('flight_search_btn'),
          variant: TravellaButtonVariant.gold,
          size: TravellaButtonSize.lg,
          fullWidth: true,
          leadingIcon: Icons.search_rounded,
          onPressed: _submitSearch,
        ),
      ],
    );
  }

  Widget _buildSearchButton(String label) {
    return ElevatedButton(
      onPressed: _submitSearch,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.navyDark,
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 8,
        shadowColor: AppColors.gold.withValues(alpha: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_rounded, size: 20, color: AppColors.navyDark),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.labelLG.copyWith(
              color: AppColors.navyDark,
              fontWeight: FontWeight.w700,
              letterSpacing: context.isArabic ? 0.0 : 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _TripTypePill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TripTypePill({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? AppColors.navyDark : AppColors.textOnDarkMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelSM.copyWith(
                color: isSelected ? AppColors.navyDark : AppColors.white,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchFieldBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _SearchFieldBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        hoverColor: AppColors.white.withValues(alpha: 0.08),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.overline.copyWith(
                  color: AppColors.gold,
                  fontSize: 10,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Icon(icon, color: AppColors.goldLight, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      value,
                      style: AppTextStyles.labelMD.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

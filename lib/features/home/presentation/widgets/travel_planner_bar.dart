import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/traveler_selector.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../flights/presentation/pages/flight_inquiry_page.dart';

enum PlannerTab { flights, hotels, tours, visa }

/// Premium Floating Glassmorphic Travel Planner Bar
class TravelPlannerBar extends StatefulWidget {
  const TravelPlannerBar({super.key});

  @override
  State<TravelPlannerBar> createState() => _TravelPlannerBarState();
}

class _TravelPlannerBarState extends State<TravelPlannerBar> {
  PlannerTab _selectedTab = PlannerTab.tours;

  // ── Flights State ──────────────────────────────────────────────────────────
  String _flightOrigin = 'Cairo (CAI)';
  String _flightDestination = 'Istanbul, Turkey';
  DateTime _flightDepartureDate = DateTime.now().add(const Duration(days: 14));
  DateTime _flightReturnDate = DateTime.now().add(const Duration(days: 21));
  bool _flightIsRoundTrip = true;
  TravelerSelection _flightTravelers = const TravelerSelection(adults: 2, children: 0);
  String _flightCabinClass = 'Economy';

  // ── Hotels State ───────────────────────────────────────────────────────────
  String _hotelDestination = 'Istanbul, Turkey';
  DateTime _hotelCheckInDate = DateTime.now().add(const Duration(days: 14));
  DateTime _hotelCheckOutDate = DateTime.now().add(const Duration(days: 19));
  TravelerSelection _hotelGuests = const TravelerSelection(adults: 2, children: 0, rooms: 1);

  // ── Tours State ────────────────────────────────────────────────────────────
  String _tourDestination = 'Istanbul, Turkey';
  String _tourCategory = 'All'; // All, Domestic, International, Hajj & Umrah
  DateTime _tourDate = DateTime.now().add(const Duration(days: 14));
  TravelerSelection _tourTravelers = const TravelerSelection(adults: 2, children: 0);

  // ── Visa State ─────────────────────────────────────────────────────────────
  String _visaCountry = 'Spain (Schengen)';
  String _visaType = 'Tourist Visa';
  int _visaApplicants = 1;
  DateTime _visaTravelDate = DateTime.now().add(const Duration(days: 30));

  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  // ── Validation & Submission ────────────────────────────────────────────────
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
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _onSearch() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_selectedTab) {
      case PlannerTab.flights:
        if (_flightOrigin.trim().isEmpty || _flightDestination.trim().isEmpty) {
          _showValidationError(context.tr('val_err_dest_empty'));
          return;
        }
        if (_flightOrigin.trim().toLowerCase() == _flightDestination.trim().toLowerCase()) {
          _showValidationError(context.tr('val_err_same_origin_dest'));
          return;
        }
        if (_flightDepartureDate.isBefore(today)) {
          _showValidationError(context.tr('val_err_dep_past'));
          return;
        }
        if (_flightIsRoundTrip && _flightReturnDate.isBefore(_flightDepartureDate)) {
          _showValidationError(context.tr('val_err_ret_before_dep'));
          return;
        }
        if (_flightTravelers.children > 0 &&
            _flightTravelers.childAges.length < _flightTravelers.children) {
          _showValidationError(context.tr('val_err_child_ages'));
          return;
        }

        final flightData = FlightInquiryData(
          origin: _flightOrigin,
          destination: _flightDestination,
          departureDate: _flightDepartureDate,
          returnDate: _flightIsRoundTrip ? _flightReturnDate : null,
          isRoundTrip: _flightIsRoundTrip,
          adults: _flightTravelers.adults,
          children: _flightTravelers.children,
          childAges: _flightTravelers.childAges,
          cabinClass: _flightCabinClass,
        );

        final depStr = DateFormat('yyyy-MM-dd').format(_flightDepartureDate);
        final retStr = _flightIsRoundTrip
            ? DateFormat('yyyy-MM-dd').format(_flightReturnDate)
            : '';
        final agesStr = _flightTravelers.childAges.join(',');

        final uri = Uri(
          path: AppRoutes.flightInquiry,
          queryParameters: {
            'from': _flightOrigin,
            'destination': _flightDestination,
            'departure': depStr,
            if (_flightIsRoundTrip) 'return': retStr,
            'roundTrip': _flightIsRoundTrip.toString(),
            'adults': _flightTravelers.adults.toString(),
            'children': _flightTravelers.children.toString(),
            if (agesStr.isNotEmpty) 'childAges': agesStr,
            'cabinClass': _flightCabinClass,
          },
        );

        context.go(uri.toString(), extra: flightData);
        break;

      case PlannerTab.hotels:
        if (_hotelDestination.trim().isEmpty) {
          _showValidationError(context.tr('val_err_dest_empty'));
          return;
        }
        if (_hotelCheckInDate.isBefore(today)) {
          _showValidationError(context.tr('val_err_dep_past'));
          return;
        }
        if (!_hotelCheckOutDate.isAfter(_hotelCheckInDate)) {
          _showValidationError(context.tr('val_err_checkout_before_in'));
          return;
        }

        final inStr = DateFormat('yyyy-MM-dd').format(_hotelCheckInDate);
        final outStr = DateFormat('yyyy-MM-dd').format(_hotelCheckOutDate);
        final agesStr = _hotelGuests.childAges.join(',');

        final uri = Uri(
          path: AppRoutes.hotels,
          queryParameters: {
            'destination': _hotelDestination,
            'checkIn': inStr,
            'checkOut': outStr,
            'adults': _hotelGuests.adults.toString(),
            'children': _hotelGuests.children.toString(),
            if (agesStr.isNotEmpty) 'childAges': agesStr,
            'rooms': _hotelGuests.rooms.toString(),
          },
        );

        context.go(uri.toString());
        break;

      case PlannerTab.tours:
        if (_tourDestination.trim().isEmpty) {
          _showValidationError(context.tr('val_err_dest_empty'));
          return;
        }

        String targetRoute = AppRoutes.destinations;
        if (_tourCategory == 'Domestic') {
          targetRoute = AppRoutes.domesticTours;
        } else if (_tourCategory == 'International') {
          targetRoute = AppRoutes.internationalTours;
        } else if (_tourCategory == 'Hajj & Umrah') {
          targetRoute = AppRoutes.hajjUmrah;
        }

        final dateStr = DateFormat('yyyy-MM-dd').format(_tourDate);
        final agesStr = _tourTravelers.childAges.join(',');

        final uri = Uri(
          path: targetRoute,
          queryParameters: {
            'destination': _tourDestination,
            'category': _tourCategory,
            'date': dateStr,
            'adults': _tourTravelers.adults.toString(),
            'children': _tourTravelers.children.toString(),
            if (agesStr.isNotEmpty) 'childAges': agesStr,
          },
        );

        context.go(uri.toString());
        break;

      case PlannerTab.visa:
        if (_visaCountry.trim().isEmpty) {
          _showValidationError(context.tr('val_err_dest_empty'));
          return;
        }

        final uri = Uri(
          path: AppRoutes.visaServices,
          queryParameters: {
            'country': _visaCountry,
            'visaType': _visaType,
            'applicants': _visaApplicants.toString(),
          },
        );

        context.go(uri.toString());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppBreakpoints.isDesktop(context);
    final isMobile = AppBreakpoints.isMobile(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceNavbar.withValues(alpha: 0.92),
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
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Tab selector ──────────────────────────────────────────────
              _buildTabSelector(isMobile),
              const SizedBox(height: 20),

              // ── Dynamic Input Fields per Tab ──────────────────────────────
              if (isDesktop)
                _buildDesktopFields()
              else
                _buildMobileFields(isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabSelector(bool isMobile) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _TabButton(
            icon: Icons.flight_takeoff_rounded,
            label: context.tr('tab_flights'),
            isSelected: _selectedTab == PlannerTab.flights,
            onTap: () => setState(() => _selectedTab = PlannerTab.flights),
          ),
          const SizedBox(width: 8),
          _TabButton(
            icon: Icons.hotel_rounded,
            label: context.tr('tab_hotels'),
            isSelected: _selectedTab == PlannerTab.hotels,
            onTap: () => setState(() => _selectedTab = PlannerTab.hotels),
          ),
          const SizedBox(width: 8),
          _TabButton(
            icon: Icons.explore_rounded,
            label: context.tr('tab_tours'),
            isSelected: _selectedTab == PlannerTab.tours,
            onTap: () => setState(() => _selectedTab = PlannerTab.tours),
          ),
          const SizedBox(width: 8),
          _TabButton(
            icon: Icons.article_rounded,
            label: context.tr('tab_visa'),
            isSelected: _selectedTab == PlannerTab.visa,
            onTap: () => setState(() => _selectedTab = PlannerTab.visa),
          ),
        ],
      ),
    );
  }

  // ── Desktop Horizontal Layout ──────────────────────────────────────────────
  Widget _buildDesktopFields() {
    switch (_selectedTab) {
      case PlannerTab.flights:
        return _buildDesktopFlightsFields();
      case PlannerTab.hotels:
        return _buildDesktopHotelsFields();
      case PlannerTab.tours:
        return _buildDesktopToursFields();
      case PlannerTab.visa:
        return _buildDesktopVisaFields();
    }
  }

  Widget _buildDesktopFlightsFields() {
    final isArabic = context.isArabic;
    return Row(
      children: [
        // From / Origin
        Expanded(
          flex: 3,
          child: _FieldBox(
            label: context.tr('field_from'),
            value: _flightOrigin,
            icon: Icons.flight_takeoff_rounded,
            onTap: _showOriginPicker,
          ),
        ),
        const SizedBox(width: 10),

        // Destination
        Expanded(
          flex: 3,
          child: _FieldBox(
            label: context.tr('field_destination'),
            value: _flightDestination,
            icon: Icons.place_rounded,
            onTap: _showDestinationPicker,
          ),
        ),
        const SizedBox(width: 10),

        // Departure Date
        Expanded(
          flex: 3,
          child: _FieldBox(
            label: context.tr('field_departure'),
            value: _dateFormat.format(_flightDepartureDate),
            icon: Icons.calendar_today_rounded,
            onTap: () => _pickDate(forFlightDeparture: true),
          ),
        ),
        const SizedBox(width: 10),

        // Return Date
        Expanded(
          flex: 3,
          child: _FieldBox(
            label: context.tr('field_return'),
            value: _flightIsRoundTrip
                ? _dateFormat.format(_flightReturnDate)
                : (isArabic ? 'اتجاه واحد' : 'One Way'),
            icon: Icons.event_repeat_rounded,
            onTap: () {
              if (!_flightIsRoundTrip) {
                setState(() => _flightIsRoundTrip = true);
              }
              _pickDate(forFlightDeparture: false);
            },
          ),
        ),
        const SizedBox(width: 10),

        // Travelers & Child Ages
        Expanded(
          flex: 3,
          child: _FieldBox(
            label: context.tr('field_travelers'),
            value: _flightTravelers.formattedSummary(isArabic: isArabic),
            icon: Icons.people_alt_rounded,
            onTap: _openFlightTravelersModal,
          ),
        ),
        const SizedBox(width: 14),

        // Search Button
        _buildSearchButton(context.tr('btn_search')),
      ],
    );
  }

  Widget _buildDesktopHotelsFields() {
    final isArabic = context.isArabic;
    return Row(
      children: [
        // Destination / Hotel
        Expanded(
          flex: 4,
          child: _FieldBox(
            label: context.tr('field_destination'),
            value: _hotelDestination,
            icon: Icons.hotel_rounded,
            onTap: _showHotelDestinationPicker,
          ),
        ),
        const SizedBox(width: 10),

        // Check-in
        Expanded(
          flex: 3,
          child: _FieldBox(
            label: context.tr('field_checkin'),
            value: _dateFormat.format(_hotelCheckInDate),
            icon: Icons.login_rounded,
            onTap: () => _pickHotelDate(isCheckIn: true),
          ),
        ),
        const SizedBox(width: 10),

        // Check-out
        Expanded(
          flex: 3,
          child: _FieldBox(
            label: context.tr('field_checkout'),
            value: _dateFormat.format(_hotelCheckOutDate),
            icon: Icons.logout_rounded,
            onTap: () => _pickHotelDate(isCheckIn: false),
          ),
        ),
        const SizedBox(width: 10),

        // Rooms & Guests
        Expanded(
          flex: 4,
          child: _FieldBox(
            label: context.tr('field_rooms'),
            value: _hotelGuests.formattedSummary(isArabic: isArabic, includeRooms: true),
            icon: Icons.meeting_room_rounded,
            onTap: _openHotelGuestsModal,
          ),
        ),
        const SizedBox(width: 14),

        // Search Button
        _buildSearchButton(context.tr('btn_search')),
      ],
    );
  }

  Widget _buildDesktopToursFields() {
    final isArabic = context.isArabic;
    return Row(
      children: [
        // Destination
        Expanded(
          flex: 4,
          child: _FieldBox(
            label: context.tr('field_destination'),
            value: _tourDestination,
            icon: Icons.explore_rounded,
            onTap: _showTourDestinationPicker,
          ),
        ),
        const SizedBox(width: 10),

        // Tour Type / Category
        Expanded(
          flex: 3,
          child: _FieldBox(
            label: context.tr('field_tour_type'),
            value: _tourCategory,
            icon: Icons.category_rounded,
            onTap: _showTourCategoryPicker,
          ),
        ),
        const SizedBox(width: 10),

        // Month / Travel Date
        Expanded(
          flex: 3,
          child: _FieldBox(
            label: context.tr('field_departure'),
            value: _dateFormat.format(_tourDate),
            icon: Icons.calendar_today_rounded,
            onTap: _pickTourDate,
          ),
        ),
        const SizedBox(width: 10),

        // Travelers
        Expanded(
          flex: 3,
          child: _FieldBox(
            label: context.tr('field_travelers'),
            value: _tourTravelers.formattedSummary(isArabic: isArabic),
            icon: Icons.people_alt_rounded,
            onTap: _openTourTravelersModal,
          ),
        ),
        const SizedBox(width: 14),

        // Search Button
        _buildSearchButton(context.tr('btn_search')),
      ],
    );
  }

  Widget _buildDesktopVisaFields() {
    final isArabic = context.isArabic;
    return Row(
      children: [
        // Destination Country
        Expanded(
          flex: 4,
          child: _FieldBox(
            label: context.tr('field_country'),
            value: _visaCountry,
            icon: Icons.public_rounded,
            onTap: _showVisaCountryPicker,
          ),
        ),
        const SizedBox(width: 10),

        // Visa Type
        Expanded(
          flex: 3,
          child: _FieldBox(
            label: context.tr('field_visa_type'),
            value: _visaType,
            icon: Icons.article_rounded,
            onTap: _showVisaTypePicker,
          ),
        ),
        const SizedBox(width: 10),

        // Applicants
        Expanded(
          flex: 3,
          child: _FieldBox(
            label: context.tr('field_applicants'),
            value: '$_visaApplicants ${isArabic ? 'متقدم' : 'Applicant(s)'}',
            icon: Icons.person_rounded,
            onTap: _showVisaApplicantsPicker,
          ),
        ),
        const SizedBox(width: 10),

        // Planned Travel Date
        Expanded(
          flex: 3,
          child: _FieldBox(
            label: context.tr('field_departure'),
            value: _dateFormat.format(_visaTravelDate),
            icon: Icons.calendar_today_rounded,
            onTap: _pickVisaDate,
          ),
        ),
        const SizedBox(width: 14),

        // Search Button
        _buildSearchButton(context.tr('btn_apply_visa')),
      ],
    );
  }

  Widget _buildSearchButton(String label) {
    return ElevatedButton(
      onPressed: _onSearch,
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

  // ── Mobile / Tablet Stacked Layout ─────────────────────────────────────────
  Widget _buildMobileFields(bool isMobile) {
    switch (_selectedTab) {
      case PlannerTab.flights:
        return _buildMobileFlights();
      case PlannerTab.hotels:
        return _buildMobileHotels();
      case PlannerTab.tours:
        return _buildMobileTours();
      case PlannerTab.visa:
        return _buildMobileVisa();
    }
  }

  Widget _buildMobileFlights() {
    final isArabic = context.isArabic;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _FieldBox(
                label: context.tr('field_from'),
                value: _flightOrigin,
                icon: Icons.flight_takeoff_rounded,
                onTap: _showOriginPicker,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FieldBox(
                label: context.tr('field_destination'),
                value: _flightDestination,
                icon: Icons.place_rounded,
                onTap: _showDestinationPicker,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _FieldBox(
                label: context.tr('field_departure'),
                value: _dateFormat.format(_flightDepartureDate),
                icon: Icons.calendar_today_rounded,
                onTap: () => _pickDate(forFlightDeparture: true),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FieldBox(
                label: context.tr('field_return'),
                value: _flightIsRoundTrip
                    ? _dateFormat.format(_flightReturnDate)
                    : (isArabic ? 'اتجاه واحد' : 'One Way'),
                icon: Icons.event_repeat_rounded,
                onTap: () {
                  if (!_flightIsRoundTrip) {
                    setState(() => _flightIsRoundTrip = true);
                  }
                  _pickDate(forFlightDeparture: false);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _FieldBox(
          label: context.tr('field_travelers'),
          value: _flightTravelers.formattedSummary(isArabic: isArabic),
          icon: Icons.people_alt_rounded,
          onTap: _openFlightTravelersModal,
        ),
        const SizedBox(height: 16),
        TravellaButton(
          label: context.tr('btn_search'),
          variant: TravellaButtonVariant.gold,
          size: TravellaButtonSize.lg,
          fullWidth: true,
          leadingIcon: Icons.search_rounded,
          onPressed: _onSearch,
        ),
      ],
    );
  }

  Widget _buildMobileHotels() {
    final isArabic = context.isArabic;
    return Column(
      children: [
        _FieldBox(
          label: context.tr('field_destination'),
          value: _hotelDestination,
          icon: Icons.hotel_rounded,
          onTap: _showHotelDestinationPicker,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _FieldBox(
                label: context.tr('field_checkin'),
                value: _dateFormat.format(_hotelCheckInDate),
                icon: Icons.login_rounded,
                onTap: () => _pickHotelDate(isCheckIn: true),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FieldBox(
                label: context.tr('field_checkout'),
                value: _dateFormat.format(_hotelCheckOutDate),
                icon: Icons.logout_rounded,
                onTap: () => _pickHotelDate(isCheckIn: false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _FieldBox(
          label: context.tr('field_rooms'),
          value: _hotelGuests.formattedSummary(isArabic: isArabic, includeRooms: true),
          icon: Icons.meeting_room_rounded,
          onTap: _openHotelGuestsModal,
        ),
        const SizedBox(height: 16),
        TravellaButton(
          label: context.tr('btn_search'),
          variant: TravellaButtonVariant.gold,
          size: TravellaButtonSize.lg,
          fullWidth: true,
          leadingIcon: Icons.search_rounded,
          onPressed: _onSearch,
        ),
      ],
    );
  }

  Widget _buildMobileTours() {
    final isArabic = context.isArabic;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _FieldBox(
                label: context.tr('field_destination'),
                value: _tourDestination,
                icon: Icons.explore_rounded,
                onTap: _showTourDestinationPicker,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FieldBox(
                label: context.tr('field_tour_type'),
                value: _tourCategory,
                icon: Icons.category_rounded,
                onTap: _showTourCategoryPicker,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _FieldBox(
                label: context.tr('field_departure'),
                value: _dateFormat.format(_tourDate),
                icon: Icons.calendar_today_rounded,
                onTap: _pickTourDate,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FieldBox(
                label: context.tr('field_travelers'),
                value: _tourTravelers.formattedSummary(isArabic: isArabic),
                icon: Icons.people_alt_rounded,
                onTap: _openTourTravelersModal,
              ),
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
          onPressed: _onSearch,
        ),
      ],
    );
  }

  Widget _buildMobileVisa() {
    final isArabic = context.isArabic;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _FieldBox(
                label: context.tr('field_country'),
                value: _visaCountry,
                icon: Icons.public_rounded,
                onTap: _showVisaCountryPicker,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FieldBox(
                label: context.tr('field_visa_type'),
                value: _visaType,
                icon: Icons.article_rounded,
                onTap: _showVisaTypePicker,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _FieldBox(
                label: context.tr('field_applicants'),
                value: '$_visaApplicants ${isArabic ? 'متقدم' : 'Applicant(s)'}',
                icon: Icons.person_rounded,
                onTap: _showVisaApplicantsPicker,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FieldBox(
                label: context.tr('field_departure'),
                value: _dateFormat.format(_visaTravelDate),
                icon: Icons.calendar_today_rounded,
                onTap: _pickVisaDate,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TravellaButton(
          label: context.tr('btn_apply_visa'),
          variant: TravellaButtonVariant.gold,
          size: TravellaButtonSize.lg,
          fullWidth: true,
          leadingIcon: Icons.article_rounded,
          onPressed: _onSearch,
        ),
      ],
    );
  }

  // ── Modals & Pickers ───────────────────────────────────────────────────────
  Future<void> _openFlightTravelersModal() async {
    final result = await showTravelerSelectorModal(
      context,
      initial: _flightTravelers,
      showRooms: false,
      title: context.isArabic ? 'مسافرو رحلة الطيران' : 'Flight Passengers',
    );
    if (result != null) {
      setState(() => _flightTravelers = result);
    }
  }

  Future<void> _openHotelGuestsModal() async {
    final result = await showTravelerSelectorModal(
      context,
      initial: _hotelGuests,
      showRooms: true,
      title: context.isArabic ? 'نزلاء وغرف الفندق' : 'Hotel Guests & Rooms',
    );
    if (result != null) {
      setState(() => _hotelGuests = result);
    }
  }

  Future<void> _openTourTravelersModal() async {
    final result = await showTravelerSelectorModal(
      context,
      initial: _tourTravelers,
      showRooms: false,
      title: context.isArabic ? 'المسافرون للبرنامج السياحي' : 'Tour Travelers',
    );
    if (result != null) {
      setState(() => _tourTravelers = result);
    }
  }

  Future<void> _pickDate({required bool forFlightDeparture}) async {
    final now = DateTime.now();
    final first = forFlightDeparture ? now : _flightDepartureDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: forFlightDeparture ? _flightDepartureDate : _flightReturnDate,
      firstDate: first,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => _buildDarkThemePicker(child),
    );

    if (picked != null) {
      setState(() {
        if (forFlightDeparture) {
          _flightDepartureDate = picked;
          if (_flightReturnDate.isBefore(_flightDepartureDate)) {
            _flightReturnDate = _flightDepartureDate.add(const Duration(days: 7));
          }
        } else {
          _flightReturnDate = picked;
        }
      });
    }
  }

  Future<void> _pickHotelDate({required bool isCheckIn}) async {
    final now = DateTime.now();
    final first = isCheckIn ? now : _hotelCheckInDate.add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? _hotelCheckInDate : _hotelCheckOutDate,
      firstDate: first,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => _buildDarkThemePicker(child),
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _hotelCheckInDate = picked;
          if (!_hotelCheckOutDate.isAfter(_hotelCheckInDate)) {
            _hotelCheckOutDate = _hotelCheckInDate.add(const Duration(days: 5));
          }
        } else {
          _hotelCheckOutDate = picked;
        }
      });
    }
  }

  Future<void> _pickTourDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tourDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => _buildDarkThemePicker(child),
    );

    if (picked != null) {
      setState(() => _tourDate = picked);
    }
  }

  Future<void> _pickVisaDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _visaTravelDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => _buildDarkThemePicker(child),
    );

    if (picked != null) {
      setState(() => _visaTravelDate = picked);
    }
  }

  Widget _buildDarkThemePicker(Widget? child) {
    return Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: AppColors.gold,
          onPrimary: AppColors.navyDark,
          surface: AppColors.navyMedium,
          onSurface: AppColors.white,
        ),
      ),
      child: child ?? const SizedBox.shrink(),
    );
  }

  void _showOriginPicker() {
    _showListDialog(
      title: context.isArabic ? 'اختر مدينة المغادرة' : 'Select Departure City',
      options: [
        'Cairo (CAI)',
        'Alexandria (HBE)',
        'Hurghada (HRG)',
        'Sharm El Sheikh (SSH)',
        'Luxor (LXR)',
        'Dubai (DXB)',
        'Riyadh (RUH)',
        'Jeddah (JED)',
        'Istanbul (IST)',
        'London (LHR)',
      ],
      onSelected: (val) => setState(() => _flightOrigin = val),
    );
  }

  void _showDestinationPicker() {
    _showListDialog(
      title: context.isArabic ? 'اختر وجهة الوصول' : 'Select Arrival Destination',
      options: [
        'Istanbul, Turkey',
        'Paris, France',
        'Dubai, UAE',
        'Maldives Islands',
        'Hurghada, Egypt',
        'Sharm El Sheikh, Egypt',
        'Siwa Oasis, Egypt',
        'Aswan & Luxor, Egypt',
        'Bali, Indonesia',
        'Amsterdam, Netherlands',
        'Rome, Italy',
        'Barcelona, Spain',
      ],
      onSelected: (val) => setState(() => _flightDestination = val),
    );
  }

  void _showHotelDestinationPicker() {
    _showListDialog(
      title: context.isArabic ? 'اختر وجهة الفندق' : 'Select Hotel Destination',
      options: [
        'Istanbul, Turkey',
        'Hurghada, Egypt',
        'Sharm El Sheikh, Egypt',
        'Cairo, Egypt',
        'Dubai, UAE',
        'Maldives Islands',
        'Bali, Indonesia',
        'Paris, France',
        'Makkah, Saudi Arabia',
        'Madinah, Saudi Arabia',
      ],
      onSelected: (val) => setState(() => _hotelDestination = val),
    );
  }

  void _showTourDestinationPicker() {
    _showListDialog(
      title: context.isArabic ? 'اختر وجهة الرحلة' : 'Select Tour Destination',
      options: [
        'Istanbul, Turkey',
        'Hurghada, Egypt',
        'Sharm El Sheikh, Egypt',
        'Siwa Oasis, Egypt',
        'Luxor & Aswan, Egypt',
        'Paris & Rome, Europe',
        'Bali & Ubud, Indonesia',
        'Dubai & Abu Dhabi, UAE',
        'Makkah & Madinah, KSA',
      ],
      onSelected: (val) => setState(() => _tourDestination = val),
    );
  }

  void _showTourCategoryPicker() {
    _showListDialog(
      title: context.isArabic ? 'اختر تصنيف الرحلات' : 'Select Tour Category',
      options: ['All', 'Domestic', 'International', 'Hajj & Umrah'],
      onSelected: (val) => setState(() => _tourCategory = val),
    );
  }

  void _showVisaCountryPicker() {
    _showListDialog(
      title: context.isArabic ? 'اختر دولة التأشيرة' : 'Select Visa Destination Country',
      options: [
        'Spain (Schengen)',
        'France (Schengen)',
        'Germany (Schengen)',
        'United Kingdom (UK)',
        'United States (USA)',
        'United Arab Emirates (Dubai e-Visa)',
        'Saudi Arabia (Tourist & Umrah e-Visa)',
        'Japan',
        'Turkey e-Visa',
        'China',
      ],
      onSelected: (val) => setState(() => _visaCountry = val),
    );
  }

  void _showVisaTypePicker() {
    _showListDialog(
      title: context.isArabic ? 'اختر نوع التأشيرة' : 'Select Visa Type',
      options: [
        'Tourist Visa',
        'Business Visa',
        'Student Visa',
        'Family & Transit Visa',
      ],
      onSelected: (val) => setState(() => _visaType = val),
    );
  }

  void _showVisaApplicantsPicker() {
    _showListDialog(
      title: context.isArabic ? 'عدد المتقدمين' : 'Number of Applicants',
      options: List.generate(10, (i) => '${i + 1} Applicant${i == 0 ? '' : 's'}'),
      onSelected: (val) {
        final num = int.tryParse(val.split(' ').first) ?? 1;
        setState(() => _visaApplicants = num);
      },
    );
  }

  void _showListDialog({
    required String title,
    required List<String> options,
    required ValueChanged<String> onSelected,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.navyMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: AppTextStyles.h5.copyWith(color: AppColors.white)),
        content: SizedBox(
          width: 340,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: options.length,
            separatorBuilder: (context, index) => const Divider(color: AppColors.navyDark),
            itemBuilder: (context, i) => ListTile(
              title: Text(options[i], style: AppTextStyles.bodyMD.copyWith(color: AppColors.white)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.gold),
              onTap: () {
                onSelected(options[i]);
                Navigator.pop(ctx);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.royalBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.gold : AppColors.white.withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.goldLight : AppColors.textOnDarkMuted,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.labelMD.copyWith(
                color: isSelected ? AppColors.white : AppColors.textOnDarkMuted,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _FieldBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.navyDark.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.14),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.gold, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.textOnDarkMuted,
                      fontSize: 10,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: AppTextStyles.labelMD.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

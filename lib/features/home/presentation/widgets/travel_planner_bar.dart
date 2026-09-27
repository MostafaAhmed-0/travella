import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/common_widgets.dart';

enum PlannerTab { flights, hotels, tours, visa }

/// Floating Glassmorphism Travel Planner Bar
class TravelPlannerBar extends StatefulWidget {
  const TravelPlannerBar({super.key});

  @override
  State<TravelPlannerBar> createState() => _TravelPlannerBarState();
}

class _TravelPlannerBarState extends State<TravelPlannerBar> {
  PlannerTab _selectedTab = PlannerTab.tours;
  String _origin = 'Cairo (CAI)';
  String _destination = 'Istanbul, Turkey';
  DateTime _departureDate = DateTime.now().add(const Duration(days: 14));
  DateTime _returnDate = DateTime.now().add(const Duration(days: 21));
  int _adultsCount = 2;
  int _childrenCount = 0;

  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  void _onSearch() {
    switch (_selectedTab) {
      case PlannerTab.tours:
        context.goNamed(AppRoutes.destinationsName);
        break;
      case PlannerTab.hotels:
        context.goNamed(AppRoutes.hotelsName);
        break;
      case PlannerTab.visa:
        context.goNamed(AppRoutes.visaServicesName);
        break;
      case PlannerTab.flights:
        context.goNamed(AppRoutes.bookingName);
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
        color: AppColors.surfaceNavbar.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: AppColors.royalBlue.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
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
              // ── Dynamic Input Fields ──────────────────────────────────────
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
            label: 'Flights',
            isSelected: _selectedTab == PlannerTab.flights,
            onTap: () => setState(() => _selectedTab = PlannerTab.flights),
          ),
          const SizedBox(width: 8),
          _TabButton(
            icon: Icons.hotel_rounded,
            label: 'Hotels',
            isSelected: _selectedTab == PlannerTab.hotels,
            onTap: () => setState(() => _selectedTab = PlannerTab.hotels),
          ),
          const SizedBox(width: 8),
          _TabButton(
            icon: Icons.explore_rounded,
            label: 'Tours & Packages',
            isSelected: _selectedTab == PlannerTab.tours,
            onTap: () => setState(() => _selectedTab = PlannerTab.tours),
          ),
          const SizedBox(width: 8),
          _TabButton(
            icon: Icons.article_rounded,
            label: 'Visa Services',
            isSelected: _selectedTab == PlannerTab.visa,
            onTap: () => setState(() => _selectedTab = PlannerTab.visa),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopFields() {
    return Row(
      children: [
        // From / Origin
        Expanded(
          flex: 3,
          child: _FieldBox(
            label: 'FROM',
            value: _origin,
            icon: Icons.flight_takeoff_rounded,
            onTap: _showOriginPicker,
          ),
        ),
        const SizedBox(width: 12),
        // To / Destination
        Expanded(
          flex: 3,
          child: _FieldBox(
            label: 'DESTINATION',
            value: _destination,
            icon: Icons.place_rounded,
            onTap: _showDestinationPicker,
          ),
        ),
        const SizedBox(width: 12),
        // Departure Date
        Expanded(
          flex: 3,
          child: _FieldBox(
            label: 'DEPARTURE',
            value: _dateFormat.format(_departureDate),
            icon: Icons.calendar_today_rounded,
            onTap: () => _pickDate(isDeparture: true),
          ),
        ),
        const SizedBox(width: 12),
        // Return Date (or duration)
        Expanded(
          flex: 3,
          child: _FieldBox(
            label: 'RETURN',
            value: _dateFormat.format(_returnDate),
            icon: Icons.event_repeat_rounded,
            onTap: () => _pickDate(isDeparture: false),
          ),
        ),
        const SizedBox(width: 12),
        // Travelers
        Expanded(
          flex: 3,
          child: _FieldBox(
            label: 'TRAVELERS',
            value: '$_adultsCount Adults${_childrenCount > 0 ? ', $_childrenCount Kids' : ''}',
            icon: Icons.people_alt_rounded,
            onTap: _showTravelersModal,
          ),
        ),
        const SizedBox(width: 16),
        // Search Button
        ElevatedButton(
          onPressed: _onSearch,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.navyDark,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
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
                'Search',
                style: AppTextStyles.labelLG.copyWith(
                  color: AppColors.navyDark,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileFields(bool isMobile) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _FieldBox(
                label: 'FROM',
                value: _origin,
                icon: Icons.flight_takeoff_rounded,
                onTap: _showOriginPicker,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FieldBox(
                label: 'TO',
                value: _destination,
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
                label: 'DEPART',
                value: _dateFormat.format(_departureDate),
                icon: Icons.calendar_today_rounded,
                onTap: () => _pickDate(isDeparture: true),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FieldBox(
                label: 'RETURN',
                value: _dateFormat.format(_returnDate),
                icon: Icons.event_repeat_rounded,
                onTap: () => _pickDate(isDeparture: false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _FieldBox(
          label: 'TRAVELERS',
          value: '$_adultsCount Adults${_childrenCount > 0 ? ', $_childrenCount Kids' : ''}',
          icon: Icons.people_alt_rounded,
          onTap: _showTravelersModal,
        ),
        const SizedBox(height: 16),
        TravellaButton(
          label: 'Search Available Trips',
          variant: TravellaButtonVariant.gold,
          size: TravellaButtonSize.lg,
          fullWidth: true,
          leadingIcon: Icons.search_rounded,
          onPressed: _onSearch,
        ),
      ],
    );
  }

  Future<void> _pickDate({required bool isDeparture}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isDeparture ? _departureDate : _returnDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
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
      },
    );

    if (picked != null) {
      setState(() {
        if (isDeparture) {
          _departureDate = picked;
          if (_returnDate.isBefore(_departureDate)) {
            _returnDate = _departureDate.add(const Duration(days: 7));
          }
        } else {
          _returnDate = picked;
        }
      });
    }
  }

  void _showOriginPicker() {
    _showListDialog(
      title: 'Select Departure City',
      options: ['Cairo (CAI)', 'Alexandria (HBE)', 'Hurghada (HRG)', 'Sharm El Sheikh (SSH)', 'Luxor (LXR)', 'Dubai (DXB)', 'Riyadh (RUH)'],
      onSelected: (val) => setState(() => _origin = val),
    );
  }

  void _showDestinationPicker() {
    _showListDialog(
      title: 'Select Destination',
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
      ],
      onSelected: (val) => setState(() => _destination = val),
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
        title: Text(title, style: AppTextStyles.h5.copyWith(color: AppColors.white)),
        content: SizedBox(
          width: 320,
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

  void _showTravelersModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navyMedium,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Travelers', style: AppTextStyles.h4.copyWith(color: AppColors.white)),
              const SizedBox(height: 20),
              _buildCounterRow(
                'Adults',
                'Ages 12+',
                _adultsCount,
                (v) {
                  setModalState(() => _adultsCount = v.clamp(1, 10));
                  setState(() => _adultsCount = v.clamp(1, 10));
                },
              ),
              const Divider(color: AppColors.navyDark, height: 32),
              _buildCounterRow(
                'Children',
                'Ages 2 - 11',
                _childrenCount,
                (v) {
                  setModalState(() => _childrenCount = v.clamp(0, 8));
                  setState(() => _childrenCount = v.clamp(0, 8));
                },
              ),
              const SizedBox(height: 24),
              TravellaButton(
                label: 'Done',
                fullWidth: true,
                variant: TravellaButtonVariant.gold,
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounterRow(String title, String subtitle, int count, ValueChanged<int> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.labelLG.copyWith(color: AppColors.white)),
            Text(subtitle, style: AppTextStyles.bodySM.copyWith(color: AppColors.textOnDarkMuted)),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.goldLight),
              onPressed: () => onChanged(count - 1),
            ),
            SizedBox(
              width: 32,
              child: Text(
                '$count',
                textAlign: TextAlign.center,
                style: AppTextStyles.h5.copyWith(color: AppColors.white),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.goldLight),
              onPressed: () => onChanged(count + 1),
            ),
          ],
        ),
      ],
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
          color: AppColors.navyDark.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.12),
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

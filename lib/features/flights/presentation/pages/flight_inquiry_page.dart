import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../shared/presentation/widgets/app_navbar.dart';
import '../../../../shared/presentation/widgets/app_footer.dart';
import '../../../bookings/presentation/cubit/booking_cubit.dart';
import '../../../bookings/presentation/cubit/booking_state.dart';

/// Data transfer object holding validated flight inquiry data
class FlightInquiryData {
  final String origin;
  final String destination;
  final DateTime departureDate;
  final DateTime? returnDate;
  final bool isRoundTrip;
  final int adults;
  final int children;
  final List<int> childAges;
  final String cabinClass;

  const FlightInquiryData({
    required this.origin,
    required this.destination,
    required this.departureDate,
    this.returnDate,
    this.isRoundTrip = true,
    this.adults = 1,
    this.children = 0,
    this.childAges = const [],
    this.cabinClass = 'Economy',
  });

  factory FlightInquiryData.fromUri(Uri uri) {
    final query = uri.queryParameters;
    final now = DateTime.now().add(const Duration(days: 7));
    final dep = query['departure'] != null
        ? DateTime.tryParse(query['departure']!) ?? now
        : now;
    final ret = query['return'] != null
        ? DateTime.tryParse(query['return']!)
        : null;

    final childAgesRaw = query['childAges'];
    List<int> parsedAges = [];
    if (childAgesRaw != null && childAgesRaw.isNotEmpty) {
      parsedAges = childAgesRaw
          .split(',')
          .map((e) => int.tryParse(e.trim()) ?? 6)
          .toList();
    }

    return FlightInquiryData(
      origin: query['from'] ?? 'Cairo (CAI)',
      destination: query['destination'] ?? 'Istanbul, Turkey',
      departureDate: dep,
      returnDate: ret,
      isRoundTrip: (query['roundTrip'] ?? 'true') == 'true',
      adults: int.tryParse(query['adults'] ?? '2') ?? 2,
      children: int.tryParse(query['children'] ?? '0') ?? 0,
      childAges: parsedAges,
      cabinClass: query['cabinClass'] ?? 'Economy',
    );
  }
}

class FlightInquiryPage extends StatefulWidget {
  final FlightInquiryData? initialData;

  const FlightInquiryPage({super.key, this.initialData});

  @override
  State<FlightInquiryPage> createState() => _FlightInquiryPageState();
}

class _FlightInquiryPageState extends State<FlightInquiryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  late FlightInquiryData _data;
  late String _selectedCabinClass;
  bool _directFlightOnly = false;
  bool _flexibleDates = false;
  bool _isSubmitting = false;
  String? _submissionReference;

  final DateFormat _dateFormat = DateFormat('EEE, dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _data = widget.initialData ??
        FlightInquiryData(
          origin: 'Cairo (CAI)',
          destination: 'Istanbul, Turkey',
          departureDate: DateTime.now().add(const Duration(days: 14)),
          returnDate: DateTime.now().add(const Duration(days: 21)),
          isRoundTrip: true,
          adults: 2,
          children: 0,
        );
    _selectedCabinClass = _data.cabinClass;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitInquiry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final childAgesStr = _data.childAges.isNotEmpty
        ? ' [Ages: ${_data.childAges.join(', ')}]'
        : '';
    final tripTypeStr = _data.isRoundTrip ? 'Round Trip' : 'One Way';
    final returnStr = _data.isRoundTrip && _data.returnDate != null
        ? ' | Return: ${_dateFormat.format(_data.returnDate!)}'
        : '';

    final structuredNotes = StringBuffer()
      ..writeln('=== FLIGHT INQUIRY & BOOKING REQUEST ===')
      ..writeln('Route: ${_data.origin} ➔ ${_data.destination}')
      ..writeln('Trip Type: $tripTypeStr')
      ..writeln('Departure: ${_dateFormat.format(_data.departureDate)}$returnStr')
      ..writeln('Cabin Class: $_selectedCabinClass')
      ..writeln('Travelers: ${_data.adults} Adults, ${_data.children} Children$childAgesStr')
      ..writeln('Direct Flight Only: ${_directFlightOnly ? 'Yes' : 'No'}')
      ..writeln('Flexible Dates (+/- 3 days): ${_flexibleDates ? 'Yes' : 'No'}');

    if (_notesCtrl.text.trim().isNotEmpty) {
      structuredNotes.writeln('Customer Notes: ${_notesCtrl.text.trim()}');
    }

    final bookingCubit = context.read<BookingCubit>();
    final success = await bookingCubit.submitBooking(
      customerName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      travelDate: _data.departureDate,
      travelers: _data.adults + _data.children,
      notes: structuredNotes.toString(),
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        if (success) {
          final state = bookingCubit.state;
          if (state is BookingSubmittedSuccess) {
            _submissionReference = state.booking.bookingReference;
          } else {
            _submissionReference =
                'FL-${DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase()}';
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hPad = AppBreakpoints.horizontalPadding(context);
    final isMobile = AppBreakpoints.isMobile(context);
    final isArabic = context.isArabic;

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: CustomScrollView(
        slivers: [
          // ── Navbar ────────────────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: AppNavbar(currentRoute: AppRoutes.home),
          ),

          // ── Header Banner ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.navyDark,
              padding: EdgeInsets.symmetric(
                horizontal: hPad,
                vertical: isMobile ? 40 : 64,
              ),
              child: MaxWidthContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.flight_takeoff_rounded, color: AppColors.gold, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            isArabic ? 'حجز واستفسار الطيران' : 'FLIGHT INQUIRY & RESERVATION',
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isArabic
                          ? 'طلب حجز رحلة طيران مخصصة'
                          : 'Bespoke Flight Booking Request',
                      style: (isMobile ? AppTextStyles.h2 : AppTextStyles.h1).copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isArabic
                          ? 'يقوم مستشارو الطيران لدى ترافيلا بالبحث عن أفضل المسارات المباشرة والأسعار الحصرية على كبرى شركات الطيران العالمية.'
                          : 'Our dedicated air travel desk finds optimal direct routes, competitive fares, and premium seating on world-class airlines.',
                      style: AppTextStyles.bodyLG.copyWith(
                        color: AppColors.textOnDarkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Body Content ──────────────────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 40),
            sliver: SliverToBoxAdapter(
              child: MaxWidthContainer(
                child: _submissionReference != null
                    ? _buildSuccessConfirmation(isMobile, isArabic)
                    : _buildInquiryContent(isMobile, isArabic),
              ),
            ),
          ),

          // ── Footer ────────────────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: AppFooter(),
          ),
        ],
      ),
    );
  }

  Widget _buildInquiryContent(bool isMobile, bool isArabic) {
    if (isMobile) {
      return Column(
        children: [
          _buildFlightSummaryCard(isArabic),
          const SizedBox(height: 24),
          _buildInquiryForm(isArabic),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Flight Summary Card
        Expanded(
          flex: 4,
          child: _buildFlightSummaryCard(isArabic),
        ),
        const SizedBox(width: 32),
        // Right Column: Interactive Form
        Expanded(
          flex: 6,
          child: _buildInquiryForm(isArabic),
        ),
      ],
    );
  }

  Widget _buildFlightSummaryCard(bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? 'تفاصيل الرحلة المحددة' : 'Selected Flight Details',
                style: AppTextStyles.h4.copyWith(color: AppColors.navyDark),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.royalBlueFaded,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _data.isRoundTrip
                      ? (isArabic ? 'ذهاب وعودة' : 'Round Trip')
                      : (isArabic ? 'اتجاه واحد' : 'One Way'),
                  style: AppTextStyles.labelSM.copyWith(
                    color: AppColors.royalBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Route Visualizer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'من' : 'FROM',
                        style: AppTextStyles.overline.copyWith(color: AppColors.textLightMuted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _data.origin,
                        style: AppTextStyles.labelLG.copyWith(
                          color: AppColors.navyDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _data.isRoundTrip
                        ? Icons.sync_alt_rounded
                        : Icons.arrow_forward_rounded,
                    color: AppColors.navyDark,
                    size: 18,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        isArabic ? 'إلى' : 'TO',
                        style: AppTextStyles.overline.copyWith(color: AppColors.textLightMuted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _data.destination,
                        textAlign: TextAlign.end,
                        style: AppTextStyles.labelLG.copyWith(
                          color: AppColors.navyDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Departure Date
          _buildDetailRow(
            icon: Icons.calendar_today_rounded,
            label: isArabic ? 'تاريخ الذهاب' : 'Departure Date',
            value: _dateFormat.format(_data.departureDate),
          ),
          const SizedBox(height: 14),

          // Return Date (if round trip)
          if (_data.isRoundTrip && _data.returnDate != null) ...[
            _buildDetailRow(
              icon: Icons.event_repeat_rounded,
              label: isArabic ? 'تاريخ العودة' : 'Return Date',
              value: _dateFormat.format(_data.returnDate!),
            ),
            const SizedBox(height: 14),
          ],

          // Travelers Breakdown
          _buildDetailRow(
            icon: Icons.people_alt_rounded,
            label: isArabic ? 'المسافرون' : 'Travelers',
            value: '${_data.adults} ${isArabic ? 'بالغين' : 'Adults'}${_data.children > 0 ? ', ${_data.children} ${isArabic ? 'أطفال' : 'Children'}' : ''}',
          ),

          if (_data.children > 0 && _data.childAges.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text(
                isArabic
                    ? 'أعمار الأطفال: ${_data.childAges.join(', ')} سنة'
                    : 'Child Ages: ${_data.childAges.join(', ')} yrs',
                style: AppTextStyles.bodySM.copyWith(color: AppColors.royalBlue, fontWeight: FontWeight.w600),
              ),
            ),
          ],

          const SizedBox(height: 14),
          _buildDetailRow(
            icon: Icons.airline_seat_recline_extra_rounded,
            label: isArabic ? 'درجة السفر' : 'Cabin Class',
            value: _selectedCabinClass,
          ),

          const SizedBox(height: 24),
          const Divider(color: AppColors.borderLight),
          const SizedBox(height: 16),

          // Guarantees
          Row(
            children: [
              const Icon(Icons.verified_rounded, color: AppColors.successGreen, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isArabic
                      ? 'ضمان أفضل عروض وأسعار التذاكر الفاخرة'
                      : 'Guaranteed best verified airline fares & schedules',
                  style: AppTextStyles.bodySM.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.support_agent_rounded, color: AppColors.royalBlue, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isArabic
                      ? 'مستشار سياحي خاص يتابع حجزك وتعديلاته'
                      : 'Personal travel advisor managing ticketing & seat selection',
                  style: AppTextStyles.bodySM.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.royalBlue),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySM.copyWith(color: AppColors.textLightMuted, fontSize: 11)),
              Text(value, style: AppTextStyles.labelMD.copyWith(color: AppColors.navyDark, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInquiryForm(bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'معلومات الاتصال وتفضيلات الرحلة' : 'Contact Details & Preferences',
              style: AppTextStyles.h4.copyWith(color: AppColors.navyDark),
            ),
            const SizedBox(height: 6),
            Text(
              isArabic
                  ? 'أدخل بياناتك وسيقوم خبير الطيران لدينا بالتواصل معك بالعروض المتاحة خلال دقائق.'
                  : 'Submit your contact info and our flight specialist will reach out with verified itinerary options within minutes.',
              style: AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // Name Field
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: isArabic ? 'الاسم الكامل *' : 'Full Name *',
                prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.royalBlue),
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return isArabic ? 'يرجى إدخال الاسم الكامل' : 'Please enter your full name';
                }
                if (v.trim().length < 3) {
                  return isArabic ? 'الاسم قصير جداً' : 'Name must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email & Phone
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'البريد الإلكتروني *' : 'Email Address *',
                      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.royalBlue),
                      filled: true,
                      fillColor: AppColors.surfaceLight,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return isArabic ? 'البريد مطلوب' : 'Email is required';
                      }
                      if (!v.contains('@') || !v.contains('.')) {
                        return isArabic ? 'بريد غير صالح' : 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'رقم الهاتف / واتساب *' : 'Phone / WhatsApp *',
                      prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.royalBlue),
                      filled: true,
                      fillColor: AppColors.surfaceLight,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return isArabic ? 'رقم الهاتف مطلوب' : 'Phone number is required';
                      }
                      if (v.trim().length < 7) {
                        return isArabic ? 'رقم هاتف غير صالح' : 'Enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Cabin Class Selector
            Text(
              isArabic ? 'درجة السفر المفضلة:' : 'Preferred Cabin Class:',
              style: AppTextStyles.labelMD.copyWith(color: AppColors.navyDark, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: ['Economy', 'Premium Economy', 'Business Class', 'First Class'].map((cabin) {
                final isSel = _selectedCabinClass == cabin;
                return ChoiceChip(
                  label: Text(cabin),
                  selected: isSel,
                  selectedColor: AppColors.royalBlue,
                  labelStyle: TextStyle(
                    color: isSel ? AppColors.white : AppColors.navyDark,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                  ),
                  backgroundColor: AppColors.surfaceLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: isSel ? AppColors.royalBlue : AppColors.borderLight),
                  ),
                  onSelected: (_) => setState(() => _selectedCabinClass = cabin),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Toggles
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                isArabic ? 'أفضل الرحلات المباشرة فقط' : 'Prefer direct / non-stop flights only',
                style: AppTextStyles.bodyMD.copyWith(color: AppColors.navyDark),
              ),
              value: _directFlightOnly,
              activeColor: AppColors.royalBlue,
              onChanged: (v) => setState(() => _directFlightOnly = v ?? false),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                isArabic ? 'تواريخ السفر مرنة (± 3 أيام للبحث عن أفضل سعر)' : 'My dates are flexible (± 3 days for best rates)',
                style: AppTextStyles.bodyMD.copyWith(color: AppColors.navyDark),
              ),
              value: _flexibleDates,
              activeColor: AppColors.royalBlue,
              onChanged: (v) => setState(() => _flexibleDates = v ?? false),
            ),
            const SizedBox(height: 12),

            // Additional Notes
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: isArabic ? 'ملاحظات إضافية أو شركة طيران مفضلة' : 'Additional Notes / Preferred Airline / Special Meals',
                hintText: isArabic
                    ? 'مثال: تفضيل مقاعد بجانب النافذة، طيران الإمارات أو الخطوط السعودية، وجبة نباتية...'
                    : 'e.g. Prefer Emirates/Qatar Airways, extra baggage, wheelchair assistance, aisle seats...',
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 28),

            // Submit Button
            TravellaButton(
              label: isArabic ? 'إرسال طلب الحجز والاستفسار' : 'Submit Flight Request',
              variant: TravellaButtonVariant.gold,
              size: TravellaButtonSize.lg,
              fullWidth: true,
              leadingIcon: Icons.send_rounded,
              isLoading: _isSubmitting,
              onPressed: _submitInquiry,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessConfirmation(bool isMobile, bool isArabic) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 48),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.08),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.successGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.successGreen,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isArabic ? 'تم استلام طلب رحلتك بنجاح!' : 'Flight Inquiry Received Successfully!',
            textAlign: TextAlign.center,
            style: (isMobile ? AppTextStyles.h3 : AppTextStyles.h2).copyWith(
              color: AppColors.navyDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isArabic
                ? 'شكراً لك، رقم مرجع الطلب الخاص بك هو:'
                : 'Thank you! Your flight reservation request reference number is:',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLG.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold, width: 1.5),
            ),
            child: Text(
              _submissionReference ?? 'FL-REQ-PENDING',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.royalBlueDark,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isArabic ? 'المسار:' : 'Route:', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${_data.origin} ➔ ${_data.destination}'),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isArabic ? 'تاريخ السفر:' : 'Departure:', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(_dateFormat.format(_data.departureDate)),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isArabic ? 'المسافرون:' : 'Travelers:', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${_data.adults} Adults${_data.children > 0 ? ', ${_data.children} Children' : ''}'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => context.goNamed(AppRoutes.homeName),
                icon: const Icon(Icons.home_rounded, size: 18),
                label: Text(isArabic ? 'العودة للرئيسية' : 'Back to Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  final msg = Uri.encodeComponent(
                      'Hello Travella, I just submitted flight inquiry $_submissionReference (${_data.origin} to ${_data.destination}).');
                  launchUrl(Uri.parse('https://wa.me/201000000000?text=$msg'), mode: LaunchMode.externalApplication);
                },
                icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                label: Text(isArabic ? 'متابعة عبر واتساب' : 'Instant WhatsApp Assistance'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.successGreen,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

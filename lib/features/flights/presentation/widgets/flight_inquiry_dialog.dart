import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/localization/app_translations.dart';
import '../cubit/flight_cubit.dart';
import '../cubit/flight_state.dart';
import '../../data/models/flight_models.dart';

Future<void> showFlightInquiryDialog(
  BuildContext context, {
  required FlightSearchQuery query,
  FlightOffer? selectedOffer,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => BlocProvider.value(
      value: context.read<FlightCubit>(),
      child: _FlightInquiryDialog(
        query: query,
        selectedOffer: selectedOffer,
      ),
    ),
  );
}

class _FlightInquiryDialog extends StatefulWidget {
  final FlightSearchQuery query;
  final FlightOffer? selectedOffer;

  const _FlightInquiryDialog({
    required this.query,
    this.selectedOffer,
  });

  @override
  State<_FlightInquiryDialog> createState() => _FlightInquiryDialogState();
}

class _FlightInquiryDialogState extends State<_FlightInquiryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  bool _directFlightOnly = false;
  bool _flexibleDates = false;
  String _selectedCabinClass = 'Economy';
  bool _isSubmitting = false;

  final DateFormat _dateFormat = DateFormat('EEE, dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _selectedCabinClass = widget.selectedOffer?.cabinClass ?? widget.query.cabinClass;
    _directFlightOnly = widget.selectedOffer?.isNonStop ?? false;
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

    final flightCubit = context.read<FlightCubit>();
    await flightCubit.submitFlightInquiry(
      query: widget.query.copyWith(cabinClass: _selectedCabinClass),
      customerName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      userNotes: _notesCtrl.text.trim(),
      directOnly: _directFlightOnly,
      flexibleDates: _flexibleDates,
      selectedOffer: widget.selectedOffer,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 700;

    return BlocBuilder<FlightCubit, FlightState>(
      builder: (context, state) {
        if (state is FlightInquirySubmitted) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: AppColors.white,
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 580),
              padding: EdgeInsets.all(isMobile ? 24 : 36),
              child: _buildSuccessView(state, isArabic),
            ),
          );
        }

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: AppColors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 680),
            padding: EdgeInsets.all(isMobile ? 20 : 32),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.royalBlueFaded,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.flight_takeoff_rounded,
                                color: AppColors.royalBlue,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isArabic ? 'طلب حجز واستفسار طيران' : 'Flight Booking & Consultation',
                                  style: AppTextStyles.h4.copyWith(
                                    color: AppColors.navyDark,
                                    fontSize: isMobile ? 16 : 18,
                                  ),
                                ),
                                Text(
                                  isArabic
                                      ? 'مكتب استشارات الطيران لدى ترافيلا'
                                      : 'Travella Certified Air Travel Concierge',
                                  style: AppTextStyles.bodySM.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: AppColors.gray400),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.borderLight),
                    const SizedBox(height: 14),

                    // Flight Summary Banner
                    _buildFlightSummaryBanner(isArabic),
                    const SizedBox(height: 20),

                    // Notice
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.royalBlue.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.royalBlue.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppColors.royalBlue, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isArabic
                                  ? 'لا يتم خصم أي مبالغ الآن. سيقوم مستشار الطيران بالتحقق من جداول ومقاعد الطيران وإرسال أفضل الأسعار.'
                                  : 'Zero upfront commitment. Our air specialist will verify availability and quote the optimal airline rates.',
                              style: AppTextStyles.bodySM.copyWith(
                                color: AppColors.navyDark,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Contact Fields
                    Text(
                      isArabic ? 'معلومات المسافر الرئيسي للتواصل' : 'Primary Traveler Contact Details',
                      style: AppTextStyles.labelLG.copyWith(
                        color: AppColors.navyDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Name
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
                          return isArabic ? 'يرجى إدخال الاسم' : 'Please enter your name';
                        }
                        if (v.trim().length < 3) {
                          return isArabic ? 'الاسم قصير جداً' : 'Name must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

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
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: isArabic ? 'الهاتف / واتساب *' : 'Phone / WhatsApp *',
                              prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.royalBlue),
                              filled: true,
                              fillColor: AppColors.surfaceLight,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return isArabic ? 'رقم الهاتف مطلوب' : 'Phone is required';
                              }
                              if (v.trim().length < 7) {
                                return isArabic ? 'رقم هاتف غير صالح' : 'Enter a valid phone';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Cabin Class Chips
                    Text(
                      isArabic ? 'درجة السفر المفضلة:' : 'Preferred Cabin Class:',
                      style: AppTextStyles.labelMD.copyWith(
                        color: AppColors.navyDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['Economy', 'Premium Economy', 'Business Class', 'First Class'].map((cabin) {
                        final isSel = _selectedCabinClass == cabin;
                        return ChoiceChip(
                          label: Text(cabin),
                          selected: isSel,
                          selectedColor: AppColors.royalBlue,
                          labelStyle: TextStyle(
                            color: isSel ? AppColors.white : AppColors.navyDark,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                            fontSize: 12,
                          ),
                          backgroundColor: AppColors.surfaceLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: isSel ? AppColors.royalBlue : AppColors.borderLight),
                          ),
                          onSelected: (_) => setState(() => _selectedCabinClass = cabin),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Checkboxes
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        isArabic ? 'تفضيل رحلات مباشرة بدون توقف' : 'Prefer direct / non-stop flights only',
                        style: AppTextStyles.bodyMD.copyWith(color: AppColors.navyDark, fontSize: 13),
                      ),
                      value: _directFlightOnly,
                      activeColor: AppColors.royalBlue,
                      onChanged: (v) => setState(() => _directFlightOnly = v ?? false),
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        isArabic ? 'التواريخ مرنة (± 3 أيام للبحث عن أفضل سعر)' : 'Flexible travel dates (+/- 3 days for best fares)',
                        style: AppTextStyles.bodyMD.copyWith(color: AppColors.navyDark, fontSize: 13),
                      ),
                      value: _flexibleDates,
                      activeColor: AppColors.royalBlue,
                      onChanged: (v) => setState(() => _flexibleDates = v ?? false),
                    ),
                    const SizedBox(height: 12),

                    // Notes
                    TextFormField(
                      controller: _notesCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: isArabic ? 'ملاحظات إضافية أو شركة طيران مفضلة' : 'Special Notes / Preferred Airline / Dietary / Loyalty No.',
                        hintText: isArabic ? 'مثال: تفضيل مقعد نافذة، طيران الإمارات، وجبة خالية من الغلوتين...' : 'e.g. Prefer Emirates/Saudia, window seat, extra baggage...',
                        filled: true,
                        fillColor: AppColors.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit CTA
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildFlightSummaryBanner(bool isArabic) {
    final query = widget.query;
    final offer = widget.selectedOffer;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${query.origin} ➔ ${query.destination}',
                style: AppTextStyles.labelLG.copyWith(
                  color: AppColors.navyDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  query.isRoundTrip
                      ? (isArabic ? 'ذهاب وعودة' : 'Round Trip')
                      : (isArabic ? 'اتجاه واحد' : 'One Way'),
                  style: const TextStyle(
                    color: AppColors.goldDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${isArabic ? 'المغادرة: ' : 'Departure: '}${_dateFormat.format(query.departureDate)}',
                style: AppTextStyles.bodySM.copyWith(color: AppColors.textSecondary),
              ),
              if (query.isRoundTrip && query.returnDate != null)
                Text(
                  '${isArabic ? 'العودة: ' : 'Return: '}${_dateFormat.format(query.returnDate!)}',
                  style: AppTextStyles.bodySM.copyWith(color: AppColors.textSecondary),
                ),
            ],
          ),
          if (offer != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${offer.airlineName} (${offer.flightNumber})',
                  style: AppTextStyles.labelSM.copyWith(
                    color: AppColors.royalBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Est: ${offer.currency} ${offer.price.toInt()}',
                  style: AppTextStyles.labelSM.copyWith(
                    color: AppColors.navyDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuccessView(FlightInquirySubmitted state, bool isArabic) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.successGreen.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: AppColors.successGreen,
            size: 44,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          isArabic ? 'تم استلام طلب حجز الطيران' : 'Flight Request Received',
          textAlign: TextAlign.center,
          style: AppTextStyles.h3.copyWith(
            color: AppColors.navyDark,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          isArabic
              ? 'We received your flight request. Our team will contact you with available options.'
              : 'We received your flight request. Our team will contact you with available options.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMD.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 18),

        // Reference Box
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gold, width: 1.5),
          ),
          child: Column(
            children: [
              Text(
                isArabic ? 'الرقم المرجعي للطلب' : 'REQUEST REFERENCE',
                style: AppTextStyles.overline.copyWith(
                  color: AppColors.textLightMuted,
                  letterSpacing: 1.5,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                state.referenceCode,
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.navyDark,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // WhatsApp CTA + Done
        Wrap(
          spacing: 12,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                final text = Uri.encodeComponent(
                  'Hello Travella, I just submitted flight inquiry ${state.referenceCode} for route ${state.query.origin} to ${state.query.destination}.',
                );
                launchUrl(Uri.parse('https://wa.me/201000000000?text=$text'), mode: LaunchMode.externalApplication);
              },
              icon: const Icon(Icons.chat_bubble_rounded, size: 18),
              label: Text(isArabic ? 'متابعة عبر واتساب' : 'Instant WhatsApp Assistance'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successGreen,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(isArabic ? 'تم' : 'Done'),
            ),
          ],
        ),
      ],
    );
  }
}

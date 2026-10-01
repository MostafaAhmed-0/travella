import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/traveler_selector.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../data/models/hotel_model.dart';
import '../../../bookings/presentation/cubit/booking_cubit.dart';
import '../../../bookings/presentation/cubit/booking_state.dart';

class HotelBookingDialog extends StatefulWidget {
  final HotelModel hotel;
  final DateTime checkIn;
  final DateTime checkOut;
  final TravelerSelection travelers;

  const HotelBookingDialog({
    super.key,
    required this.hotel,
    required this.checkIn,
    required this.checkOut,
    required this.travelers,
  });

  @override
  State<HotelBookingDialog> createState() => _HotelBookingDialogState();
}

class _HotelBookingDialogState extends State<HotelBookingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  late DateTime _checkIn;
  late DateTime _checkOut;
  late TravelerSelection _travelers;
  bool _isSubmitting = false;
  String? _bookingRef;

  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _checkIn = widget.checkIn;
    _checkOut = widget.checkOut;
    _travelers = widget.travelers;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final nights = _checkOut.difference(_checkIn).inDays.clamp(1, 365);
    final totalEstimate = widget.hotel.price * nights * _travelers.rooms;

    final structuredNotes = StringBuffer()
      ..writeln('=== HOTEL RESERVATION REQUEST ===')
      ..writeln('Hotel Name: ${widget.hotel.name}')
      ..writeln('Location: ${widget.hotel.location}')
      ..writeln('Room Type: ${widget.hotel.roomType}')
      ..writeln('Check-in: ${_dateFormat.format(_checkIn)}')
      ..writeln('Check-out: ${_dateFormat.format(_checkOut)} ($nights Nights)')
      ..writeln('Rooms: ${_travelers.rooms}')
      ..writeln('Adults: ${_travelers.adults}')
      ..writeln('Children: ${_travelers.children}');

    if (_travelers.children > 0 && _travelers.childAges.isNotEmpty) {
      structuredNotes.writeln('Child Ages: ${_travelers.childAges.join(", ")} years old');
    }

    structuredNotes.writeln('Estimated Total: ${widget.hotel.currency} $totalEstimate (Zero Upfront)');

    if (_notesCtrl.text.trim().isNotEmpty) {
      structuredNotes.writeln('Customer Special Requests: ${_notesCtrl.text.trim()}');
    }

    final bookingCubit = context.read<BookingCubit>();
    final success = await bookingCubit.submitBooking(
      customerName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      travelDate: _checkIn,
      travelers: _travelers.totalTravelers,
      adultsCount: _travelers.adults,
      childrenCount: _travelers.children,
      childrenAges: _travelers.childAges,
      notes: structuredNotes.toString(),
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        if (success) {
          final state = bookingCubit.state;
          if (state is BookingSubmittedSuccess) {
            _bookingRef = state.booking.bookingReference;
          } else {
            _bookingRef = 'HT-${DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase()}';
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;
    final nights = _checkOut.difference(_checkIn).inDays.clamp(1, 365);
    final totalEstimate = widget.hotel.price * nights * _travelers.rooms;

    if (_bookingRef != null) {
      return AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 60),
            const SizedBox(height: 16),
            Text(
              isArabic ? 'تم إرسال طلب حجز الفندق بنجاح' : 'Hotel Reservation Request Received!',
              style: AppTextStyles.h4.copyWith(color: AppColors.navyDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isArabic ? 'رقم الطلب المرجعي:' : 'Your reservation reference code:',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.gold, width: 1.5),
              ),
              child: Text(
                _bookingRef!,
                style: AppTextStyles.labelLG.copyWith(
                  color: AppColors.royalBlueDark,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isArabic
                  ? 'تم حفظ طلبك بحالة "قيد المراجعة" في النظام. سيقوم مستشار حجز الفنادق بالتواصل معك لتأكيد توافر الغرفة وإصدار القسيمة الفندقية الرسمية.'
                  : 'Your reservation request is saved with status "Pending". A Travella concierge specialist will contact you shortly to confirm room allocation and issue your official voucher.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TravellaButton(
            label: isArabic ? 'إغلاق' : 'Close',
            variant: TravellaButtonVariant.primary,
            fullWidth: true,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    }

    return AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.royalBlueFaded,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.hotel_rounded, color: AppColors.royalBlue, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.hotel.localizedName(isArabic),
                  style: AppTextStyles.h5.copyWith(color: AppColors.navyDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${widget.hotel.city}, ${widget.hotel.country} • ${widget.hotel.currency} ${widget.hotel.price.toInt()}/night',
                  style: AppTextStyles.bodySM.copyWith(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Booking Schedule Summary Box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(isArabic ? 'تاريخ الوصول' : 'Check-in',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textLightMuted)),
                              Text(_dateFormat.format(_checkIn),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const Icon(Icons.arrow_forward_rounded, color: AppColors.gold, size: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(isArabic ? 'تاريخ المغادرة' : 'Check-out',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textLightMuted)),
                              Text(_dateFormat.format(_checkOut),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.royalBlueFaded,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$nights ${isArabic ? 'ليالٍ' : 'Nights'}',
                              style: const TextStyle(
                                  color: AppColors.royalBlue, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(color: AppColors.borderLight, height: 1),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _travelers.formattedSummary(isArabic: isArabic, includeRooms: true),
                            style: AppTextStyles.bodySM.copyWith(
                              color: AppColors.navyDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${widget.hotel.currency} $totalEstimate',
                            style: AppTextStyles.labelLG.copyWith(
                              color: AppColors.royalBlueDark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      if (_travelers.children > 0 && _travelers.childAges.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              isArabic
                                  ? 'أعمار الأطفال: ${_travelers.childAges.join(", ")} سنوات'
                                  : 'Child Ages: ${_travelers.childAges.join(", ")} years',
                              style: const TextStyle(fontSize: 11, color: AppColors.royalBlue),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Customer Contact Details
                Text(
                  isArabic ? 'بيانات المسافر للتواصل' : 'Customer Contact Details',
                  style: AppTextStyles.labelLG.copyWith(
                    color: AppColors.navyDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),

                // Full Name
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'الاسم الكامل *' : 'Full Legal Name *',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? (isArabic ? 'الاسم مطلوب' : 'Name is required')
                      : null,
                ),
                const SizedBox(height: 12),

                // Email & Phone
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: isArabic ? 'البريد الإلكتروني *' : 'Email Address *',
                          prefixIcon: const Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: AppColors.surfaceLight,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (v) => v == null || !v.contains('@')
                            ? (isArabic ? 'بريد غير صالح' : 'Valid email required')
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: isArabic ? 'الهاتف / واتساب *' : 'Phone / WhatsApp *',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          filled: true,
                          fillColor: AppColors.surfaceLight,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (v) => v == null || v.trim().length < 7
                            ? (isArabic ? 'هاتف غير صالح' : 'Valid phone required')
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Special Requests / Notes
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'ملاحظات أو طلبات خاصة (اختياري)' : 'Special Requests / Preferences',
                    hintText: isArabic
                        ? 'مثال: سرير إضافي، إطلالة على البحر، وصول متأخر، طابق علوي...'
                        : 'e.g. King bed, sea view, late check-in, high floor...',
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(isArabic ? 'إلغاء' : 'Cancel', style: const TextStyle(color: AppColors.gray600)),
        ),
        TravellaButton(
          label: isArabic ? 'تأكيد إرسال الطلب' : 'Confirm Reservation Request',
          variant: TravellaButtonVariant.gold,
          isLoading: _isSubmitting,
          onPressed: _submitBooking,
        ),
      ],
    );
  }
}

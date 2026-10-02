import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../data/models/airport_transfer_model.dart';
import '../cubit/transfers_cubit.dart';
import '../cubit/transfers_state.dart';

class TransferBookingDialog extends StatefulWidget {
  final TransferVehicleModel vehicle;
  final TransfersState state;
  final TransfersCubit cubit;

  const TransferBookingDialog({
    super.key,
    required this.vehicle,
    required this.state,
    required this.cubit,
  });

  static Future<void> show(
    BuildContext context, {
    required TransferVehicleModel vehicle,
    required TransfersState state,
    required TransfersCubit cubit,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => TransferBookingDialog(
        vehicle: vehicle,
        state: state,
        cubit: cubit,
      ),
    );
  }

  @override
  State<TransferBookingDialog> createState() => _TransferBookingDialogState();
}

class _TransferBookingDialogState extends State<TransferBookingDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _flightController;
  late final TextEditingController _notesController;

  bool _isSubmitted = false;
  String? _bookingId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _flightController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _flightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await widget.cubit.createBookingRequest(
      vehicle: widget.vehicle,
      customerName: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      flightNumber: _flightController.text,
      specialRequests: _notesController.text,
    );

    if (success && mounted) {
      setState(() {
        _isSubmitted = true;
        _bookingId = widget.cubit.state.bookingSuccessId ??
            'TB-${DateTime.now().millisecondsSinceEpoch % 100000}';
      });
    }
  }

  Future<void> _openWhatsApp() async {
    final msg = Uri.encodeComponent(
      'Hello Travella! I just booked an airport transfer (Ref: ${_bookingId ?? "Pending"}). '
      'Vehicle: ${widget.vehicle.vehicleName}, Date: ${DateFormat('yyyy-MM-dd').format(widget.state.pickupDate)}, '
      'From: ${widget.state.pickupLocation} To: ${widget.state.dropoffLocation}.',
    );
    final uri = Uri.parse('https://wa.me/201000000000?text=$msg');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 650;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 24,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 780),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.navyDark.withValues(alpha: 0.3),
              blurRadius: 35,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: _isSubmitted ? _buildSuccessView(isArabic) : _buildFormView(isArabic, isMobile),
        ),
      ),
    );
  }

  Widget _buildFormView(bool isArabic, bool isMobile) {
    final dateFormat = DateFormat('EEEE, MMM d, yyyy');

    return Column(
      children: [
        // Modal Header
        Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
          color: AppColors.navyDark,
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.airport_shuttle_rounded, color: AppColors.navyDark, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'تأكيد حجز التوصيل الخاص' : 'Complete Transfer Reservation',
                      style: AppTextStyles.h6.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.vehicle.getLocalizedName(isArabic),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: AppColors.white),
              ),
            ],
          ),
        ),

        // Scrollable Form Body
        Expanded(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(isMobile ? 18 : 24),
              children: [
                // 1. Trip Summary Recap Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.trip_origin_rounded, color: AppColors.goldDark, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isArabic ? 'مكان الاستلام' : 'Pick-up Location',
                                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 10),
                                ),
                                Text(
                                  widget.state.pickupLocation,
                                  style: AppTextStyles.bodySM.copyWith(fontWeight: FontWeight.bold, color: AppColors.navyDark),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Icon(Icons.more_vert_rounded, size: 16, color: AppColors.gray400),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.place_rounded, color: AppColors.royalBlue, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isArabic ? 'مكان الوصول' : 'Drop-off Location',
                                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 10),
                                ),
                                Text(
                                  widget.state.dropoffLocation,
                                  style: AppTextStyles.bodySM.copyWith(fontWeight: FontWeight.bold, color: AppColors.navyDark),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: AppColors.gray300),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_month_rounded, size: 14, color: AppColors.gray600),
                              const SizedBox(width: 4),
                              Text(
                                '${dateFormat.format(widget.state.pickupDate)} (${widget.state.pickupTime})',
                                style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600, color: AppColors.navyDark),
                              ),
                            ],
                          ),
                          Text(
                            widget.state.passengers.formattedSummary(isArabic: isArabic, includeRooms: false),
                            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.royalBlue),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Customer Contact Info
                Text(
                  isArabic ? 'معلومات العميل والمسافر' : 'Primary Passenger Details',
                  style: AppTextStyles.bodyMD.copyWith(fontWeight: FontWeight.bold, color: AppColors.navyDark),
                ),
                const SizedBox(height: 12),

                // Full Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'الاسم الكامل *' : 'Full Name *',
                    prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.goldDark),
                    filled: true,
                    fillColor: AppColors.lightGray,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? (isArabic ? 'يرجى كتابة الاسم الكامل' : 'Please enter your full name')
                      : null,
                ),
                const SizedBox(height: 12),

                // Email & Phone
                if (isMobile) ...[
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'البريد الإلكتروني *' : 'Email Address *',
                      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.goldDark),
                      filled: true,
                      fillColor: AppColors.lightGray,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    validator: (v) => (v == null || !v.contains('@'))
                        ? (isArabic ? 'يرجى إدخال بريد إلكتروني صحيح' : 'Please enter a valid email')
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'رقم الهاتف / الواتساب *' : 'Phone / WhatsApp *',
                      prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.goldDark),
                      filled: true,
                      fillColor: AppColors.lightGray,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    validator: (v) => (v == null || v.trim().length < 6)
                        ? (isArabic ? 'يرجى كتابة رقم هاتف صالح' : 'Please enter a valid phone number')
                        : null,
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: isArabic ? 'البريد الإلكتروني *' : 'Email Address *',
                            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.goldDark),
                            filled: true,
                            fillColor: AppColors.lightGray,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          validator: (v) => (v == null || !v.contains('@'))
                              ? (isArabic ? 'بريد إلكتروني غير صالح' : 'Enter valid email')
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: isArabic ? 'رقم الهاتف / الواتساب *' : 'Phone / WhatsApp *',
                            prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.goldDark),
                            filled: true,
                            fillColor: AppColors.lightGray,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          validator: (v) => (v == null || v.trim().length < 6)
                              ? (isArabic ? 'رقم هاتف غير صالح' : 'Enter valid phone')
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),

                // 3. Flight Info & Special Requests
                TextFormField(
                  controller: _flightController,
                  decoration: InputDecoration(
                    labelText: context.tr('transfers_flight_no'),
                    hintText: 'e.g. MS 777 or Terminal 3',
                    prefixIcon: const Icon(Icons.flight_outlined, color: AppColors.royalBlue),
                    filled: true,
                    fillColor: AppColors.lightGray,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'ملاحظات إضافية أو طلب كرسي أطفال' : 'Special requests, booster seat, extra luggage',
                    prefixIcon: const Icon(Icons.edit_note_rounded, color: AppColors.gray500),
                    filled: true,
                    fillColor: AppColors.lightGray,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),

                // Fare Summary Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.navyDark,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? 'المبلغ الإجمالي المستحق' : 'Total Fixed Price',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textOnDarkMuted),
                          ),
                          Text(
                            isArabic ? 'شامل الضرائب والانتظار' : 'No hidden surge fees',
                            style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        '\$${widget.vehicle.basePrice.toStringAsFixed(0)} ${widget.vehicle.currency}',
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Action Buttons
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border(top: BorderSide(color: AppColors.gray200)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(isArabic ? 'إلغاء' : 'Cancel'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: TravellaButton(
                  label: context.tr('transfers_book_btn'),
                  variant: TravellaButtonVariant.gold,
                  size: TravellaButtonSize.lg,
                  leadingIcon: Icons.check_circle_outline_rounded,
                  onPressed: _submitBooking,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView(bool isArabic) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 48),
          ),
          const SizedBox(height: 20),
          Text(
            context.tr('transfers_booking_success_title'),
            style: AppTextStyles.h4.copyWith(
              color: AppColors.navyDark,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            context.tr('transfers_booking_success_desc'),
            style: AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isArabic ? 'رقم المرجع: ' : 'Booking Reference: ',
                  style: AppTextStyles.bodySM.copyWith(color: AppColors.textSecondary),
                ),
                Text(
                  _bookingId ?? 'TB-PENDING',
                  style: AppTextStyles.bodyMD.copyWith(fontWeight: FontWeight.bold, color: AppColors.navyDark),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openWhatsApp,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFF25D366)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.chat_bubble_rounded, color: Color(0xFF25D366), size: 18),
                  label: Text(
                    isArabic ? 'متابعة عبر الواتساب' : 'WhatsApp Support',
                    style: const TextStyle(color: Color(0xFF25D366), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TravellaButton(
                  label: isArabic ? 'تم، إغلاق' : 'Done',
                  variant: TravellaButtonVariant.gold,
                  size: TravellaButtonSize.lg,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

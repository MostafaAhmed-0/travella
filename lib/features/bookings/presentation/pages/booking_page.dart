import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../shared/presentation/widgets/app_navbar.dart';
import '../../../../shared/presentation/widgets/app_footer.dart';
import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime? _travelDate;
  int _travelers = 2;
  String _selectedTour = 'Hurghada Red Sea Adventure';

  final List<String> _popularTours = [
    'Hurghada Red Sea Adventure',
    'Sharm El Sheikh Sinai Safari',
    'Royal Nile Cruise: Aswan to Luxor',
    'Siwa Eco-Lodge & Salt Lakes',
    'Grand Istanbul & Ottoman Palaces',
    'Romantic Paris & Versailles',
    'Dubai Ultimate Luxury & Safari',
    'Maldives Overwater Luxury Escape',
    'VIP Diamond Umrah Package',
    'Royal Platinum Hajj Package',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.royalBlue,
              onPrimary: AppColors.white,
              onSurface: AppColors.navyDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _travelDate = picked);
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() == true) {
      context.read<BookingCubit>().submitBooking(
        customerName: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        tourId: _selectedTour,
        travelDate: _travelDate,
        travelers: _travelers,
        notes: _notesCtrl.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(context);
    final hPad = AppBreakpoints.horizontalPadding(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AppNavbar(currentRoute: AppRoutes.booking),

            // ── Hero Banner ──────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: hPad,
                vertical: isMobile ? 48 : 80,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.navyDark, AppColors.navyMedium],
                ),
              ),
              child: MaxWidthContainer(
                maxWidth: 800,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.gold,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'CONCIERGE TRAVEL BOOKING',
                            style: AppTextStyles.labelSM.copyWith(
                              color: AppColors.goldLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Reserve Your Unforgettable Journey',
                      style: AppTextStyles.h1.copyWith(
                        color: AppColors.white,
                        fontSize: isMobile ? 30 : 44,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Complete our quick booking request and our dedicated travel concierge will confirm your itinerary within 2 business hours.',
                      style: AppTextStyles.bodyLG.copyWith(
                        color: AppColors.textOnDarkMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // ── Form Section ─────────────────────────────────────────────────
            Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: MaxWidthContainer(
                  maxWidth: 720,
                  child: BlocConsumer<BookingCubit, BookingState>(
                    listener: (context, state) {
                      if (state is BookingSubmittedSuccess) {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.success,
                                  size: 28,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Booking Received!',
                                  style: AppTextStyles.h4,
                                ),
                              ],
                            ),
                            content: Text(
                              'Thank you, ${_nameCtrl.text.trim()}! Your booking request for $_selectedTour has been recorded into our system. Our travel advisor will reach out to you at ${_emailCtrl.text.trim()} shortly.',
                              style: AppTextStyles.bodyMD,
                            ),
                            actions: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.navy,
                                  foregroundColor: AppColors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  context.goNamed(AppRoutes.homeName);
                                },
                                child: const Text('Back to Home'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      final isLoading = state is BookingLoading;

                      return Container(
                        padding: EdgeInsets.all(isMobile ? 24 : 40),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.borderLight),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.navy.withValues(alpha: 0.08),
                              blurRadius: 36,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '1. Select Tour Package',
                                style: AppTextStyles.h5,
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                value: _selectedTour,
                                items: _popularTours
                                    .map(
                                      (t) => DropdownMenuItem(
                                        value: t,
                                        child: Text(t),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    setState(() => _selectedTour = v);
                                  }
                                },
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.flight_takeoff_rounded,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              Text(
                                '2. Traveler Contact Details',
                                style: AppTextStyles.h5,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _nameCtrl,
                                decoration: InputDecoration(
                                  labelText: 'Full Name',
                                  hintText: 'John Doe',
                                  prefixIcon: const Icon(
                                    Icons.person_outline_rounded,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Please enter your name'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _emailCtrl,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        labelText: 'Email Address',
                                        hintText: 'john@example.com',
                                        prefixIcon: const Icon(
                                          Icons.email_outlined,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      validator: (v) =>
                                          (v == null || !v.contains('@'))
                                          ? 'Valid email required'
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _phoneCtrl,
                                      keyboardType: TextInputType.phone,
                                      decoration: InputDecoration(
                                        labelText: 'Phone / WhatsApp',
                                        hintText: '+1 234 567 8900',
                                        prefixIcon: const Icon(
                                          Icons.phone_outlined,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      validator: (v) =>
                                          (v == null || v.trim().isEmpty)
                                          ? 'Phone is required'
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              Text(
                                '3. Travel Schedule & Guests',
                                style: AppTextStyles.h5,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: _pickDate,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: AppColors.borderLight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_month_rounded,
                                              color: AppColors.royalBlue,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              _travelDate == null
                                                  ? 'Choose Departure Date'
                                                  : '${_travelDate!.day}/${_travelDate!.month}/${_travelDate!.year}',
                                              style: AppTextStyles.bodyMD
                                                  .copyWith(
                                                    color: _travelDate == null
                                                        ? AppColors.gray500
                                                        : AppColors.navyDark,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.borderLight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.group_outlined,
                                          color: AppColors.royalBlue,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Travelers: $_travelers',
                                          style: AppTextStyles.labelMD,
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.remove_circle_outline,
                                            size: 20,
                                          ),
                                          onPressed: _travelers > 1
                                              ? () =>
                                                    setState(() => _travelers--)
                                              : null,
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.add_circle_outline,
                                            size: 20,
                                          ),
                                          onPressed: _travelers < 20
                                              ? () =>
                                                    setState(() => _travelers++)
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              Text(
                                '4. Special Requests or Notes (Optional)',
                                style: AppTextStyles.h5,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _notesCtrl,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText:
                                      'e.g. Dietary preferences, honeymoon arrangements, room upgrades...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),

                              TravellaButton(
                                label: 'Submit Booking Request',
                                size: TravellaButtonSize.lg,
                                fullWidth: true,
                                isLoading: isLoading,
                                leadingIcon: Icons.send_rounded,
                                onPressed: isLoading ? null : _handleSubmit,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 60),
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}

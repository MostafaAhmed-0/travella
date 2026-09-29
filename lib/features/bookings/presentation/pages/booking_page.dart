import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../data/models/booking_model.dart';
import '../../../../data/models/tour_model.dart';
import '../../../../data/repositories/tour_repository.dart';
import '../../../../shared/presentation/widgets/app_navbar.dart';
import '../../../../shared/presentation/widgets/app_footer.dart';
import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';

class BookingPage extends StatefulWidget {
  final String? preselectedTourId;

  const BookingPage({
    super.key,
    this.preselectedTourId,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  // Steps: 1 = Contact, 2 = Tour & Dates, 3 = Special Requests, 4 = Review, 5 = Confirmation
  int _currentStep = 1;

  final _formKeyStep1 = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final TourRepository _tourRepository = TourRepository();

  DateTime? _travelDate;
  int _travelers = 2;
  String? _selectedTourId;
  List<TourModel> _tours = [];
  bool _isLoadingTours = true;
  String? _tourSelectionError;
  String? _dateSelectionError;

  // Selected quick chips for Step 3
  final Set<String> _selectedQuickRequests = {};

  final List<String> _quickRequestOptions = [
    'Vegetarian / Halal Meals',
    'Airport VIP Fast-Track & Transfer',
    'Honeymoon / Anniversary Setup',
    'High Floor / Ocean View Room',
    'Private English & Arabic Guide',
    'Wheelchair / Mobility Support',
    'Connecting Family Rooms',
    'Late Check-out Request',
  ];

  // Completed booking reference for Step 5
  BookingModel? _confirmedBooking;

  @override
  void initState() {
    super.initState();
    _selectedTourId = widget.preselectedTourId;
    _travelDate = DateTime.now().add(const Duration(days: 14));
    _loadTours();
  }

  Future<void> _loadTours() async {
    try {
      final list = await _tourRepository.getAllTours(activeOnly: true);
      if (mounted) {
        setState(() {
          _tours = list;
          _isLoadingTours = false;
          if (_selectedTourId == null ||
              !_tours.any((t) => t.id == _selectedTourId)) {
            if (_tours.isNotEmpty) {
              _selectedTourId = _tours.first.id;
            }
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingTours = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  TourModel? get _selectedTour {
    if (_selectedTourId == null) return null;
    final match = _tours.where((t) => t.id == _selectedTourId);
    return match.isNotEmpty ? match.first : null;
  }

  String _getSelectedTourTitle() {
    return _selectedTour?.title ?? 'Custom Travel Itinerary';
  }

  double get _estimatedTotal {
    final tour = _selectedTour;
    if (tour == null) return 0.0;
    return tour.price * _travelers;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _travelDate ?? DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
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
      setState(() {
        _travelDate = picked;
        _dateSelectionError = null;
      });
    }
  }

  void _goToStep(int step) {
    if (step < 1 || step > 4) return;

    // Step 1 Validation
    if (_currentStep == 1 && step > 1) {
      if (!_formKeyStep1.currentState!.validate()) {
        return;
      }
    }

    // Step 2 Validation
    if (_currentStep == 2 && step > 2) {
      bool valid = true;
      if (_selectedTourId == null && _tours.isNotEmpty) {
        setState(() => _tourSelectionError = 'Please select a tour package.');
        valid = false;
      }
      if (_travelDate == null) {
        setState(() => _dateSelectionError = 'Please choose a travel date.');
        valid = false;
      }
      if (!valid) return;
    }

    setState(() {
      _currentStep = step;
    });
  }

  String _buildAggregatedNotes() {
    final notes = _notesCtrl.text.trim();
    if (_selectedQuickRequests.isEmpty) {
      return notes;
    }
    final requestsStr = 'Preferences: ${_selectedQuickRequests.join(', ')}';
    if (notes.isEmpty) {
      return requestsStr;
    }
    return '$requestsStr\nAdditional Notes: $notes';
  }

  void _submitBooking() {
    final tourTitle = _getSelectedTourTitle();
    final combinedNotes = _buildAggregatedNotes();

    context.read<BookingCubit>().submitBooking(
          customerName: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          tourId: _selectedTourId,
          travelDate: _travelDate,
          travelers: _travelers,
          notes: combinedNotes,
        );
  }

  Future<void> _openWhatsApp(BookingModel booking) async {
    final ref = booking.bookingReference;
    final tour = booking.tourTitle ?? _getSelectedTourTitle();
    final dateStr = booking.travelDate != null
        ? DateFormat('MMMM dd, yyyy').format(booking.travelDate!)
        : 'Upcoming Date';
    final guests = booking.travelers;

    final message =
        'Hello Travella Concierge! 🌟\nI have just submitted booking inquiry reference *$ref* for *$tour* ($guests Guests on $dateStr).\nPlease confirm my itinerary details.';

    final uri = Uri.parse(
        'https://wa.me/201000000000?text=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch WhatsApp. Reference code copied!'),
            backgroundColor: AppColors.royalBlue,
          ),
        );
      }
    }
  }

  void _copyReference(String ref) {
    Clipboard.setData(ClipboardData(text: ref));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking Reference $ref copied to clipboard!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _currentStep = 1;
      _confirmedBooking = null;
      _nameCtrl.clear();
      _emailCtrl.clear();
      _phoneCtrl.clear();
      _notesCtrl.clear();
      _selectedQuickRequests.clear();
      _travelers = 2;
      _travelDate = DateTime.now().add(const Duration(days: 14));
      if (_tours.isNotEmpty) {
        _selectedTourId = _tours.first.id;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(context);
    final hPad = AppBreakpoints.horizontalPadding(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: BlocConsumer<BookingCubit, BookingState>(
        listener: (context, state) {
          if (state is BookingSubmittedSuccess) {
            setState(() {
              _confirmedBooking = state.booking.copyWith(
                tourTitle: _getSelectedTourTitle(),
              );
              _currentStep = 5;
            });
          } else if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state is BookingLoading;

          return SingleChildScrollView(
            child: Column(
              children: [
                const AppNavbar(currentRoute: AppRoutes.booking),

                // ── Hero Banner ───────────────────────────────────────────────
                _buildHeroBanner(isMobile, hPad),

                // ── Stepper Navigation Bar (Hidden on Confirmation) ───────────
                if (_currentStep < 5) ...[
                  Transform.translate(
                    offset: const Offset(0, -32),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: hPad),
                      child: MaxWidthContainer(
                        maxWidth: 860,
                        child: _buildStepperBar(isMobile),
                      ),
                    ),
                  ),
                ],

                // ── Main Content Form Card ────────────────────────────────────
                Padding(
                  padding: EdgeInsets.only(
                    left: hPad,
                    right: hPad,
                    bottom: 60,
                    top: _currentStep == 5 ? 24 : 0,
                  ),
                  child: MaxWidthContainer(
                    maxWidth: 860,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildCurrentStepContent(isMobile, isSubmitting),
                    ),
                  ),
                ),

                const AppFooter(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Hero Header ────────────────────────────────────────────────────────────
  Widget _buildHeroBanner(bool isMobile, double hPad) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: hPad,
        vertical: isMobile ? 44 : 70,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.navyDark,
            AppColors.navyMedium,
            AppColors.royalBlueDark,
          ],
        ),
      ),
      child: MaxWidthContainer(
        maxWidth: 800,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                    Icons.verified_rounded,
                    color: AppColors.gold,
                    size: 15,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Travella Direct Booking & Concierge System',
                    style: AppTextStyles.labelSM.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _currentStep == 5
                  ? 'Reservation Request Confirmed'
                  : 'Reserve Your Unforgettable Journey',
              style: AppTextStyles.h1.copyWith(
                color: AppColors.white,
                fontSize: isMobile ? 28 : 42,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _currentStep == 5
                  ? 'Thank you for choosing Travella. Your luxury travel specialist is on standby.'
                  : 'Fast 5-step booking request with zero upfront commitment. Our travel concierge will verify availability and confirm your personalized itinerary.',
              style: AppTextStyles.bodyLG.copyWith(
                color: AppColors.textOnDarkMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Step Indicator Bar ─────────────────────────────────────────────────────
  Widget _buildStepperBar(bool isMobile) {
    final steps = [
      {'num': 1, 'title': 'Contact', 'icon': Icons.person_outline_rounded},
      {'num': 2, 'title': 'Tour & Dates', 'icon': Icons.flight_takeoff_rounded},
      {'num': 3, 'title': 'Requests', 'icon': Icons.room_service_outlined},
      {'num': 4, 'title': 'Review', 'icon': Icons.rate_review_outlined},
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyDark.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: steps.map((s) {
          final stepNum = s['num'] as int;
          final title = s['title'] as String;
          final icon = s['icon'] as IconData;
          final isActive = _currentStep == stepNum;
          final isCompleted = _currentStep > stepNum;

          return InkWell(
            onTap: () {
              if (stepNum < _currentStep) {
                _goToStep(stepNum);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? AppColors.success
                          : isActive
                              ? AppColors.royalBlue
                              : AppColors.lightGray,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check,
                              color: AppColors.white, size: 18)
                          : Text(
                              '$stepNum',
                              style: TextStyle(
                                color: isActive
                                    ? AppColors.white
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                    ),
                  ),
                  if (!isMobile) ...[
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Step $stepNum',
                          style: AppTextStyles.caption.copyWith(
                            color: isActive
                                ? AppColors.royalBlue
                                : AppColors.textLightMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          title,
                          style: AppTextStyles.labelSM.copyWith(
                            color: isActive
                                ? AppColors.navyDark
                                : AppColors.textSecondary,
                            fontWeight:
                                isActive ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Step Content Switcher ──────────────────────────────────────────────────
  Widget _buildCurrentStepContent(bool isMobile, bool isSubmitting) {
    switch (_currentStep) {
      case 1:
        return _buildStep1Contact(isMobile);
      case 2:
        return _buildStep2TourAndDates(isMobile);
      case 3:
        return _buildStep3SpecialRequests(isMobile);
      case 4:
        return _buildStep4Review(isMobile, isSubmitting);
      case 5:
        return _buildStep5Confirmation(isMobile);
      default:
        return const SizedBox.shrink();
    }
  }

  // ── STEP 1: Traveler Contact Details ──────────────────────────────────────
  Widget _buildStep1Contact(bool isMobile) {
    return _StepCardContainer(
      title: 'Step 1: Primary Traveler Contact Details',
      subtitle:
          'Please provide your official contact information for itinerary confirmations.',
      child: Form(
        key: _formKeyStep1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full Name
            Text('Full Legal Name *', style: AppTextStyles.labelMD),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                hintText: 'e.g. Alexander Hamilton',
                prefixIcon: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.royalBlue,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Full name is required';
                }
                if (v.trim().length < 2) {
                  return 'Please enter a valid full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Email & Phone in Row on Desktop
            if (!isMobile)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email Address *', style: AppTextStyles.labelMD),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'alexander@example.com',
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: AppColors.royalBlue,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Email is required';
                            }
                            final emailRegex =
                                RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegex.hasMatch(v.trim())) {
                              return 'Enter a valid email (e.g. name@domain.com)';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Phone / WhatsApp Number *',
                            style: AppTextStyles.labelMD),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: '+20 100 123 4567',
                            prefixIcon: const Icon(
                              Icons.phone_outlined,
                              color: AppColors.royalBlue,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Phone number is required';
                            }
                            if (v.trim().length < 7) {
                              return 'Enter a valid contact number';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else ...[
              Text('Email Address *', style: AppTextStyles.labelMD),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'alexander@example.com',
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: AppColors.royalBlue,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Email is required';
                  }
                  final emailRegex =
                      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(v.trim())) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text('Phone / WhatsApp Number *', style: AppTextStyles.labelMD),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '+20 100 123 4567',
                  prefixIcon: const Icon(
                    Icons.phone_outlined,
                    color: AppColors.royalBlue,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  if (v.trim().length < 7) {
                    return 'Enter a valid contact number';
                  }
                  return null;
                },
              ),
            ],

            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TravellaButton(
                  label: 'Next: Tour & Dates',
                  variant: TravellaButtonVariant.primary,
                  size: TravellaButtonSize.lg,
                  trailingIcon: Icons.arrow_forward_rounded,
                  onPressed: () => _goToStep(2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── STEP 2: Tour, Travel Date, and Travelers ──────────────────────────────
  Widget _buildStep2TourAndDates(bool isMobile) {
    final tour = _selectedTour;

    return _StepCardContainer(
      title: 'Step 2: Tour Selection & Travel Schedule',
      subtitle:
          'Choose your desired package, travel dates, and party size.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tour Package Select
          Text('Select Tour Package *', style: AppTextStyles.labelMD),
          const SizedBox(height: 8),
          if (_isLoadingTours)
            const LinearProgressIndicator(color: AppColors.royalBlue)
          else if (_tours.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Custom Tour Consultation'),
            )
          else
            DropdownButtonFormField<String>(
              initialValue: _selectedTourId,
              isExpanded: true,
              items: _tours
                  .map(
                    (t) => DropdownMenuItem(
                      value: t.id,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${t.title} (${t.destination.isNotEmpty ? t.destination : t.country})',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${t.currency} ${t.price.toInt()}/person',
                            style: const TextStyle(
                              color: AppColors.royalBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    _selectedTourId = v;
                    _tourSelectionError = null;
                  });
                }
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.flight_takeoff_rounded,
                  color: AppColors.royalBlue,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: _tourSelectionError,
              ),
            ),

          if (tour != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.royalBlue, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Duration: ${tour.duration} • Base Rate: ${tour.currency} ${tour.price.toInt()} per traveler',
                      style: AppTextStyles.bodySM.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Date & Travelers Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Travel Date Picker
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Travel Date *', style: AppTextStyles.labelMD),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _dateSelectionError != null
                                ? AppColors.error
                                : AppColors.borderLight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.white,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              color: AppColors.royalBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _travelDate == null
                                    ? 'Pick departure date'
                                    : DateFormat('EEE, MMM dd, yyyy')
                                        .format(_travelDate!),
                                style: AppTextStyles.bodyMD.copyWith(
                                  color: _travelDate == null
                                      ? AppColors.textLightMuted
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_dateSelectionError != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        _dateSelectionError!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Travelers Stepper
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Travelers *', style: AppTextStyles.labelMD),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderLight),
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline_rounded),
                            color: _travelers > 1
                                ? AppColors.royalBlue
                                : AppColors.gray400,
                            onPressed: _travelers > 1
                                ? () => setState(() => _travelers--)
                                : null,
                          ),
                          Text(
                            '$_travelers',
                            style: AppTextStyles.h5.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.navyDark,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline_rounded),
                            color: _travelers < 30
                                ? AppColors.royalBlue
                                : AppColors.gray400,
                            onPressed: _travelers < 30
                                ? () => setState(() => _travelers++)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Total Estimate Callout
          if (tour != null)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ESTIMATED TOTAL (ZERO UPFRONT)',
                        style: AppTextStyles.overline.copyWith(
                          color: AppColors.navyDark,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        '$_travelers x ${tour.currency} ${tour.price.toInt()} per guest',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${tour.currency} ${_estimatedTotal.toInt()}',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.navyDark,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TravellaButton(
                label: 'Back',
                variant: TravellaButtonVariant.secondary,
                leadingIcon: Icons.arrow_back_rounded,
                onPressed: () => _goToStep(1),
              ),
              TravellaButton(
                label: 'Next: Special Requests',
                variant: TravellaButtonVariant.primary,
                size: TravellaButtonSize.lg,
                trailingIcon: Icons.arrow_forward_rounded,
                onPressed: () => _goToStep(3),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── STEP 3: Special Requests ───────────────────────────────────────────────
  Widget _buildStep3SpecialRequests(bool isMobile) {
    return _StepCardContainer(
      title: 'Step 3: Special Requests & Preferences',
      subtitle:
          'Personalize your journey with tailored amenities, dietary preferences, or VIP services.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Popular Travel Preferences', style: AppTextStyles.labelMD),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _quickRequestOptions.map((opt) {
              final isSelected = _selectedQuickRequests.contains(opt);
              return FilterChip(
                label: Text(opt),
                selected: isSelected,
                selectedColor: AppColors.royalBlue.withValues(alpha: 0.15),
                checkmarkColor: AppColors.royalBlue,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.royalBlueDark : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
                backgroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.royalBlue
                        : AppColors.borderLight,
                  ),
                ),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedQuickRequests.add(opt);
                    } else {
                      _selectedQuickRequests.remove(opt);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('Additional Notes / Custom Inquiries (Optional)',
              style: AppTextStyles.labelMD),
          const SizedBox(height: 8),
          TextFormField(
            controller: _notesCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  'e.g. Flight arrival numbers, specific hotel room views, celebration surprises, or accessibility requirements...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TravellaButton(
                label: 'Back',
                variant: TravellaButtonVariant.secondary,
                leadingIcon: Icons.arrow_back_rounded,
                onPressed: () => _goToStep(2),
              ),
              TravellaButton(
                label: 'Next: Review Booking',
                variant: TravellaButtonVariant.primary,
                size: TravellaButtonSize.lg,
                trailingIcon: Icons.arrow_forward_rounded,
                onPressed: () => _goToStep(4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── STEP 4: Review Booking ────────────────────────────────────────────────
  Widget _buildStep4Review(bool isMobile, bool isSubmitting) {
    final tour = _selectedTour;
    final aggregatedNotes = _buildAggregatedNotes();

    return _StepCardContainer(
      title: 'Step 4: Review Your Booking Request',
      subtitle:
          'Please verify your travel itinerary and contact details before submitting.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Customer Contact
          _ReviewSection(
            icon: Icons.person_rounded,
            title: 'Traveler Details',
            children: [
              _ReviewRow(label: 'Full Name', value: _nameCtrl.text.trim()),
              _ReviewRow(label: 'Email', value: _emailCtrl.text.trim()),
              _ReviewRow(label: 'Phone / WhatsApp', value: _phoneCtrl.text.trim()),
            ],
          ),
          const Divider(height: 32, color: AppColors.borderLight),

          // Section 2: Tour & Schedule
          _ReviewSection(
            icon: Icons.flight_takeoff_rounded,
            title: 'Tour & Schedule',
            children: [
              _ReviewRow(
                label: 'Tour Package',
                value: tour?.title ?? _getSelectedTourTitle(),
              ),
              _ReviewRow(
                label: 'Destination',
                value: tour != null && tour.destination.isNotEmpty
                    ? '${tour.destination}, ${tour.country}'
                    : 'Travella Signature Destination',
              ),
              _ReviewRow(
                label: 'Departure Date',
                value: _travelDate != null
                    ? DateFormat('EEEE, MMMM dd, yyyy').format(_travelDate!)
                    : 'To be scheduled',
              ),
              _ReviewRow(
                label: 'Number of Travelers',
                value: '$_travelers ${_travelers == 1 ? "Guest" : "Guests"}',
              ),
            ],
          ),
          const Divider(height: 32, color: AppColors.borderLight),

          // Section 3: Special Requests
          if (aggregatedNotes.isNotEmpty) ...[
            _ReviewSection(
              icon: Icons.room_service_rounded,
              title: 'Special Requests & Preferences',
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    aggregatedNotes,
                    style: AppTextStyles.bodyMD.copyWith(
                      color: AppColors.navyDark,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 32, color: AppColors.borderLight),
          ],

          // Section 4: Price & Future Payment Architecture Note
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.navyDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Estimated Price',
                      style: AppTextStyles.bodyLG.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      tour != null
                          ? '${tour.currency} ${_estimatedTotal.toInt()}'
                          : 'Custom Quote',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.navyMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      color: AppColors.gold,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Booking Status: Pending. No immediate charge. Future online gateways (Stripe, Paymob, Fawry) ready.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textOnDarkMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TravellaButton(
                label: 'Back',
                variant: TravellaButtonVariant.secondary,
                leadingIcon: Icons.arrow_back_rounded,
                onPressed: isSubmitting ? null : () => _goToStep(3),
              ),
              TravellaButton(
                label: 'Confirm & Submit Booking',
                variant: TravellaButtonVariant.primary,
                size: TravellaButtonSize.lg,
                isLoading: isSubmitting,
                leadingIcon: Icons.send_rounded,
                onPressed: isSubmitting ? null : _submitBooking,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── STEP 5: Premium Confirmation Page ──────────────────────────────────────
  Widget _buildStep5Confirmation(bool isMobile) {
    final booking = _confirmedBooking ??
        BookingModel(
          id: 'TRV-${DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase()}',
          customerName: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          tourId: _selectedTourId,
          travelDate: _travelDate,
          travelers: _travelers,
          status: BookingStatus.pending,
          tourTitle: _getSelectedTourTitle(),
        );

    final ref = booking.bookingReference;
    final tourTitle = booking.tourTitle ?? _getSelectedTourTitle();
    final dateStr = booking.travelDate != null
        ? DateFormat('EEEE, MMMM dd, yyyy').format(booking.travelDate!)
        : 'Flexible Departure';

    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 44),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyDark.withValues(alpha: 0.1),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Luxury Success Badge
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.gold, AppColors.goldDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.check_circle_rounded,
                color: AppColors.navyDark,
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Your travel request has been received.',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.navyDark,
              fontWeight: FontWeight.w900,
              fontSize: isMobile ? 24 : 32,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Text(
              'Thank you, ${booking.customerName}! Your booking has been saved to our database with status pending. A dedicated Travella travel concierge is preparing your personalized itinerary.',
              style: AppTextStyles.bodyLG.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),

          // Booking Details Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 20 : 28),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                // Reference Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BOOKING REFERENCE',
                          style: AppTextStyles.overline.copyWith(
                            color: AppColors.textLightMuted,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              ref,
                              style: AppTextStyles.h4.copyWith(
                                color: AppColors.royalBlueDark,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.copy_rounded,
                                size: 18,
                                color: AppColors.royalBlue,
                              ),
                              tooltip: 'Copy Reference',
                              onPressed: () => _copyReference(ref),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time_filled_rounded,
                            color: AppColors.goldDark,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            booking.status.label.toUpperCase(),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.goldDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 28, color: AppColors.borderLight),

                // Details Grid
                _ConfirmationItem(
                  icon: Icons.flight_takeoff_rounded,
                  label: 'Tour Package',
                  value: tourTitle,
                ),
                const SizedBox(height: 12),
                _ConfirmationItem(
                  icon: Icons.calendar_today_rounded,
                  label: 'Travel Date',
                  value: dateStr,
                ),
                const SizedBox(height: 12),
                _ConfirmationItem(
                  icon: Icons.group_rounded,
                  label: 'Travelers',
                  value: '${booking.travelers} Guests',
                ),
                const SizedBox(height: 12),
                _ConfirmationItem(
                  icon: Icons.contact_mail_rounded,
                  label: 'Contact Details',
                  value: '${booking.email} • ${booking.phone}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // ── WhatsApp Contact CTA ──────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF25D366).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFF25D366).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.chat_bubble_rounded,
                      color: Color(0xFF25D366),
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Instant VIP Concierge Assistance',
                      style: AppTextStyles.h5.copyWith(
                        color: AppColors.navyDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Want immediate confirmation or have special questions? Chat directly with our travel desk on WhatsApp.',
                  style: AppTextStyles.bodyMD.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _openWhatsApp(booking),
                  icon: const Icon(Icons.forum_rounded, color: AppColors.white),
                  label: const Text(
                    'Contact us on WhatsApp',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Navigation buttons
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              TravellaButton(
                label: 'Book Another Tour',
                variant: TravellaButtonVariant.secondary,
                leadingIcon: Icons.add_rounded,
                onPressed: _resetForm,
              ),
              TravellaButton(
                label: 'Back to Home',
                variant: TravellaButtonVariant.primary,
                trailingIcon: Icons.home_rounded,
                onPressed: () => context.goNamed(AppRoutes.homeName),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Supporting Widget Classes ────────────────────────────────────────────────

class _StepCardContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _StepCardContainer({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(context);

    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 36),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyDark.withValues(alpha: 0.06),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.h4.copyWith(
              color: AppColors.navyDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: AppTextStyles.bodyMD.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 28),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 28),
          child,
        ],
      ),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _ReviewSection({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.royalBlue, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTextStyles.h5.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.navyDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...children,
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTextStyles.bodyMD.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMD.copyWith(
                color: AppColors.navyDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ConfirmationItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.royalBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.royalBlue, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMD.copyWith(
                  color: AppColors.navyDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

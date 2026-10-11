import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/utils/external_link_helper.dart';
import '../../../site_settings/presentation/cubit/site_settings_cubit.dart';
import '../../../../data/models/site_settings_model.dart';
import '../../../../data/models/booking_model.dart';
import '../../../../data/models/tour_model.dart';
import '../../../../data/repositories/tour_repository.dart';
import '../../../../shared/presentation/widgets/app_navbar.dart';
import '../../../../shared/presentation/widgets/app_footer.dart';
import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';

class BookingPage extends StatefulWidget {
  final String? preselectedTourId;

  const BookingPage({super.key, this.preselectedTourId});

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
  int _adults = 2;
  int _children = 0;
  List<int?> _childAges = [];
  String? _childAgeError;
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

  int get _totalTravelers => _adults + _children;

  double get _estimatedTotal {
    final tour = _selectedTour;
    if (tour == null) return 0.0;
    return tour.price * _totalTravelers;
  }

  String _getChildTitle(int index, bool isArabic) {
    final childNum = index + 1;
    if (isArabic) {
      switch (childNum) {
        case 1:
          return 'سن الطفل الأول';
        case 2:
          return 'سن الطفل الثاني';
        case 3:
          return 'سن الطفل الثالث';
        case 4:
          return 'سن الطفل الرابع';
        case 5:
          return 'سن الطفل الخامس';
        case 6:
          return 'سن الطفل السادس';
        case 7:
          return 'سن الطفل السابع';
        case 8:
          return 'سن الطفل الثامن';
        case 9:
          return 'سن الطفل التاسع';
        case 10:
          return 'سن الطفل العاشر';
        default:
          return 'سن الطفل رقم $childNum';
      }
    } else {
      return 'Child $childNum Age';
    }
  }

  void _onAdultsChanged(int newAdults) {
    if (newAdults < AppConstants.minAdults ||
        newAdults > AppConstants.maxAdults) {
      return;
    }
    setState(() {
      _adults = newAdults;
    });
  }

  void _onChildrenChanged(int newChildren) {
    if (newChildren < AppConstants.minChildren ||
        newChildren > AppConstants.maxChildren) {
      return;
    }
    setState(() {
      _children = newChildren;
      if (_children == 0) {
        _childAges.clear();
        _childAgeError = null;
      } else if (_childAges.length < _children) {
        while (_childAges.length < _children) {
          _childAges.add(null);
        }
      } else if (_childAges.length > _children) {
        _childAges = _childAges.sublist(0, _children);
      }
    });
  }

  void _setChildAge(int index, int? age) {
    if (index >= 0 && index < _childAges.length) {
      setState(() {
        _childAges[index] = age;
        if (_childAgeError != null && _childAges.every((a) => a != null)) {
          _childAgeError = null;
        }
      });
    }
  }

  bool _validateChildAges() {
    if (_children == 0) {
      _childAgeError = null;
      return true;
    }
    final hasMissing = _childAges.any(
      (age) =>
          age == null ||
          age < AppConstants.minChildAge ||
          age > AppConstants.maxChildAge,
    );
    if (hasMissing) {
      setState(() {
        _childAgeError = context.tr('child_age_missing_err');
      });
      return false;
    }
    setState(() {
      _childAgeError = null;
    });
    return true;
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
      if (!_validateChildAges()) {
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
    if (!_validateChildAges()) {
      setState(() {
        _currentStep = 2;
      });
      return;
    }

    final combinedNotes = _buildAggregatedNotes();
    final validChildAges = _childAges.whereType<int>().toList();

    context.read<BookingCubit>().submitBooking(
      customerName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      tourId: _selectedTourId,
      travelDate: _travelDate,
      travelers: _totalTravelers,
      adultsCount: _adults,
      childrenCount: _children,
      childrenAges: validChildAges,
      notes: combinedNotes,
    );
  }

  Future<void> _openWhatsApp(BookingModel booking) async {
    final ref = booking.bookingReference;
    final tour = booking.tourTitle ?? _getSelectedTourTitle();
    final dateStr = booking.travelDate != null
        ? DateFormat('MMMM dd, yyyy').format(booking.travelDate!)
        : 'Upcoming Date';
    final guestsStr = booking.formattedTravelersSummary(isArabic: context.isArabic);

    final message =
        'Hello Travella Concierge! 🌟\nI have just submitted booking inquiry reference *$ref* for *$tour* ($guestsStr on $dateStr).\nPlease confirm my itinerary details.';

    final settings = context.read<SiteSettingsCubit?>()?.state.settings ??
        SiteSettingsModel.initial();

    final launched = await ExternalLinkHelper.openWhatsApp(
      rawPhoneOrUrl: settings.whatsappNumber,
      message: message,
    );

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not launch WhatsApp. Reference code copied!'),
          backgroundColor: AppColors.royalBlue,
        ),
      );
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
      _adults = 2;
      _children = 0;
      _childAges.clear();
      _childAgeError = null;
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
                    context.tr('booking_hero_badge'),
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
                  ? context.tr('step_5_confirmed_title')
                  : context.tr('booking_hero_title'),
              style: AppTextStyles.h1.copyWith(
                color: AppColors.white,
                fontSize: isMobile ? 28 : 42,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _currentStep == 5
                  ? context.tr('step_5_confirmed_subtitle')
                  : context.tr('booking_hero_subtitle'),
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
      {
        'num': 1,
        'title': context.isArabic ? 'بيانات التواصل' : 'Contact',
        'icon': Icons.person_outline_rounded,
      },
      {
        'num': 2,
        'title': context.isArabic ? 'الرحلة والتاريخ' : 'Tour & Dates',
        'icon': Icons.flight_takeoff_rounded,
      },
      {
        'num': 3,
        'title': context.isArabic ? 'الطلبات الخاصة' : 'Requests',
        'icon': Icons.room_service_outlined,
      },
      {
        'num': 4,
        'title': context.isArabic ? 'المراجعة' : 'Review',
        'icon': Icons.rate_review_outlined,
      },
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
          final isActive = _currentStep == stepNum;
          final isCompleted = _currentStep > stepNum;

          return Flexible(
            child: InkWell(
              onTap: () {
                if (stepNum < _currentStep) {
                  _goToStep(stepNum);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
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
                            ? const Icon(
                                Icons.check,
                                color: AppColors.white,
                                size: 18,
                              )
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
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Step $stepNum',
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption.copyWith(
                                color: isActive
                                    ? AppColors.royalBlue
                                    : AppColors.textLightMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              title,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.labelSM.copyWith(
                                color: isActive
                                    ? AppColors.navyDark
                                    : AppColors.textSecondary,
                                fontWeight: isActive
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
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
      title: context.tr('step_1_title'),
      subtitle: context.tr('step_1_subtitle'),
      child: Form(
        key: _formKeyStep1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full Name
            Text(context.tr('full_name_label'), style: AppTextStyles.labelMD),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                hintText: context.isArabic
                    ? 'مثال: أحمد محمد'
                    : 'e.g. Alexander Hamilton',
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
                  return context.isArabic
                      ? 'الاسم مطلوب'
                      : 'Full name is required';
                }
                if (v.trim().length < 2) {
                  return context.isArabic
                      ? 'يرجى إدخال اسم صحيح'
                      : 'Please enter a valid full name';
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
                        Text(
                          context.tr('email_label'),
                          style: AppTextStyles.labelMD,
                        ),
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
                              return context.isArabic
                                  ? 'البريد الإلكتروني مطلوب'
                                  : 'Email is required';
                            }
                            final emailRegex = RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            );
                            if (!emailRegex.hasMatch(v.trim())) {
                              return context.isArabic
                                  ? 'يرجى إدخال بريد إلكتروني صحيح'
                                  : 'Enter a valid email (e.g. name@domain.com)';
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
                        Text(
                          context.tr('phone_label'),
                          style: AppTextStyles.labelMD,
                        ),
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
                              return context.isArabic
                                  ? 'رقم الهاتف مطلوب'
                                  : 'Phone number is required';
                            }
                            if (v.trim().length < 7) {
                              return context.isArabic
                                  ? 'يرجى إدخال رقم هاتف صحيح'
                                  : 'Enter a valid contact number';
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
              Text(context.tr('email_label'), style: AppTextStyles.labelMD),
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
                    return context.isArabic
                        ? 'البريد الإلكتروني مطلوب'
                        : 'Email is required';
                  }
                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );
                  if (!emailRegex.hasMatch(v.trim())) {
                    return context.isArabic
                        ? 'يرجى إدخال بريد إلكتروني صحيح'
                        : 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(context.tr('phone_label'), style: AppTextStyles.labelMD),
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
                    return context.isArabic
                        ? 'رقم الهاتف مطلوب'
                        : 'Phone number is required';
                  }
                  if (v.trim().length < 7) {
                    return context.isArabic
                        ? 'يرجى إدخال رقم هاتف صحيح'
                        : 'Enter a valid contact number';
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
                  label: context.tr('btn_next_tour'),
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
      title: context.tr('step_2_title'),
      subtitle: context.tr('step_2_subtitle'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tour Package Select
          Text(context.tr('select_tour_label'), style: AppTextStyles.labelMD),
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
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
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
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.royalBlue,
                    size: 20,
                  ),
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

          // Travel Date Picker
          Text(context.tr('travel_date_label'), style: AppTextStyles.labelMD),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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
                          ? (context.isArabic
                                ? 'اختر تاريخ السفر'
                                : 'Pick departure date')
                          : DateFormat(
                              'EEE, MMM dd, yyyy',
                            ).format(_travelDate!),
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
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ],
          const SizedBox(height: 24),

          // ── TRAVELERS & FAMILY BREAKDOWN ─────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navyDark.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.family_restroom_rounded,
                          color: AppColors.royalBlue,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.tr('travelers_label'),
                          style: AppTextStyles.h5.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.navyDark,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.royalBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_totalTravelers ${context.isArabic ? (_totalTravelers == 1 ? "مسافر" : "مسافرين") : (_totalTravelers == 1 ? "Traveler" : "Travelers")}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.royalBlueDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.borderLight),
                const SizedBox(height: 16),

                // Adults Stepper Row
                _buildTravelerStepperRow(
                  title: context.tr('adults_count_title'),
                  subtitle: context.tr('adults_count_subtitle'),
                  value: _adults,
                  minValue: AppConstants.minAdults,
                  maxValue: AppConstants.maxAdults,
                  onChanged: _onAdultsChanged,
                ),

                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.borderLight),
                const SizedBox(height: 16),

                // Children Stepper Row
                _buildTravelerStepperRow(
                  title: context.tr('children_count_title'),
                  subtitle: context.tr('children_count_subtitle'),
                  value: _children,
                  minValue: AppConstants.minChildren,
                  maxValue: AppConstants.maxChildren,
                  onChanged: _onChildrenChanged,
                ),

                // Dynamic Child Age Selectors
                if (_children > 0) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _childAgeError != null
                            ? AppColors.error
                            : AppColors.royalBlue.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.child_care_rounded,
                              color: AppColors.royalBlue,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                context.isArabic
                                    ? 'تحديد سن كل طفل (مطلوب لسياسات التذاكر والإقامة الفندقية)'
                                    : 'Specify child age (Required for ticketing & rooming)',
                                style: AppTextStyles.bodySM.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.navyDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: List.generate(_children, (index) {
                            final currentAge = index < _childAges.length
                                ? _childAges[index]
                                : null;
                            return Container(
                              width: isMobile ? double.infinity : 220,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: currentAge == null
                                      ? AppColors.goldDark
                                      : AppColors.borderLight,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _getChildTitle(index, context.isArabic),
                                    style: AppTextStyles.caption.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.navyDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton<int>(
                                      value: currentAge,
                                      isExpanded: true,
                                      hint: Text(
                                        context.isArabic
                                            ? 'اختر العمر'
                                            : 'Select age',
                                        style: AppTextStyles.bodySM.copyWith(
                                          color: AppColors.textLightMuted,
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: AppColors.royalBlue,
                                      ),
                                      items: List.generate(
                                        AppConstants.maxChildAge -
                                            AppConstants.minChildAge +
                                            1,
                                        (i) {
                                          final age =
                                              AppConstants.minChildAge + i;
                                          String label;
                                          if (age == 0) {
                                            label = context.tr(
                                              'child_infant_label',
                                            );
                                          } else if (age == 1) {
                                            label =
                                                '1 ${context.tr('child_single_year')}';
                                          } else if (age == 2 && context.isArabic) {
                                            label = 'سنتان (2)';
                                          } else {
                                            label =
                                                '$age ${context.tr('child_plural_years')}';
                                          }
                                          return DropdownMenuItem<int>(
                                            value: age,
                                            child: Text(
                                              label,
                                              style: AppTextStyles.bodySM
                                                  .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                      onChanged: (age) =>
                                          _setChildAge(index, age),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                        if (_childAgeError != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: AppColors.error,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _childAgeError!,
                                  style: const TextStyle(
                                    color: AppColors.error,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Total Estimate Callout
          if (tour != null)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('estimated_total'),
                        style: AppTextStyles.overline.copyWith(
                          color: AppColors.navyDark,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        '$_totalTravelers x ${tour.currency} ${tour.price.toInt()} per guest',
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
                label: context.tr('btn_back'),
                variant: TravellaButtonVariant.secondary,
                leadingIcon: Icons.arrow_back_rounded,
                onPressed: () => _goToStep(1),
              ),
              TravellaButton(
                label: context.tr('btn_next_requests'),
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

  Widget _buildTravelerStepperRow({
    required String title,
    required String subtitle,
    required int value,
    required int minValue,
    required int maxValue,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMD.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline_rounded),
                iconSize: 20,
                color: value > minValue
                    ? AppColors.royalBlue
                    : AppColors.gray400,
                onPressed: value > minValue ? () => onChanged(value - 1) : null,
              ),
              SizedBox(
                width: 28,
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h5.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.navyDark,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded),
                iconSize: 20,
                color: value < maxValue
                    ? AppColors.royalBlue
                    : AppColors.gray400,
                onPressed: value < maxValue ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── STEP 3: Special Requests ───────────────────────────────────────────────
  Widget _buildStep3SpecialRequests(bool isMobile) {
    return _StepCardContainer(
      title: context.tr('step_3_title'),
      subtitle: context.tr('step_3_subtitle'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('popular_prefs'), style: AppTextStyles.labelMD),
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
                  color: isSelected
                      ? AppColors.royalBlueDark
                      : AppColors.textPrimary,
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
          Text(context.tr('additional_notes'), style: AppTextStyles.labelMD),
          const SizedBox(height: 8),
          TextFormField(
            controller: _notesCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: context.isArabic
                  ? 'مثال: رقم رحلة الوصول، تفضيل إطلالة الغرفة، ترتيبات خاصة، أو متطلبات وصول...'
                  : 'e.g. Flight arrival numbers, specific hotel room views, celebration surprises, or accessibility requirements...',
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
                label: context.tr('btn_back'),
                variant: TravellaButtonVariant.secondary,
                leadingIcon: Icons.arrow_back_rounded,
                onPressed: () => _goToStep(2),
              ),
              TravellaButton(
                label: context.tr('btn_next_review'),
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
      title: context.tr('step_4_title'),
      subtitle: context.tr('step_4_subtitle'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Customer Contact
          _ReviewSection(
            icon: Icons.person_rounded,
            title: context.tr('traveler_details'),
            children: [
              _ReviewRow(
                label: context.isArabic ? 'الاسم الكامل' : 'Full Name',
                value: _nameCtrl.text.trim(),
              ),
              _ReviewRow(
                label: context.isArabic ? 'البريد الإلكتروني' : 'Email',
                value: _emailCtrl.text.trim(),
              ),
              _ReviewRow(
                label: context.isArabic
                    ? 'الهاتف / واتساب'
                    : 'Phone / WhatsApp',
                value: _phoneCtrl.text.trim(),
              ),
            ],
          ),
          const Divider(height: 32, color: AppColors.borderLight),

          // Section 2: Tour & Schedule
          _ReviewSection(
            icon: Icons.flight_takeoff_rounded,
            title: context.tr('tour_schedule'),
            children: [
              _ReviewRow(
                label: context.isArabic ? 'البرنامج السياحي' : 'Tour Package',
                value: tour?.title ?? _getSelectedTourTitle(),
              ),
              _ReviewRow(
                label: context.isArabic ? 'الوجهة' : 'Destination',
                value: tour != null && tour.destination.isNotEmpty
                    ? '${tour.destination}, ${tour.country}'
                    : 'Travella Signature Destination',
              ),
              _ReviewRow(
                label: context.isArabic ? 'تاريخ السفر' : 'Departure Date',
                value: _travelDate != null
                    ? DateFormat('EEEE, MMMM dd, yyyy').format(_travelDate!)
                    : (context.isArabic
                          ? 'سيتم التحديد لاحقاً'
                          : 'To be scheduled'),
              ),
              _ReviewRow(
                label: context.tr('travelers_count_summary'),
                value:
                    '$_totalTravelers ${context.isArabic ? (_totalTravelers == 1 ? "مسافر" : "مسافرين") : (_totalTravelers == 1 ? "Guest" : "Guests")} ($_adults ${context.tr('adults_count_title')}${_children > 0 ? ", $_children ${context.tr('children_count_title')}" : ""})',
              ),
              if (_children > 0 && _childAges.isNotEmpty)
                _ReviewRow(
                  label: context.tr('children_ages_summary'),
                  value: _childAges
                      .whereType<int>()
                      .map(
                        (a) => a == 0
                            ? context.tr('child_infant_label')
                            : '$a ${a == 1 ? context.tr('child_single_year') : context.tr('child_plural_years')}',
                      )
                      .join(', '),
                ),
            ],
          ),
          const Divider(height: 32, color: AppColors.borderLight),

          // Section 3: Special Requests
          if (aggregatedNotes.isNotEmpty) ...[
            _ReviewSection(
              icon: Icons.room_service_rounded,
              title: context.tr('special_requests_title'),
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
                      context.tr('total_estimate_price'),
                      style: AppTextStyles.bodyLG.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      tour != null
                          ? '${tour.currency} ${_estimatedTotal.toInt()}'
                          : (context.isArabic
                                ? 'عرض سعر مخصص'
                                : 'Custom Quote'),
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
                        context.tr('payment_arch_note'),
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
                label: context.tr('btn_back'),
                variant: TravellaButtonVariant.secondary,
                leadingIcon: Icons.arrow_back_rounded,
                onPressed: isSubmitting ? null : () => _goToStep(3),
              ),
              TravellaButton(
                label: context.tr('btn_submit_booking'),
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
    final booking =
        _confirmedBooking ??
        BookingModel(
          id: 'TRV-${DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase()}',
          customerName: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          tourId: _selectedTourId,
          travelDate: _travelDate,
          travelers: _totalTravelers,
          adultsCount: _adults,
          childrenCount: _children,
          childrenAges: _childAges.whereType<int>().toList(),
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
            context.tr('step_5_confirmed_title'),
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
              context.isArabic
                  ? 'شكراً لك، ${booking.customerName}! تم إرسال طلب حجزك بنجاح وحفظه في النظام بحالة "قيد المراجعة". سيقوم مستشارك السياحي بالتواصل مع حضرتك في أقرب وقت لتأكيد الحجز ومراجعة كافة التفاصيل.'
                  : 'Thank you, ${booking.customerName}! Your booking request has been submitted successfully and is currently pending review. A dedicated travel advisor will contact you shortly to confirm your reservation and finalize the itinerary.',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('booking_ref_label'),
                            style: AppTextStyles.overline.copyWith(
                              color: AppColors.textLightMuted,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  ref,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.h4.copyWith(
                                    color: AppColors.royalBlueDark,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.copy_rounded,
                                  size: 18,
                                  color: AppColors.royalBlue,
                                ),
                                tooltip: context.isArabic
                                    ? 'نسخ الرقم المرجعي'
                                    : 'Copy Reference',
                                onPressed: () => _copyReference(ref),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
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
                            context.isArabic
                                ? 'قيد المراجعة'
                                : booking.status.label.toUpperCase(),
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
                  label: context.isArabic ? 'البرنامج السياحي' : 'Tour Package',
                  value: tourTitle,
                ),
                const SizedBox(height: 12),
                _ConfirmationItem(
                  icon: Icons.calendar_today_rounded,
                  label: context.isArabic ? 'تاريخ السفر' : 'Travel Date',
                  value: dateStr,
                ),
                const SizedBox(height: 12),
                _ConfirmationItem(
                  icon: Icons.group_rounded,
                  label: context.isArabic ? 'تفاصيل المسافرين' : 'Travelers',
                  value: booking.formattedTravelersSummary(isArabic: context.isArabic),
                ),
                if (booking.hasChildren) ...[
                  const SizedBox(height: 12),
                  _ConfirmationItem(
                    icon: Icons.child_care_rounded,
                    label: context.isArabic ? 'أعمار الأطفال' : 'Child Ages',
                    value: booking.formattedChildAges(isArabic: context.isArabic),
                  ),
                ],
                const SizedBox(height: 12),
                _ConfirmationItem(
                  icon: Icons.contact_mail_rounded,
                  label: context.isArabic
                      ? 'بيانات التواصل'
                      : 'Contact Details',
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
                      context.tr('whatsapp_concierge_title'),
                      style: AppTextStyles.h5.copyWith(
                        color: AppColors.navyDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('whatsapp_concierge_desc'),
                  style: AppTextStyles.bodyMD.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _openWhatsApp(booking),
                  icon: const Icon(Icons.forum_rounded, color: AppColors.white),
                  label: Text(
                    context.tr('whatsapp_btn_label'),
                    style: const TextStyle(
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
                label: context.tr('btn_book_another'),
                variant: TravellaButtonVariant.secondary,
                leadingIcon: Icons.add_rounded,
                onPressed: _resetForm,
              ),
              TravellaButton(
                label: context.tr('btn_back_home'),
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
          Flexible(
            flex: 4,
            child: Text(
              label,
              style: AppTextStyles.bodyMD.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 6,
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

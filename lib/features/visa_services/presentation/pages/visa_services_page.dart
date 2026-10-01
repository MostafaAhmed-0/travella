import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/animations/animation_widgets.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../data/models/visa_model.dart';
import '../../../../data/repositories/visa_repository.dart';
import '../../../../shared/presentation/widgets/app_navbar.dart';
import '../../../../shared/presentation/widgets/app_footer.dart';
import '../../../bookings/presentation/cubit/booking_cubit.dart';
import '../../../bookings/presentation/cubit/booking_state.dart';

class VisaServicesPage extends StatefulWidget {
  final String? initialCountry;
  final String? initialVisaType;
  final int? initialApplicants;

  const VisaServicesPage({
    super.key,
    this.initialCountry,
    this.initialVisaType,
    this.initialApplicants,
  });

  @override
  State<VisaServicesPage> createState() => _VisaServicesPageState();
}

class _VisaServicesPageState extends State<VisaServicesPage> {
  final VisaRepository _repository = VisaRepository();
  List<VisaServiceModel> _allVisaServices = [];
  List<VisaServiceModel> _filteredVisaServices = [];
  bool _isLoading = true;
  String? _errorMessage;

  late TextEditingController _searchCtrl;
  String _searchQuery = '';
  String _selectedRegion = 'All';

  final List<String> _regions = ['All', 'Europe', 'UK & USA', 'Middle East', 'Asia'];

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialCountry ?? '';
    _searchCtrl = TextEditingController(text: _searchQuery);
    _loadVisaServices();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadVisaServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _repository.getAllCountries(activeOnly: true);
      if (mounted) {
        setState(() {
          _allVisaServices = list;
          _isLoading = false;
          _applyFilters();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    var result = List<VisaServiceModel>.from(_allVisaServices);

    if (_selectedRegion != 'All') {
      final reg = _selectedRegion.toLowerCase();
      result = result.where((v) =>
          v.region.toLowerCase().contains(reg) ||
          v.country.toLowerCase().contains(reg)).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      result = result.where((v) =>
          v.country.toLowerCase().contains(q) ||
          (v.countryAr != null && v.countryAr!.toLowerCase().contains(q)) ||
          v.visaType.toLowerCase().contains(q) ||
          v.description.toLowerCase().contains(q) ||
          (v.descriptionAr != null && v.descriptionAr!.toLowerCase().contains(q))).toList();
    }

    setState(() {
      _filteredVisaServices = result;
    });
  }

  void _showApplyModal(VisaServiceModel service) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _VisaApplicationModal(
        service: service,
        initialApplicants: widget.initialApplicants ?? 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hPad = AppBreakpoints.horizontalPadding(context);
    final isMobile = AppBreakpoints.isMobile(context);
    final isArabic = context.isArabic;
    final columns = isMobile ? 1 : (AppBreakpoints.isTablet(context) ? 2 : 3);

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: CustomScrollView(
        slivers: [
          // ── Navbar ────────────────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: AppNavbar(currentRoute: AppRoutes.visaServices),
          ),

          // ── Header ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.navyDark,
              padding: EdgeInsets.symmetric(
                horizontal: hPad,
                vertical: isMobile ? 48 : 72,
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
                          const Icon(Icons.verified_user_rounded, color: AppColors.gold, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            isArabic ? 'خدمات التأشيرات واستشارات السفر' : 'CONSULAR & TRAVEL PERMITS',
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isArabic ? 'خدمات التأشيرات السياحية العالمية' : 'Global Visa Assistance',
                      style: (isMobile ? AppTextStyles.h2 : AppTextStyles.h1).copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isArabic
                          ? 'استخراج تأشيرات الشنغن، بريطانيا، أمريكا، إلكترونية دبي والسعودية وشرق آسيا بأعلى نسب قبول ومتابعة دقيقة.'
                          : 'Hassle-free Schengen, UK, US, Dubai e-Visa, and Asian tourist visas with industry-leading approval rates.',
                      style: AppTextStyles.bodyLG.copyWith(
                        color: AppColors.textOnDarkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Search & Region Filter ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 20),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(bottom: BorderSide(color: AppColors.borderLight)),
              ),
              child: MaxWidthContainer(
                child: Column(
                  children: [
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (val) {
                        _searchQuery = val;
                        _applyFilters();
                      },
                      decoration: InputDecoration(
                        hintText: isArabic
                            ? 'ابحث عن تأشيرة باسم الدولة أو نوع التأشيرة...'
                            : 'Search visa by destination country or type...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.royalBlue),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  _searchQuery = '';
                                  _applyFilters();
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.surfaceLight,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.borderLight),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.borderLight),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _regions.map((reg) {
                          final isSel = _selectedRegion == reg;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: FilterChip(
                              label: Text(reg),
                              selected: isSel,
                              onSelected: (_) {
                                setState(() => _selectedRegion = reg);
                                _applyFilters();
                              },
                              selectedColor: AppColors.navy,
                              checkmarkColor: AppColors.white,
                              labelStyle: TextStyle(
                                color: isSel ? AppColors.white : AppColors.navyDark,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                              ),
                              backgroundColor: AppColors.surfaceLight,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                                side: BorderSide(
                                  color: isSel ? AppColors.navy : AppColors.borderLight,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 40),
            sliver: SliverToBoxAdapter(
              child: MaxWidthContainer(
                child: _buildContent(columns, isMobile, isArabic),
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

  Widget _buildContent(int columns, bool isMobile, bool isArabic) {
    if (_isLoading) {
      return SizedBox(
        height: 400,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.royalBlue),
              const SizedBox(height: 16),
              Text(
                isArabic ? 'جاري تحميل خدمات التأشيرات...' : 'Loading visa services from Supabase...',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return SizedBox(
        height: 360,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.errorRed, size: 54),
              const SizedBox(height: 14),
              Text(
                isArabic ? 'فشل تحميل خدمات التأشيرات' : 'Failed to load visa services',
                style: AppTextStyles.h4,
              ),
              const SizedBox(height: 8),
              Text(_errorMessage!, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              TravellaButton(
                label: isArabic ? 'إعادة المحاولة' : 'Retry',
                variant: TravellaButtonVariant.primary,
                onPressed: _loadVisaServices,
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredVisaServices.isEmpty) {
      return SizedBox(
        height: 360,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.description_outlined, color: AppColors.gray400, size: 56),
              const SizedBox(height: 16),
              Text(
                isArabic ? 'لا توجد تأشيرات متاحة لهذا البحث' : 'No visa services found matching your criteria.',
                style: AppTextStyles.h4,
              ),
              const SizedBox(height: 8),
              Text(
                isArabic ? 'جرّب تعديل مصطلح البحث أو اختيار منطقة أخرى.' : 'Try adjusting your destination country keyword or region filter.',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              TravellaButton(
                label: isArabic ? 'إعادة ضبط الفلاتر' : 'Reset Filters',
                variant: TravellaButtonVariant.secondary,
                onPressed: () {
                  _searchCtrl.clear();
                  setState(() {
                    _searchQuery = '';
                    _selectedRegion = 'All';
                  });
                  _applyFilters();
                },
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisExtent: isMobile ? 500 : 510,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: _filteredVisaServices.length,
      itemBuilder: (context, i) {
        final service = _filteredVisaServices[i];
        return ScaleInOnScroll(
          delay: Duration(milliseconds: (i % 3) * 60),
          child: _VisaServiceCard(
            service: service,
            onApply: () => _showApplyModal(service),
          ),
        );
      },
    );
  }
}

class _VisaServiceCard extends StatefulWidget {
  final VisaServiceModel service;
  final VoidCallback onApply;

  const _VisaServiceCard({
    required this.service,
    required this.onApply,
  });

  @override
  State<_VisaServiceCard> createState() => _VisaServiceCardState();
}

class _VisaServiceCardState extends State<_VisaServiceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.service;
    final isArabic = context.isArabic;
    final countryName = s.localizedCountry(isArabic);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0.0, _isHovered ? -6.0 : 0.0, 0.0),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered ? AppColors.royalBlue : AppColors.borderLight,
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? AppColors.royalBlue.withValues(alpha: 0.12)
                  : AppColors.navy.withValues(alpha: 0.04),
              blurRadius: _isHovered ? 28 : 14,
              offset: Offset(0, _isHovered ? 12 : 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with flag & fee
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.royalBlueFaded,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(s.flagEmoji, style: const TextStyle(fontSize: 24)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gold),
                    ),
                    child: Text(
                      isArabic ? 'الرسوم \$${s.price.toInt()}' : 'Fee \$${s.price.toInt()}',
                      style: const TextStyle(
                        color: AppColors.goldDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Country & Visa Type
              Text(
                countryName,
                style: AppTextStyles.h4.copyWith(color: AppColors.navyDark),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                s.visaType,
                style: AppTextStyles.labelMD.copyWith(color: AppColors.royalBlue),
              ),
              const SizedBox(height: 10),

              // Processing Time & Validity
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 14, color: AppColors.gray600),
                  const SizedBox(width: 4),
                  Text(
                    isArabic ? 'مدة الإنجاز: ${s.processingTime}' : 'Processing: ${s.processingTime}',
                    style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(color: AppColors.borderLight),
              const SizedBox(height: 10),

              // Requirements checklist
              Text(
                isArabic ? 'المستندات المطلوبة:' : 'Key Requirements:',
                style: AppTextStyles.labelSM.copyWith(
                  color: AppColors.navyDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: s.requirements.isEmpty
                    ? Text(
                        isArabic
                            ? '• جواز سفر ساري (6 أشهر فأكثر)\n• كشف حساب بنكي لآخر 6 أشهر\n• صور شخصية وحجوزات طيران وفنادق'
                            : '• Valid Passport (6+ months)\n• Bank Statement\n• Photo & Flight/Hotel Vouchers',
                        style: const TextStyle(fontSize: 12, height: 1.6, color: AppColors.textSecondary),
                      )
                    : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: s.requirements.take(3).length,
                        itemBuilder: (context, idx) {
                          final req = s.requirements[idx];
                          final reqText = req.localizedRequirement(isArabic);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.successGreen),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    reqText,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 16),
              TravellaButton(
                label: isArabic ? 'طلب التأشيرة والاستشارة' : 'Apply & Consultation',
                variant: _isHovered ? TravellaButtonVariant.gold : TravellaButtonVariant.primary,
                fullWidth: true,
                onPressed: widget.onApply,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Complete Visa Consultation & Application Modal connected to Supabase
class _VisaApplicationModal extends StatefulWidget {
  final VisaServiceModel service;
  final int initialApplicants;

  const _VisaApplicationModal({
    required this.service,
    required this.initialApplicants,
  });

  @override
  State<_VisaApplicationModal> createState() => _VisaApplicationModalState();
}

class _VisaApplicationModalState extends State<_VisaApplicationModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passportCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  late int _applicants;
  late DateTime _travelDate;
  bool _isSubmitting = false;
  String? _submittedRef;

  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _applicants = widget.initialApplicants.clamp(1, 10);
    _travelDate = DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passportCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitVisaRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final totalFee = widget.service.price * _applicants;
    final structuredNotes = StringBuffer()
      ..writeln('=== VISA CONSULTATION & APPLICATION REQUEST ===')
      ..writeln('Country: ${widget.service.country}')
      ..writeln('Visa Type: ${widget.service.visaType}')
      ..writeln('Number of Applicants: $_applicants')
      ..writeln('Planned Travel Date: ${_dateFormat.format(_travelDate)}')
      ..writeln('Processing Time: ${widget.service.processingTime}')
      ..writeln('Estimated Fees: \$${totalFee.toInt()}');

    if (_passportCtrl.text.trim().isNotEmpty) {
      structuredNotes.writeln('Passport / Nationality: ${_passportCtrl.text.trim()}');
    }
    if (_notesCtrl.text.trim().isNotEmpty) {
      structuredNotes.writeln('Additional Notes: ${_notesCtrl.text.trim()}');
    }

    final bookingCubit = context.read<BookingCubit>();
    final success = await bookingCubit.submitBooking(
      customerName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      travelDate: _travelDate,
      travelers: _applicants,
      notes: structuredNotes.toString(),
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        if (success) {
          final state = bookingCubit.state;
          if (state is BookingSubmittedSuccess) {
            _submittedRef = state.booking.bookingReference;
          } else {
            _submittedRef = 'VS-${DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase()}';
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;
    final s = widget.service;

    if (_submittedRef != null) {
      return AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 56),
            const SizedBox(height: 16),
            Text(
              isArabic ? 'تم إرسال طلب التأشيرة بنجاح' : 'Visa Application Request Submitted!',
              style: AppTextStyles.h4.copyWith(color: AppColors.navyDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isArabic ? 'رقم الطلب المرجعي:' : 'Your visa application reference number:',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.gold),
              ),
              child: Text(
                _submittedRef!,
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
                  ? 'تم استلام طلبك بنجاح، وسيقوم مستشار التأشيرات بالتواصل مع حضرتك لمراجعة المستندات واستكمال الإجراءات.'
                  : 'Your request has been received. A dedicated visa specialist will contact you shortly to review your documents and proceed with the application.',
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
          Text(s.flagEmoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? 'التقديم على تأشيرة ${s.localizedCountry(isArabic)}' : 'Apply for ${s.country} Visa',
                  style: AppTextStyles.h5.copyWith(color: AppColors.navyDark),
                ),
                Text(
                  '${s.visaType} • ${s.processingTime} • \$${s.price.toInt()}/person',
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
        width: 480,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Applicant & Date row
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isArabic ? 'عدد المتقدمين' : 'Applicants', style: const TextStyle(fontSize: 11, color: AppColors.textLightMuted)),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, size: 18),
                                onPressed: _applicants > 1 ? () => setState(() => _applicants--) : null,
                              ),
                              Text('$_applicants', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, size: 18),
                                onPressed: _applicants < 10 ? () => setState(() => _applicants++) : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isArabic ? 'تاريخ السفر المخطط' : 'Planned Travel Date', style: const TextStyle(fontSize: 11, color: AppColors.textLightMuted)),
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _travelDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setState(() => _travelDate = picked);
                              }
                            },
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.royalBlue),
                                const SizedBox(width: 4),
                                Text(_dateFormat.format(_travelDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Name
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'الاسم الكامل بالإنجليزية *' : 'Full Name (as in Passport) *',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? (isArabic ? 'الاسم مطلوب' : 'Full name is required')
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
                          labelText: isArabic ? 'البريد *' : 'Email *',
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

                // Passport / Nationality
                TextFormField(
                  controller: _passportCtrl,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'الجنسية / دولة إصدار الجواز' : 'Nationality / Passport Issuing Country',
                    prefixIcon: const Icon(Icons.flag_outlined),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),

                // Notes
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'ملاحظات إضافية' : 'Additional Notes / Previous Visa History',
                    hintText: isArabic
                        ? 'مثال: موعد مستعجل، تم الحصول على تأشيرة سابقة...'
                        : 'e.g. Urgent appointment required, held previous Schengen/US visa...',
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
          label: isArabic ? 'إرسال طلب التأشيرة' : 'Submit Visa Request',
          variant: TravellaButtonVariant.gold,
          isLoading: _isSubmitting,
          onPressed: _submitVisaRequest,
        ),
      ],
    );
  }
}

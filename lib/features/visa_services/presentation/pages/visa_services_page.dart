import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/animations/animation_widgets.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/utils/country_flag_helper.dart';
import '../../../../data/models/visa_model.dart';
import '../../../../data/repositories/visa_repository.dart';
import '../../../../shared/presentation/widgets/app_navbar.dart';
import '../../../../shared/presentation/widgets/app_footer.dart';
import 'visa_details_page.dart';

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

  // Search & Filters (Destination Country, Visa Type, Travel Purpose, Processing Time)
  late TextEditingController _searchCtrl;
  String _searchQuery = '';
  String _selectedVisaType = 'All';
  String _selectedTravelPurpose = 'All';
  String _selectedProcessingTime = 'All';
  String _selectedRegion = 'All';

  final List<String> _regions = ['All', 'Europe', 'UK & USA', 'Middle East', 'Asia'];
  final List<String> _visaTypes = ['All', 'Tourist Visa', 'Business / Conference', 'Express Fast-Track Visa'];
  final List<String> _purposes = ['All', 'Tourism', 'Business', 'Family Visit', 'Transit', 'Study', 'Medical'];
  final List<String> _processingTimes = ['All', 'Fast (1-5 Days)', 'Standard (6-15 Days)', 'Consular (15+ Days)'];

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialCountry ?? '';
    _searchCtrl = TextEditingController(text: _searchQuery);
    _selectedVisaType = widget.initialVisaType ?? 'All';
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

    if (_selectedVisaType != 'All') {
      final type = _selectedVisaType.toLowerCase();
      result = result.where((v) => v.visaType.toLowerCase().contains(type)).toList();
    }

    if (_selectedProcessingTime != 'All') {
      if (_selectedProcessingTime.contains('Fast')) {
        result = result.where((v) =>
            v.processingTime.contains('1-') ||
            v.processingTime.contains('2-') ||
            v.processingTime.contains('3-') ||
            v.processingTime.contains('5') ||
            v.processingTime.contains('Express')).toList();
      } else if (_selectedProcessingTime.contains('Standard')) {
        result = result.where((v) =>
            v.processingTime.contains('7') ||
            v.processingTime.contains('10') ||
            v.processingTime.contains('12') ||
            v.processingTime.contains('14') ||
            v.processingTime.contains('15')).toList();
      }
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

  void _openApplicationFlow(VisaServiceModel service) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => VisaApplicationFlowDialog(
        service: service,
        onSubmitted: () {
          // Success feedback
        },
      ),
    );
  }

  void _openQuickApplyHero() {
    if (_allVisaServices.isNotEmpty) {
      _openApplicationFlow(_allVisaServices.first);
    }
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

          // ── 1. Hero Section ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.navyDark,
              padding: EdgeInsets.symmetric(
                horizontal: hPad,
                vertical: isMobile ? 54 : 84,
              ),
              child: MaxWidthContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_user_rounded, color: AppColors.gold, size: 14),
                          const SizedBox(width: 8),
                          Text(
                            isArabic ? 'خدمات التأشيرات واستشارات السفر الرسمية' : 'CONSULAR & VISA SERVICES',
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
                    const SizedBox(height: 18),

                    // Title
                    Text(
                      isArabic ? 'خدمات التأشيرات' : 'Visa Services',
                      style: (isMobile ? AppTextStyles.h2 : AppTextStyles.h1).copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Subtitle explaining Travella helps customers with applications and requirements
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 820),
                      child: Text(
                        isArabic
                            ? 'تساعد ترافيلا عملاءها في استخراج كافة تأشيرات السفر حول العالم، تجهيز المتطلبات والمستندات، حجز مواعيد المقابلات والبصمات، مع توفير استشارات متخصصة لضمان أعلى نسب قبول.'
                            : 'Travella helps customers with visa applications, consular requirements, embassy appointment scheduling, and end-to-end documentation with industry-leading approval rates.',
                        style: AppTextStyles.bodyLG.copyWith(
                          color: AppColors.textOnDarkMuted,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // CTA: Apply for a Visa
                    Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        TravellaButton(
                          label: isArabic ? 'التقديم على تأشيرة' : 'Apply for a Visa',
                          variant: TravellaButtonVariant.gold,
                          size: TravellaButtonSize.lg,
                          leadingIcon: Icons.send_rounded,
                          onPressed: _openQuickApplyHero,
                        ),
                        TravellaButton(
                          label: isArabic ? 'استكشاف متطلبات الدول' : 'Explore Destinations',
                          variant: TravellaButtonVariant.outline,
                          size: TravellaButtonSize.lg,
                          onPressed: () {
                            // Scroll down smoothly
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── 3. Visa Search & Multi-Filter Bar ──────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 24),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(bottom: BorderSide(color: AppColors.borderLight)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: MaxWidthContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'بحث وتصفية التأشيرات' : 'Search & Filter Visa Services',
                      style: AppTextStyles.labelLG.copyWith(fontWeight: FontWeight.bold, color: AppColors.navyDark),
                    ),
                    const SizedBox(height: 14),

                    // Main Search Input (Destination Country)
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (val) {
                        _searchQuery = val;
                        _applyFilters();
                      },
                      decoration: InputDecoration(
                        hintText: isArabic
                            ? 'ابحث باسم دولة الوجهة (مثل: المملكة المتحدة، إسبانيا، اليابان)...'
                            : 'Search destination country (e.g. United Kingdom, Japan, Schengen)...',
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    const SizedBox(height: 16),

                    // 4 Filter Selectors: Destination Region, Visa Type, Travel Purpose, Processing Time
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Visa Type Filter
                        _buildFilterDropdown(
                          label: isArabic ? 'نوع التأشيرة' : 'Visa Type',
                          value: _selectedVisaType,
                          items: _visaTypes,
                          onChanged: (val) {
                            setState(() => _selectedVisaType = val!);
                            _applyFilters();
                          },
                        ),

                        // Travel Purpose Filter
                        _buildFilterDropdown(
                          label: isArabic ? 'الغرض من السفر' : 'Travel Purpose',
                          value: _selectedTravelPurpose,
                          items: _purposes,
                          onChanged: (val) {
                            setState(() => _selectedTravelPurpose = val!);
                            _applyFilters();
                          },
                        ),

                        // Processing Time Filter
                        _buildFilterDropdown(
                          label: isArabic ? 'مدة المعالجة' : 'Processing Time',
                          value: _selectedProcessingTime,
                          items: _processingTimes,
                          onChanged: (val) {
                            setState(() => _selectedProcessingTime = val!);
                            _applyFilters();
                          },
                        ),

                        // Reset Button
                        if (_selectedVisaType != 'All' || _selectedTravelPurpose != 'All' || _selectedProcessingTime != 'All' || _selectedRegion != 'All' || _searchQuery.isNotEmpty)
                          TextButton.icon(
                            icon: const Icon(Icons.restart_alt_rounded, size: 16, color: AppColors.errorRed),
                            label: Text(
                              isArabic ? 'إعادة ضبط' : 'Reset Filters',
                              style: const TextStyle(color: AppColors.errorRed, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() {
                                _searchQuery = '';
                                _selectedVisaType = 'All';
                                _selectedTravelPurpose = 'All';
                                _selectedProcessingTime = 'All';
                                _selectedRegion = 'All';
                              });
                              _applyFilters();
                            },
                          ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Region Quick Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _regions.map((reg) {
                          final isSel = _selectedRegion == reg;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
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
                                fontSize: 12,
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

          // ── 2. Popular Visa Destinations (Dynamic from Supabase) ───────────
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 36),
              child: MaxWidthContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? 'أشهر وجهات التأشيرات المطلوبة' : 'Popular Visa Destinations',
                              style: AppTextStyles.h3.copyWith(color: AppColors.navyDark, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isArabic
                                  ? 'تأشيرات سياحية وتجارية معتمدة مع أعلى نسب قبول'
                                  : 'Verified tourist & business visa services from Supabase',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                        if (!isMobile)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.royalBlueFaded,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              '${_filteredVisaServices.length} Destinaitons',
                              style: const TextStyle(color: AppColors.royalBlue, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildContent(columns, isMobile, isArabic),
                  ],
                ),
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

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: const TextStyle(fontSize: 12, color: AppColors.gray600)),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isDense: true,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.navyDark),
              items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
              onChanged: onChanged,
            ),
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
                isArabic ? 'جاري تحميل خدمات التأشيرات...' : 'Loading visa destinations from Supabase...',
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
                    _selectedVisaType = 'All';
                    _selectedTravelPurpose = 'All';
                    _selectedProcessingTime = 'All';
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
        mainAxisExtent: isMobile ? 480 : 490,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: _filteredVisaServices.length,
      itemBuilder: (context, i) {
        final service = _filteredVisaServices[i];
        return ScaleInOnScroll(
          delay: Duration(milliseconds: (i % 3) * 60),
          child: VisaDestinationCard(
            service: service,
            onApply: () => _openApplicationFlow(service),
            onViewDetails: () {
              context.go('/visa-services/${service.id}');
            },
          ),
        );
      },
    );
  }
}

/// Dynamic Destination Card displaying: Country flag/image, Country name, Visa types, Starting price, Processing time, View Details, Apply Now
class VisaDestinationCard extends StatefulWidget {
  final VisaServiceModel service;
  final VoidCallback onApply;
  final VoidCallback onViewDetails;

  const VisaDestinationCard({
    super.key,
    required this.service,
    required this.onApply,
    required this.onViewDetails,
  });

  @override
  State<VisaDestinationCard> createState() => _VisaDestinationCardState();
}

class _VisaDestinationCardState extends State<VisaDestinationCard> {
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
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with flag/image & price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.royalBlueFaded,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.royalBlue.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      CountryFlagHelper.getFlag(s.country, s.flagEmoji),
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                  if (s.price > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.gold),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            isArabic ? 'يبدأ من' : 'Starting at',
                            style: const TextStyle(fontSize: 9, color: AppColors.goldDark),
                          ),
                          Text(
                            '\$${s.price.toInt()}',
                            style: const TextStyle(
                              color: AppColors.goldDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Country Name & Visa Type
              Text(
                countryName,
                style: AppTextStyles.h4.copyWith(color: AppColors.navyDark),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                s.visaType,
                style: AppTextStyles.labelMD.copyWith(color: AppColors.royalBlue, fontWeight: FontWeight.w600),
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

              // Key Requirements
              Text(
                isArabic ? 'المستندات والمتطلبات:' : 'Key Requirements:',
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

              const SizedBox(height: 14),

              // Card Actions: View Details & Apply Now
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.royalBlue),
                        foregroundColor: AppColors.royalBlue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: widget.onViewDetails,
                      child: Text(
                        isArabic ? 'التفاصيل' : 'View Details',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isHovered ? AppColors.gold : AppColors.navy,
                        foregroundColor: _isHovered ? AppColors.navy : AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: widget.onApply,
                      child: Text(
                        isArabic ? 'قدّم الآن' : 'Apply Now',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

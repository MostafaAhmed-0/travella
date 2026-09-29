import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/animations/animation_widgets.dart';
import '../../../../data/models/visa_model.dart';
import '../../../../data/repositories/visa_repository.dart';
import '../../../../shared/presentation/widgets/app_navbar.dart';
import '../../../../shared/presentation/widgets/app_footer.dart';

class VisaServicesPage extends StatefulWidget {
  const VisaServicesPage({super.key});

  @override
  State<VisaServicesPage> createState() => _VisaServicesPageState();
}

class _VisaServicesPageState extends State<VisaServicesPage> {
  final VisaRepository _repository = VisaRepository();
  List<VisaServiceModel> _allVisaServices = [];
  List<VisaServiceModel> _filteredVisaServices = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedRegion = 'All';

  final List<String> _regions = ['All', 'Europe', 'UK & USA', 'Middle East', 'Asia'];

  @override
  void initState() {
    super.initState();
    _loadVisaServices();
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
          _errorMessage = e.toString();
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
          v.visaType.toLowerCase().contains(q) ||
          v.description.toLowerCase().contains(q)).toList();
    }

    setState(() {
      _filteredVisaServices = result;
    });
  }

  void _showApplyModal(VisaServiceModel service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(service.flagEmoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Apply for ${service.country} Visa',
                style: AppTextStyles.h5.copyWith(color: AppColors.navyDark),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Visa Category: ${service.visaType}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.royalBlue),
            ),
            const SizedBox(height: 6),
            Text('Processing Time: ${service.processingTime} • Fee: \$${service.price.toInt()}'),
            const SizedBox(height: 16),
            const Text(
              'A dedicated Travella visa specialist will audit your application documents, schedule your embassy appointment, and issue flight/hotel vouchers.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.gray600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.goNamed(AppRoutes.contactName);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.navyDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Proceed with Consultation', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hPad = AppBreakpoints.horizontalPadding(context);
    final isMobile = AppBreakpoints.isMobile(context);
    final columns = isMobile ? 1 : (AppBreakpoints.isTablet(context) ? 2 : 3);

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: CustomScrollView(
        slivers: [
          // ── Navbar ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
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
                      ),
                      child: const Text(
                        'CONSULAR & TRAVEL PERMITS',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Global Visa Assistance',
                      style: (isMobile ? AppTextStyles.h2 : AppTextStyles.h1).copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Hassle-free Schengen, UK, US, Dubai e-Visa and Asian travel visas with high approval rates.',
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
              color: AppColors.white,
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 20),
              child: MaxWidthContainer(
                child: Column(
                  children: [
                    TextField(
                      onChanged: (val) {
                        _searchQuery = val;
                        _applyFilters();
                      },
                      decoration: InputDecoration(
                        hintText: 'Search visa by destination country or type...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.royalBlue),
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
                child: _buildContent(columns, isMobile),
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

  Widget _buildContent(int columns, bool isMobile) {
    if (_isLoading) {
      return const SizedBox(
        height: 400,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.royalBlue),
              SizedBox(height: 16),
              Text('Loading visa services from Supabase...', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return SizedBox(
        height: 350,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.errorRed, size: 50),
              const SizedBox(height: 12),
              Text('Failed to load visa services', style: AppTextStyles.h4),
              const SizedBox(height: 6),
              Text(_errorMessage!, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              TravellaButton(
                label: 'Retry',
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
        height: 350,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.description_outlined, color: AppColors.gray400, size: 56),
              const SizedBox(height: 16),
              Text('No visa services found', style: AppTextStyles.h4),
              const SizedBox(height: 8),
              const Text('No visa services available for this destination at the moment.', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              TravellaButton(
                label: 'Reset Filters',
                variant: TravellaButtonVariant.secondary,
                onPressed: () {
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
        mainAxisExtent: isMobile ? 480 : 500,
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
                      'Fee \$${s.price.toInt()}',
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
                s.country,
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
                    'Processing: ${s.processingTime}',
                    style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(color: AppColors.borderLight),
              const SizedBox(height: 12),

              // Requirements checklist
              Text(
                'Requirements:',
                style: AppTextStyles.labelSM.copyWith(color: AppColors.navyDark, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: s.requirements.isEmpty
                    ? const Text('• Valid Passport (6+ months)\n• Bank Statement\n• Photo & Travel Voucher', style: TextStyle(fontSize: 12, height: 1.6, color: AppColors.textSecondary))
                    : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: s.requirements.take(3).length,
                        itemBuilder: (context, idx) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.successGreen),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    s.requirements[idx].requirement,
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
                label: 'Apply & Consultation',
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

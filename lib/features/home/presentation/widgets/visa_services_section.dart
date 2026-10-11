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

class VisaServicesSection extends StatefulWidget {
  const VisaServicesSection({super.key});

  @override
  State<VisaServicesSection> createState() => _VisaServicesSectionState();
}

class _VisaServicesSectionState extends State<VisaServicesSection> {
  final VisaRepository _repository = VisaRepository();
  List<VisaCountryModel> _countries = [];
  bool _isLoading = true;
  int _selectedCountryIndex = 0;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVisaData();
  }

  Future<void> _loadVisaData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _repository.getPopularCountries();
      if (mounted) {
        setState(() {
          _countries = list;
          _isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    final hPad = AppBreakpoints.horizontalPadding(context);
    final isMobile = AppBreakpoints.isMobile(context);
    final isDesktop = AppBreakpoints.isDesktop(context);
    final features = _repository.getFeatures();

    return Container(
      color: AppColors.surfaceLight,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: isMobile ? 60 : 100),
      child: MaxWidthContainer(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────────
            SlideInOnScroll(
              child: const SectionHeader(
                badge: 'Visa & Consular Services',
                title: 'Your Visa Journey, Made Simple',
                subtitle: 'Stress-free visa processing with certified documentation specialists, biometric scheduling, and a 98% approval rate.',
                alignment: CrossAxisAlignment.center,
              ),
            ),
            const SizedBox(height: 56),

            // ── 6 Service Pillars Grid ─────────────────────────────────────
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 1 : (AppBreakpoints.isTablet(context) ? 2 : 3),
                mainAxisExtent: 150,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: features.length,
              itemBuilder: (context, i) {
                final feat = features[i];
                return ScaleInOnScroll(
                  delay: Duration(milliseconds: i * 60),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.navy.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.royalBlueFaded,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.check_circle_outline_rounded,
                            color: AppColors.royalBlue,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(feat.title, style: AppTextStyles.h6),
                              const SizedBox(height: 4),
                              Text(
                                feat.description,
                                style: AppTextStyles.bodySM.copyWith(color: AppColors.textSecondary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 60),

            // ── Interactive Country Explorer ───────────────────────────────
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: AppColors.royalBlue),
                ),
              )
            else if (_errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.royalBlue, size: 36),
                      const SizedBox(height: 8),
                      Text('Unable to load visa destinations', style: AppTextStyles.h6),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadVisaData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.royalBlue,
                          foregroundColor: AppColors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_countries.isNotEmpty) ...[
              SlideInOnScroll(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isMobile ? 20 : 36),
                  decoration: BoxDecoration(
                    color: AppColors.navyDark,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.navy.withValues(alpha: 0.3),
                        blurRadius: 36,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
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
                                'Select Country & Visa Category',
                                style: AppTextStyles.h4.copyWith(color: AppColors.white),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Fast-track visa consultation and requirements checklist',
                                style: AppTextStyles.bodySM.copyWith(color: AppColors.textOnDarkMuted),
                              ),
                            ],
                          ),
                          if (isDesktop)
                            TravellaButton(
                              label: 'Start Application',
                              variant: TravellaButtonVariant.gold,
                              onPressed: () => context.goNamed(AppRoutes.visaServicesName),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Country selector tabs
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(_countries.length, (index) {
                            final c = _countries[index];
                            final isSel = _selectedCountryIndex == index;
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: InkWell(
                                onTap: () => setState(() => _selectedCountryIndex = index),
                                borderRadius: BorderRadius.circular(12),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSel ? AppColors.royalBlue : AppColors.navyMedium,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSel ? AppColors.gold : AppColors.white.withValues(alpha: 0.1),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(c.flagEmoji, style: const TextStyle(fontSize: 16)),
                                      const SizedBox(width: 8),
                                      Text(
                                        c.countryName,
                                        style: AppTextStyles.labelMD.copyWith(
                                          color: isSel ? AppColors.white : AppColors.textOnDarkMuted,
                                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Selected Country Info Card
                      _buildCountryInfoCard(_countries[_selectedCountryIndex], isMobile),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCountryInfoCard(VisaCountryModel country, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: AppColors.navyMedium,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(country.flagEmoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        country.countryName,
                        style: AppTextStyles.h4.copyWith(color: AppColors.white),
                      ),
                      Text(
                        'Processing Time: ${country.processingTime} • Validity: ${country.validity}',
                        style: AppTextStyles.bodySM.copyWith(color: AppColors.goldLight),
                      ),
                    ],
                  ),
                ],
              ),
              if (!isMobile)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.gold),
                      ),
                      child: Text(
                        'Fee from \$${country.fee.toInt()}',
                        style: AppTextStyles.labelLG.copyWith(color: AppColors.gold, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 14),
                    TravellaButton(
                      label: 'Apply for Visa',
                      variant: TravellaButtonVariant.gold,
                      size: TravellaButtonSize.sm,
                      trailingIcon: Icons.arrow_forward_rounded,
                      onPressed: () => context.goNamed(
                        AppRoutes.visaServicesName,
                        queryParameters: {'country': country.countryName},
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.dividerDark),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Required Documentation Checklist:',
              style: AppTextStyles.labelLG.copyWith(color: AppColors.white),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: country.requirements.map((req) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.navyDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.gold, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      req.requirement,
                      style: AppTextStyles.bodySM.copyWith(color: AppColors.white),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          if (isMobile) ...[
            const SizedBox(height: 20),
            TravellaButton(
              label: 'Apply for ${country.countryName} Visa',
              variant: TravellaButtonVariant.gold,
              fullWidth: true,
              onPressed: () => context.goNamed(AppRoutes.visaServicesName),
            ),
          ],
        ],
      ),
    );
  }
}

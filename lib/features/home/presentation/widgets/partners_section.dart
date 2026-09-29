import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../data/models/partner_model.dart';
import '../../../../data/repositories/partner_repository.dart';

class PartnersSection extends StatefulWidget {
  const PartnersSection({super.key});

  @override
  State<PartnersSection> createState() => _PartnersSectionState();
}

class _PartnersSectionState extends State<PartnersSection>
    with SingleTickerProviderStateMixin {
  final PartnerRepository _repository = PartnerRepository();
  late final AnimationController _controller;
  List<PartnerModel> _partners = [];

  static const _defaultNames = [
    'Emirates Airlines',
    'Qatar Airways',
    'Turkish Airlines',
    'EgyptAir',
    'Marriott Luxury Collection',
    'Four Seasons Hotels',
    'Hilton Worldwide',
    'Rixos Premium Resorts',
    'Fairmont Hotels',
    'Accor Group',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28),
    )..repeat();
    _loadPartners();
  }

  Future<void> _loadPartners() async {
    try {
      final list = await _repository.getPartners(activeOnly: true);
      if (mounted && list.isNotEmpty) {
        setState(() {
          _partners = list;
        });
      }
    } catch (_) {
      // Keep defaults
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(context);
    final partnerNames = _partners.isNotEmpty
        ? _partners.map((p) => p.name).toList()
        : _defaultNames;

    return Container(
      color: AppColors.navyDark,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 36 : 48),
      child: Column(
        children: [
          MaxWidthContainer(
            child: Center(
              child: Text(
                'TRUSTED BY GLOBAL AIRLINES & HOSPITALITY LEADERS',
                style: AppTextStyles.overline.copyWith(
                  color: AppColors.goldLight.withValues(alpha: 0.8),
                  letterSpacing: 2.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Infinite Ticker
          SizedBox(
            height: 52,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = 220.0;
                    final totalWidth = partnerNames.length * itemWidth;
                    final offset = _controller.value * totalWidth;

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Transform.translate(
                          offset: Offset(-offset, 0),
                          child: Row(
                            children: [
                              ...partnerNames.map((name) => _buildPartnerChip(name, itemWidth)),
                              ...partnerNames.map((name) => _buildPartnerChip(name, itemWidth)),
                              ...partnerNames.map((name) => _buildPartnerChip(name, itemWidth)),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerChip(String name, double width) {
    return Container(
      width: width,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.navyMedium,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.flight_takeoff_rounded, size: 16, color: AppColors.gold),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              name,
              style: AppTextStyles.labelMD.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

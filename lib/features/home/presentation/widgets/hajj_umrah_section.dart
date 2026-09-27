import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/animations/animation_widgets.dart';
import '../../../../data/models/hajj_umrah_model.dart';
import '../../../../data/repositories/hajj_umrah_repository.dart';

class HajjUmrahSection extends StatefulWidget {
  const HajjUmrahSection({super.key});

  @override
  State<HajjUmrahSection> createState() => _HajjUmrahSectionState();
}

class _HajjUmrahSectionState extends State<HajjUmrahSection> {
  final HajjUmrahRepository _repository = const HajjUmrahRepository();
  List<HajjUmrahPackageModel> _packages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    final list = await _repository.getPackages();
    if (mounted) {
      setState(() {
        _packages = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hPad = AppBreakpoints.horizontalPadding(context);
    final isMobile = AppBreakpoints.isMobile(context);
    final columns = isMobile ? 1 : (AppBreakpoints.isTablet(context) ? 2 : 3);

    return Container(
      color: AppColors.navyDark,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: isMobile ? 60 : 100),
      child: MaxWidthContainer(
        child: Column(
          children: [
            SlideInOnScroll(
              child: const SectionHeader(
                badge: 'Hajj & Umrah Services',
                title: 'Spiritual Journeys, Carefully Arranged',
                subtitle: '5-star accommodations directly facing the Holy Haram, VIP private transportation, and comprehensive religious guidance.',
                alignment: CrossAxisAlignment.center,
                onDark: true,
              ),
            ),
            const SizedBox(height: 56),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisExtent: isMobile ? 540 : 560,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                itemCount: _packages.length,
                itemBuilder: (context, i) {
                  return ScaleInOnScroll(
                    delay: Duration(milliseconds: i * 100),
                    child: _HajjUmrahCard(package: _packages[i]),
                  );
                },
              ),

            const SizedBox(height: 48),
            SlideInOnScroll(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.navyMedium,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 24),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        'Accredited by the Ministry of Hajj & Umrah • Licensed Electronic Visa Portal',
                        style: AppTextStyles.bodyMD.copyWith(color: AppColors.goldLight),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HajjUmrahCard extends StatefulWidget {
  final HajjUmrahPackageModel package;
  const _HajjUmrahCard({required this.package});

  @override
  State<_HajjUmrahCard> createState() => _HajjUmrahCardState();
}

class _HajjUmrahCardState extends State<_HajjUmrahCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final pkg = widget.package;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0.0, _isHovered ? -8.0 : 0.0, 0.0),
        decoration: BoxDecoration(
          color: AppColors.navyMedium,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _isHovered
                ? AppColors.gold
                : AppColors.gold.withValues(alpha: 0.25),
            width: _isHovered ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? AppColors.gold.withValues(alpha: 0.22)
                  : Colors.black.withValues(alpha: 0.3),
              blurRadius: _isHovered ? 36 : 16,
              offset: Offset(0, _isHovered ? 14 : 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Banner
              SizedBox(
                height: 180,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AnimatedScale(
                      scale: _isHovered ? 1.05 : 1.0,
                      duration: const Duration(milliseconds: 400),
                      child: Image.network(
                        pkg.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.navyDark,
                          child: const Icon(Icons.mosque_rounded, color: AppColors.gold),
                        ),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.transparent,
                            AppColors.navyMedium,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.navyDark.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          pkg.category,
                          style: AppTextStyles.labelSM.copyWith(color: AppColors.gold),
                        ),
                      ),
                    ),
                    if (pkg.badge != null)
                      Positioned(
                        top: 14,
                        right: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            pkg.badge!,
                            style: AppTextStyles.labelSM.copyWith(
                              color: AppColors.navyDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Package Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pkg.title,
                        style: AppTextStyles.h4.copyWith(color: AppColors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pkg.subtitle,
                        style: AppTextStyles.bodySM.copyWith(color: AppColors.textOnDarkMuted),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),

                      // Hotel & Distance Info
                      _buildHotelInfoRow(Icons.hotel_rounded, 'Makkah: ${pkg.makkahHotel}', pkg.makkahDistance),
                      const SizedBox(height: 8),
                      _buildHotelInfoRow(Icons.hotel_rounded, 'Madinah: ${pkg.madinahHotel}', pkg.madinahDistance),

                      const SizedBox(height: 16),
                      Text(
                        'Key Inclusions:',
                        style: AppTextStyles.labelSM.copyWith(color: AppColors.goldLight),
                      ),
                      const SizedBox(height: 6),
                      ...pkg.inclusions.take(3).map((inc) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: AppColors.gold, size: 14),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  inc,
                                  style: AppTextStyles.bodySM.copyWith(color: AppColors.white),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const Spacer(),
                      const Divider(color: AppColors.dividerDark, height: 16),

                      // Price & Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PACKAGE FROM',
                                style: AppTextStyles.overline.copyWith(
                                  color: AppColors.goldLight,
                                  fontSize: 9,
                                ),
                              ),
                              Text(
                                '\$${pkg.price.toInt()}',
                                style: AppTextStyles.h4.copyWith(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () => context.goNamed(AppRoutes.hajjUmrahName),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gold,
                              foregroundColor: AppColors.navyDark,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            child: Text(
                              'Inquire Now',
                              style: AppTextStyles.labelMD.copyWith(
                                color: AppColors.navyDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHotelInfoRow(IconData icon, String hotel, String distance) {
    return Row(
      children: [
        Icon(icon, color: AppColors.gold, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hotel,
                style: AppTextStyles.labelSM.copyWith(color: AppColors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                distance,
                style: AppTextStyles.bodySM.copyWith(color: AppColors.goldLight, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

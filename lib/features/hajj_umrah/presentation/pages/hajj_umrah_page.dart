import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/animations/animation_widgets.dart';
import '../../../../data/models/tour_model.dart';
import '../../../../data/repositories/tour_repository.dart';
import '../../../../shared/presentation/widgets/app_navbar.dart';
import '../../../../shared/presentation/widgets/app_footer.dart';

class HajjUmrahPage extends StatefulWidget {
  const HajjUmrahPage({super.key});

  @override
  State<HajjUmrahPage> createState() => _HajjUmrahPageState();
}

class _HajjUmrahPageState extends State<HajjUmrahPage> {
  final TourRepository _repository = TourRepository();
  List<TourModel> _allPilgrimages = [];
  List<TourModel> _filteredPilgrimages = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedTab = 'All';

  final List<String> _tabs = [
    'All',
    'Umrah Packages',
    'Hajj Packages',
  ];

  @override
  void initState() {
    super.initState();
    _loadPilgrimages();
  }

  Future<void> _loadPilgrimages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _repository.getHajjUmrahTours(activeOnly: true);
      if (mounted) {
        setState(() {
          _allPilgrimages = list;
          _isLoading = false;
          _applyFilter();
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

  void _applyFilter() {
    var result = List<TourModel>.from(_allPilgrimages);

    if (_selectedTab == 'Umrah Packages') {
      result = result.where((t) => t.type == TourType.umrah).toList();
    } else if (_selectedTab == 'Hajj Packages') {
      result = result.where((t) => t.type == TourType.hajj).toList();
    }

    setState(() {
      _filteredPilgrimages = result;
    });
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
            child: AppNavbar(currentRoute: AppRoutes.hajjUmrah),
          ),

          // ── Page Header ──────────────────────────────────────────────────
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
                        'SPIRITUAL PILGRIMAGES',
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
                      'Hajj & Umrah Packages',
                      style: (isMobile ? AppTextStyles.h2 : AppTextStyles.h1).copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '5-star front-row Haram accommodations in Makkah & Madinah, VIP private transfers, and scholar guides.',
                      style: AppTextStyles.bodyLG.copyWith(
                        color: AppColors.textOnDarkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Tabs Bar ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.white,
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 20),
              child: MaxWidthContainer(
                child: Row(
                  children: _tabs.map((tab) {
                    final isSel = _selectedTab == tab;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ChoiceChip(
                        label: Text(tab),
                        selected: isSel,
                        onSelected: (_) {
                          setState(() => _selectedTab = tab);
                          _applyFilter();
                        },
                        selectedColor: AppColors.navy,
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
              CircularProgressIndicator(color: AppColors.gold),
              SizedBox(height: 16),
              Text('Loading pilgrimage packages...', style: TextStyle(color: AppColors.textSecondary)),
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
              Text('Failed to load packages', style: AppTextStyles.h4),
              const SizedBox(height: 6),
              Text(_errorMessage!, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              TravellaButton(
                label: 'Retry',
                variant: TravellaButtonVariant.primary,
                onPressed: _loadPilgrimages,
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredPilgrimages.isEmpty) {
      return SizedBox(
        height: 350,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mosque_rounded, color: AppColors.gray400, size: 56),
              const SizedBox(height: 16),
              Text('No pilgrimage packages available', style: AppTextStyles.h4),
              const SizedBox(height: 8),
              const Text('No packages available in this category at the moment.', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              TravellaButton(
                label: 'Show All Pilgrimages',
                variant: TravellaButtonVariant.secondary,
                onPressed: () {
                  setState(() => _selectedTab = 'All');
                  _applyFilter();
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
        mainAxisExtent: isMobile ? 480 : 510,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: _filteredPilgrimages.length,
      itemBuilder: (context, i) {
        final tour = _filteredPilgrimages[i];
        return ScaleInOnScroll(
          delay: Duration(milliseconds: (i % 3) * 60),
          child: _HajjUmrahCard(tour: tour),
        );
      },
    );
  }
}

class _HajjUmrahCard extends StatefulWidget {
  final TourModel tour;
  const _HajjUmrahCard({required this.tour});

  @override
  State<_HajjUmrahCard> createState() => _HajjUmrahCardState();
}

class _HajjUmrahCardState extends State<_HajjUmrahCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final tour = widget.tour;
    final isHajj = tour.type == TourType.hajj;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => context.goNamed(
          AppRoutes.tourDetailsName,
          pathParameters: {'id': tour.id},
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0.0, _isHovered ? -8.0 : 0.0, 0.0),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: _isHovered ? AppColors.gold : AppColors.gold.withValues(alpha: 0.3),
              width: _isHovered ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? AppColors.gold.withValues(alpha: 0.18)
                    : AppColors.navy.withValues(alpha: 0.05),
                blurRadius: _isHovered ? 32 : 16,
                offset: Offset(0, _isHovered ? 14 : 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AnimatedScale(
                        scale: _isHovered ? 1.05 : 1.0,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        child: Image.network(
                          tour.imageUrl,
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
                              Colors.black.withValues(alpha: 0.35),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.4),
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
                            isHajj ? 'HAJJ PACKAGE' : 'UMRAH PACKAGE',
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      if (tour.badge != null)
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
                              tour.badge!,
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

                // Details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.schedule_rounded, size: 14, color: AppColors.goldDark),
                                const SizedBox(width: 4),
                                Text(
                                  tour.duration,
                                  style: AppTextStyles.labelSM.copyWith(
                                    color: AppColors.goldDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, size: 16, color: AppColors.gold),
                                const SizedBox(width: 2),
                                Text(
                                  '${tour.rating} (${tour.reviewsCount})',
                                  style: AppTextStyles.labelSM.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          tour.title,
                          style: AppTextStyles.h5.copyWith(color: AppColors.navyDark),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tour.description,
                          style: AppTextStyles.bodySM.copyWith(color: AppColors.textSecondary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        const Divider(color: AppColors.borderLight, height: 16),
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
                                  '${tour.currency} ${tour.price.toInt()}',
                                  style: AppTextStyles.h4.copyWith(
                                    color: AppColors.navyDark,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () => context.goNamed(
                                AppRoutes.tourDetailsName,
                                pathParameters: {'id': tour.id},
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isHovered ? AppColors.gold : AppColors.navy,
                                foregroundColor: _isHovered ? AppColors.navyDark : AppColors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                              ),
                              child: Text(
                                'View Details',
                                style: AppTextStyles.labelMD.copyWith(
                                  color: _isHovered ? AppColors.navyDark : AppColors.white,
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
      ),
    );
  }
}

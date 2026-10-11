import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/animations/animation_widgets.dart';
import '../../../../data/models/destination_model.dart';
import '../../../../data/repositories/destination_repository.dart';

class FeaturedDestinationsSection extends StatefulWidget {
  const FeaturedDestinationsSection({super.key});

  @override
  State<FeaturedDestinationsSection> createState() =>
      _FeaturedDestinationsSectionState();
}

class _FeaturedDestinationsSectionState
    extends State<FeaturedDestinationsSection> {
  final DestinationRepository _repository = DestinationRepository();
  String _selectedCategory = 'All';
  List<DestinationModel> _destinations = [];
  bool _isLoading = true;

  final List<String> _categories = [
    'All',
    'Egypt',
    'Europe',
    'Middle East',
    'Exotic',
  ];

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDestinations();
  }

  Future<void> _loadDestinations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _repository.getDestinations(
        featuredOnly: true,
        region: _selectedCategory == 'All' ? null : _selectedCategory,
      );
      if (mounted) {
        setState(() {
          _destinations = list;
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

  void _onCategorySelected(String category) {
    if (_selectedCategory == category) return;
    setState(() {
      _selectedCategory = category;
      _isLoading = true;
    });
    _loadDestinations();
  }

  @override
  Widget build(BuildContext context) {
    final hPad = AppBreakpoints.horizontalPadding(context);
    final isMobile = AppBreakpoints.isMobile(context);
    final columns = isMobile ? 1 : (AppBreakpoints.isTablet(context) ? 2 : 3);

    return Container(
      color: AppColors.white,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: isMobile ? 60 : 100),
      child: MaxWidthContainer(
        child: Column(
          children: [
            // ── Section Header ─────────────────────────────────────────────
            SlideInOnScroll(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: SectionHeader(
                      badge: 'Iconic Destinations',
                      title: 'Explore Extraordinary Places',
                      subtitle: 'From historic grand capitals to pristine desert oases and turquoise coral reefs.',
                    ),
                  ),
                  if (!isMobile)
                    TravellaButton(
                      label: 'View All Destinations',
                      variant: TravellaButtonVariant.secondary,
                      trailingIcon: Icons.arrow_forward_rounded,
                      onPressed: () => context.goNamed(AppRoutes.destinationsName),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // ── Category Filter Tabs ───────────────────────────────────────
            SlideInOnScroll(
              delay: const Duration(milliseconds: 100),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: InkWell(
                        onTap: () => _onCategorySelected(cat),
                        borderRadius: BorderRadius.circular(100),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.navy : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: isSelected ? AppColors.navy : AppColors.borderLight,
                            ),
                          ),
                          child: Text(
                            cat,
                            style: AppTextStyles.labelMD.copyWith(
                              color: isSelected ? AppColors.white : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // ── Destinations Grid ──────────────────────────────────────────
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(color: AppColors.royalBlue),
                ),
              )
            else if (_errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.errorRed, size: 40),
                      const SizedBox(height: 12),
                      Text('Failed to load featured destinations', style: AppTextStyles.h5),
                      const SizedBox(height: 12),
                      TravellaButton(
                        label: 'Retry',
                        variant: TravellaButtonVariant.primary,
                        onPressed: _loadDestinations,
                      ),
                    ],
                  ),
                ),
              )
            else if (_destinations.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: Column(
                    children: [
                      Icon(Icons.place_outlined, color: AppColors.gray400, size: 48),
                      SizedBox(height: 12),
                      Text('No featured destinations available at the moment.', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisExtent: isMobile ? 380 : 420,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                itemCount: _destinations.length,
                itemBuilder: (context, i) {
                  return ScaleInOnScroll(
                    delay: Duration(milliseconds: (i % 3) * 100),
                    child: _DestinationCard(destination: _destinations[i]),
                  );
                },
              ),

            if (isMobile) ...[
              const SizedBox(height: 32),
              TravellaButton(
                label: 'View All Destinations',
                variant: TravellaButtonVariant.secondary,
                fullWidth: true,
                trailingIcon: Icons.arrow_forward_rounded,
                onPressed: () => context.goNamed(AppRoutes.destinationsName),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DestinationCard extends StatefulWidget {
  final DestinationModel destination;
  const _DestinationCard({required this.destination});

  @override
  State<_DestinationCard> createState() => _DestinationCardState();
}

class _DestinationCardState extends State<_DestinationCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final dest = widget.destination;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => context.goNamed(
          AppRoutes.destinationsName,
          queryParameters: {'search': dest.title},
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0.0, _isHovered ? -8.0 : 0.0, 0.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? AppColors.navy.withValues(alpha: 0.22)
                    : AppColors.navy.withValues(alpha: 0.08),
                blurRadius: _isHovered ? 36 : 16,
                offset: Offset(0, _isHovered ? 18 : 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Image with scale effect
                AnimatedScale(
                  scale: _isHovered ? 1.07 : 1.0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  child: Image.network(
                    dest.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.navyMedium,
                      child: const Center(
                        child: Icon(Icons.photo_size_select_actual_outlined, color: AppColors.gray400),
                      ),
                    ),
                  ),
                ),

                // Gradient Vignette Overlay
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.3),
                        AppColors.navyDark.withValues(alpha: 0.92),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),

                // Top Badges
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.navyDark.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: AppColors.white.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.place_rounded, size: 14, color: AppColors.gold),
                            const SizedBox(width: 4),
                            Text(
                              dest.country,
                              style: AppTextStyles.labelSM.copyWith(color: AppColors.white),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 14, color: AppColors.navyDark),
                            const SizedBox(width: 3),
                            Text(
                              dest.rating.toStringAsFixed(1),
                              style: AppTextStyles.labelSM.copyWith(
                                color: AppColors.navyDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Content
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        dest.title,
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        dest.description,
                        style: AppTextStyles.bodySM.copyWith(
                          color: AppColors.textOnDarkMuted,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 14),
                      const Divider(color: AppColors.dividerDark, height: 1),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'STARTING FROM',
                                style: AppTextStyles.overline.copyWith(
                                  color: AppColors.goldLight,
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                '\$${dest.startingPrice.toInt()}',
                                style: AppTextStyles.h4.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: _isHovered ? AppColors.gold : AppColors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Explore',
                                  style: AppTextStyles.labelMD.copyWith(
                                    color: _isHovered ? AppColors.navyDark : AppColors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 16,
                                  color: _isHovered ? AppColors.navyDark : AppColors.white,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
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

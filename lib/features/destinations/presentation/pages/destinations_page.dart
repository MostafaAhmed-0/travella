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
import '../../../../shared/presentation/widgets/app_navbar.dart';
import '../../../../shared/presentation/widgets/app_footer.dart';

class DestinationsPage extends StatefulWidget {
  final String? initialQuery;
  const DestinationsPage({super.key, this.initialQuery});

  @override
  State<DestinationsPage> createState() => _DestinationsPageState();
}

class _DestinationsPageState extends State<DestinationsPage> {
  final DestinationRepository _repository = DestinationRepository();
  List<DestinationModel> _allDestinations = [];
  List<DestinationModel> _filteredDestinations = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedCategory = 'All';
  late TextEditingController _searchCtrl;
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Egypt',
    'Europe',
    'Middle East',
    'Asia',
    'Exotic',
  ];

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialQuery ?? '';
    _searchCtrl = TextEditingController(text: _searchQuery);
    _loadDestinations();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDestinations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await _repository.getDestinations();
      if (mounted) {
        setState(() {
          _allDestinations = items;
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
    var result = List<DestinationModel>.from(_allDestinations);

    if (_selectedCategory != 'All') {
      final cat = _selectedCategory.toLowerCase();
      result = result.where((d) =>
          d.region.toLowerCase().contains(cat) ||
          d.country.toLowerCase().contains(cat) ||
          d.tags.any((t) => t.toLowerCase().contains(cat))).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      result = result.where((d) =>
          d.name.toLowerCase().contains(q) ||
          d.country.toLowerCase().contains(q) ||
          d.description.toLowerCase().contains(q)).toList();
    }

    setState(() {
      _filteredDestinations = result;
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
            child: AppNavbar(currentRoute: AppRoutes.destinations),
          ),

          // ── Page Hero Header ─────────────────────────────────────────────
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
                        'EXPLORE THE GLOBE',
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
                      'World Destinations',
                      style: (isMobile ? AppTextStyles.h2 : AppTextStyles.h1).copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Curated travel destinations spanning ancient heritage sites, tropical islands, and vibrant capitals.',
                      style: AppTextStyles.bodyLG.copyWith(
                        color: AppColors.textOnDarkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Search & Filter Controls ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.white,
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 24),
              child: MaxWidthContainer(
                child: Column(
                  children: [
                    // Search bar & Category filters
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: (val) {
                              _searchQuery = val;
                              _applyFilters();
                            },
                            decoration: InputDecoration(
                              hintText: 'Search destinations by city, country or attraction...',
                              prefixIcon: const Icon(Icons.search, color: AppColors.royalBlue),
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories.map((cat) {
                          final isSelected = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: FilterChip(
                              label: Text(cat),
                              selected: isSelected,
                              onSelected: (_) {
                                setState(() => _selectedCategory = cat);
                                _applyFilters();
                              },
                              selectedColor: AppColors.navy,
                              checkmarkColor: AppColors.white,
                              labelStyle: TextStyle(
                                color: isSelected ? AppColors.white : AppColors.navyDark,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                              backgroundColor: AppColors.surfaceLight,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                                side: BorderSide(
                                  color: isSelected ? AppColors.navy : AppColors.borderLight,
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

          // ── Main Content Grid ────────────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 40),
            sliver: SliverToBoxAdapter(
              child: MaxWidthContainer(
                child: _buildGridContent(columns, isMobile),
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

  Widget _buildGridContent(int columns, bool isMobile) {
    if (_isLoading) {
      return const SizedBox(
        height: 400,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.royalBlue),
              SizedBox(height: 16),
              Text('Loading destinations from Supabase...', style: TextStyle(color: AppColors.textSecondary)),
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
              Text('Failed to load destinations', style: AppTextStyles.h4),
              const SizedBox(height: 6),
              Text(_errorMessage!, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              TravellaButton(
                label: 'Retry',
                variant: TravellaButtonVariant.primary,
                onPressed: _loadDestinations,
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredDestinations.isEmpty) {
      return SizedBox(
        height: 350,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off_rounded, color: AppColors.gray400, size: 56),
              const SizedBox(height: 16),
              Text('No destinations found', style: AppTextStyles.h4),
              const SizedBox(height: 8),
              const Text('No destinations match your filter criteria at the moment.', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              TravellaButton(
                label: 'Reset Filters',
                variant: TravellaButtonVariant.secondary,
                onPressed: () {
                  setState(() {
                    _selectedCategory = 'All';
                    _searchQuery = '';
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
        mainAxisExtent: isMobile ? 380 : 420,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: _filteredDestinations.length,
      itemBuilder: (context, i) {
        final dest = _filteredDestinations[i];
        return ScaleInOnScroll(
          delay: Duration(milliseconds: (i % 3) * 60),
          child: _DestinationGridCard(destination: dest),
        );
      },
    );
  }
}

class _DestinationGridCard extends StatefulWidget {
  final DestinationModel destination;
  const _DestinationGridCard({required this.destination});

  @override
  State<_DestinationGridCard> createState() => _DestinationGridCardState();
}

class _DestinationGridCardState extends State<_DestinationGridCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final dest = widget.destination;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          // Navigate to domestic or international tours filtered by destination
          context.goNamed(AppRoutes.domesticToursName);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0.0, _isHovered ? -8.0 : 0.0, 0.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? AppColors.navy.withValues(alpha: 0.22)
                    : AppColors.navy.withValues(alpha: 0.08),
                blurRadius: _isHovered ? 32 : 14,
                offset: Offset(0, _isHovered ? 16 : 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Image
                AnimatedScale(
                  scale: _isHovered ? 1.07 : 1.0,
                  duration: const Duration(milliseconds: 400),
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

                // Gradient Overlay
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.35),
                        AppColors.navyDark.withValues(alpha: 0.94),
                      ],
                      stops: const [0.0, 0.4, 1.0],
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
                          color: AppColors.navyDark.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: AppColors.white.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.place_rounded, size: 13, color: AppColors.gold),
                            const SizedBox(width: 4),
                            Text(
                              dest.country,
                              style: AppTextStyles.labelSM.copyWith(color: AppColors.white),
                            ),
                          ],
                        ),
                      ),
                      if (dest.featured)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Text(
                            'Featured',
                            style: TextStyle(
                              color: AppColors.navyDark,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
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
                        dest.name,
                        style: AppTextStyles.h3.copyWith(color: AppColors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        dest.description,
                        style: AppTextStyles.bodySM.copyWith(color: AppColors.textOnDarkMuted),
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
                                  fontSize: 9,
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
                          Container(
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
                                  size: 15,
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

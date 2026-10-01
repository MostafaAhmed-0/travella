import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/animations/animation_widgets.dart';
import '../../../../data/models/hotel_model.dart';
import '../../../../data/repositories/hotel_repository.dart';
import '../../../../shared/presentation/widgets/app_navbar.dart';
import '../../../../shared/presentation/widgets/app_footer.dart';

class HotelsPage extends StatefulWidget {
  const HotelsPage({super.key});

  @override
  State<HotelsPage> createState() => _HotelsPageState();
}

class _HotelsPageState extends State<HotelsPage> {
  final HotelRepository _repository = HotelRepository();
  List<HotelModel> _allHotels = [];
  List<HotelModel> _filteredHotels = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedRating = 'All';
  String _sortBy = 'Recommended';

  final List<String> _ratingFilters = ['All', '5 Stars', '4 Stars', '4.9+ Rated'];
  final List<String> _sortOptions = ['Recommended', 'Price: Low to High', 'Price: High to Low', 'Rating'];

  @override
  void initState() {
    super.initState();
    _loadHotels();
  }

  Future<void> _loadHotels() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _repository.getAllHotels(activeOnly: true);
      if (mounted) {
        setState(() {
          _allHotels = list;
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
    var result = List<HotelModel>.from(_allHotels);

    if (_selectedRating == '5 Stars') {
      result = result.where((h) => h.stars == 5).toList();
    } else if (_selectedRating == '4 Stars') {
      result = result.where((h) => h.stars == 4).toList();
    } else if (_selectedRating == '4.9+ Rated') {
      result = result.where((h) => h.rating >= 4.9).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      result = result.where((h) =>
          h.name.toLowerCase().contains(q) ||
          h.location.toLowerCase().contains(q) ||
          h.description.toLowerCase().contains(q)).toList();
    }

    if (_sortBy == 'Price: Low to High') {
      result.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortBy == 'Price: High to Low') {
      result.sort((a, b) => b.price.compareTo(a.price));
    } else if (_sortBy == 'Rating') {
      result.sort((a, b) => b.rating.compareTo(a.rating));
    }

    setState(() {
      _filteredHotels = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hPad = AppBreakpoints.horizontalPadding(context);
    final isMobile = AppBreakpoints.isMobile(context);
    final columns = isMobile ? 1 : 2;

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: CustomScrollView(
        slivers: [
          // ── Navbar ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: AppNavbar(currentRoute: AppRoutes.hotels),
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
                        'LUXURY ACCOMMODATIONS',
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
                      'Luxury Hotels & Resorts',
                      style: (isMobile ? AppTextStyles.h2 : AppTextStyles.h1).copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Handpicked 5-star beachfront resorts, overwater villas, and historic palace sanctuaries.',
                      style: AppTextStyles.bodyLG.copyWith(
                        color: AppColors.textOnDarkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Filters Bar ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.white,
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 20),
              child: MaxWidthContainer(
                child: Column(
                  children: [
                    if (isMobile) ...[
                      TextField(
                        onChanged: (val) {
                          _searchQuery = val;
                          _applyFilters();
                        },
                        decoration: InputDecoration(
                          hintText: 'Search hotels...',
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
                      const SizedBox(height: 12),
                      DropdownButtonHideUnderline(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: DropdownButton<String>(
                            value: _sortBy,
                            isExpanded: true,
                            icon: const Icon(Icons.sort_rounded, color: AppColors.royalBlue),
                            items: _sortOptions.map((s) {
                              return DropdownMenuItem<String>(
                                value: s,
                                child: Text(s, style: AppTextStyles.labelMD),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _sortBy = val);
                                _applyFilters();
                              }
                            },
                          ),
                        ),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (val) {
                                _searchQuery = val;
                                _applyFilters();
                              },
                              decoration: InputDecoration(
                                hintText: 'Search hotels by name, city, or destination...',
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
                          ),
                          const SizedBox(width: 16),
                          DropdownButtonHideUnderline(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: DropdownButton<String>(
                                value: _sortBy,
                                icon: const Icon(Icons.sort_rounded, color: AppColors.royalBlue),
                                items: _sortOptions.map((s) {
                                  return DropdownMenuItem<String>(
                                    value: s,
                                    child: Text(s, style: AppTextStyles.labelMD),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _sortBy = val);
                                    _applyFilters();
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 14),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _ratingFilters.map((r) {
                          final isSel = _selectedRating == r;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: FilterChip(
                              label: Text(r),
                              selected: isSel,
                              onSelected: (_) {
                                setState(() => _selectedRating = r);
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
              Text('Loading luxury hotels...', style: TextStyle(color: AppColors.textSecondary)),
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
              Text('Failed to load hotels', style: AppTextStyles.h4),
              const SizedBox(height: 6),
              Text(_errorMessage!, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              TravellaButton(
                label: 'Retry',
                variant: TravellaButtonVariant.primary,
                onPressed: _loadHotels,
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredHotels.isEmpty) {
      return SizedBox(
        height: 350,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hotel_rounded, color: AppColors.gray400, size: 56),
              const SizedBox(height: 16),
              Text('No hotels available at the moment.', style: AppTextStyles.h4),
              const SizedBox(height: 8),
              const Text('Try adjusting your search query or rating filter.', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              TravellaButton(
                label: 'Reset Filters',
                variant: TravellaButtonVariant.secondary,
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _selectedRating = 'All';
                    _sortBy = 'Recommended';
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
        mainAxisExtent: isMobile ? 500 : 360,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: _filteredHotels.length,
      itemBuilder: (context, i) {
        return ScaleInOnScroll(
          delay: Duration(milliseconds: (i % 2) * 80),
          child: _HotelGridCard(hotel: _filteredHotels[i], isMobile: isMobile),
        );
      },
    );
  }
}

class _HotelGridCard extends StatefulWidget {
  final HotelModel hotel;
  final bool isMobile;
  const _HotelGridCard({required this.hotel, required this.isMobile});

  @override
  State<_HotelGridCard> createState() => _HotelGridCardState();
}

class _HotelGridCardState extends State<_HotelGridCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;

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
            color: _isHovered ? AppColors.gold : AppColors.borderLight,
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? AppColors.navy.withValues(alpha: 0.12)
                  : AppColors.navy.withValues(alpha: 0.04),
              blurRadius: _isHovered ? 28 : 14,
              offset: Offset(0, _isHovered ? 12 : 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: widget.isMobile
              ? Column(
                  children: [
                    _buildImageSection(hotel),
                    Expanded(child: _buildInfoSection(hotel)),
                  ],
                )
              : Row(
                  children: [
                    Expanded(flex: 5, child: _buildImageSection(hotel)),
                    Expanded(flex: 6, child: _buildInfoSection(hotel)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildImageSection(HotelModel hotel) {
    return SizedBox(
      height: widget.isMobile ? 200 : double.infinity,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedScale(
            scale: _isHovered ? 1.06 : 1.0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            child: Image.network(
              hotel.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.navyMedium,
                child: const Icon(Icons.hotel_rounded, color: AppColors.gray400),
              ),
            ),
          ),
          if (hotel.badge != null)
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hotel.badge!,
                  style: AppTextStyles.labelSM.copyWith(
                    color: AppColors.navyDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(HotelModel hotel) {
    return Padding(
      padding: EdgeInsets.all(widget.isMobile ? 16 : 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.place_rounded, size: 14, color: AppColors.royalBlue),
                  const SizedBox(width: 4),
                  Text(
                    '${hotel.city}, ${hotel.country}',
                    style: AppTextStyles.labelSM.copyWith(
                      color: AppColors.royalBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              RatingStars(rating: hotel.rating, size: 14),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hotel.name,
            style: AppTextStyles.h4.copyWith(color: AppColors.navyDark),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            hotel.roomType,
            style: AppTextStyles.bodySM.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: hotel.amenities.take(3).map((amenity) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  amenity,
                  style: AppTextStyles.labelSM.copyWith(
                    fontSize: 11,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
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
                    'STARTING FROM',
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.textLightMuted,
                      fontSize: 9,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${hotel.currency} ${hotel.price.toInt()}',
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.royalBlueDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        ' / night',
                        style: AppTextStyles.bodySM.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => context.goNamed(AppRoutes.contactName),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isHovered ? AppColors.gold : AppColors.navy,
                  foregroundColor: _isHovered ? AppColors.navyDark : AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: Text(
                  'Book Room',
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
    );
  }
}

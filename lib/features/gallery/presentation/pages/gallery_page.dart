import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/animations/animation_widgets.dart';
import '../../../../data/models/gallery_model.dart';
import '../../../../data/repositories/gallery_repository.dart';
import '../../../../shared/presentation/widgets/app_navbar.dart';
import '../../../../shared/presentation/widgets/app_footer.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final GalleryRepository _repository = GalleryRepository();
  List<GalleryModel> _allItems = [];
  List<GalleryModel> _filteredItems = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Beach',
    'Adventure',
    'Culture',
    'Luxury',
    'Desert',
    'Nature',
  ];

  @override
  void initState() {
    super.initState();
    _loadGallery();
  }

  Future<void> _loadGallery() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _repository.getGalleryItems();
      if (mounted) {
        setState(() {
          _allItems = list;
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
    var result = List<GalleryModel>.from(_allItems);
    if (_selectedCategory != 'All') {
      result = result.where((g) => g.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
    }
    setState(() {
      _filteredItems = result;
    });
  }

  void _openLightbox(int initialIndex) {
    if (_filteredItems.isEmpty) return;
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.95),
      builder: (ctx) => _GalleryLightboxDialog(
        items: _filteredItems,
        initialIndex: initialIndex,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hPad = AppBreakpoints.horizontalPadding(context);
    final isMobile = AppBreakpoints.isMobile(context);
    final columns = isMobile ? 1 : (AppBreakpoints.isTablet(context) ? 2 : (AppBreakpoints.isDesktop(context) ? 3 : 4));

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: CustomScrollView(
        slivers: [
          // ── Navbar ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: AppNavbar(currentRoute: AppRoutes.gallery),
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
                        'TRAVEL PHOTOGRAPHY',
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
                      'Visual Stories & Gallery',
                      style: (isMobile ? AppTextStyles.h2 : AppTextStyles.h1).copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Explore moments captured across our destinations worldwide by Travella travelers and guides.',
                      style: AppTextStyles.bodyLG.copyWith(
                        color: AppColors.textOnDarkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Category Filter Bar ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.white,
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 18),
              child: MaxWidthContainer(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSel = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: FilterChip(
                          label: Text(cat),
                          selected: isSel,
                          onSelected: (_) {
                            setState(() => _selectedCategory = cat);
                            _applyFilter();
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
              Text('Loading gallery from Supabase...', style: TextStyle(color: AppColors.textSecondary)),
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
              Text('Failed to load gallery', style: AppTextStyles.h4),
              const SizedBox(height: 6),
              Text(_errorMessage!, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              TravellaButton(
                label: 'Retry',
                variant: TravellaButtonVariant.primary,
                onPressed: _loadGallery,
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredItems.isEmpty) {
      return SizedBox(
        height: 350,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.photo_library_outlined, color: AppColors.gray400, size: 56),
              const SizedBox(height: 16),
              Text('No gallery images available at the moment.', style: AppTextStyles.h4),
              const SizedBox(height: 8),
              const Text('Please check back soon as we add new visual stories.', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              TravellaButton(
                label: 'Show All Photos',
                variant: TravellaButtonVariant.secondary,
                onPressed: () {
                  setState(() => _selectedCategory = 'All');
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
        mainAxisExtent: isMobile ? 260 : 300,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: _filteredItems.length,
      itemBuilder: (context, i) {
        return ScaleInOnScroll(
          delay: Duration(milliseconds: (i % 4) * 50),
          child: _GalleryTile(
            item: _filteredItems[i],
            onTap: () => _openLightbox(i),
          ),
        );
      },
    );
  }
}

class _GalleryTile extends StatefulWidget {
  final GalleryModel item;
  final VoidCallback onTap;

  const _GalleryTile({required this.item, required this.onTap});

  @override
  State<_GalleryTile> createState() => _GalleryTileState();
}

class _GalleryTileState extends State<_GalleryTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? AppColors.navy.withValues(alpha: 0.22)
                    : AppColors.navy.withValues(alpha: 0.05),
                blurRadius: _isHovered ? 28 : 12,
                offset: Offset(0, _isHovered ? 12 : 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedScale(
                  scale: _isHovered ? 1.08 : 1.0,
                  duration: const Duration(milliseconds: 400),
                  child: Image.network(
                    widget.item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.navyMedium,
                      child: const Icon(Icons.image_outlined, color: AppColors.gray400),
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: _isHovered ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.navyDark.withValues(alpha: 0.88),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: AnimatedOpacity(
                    opacity: _isHovered ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.item.title,
                          style: AppTextStyles.labelLG.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.item.destination.isNotEmpty || widget.item.country.isNotEmpty)
                          Text(
                            '${widget.item.destination}${widget.item.destination.isNotEmpty && widget.item.country.isNotEmpty ? ", " : ""}${widget.item.country}',
                            style: AppTextStyles.bodySM.copyWith(
                              color: AppColors.goldLight,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (_isHovered)
                  const Center(
                    child: Icon(Icons.zoom_in_rounded, color: AppColors.gold, size: 40),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GalleryLightboxDialog extends StatefulWidget {
  final List<GalleryModel> items;
  final int initialIndex;

  const _GalleryLightboxDialog({
    required this.items,
    required this.initialIndex,
  });

  @override
  State<_GalleryLightboxDialog> createState() => _GalleryLightboxDialogState();
}

class _GalleryLightboxDialogState extends State<_GalleryLightboxDialog> {
  late int _currentIndex;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentIndex < widget.items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _prev() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.items[_currentIndex];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemCount: widget.items.length,
            itemBuilder: (context, i) {
              return Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 3.5,
                  child: Image.network(
                    widget.items[i].imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.items.length} — ${current.title}',
                    style: AppTextStyles.labelLG.copyWith(color: AppColors.white),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          if (_currentIndex > 0)
            Positioned(
              left: 20,
              top: 0,
              bottom: 0,
              child: Center(
                child: _NavBtn(
                  icon: Icons.chevron_left_rounded,
                  onTap: _prev,
                ),
              ),
            ),
          if (_currentIndex < widget.items.length - 1)
            Positioned(
              right: 20,
              top: 0,
              bottom: 0,
              child: Center(
                child: _NavBtn(
                  icon: Icons.chevron_right_rounded,
                  onTap: _next,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: AppColors.white, size: 30),
      ),
    );
  }
}

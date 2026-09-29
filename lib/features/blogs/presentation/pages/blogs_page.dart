import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/animations/animation_widgets.dart';
import '../../../../data/models/blog_model.dart';
import '../../../../data/repositories/blog_repository.dart';
import '../../../../shared/presentation/widgets/app_navbar.dart';
import '../../../../shared/presentation/widgets/app_footer.dart';

class BlogsPage extends StatefulWidget {
  const BlogsPage({super.key});

  @override
  State<BlogsPage> createState() => _BlogsPageState();
}

class _BlogsPageState extends State<BlogsPage> {
  final BlogRepository _repository = BlogRepository();
  List<BlogModel> _allBlogs = [];
  List<BlogModel> _filteredBlogs = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Destinations',
    'Travel Tips',
    'Hajj & Umrah',
    'Culture & Heritage',
    'Luxury Travel',
  ];

  @override
  void initState() {
    super.initState();
    _loadBlogs();
  }

  Future<void> _loadBlogs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _repository.getAllBlogs(publishedOnly: true);
      if (mounted) {
        setState(() {
          _allBlogs = list;
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
    var result = List<BlogModel>.from(_allBlogs);

    if (_selectedCategory != 'All') {
      final cat = _selectedCategory.toLowerCase();
      result = result.where((b) =>
          b.category.toLowerCase().contains(cat) ||
          b.tags.any((t) => t.toLowerCase().contains(cat))).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      result = result.where((b) =>
          b.title.toLowerCase().contains(q) ||
          b.content.toLowerCase().contains(q) ||
          b.excerpt.toLowerCase().contains(q)).toList();
    }

    setState(() {
      _filteredBlogs = result;
    });
  }

  void _readArticle(BlogModel blog) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 750),
          child: Column(
            children: [
              // Header Image
              SizedBox(
                height: 240,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: Image.network(
                        blog.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: AppColors.navyMedium),
                      ),
                    ),
                    Positioned(
                      top: 14,
                      right: 14,
                      child: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: AppColors.white, size: 20),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ),
                    Positioned(
                      bottom: 14,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.navyDark.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          blog.category,
                          style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(blog.authorAvatar.isNotEmpty
                                ? blog.authorAvatar
                                : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80'),
                          ),
                          const SizedBox(width: 10),
                          Text(blog.authorName, style: AppTextStyles.labelMD.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 14),
                          Text('• ${blog.publishedAt} • ${blog.readTime}', style: const TextStyle(color: AppColors.gray600, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(blog.title, style: AppTextStyles.h3.copyWith(color: AppColors.navyDark)),
                      if (blog.titleAr != null && blog.titleAr!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(blog.titleAr!, style: AppTextStyles.bodyLG.copyWith(color: AppColors.textSecondary), textDirection: TextDirection.rtl),
                      ],
                      const SizedBox(height: 20),
                      const Divider(color: AppColors.borderLight),
                      const SizedBox(height: 20),
                      Text(
                        blog.content,
                        style: AppTextStyles.bodyLG.copyWith(color: AppColors.textPrimary, height: 1.7),
                      ),
                      if (blog.contentAr != null && blog.contentAr!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Divider(color: AppColors.borderLight),
                        const SizedBox(height: 20),
                        Text(
                          blog.contentAr!,
                          style: AppTextStyles.bodyLG.copyWith(color: AppColors.textSecondary, height: 1.7),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
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
            child: AppNavbar(currentRoute: AppRoutes.blog),
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
                        'EDITORIAL JOURNAL',
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
                      'Travel Journal & Guides',
                      style: (isMobile ? AppTextStyles.h2 : AppTextStyles.h1).copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Inspiring narratives, packing essentials, cultural deep dives, and expert destination guides.',
                      style: AppTextStyles.bodyLG.copyWith(
                        color: AppColors.textOnDarkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Search & Filter ──────────────────────────────────────────────
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
                        hintText: 'Search articles, destinations, or travel tips...',
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
                        children: _categories.map((cat) {
                          final isSel = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: FilterChip(
                              label: Text(cat),
                              selected: isSel,
                              onSelected: (_) {
                                setState(() => _selectedCategory = cat);
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
              Text('Loading published articles...', style: TextStyle(color: AppColors.textSecondary)),
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
              Text('Failed to load articles', style: AppTextStyles.h4),
              const SizedBox(height: 6),
              Text(_errorMessage!, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              TravellaButton(
                label: 'Retry',
                variant: TravellaButtonVariant.primary,
                onPressed: _loadBlogs,
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredBlogs.isEmpty) {
      return SizedBox(
        height: 350,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.article_outlined, color: AppColors.gray400, size: 56),
              const SizedBox(height: 16),
              Text('No published articles found.', style: AppTextStyles.h4),
              const SizedBox(height: 8),
              const Text('Check back soon for fresh travel inspiration and guides.', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              TravellaButton(
                label: 'Show All Articles',
                variant: TravellaButtonVariant.secondary,
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _selectedCategory = 'All';
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
        mainAxisExtent: isMobile ? 430 : 460,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: _filteredBlogs.length,
      itemBuilder: (context, i) {
        return ScaleInOnScroll(
          delay: Duration(milliseconds: (i % 3) * 60),
          child: _BlogPageCard(
            blog: _filteredBlogs[i],
            onRead: () => _readArticle(_filteredBlogs[i]),
          ),
        );
      },
    );
  }
}

class _BlogPageCard extends StatefulWidget {
  final BlogModel blog;
  final VoidCallback onRead;

  const _BlogPageCard({required this.blog, required this.onRead});

  @override
  State<_BlogPageCard> createState() => _BlogPageCardState();
}

class _BlogPageCardState extends State<_BlogPageCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final blog = widget.blog;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onRead,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0.0, _isHovered ? -6.0 : 0.0, 0.0),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered ? AppColors.royalBlue.withValues(alpha: 0.4) : AppColors.borderLight,
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
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
                        child: Image.network(
                          blog.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.navyMedium,
                            child: const Icon(Icons.article_outlined, color: AppColors.gray400),
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
                          ),
                          child: Text(
                            blog.category,
                            style: AppTextStyles.labelSM.copyWith(color: AppColors.goldLight),
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
                          children: [
                            const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textLightMuted),
                            const SizedBox(width: 4),
                            Text(
                              '${blog.publishedAt} • ${blog.readTime}',
                              style: AppTextStyles.bodySM.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          blog.title,
                          style: AppTextStyles.h5.copyWith(color: AppColors.navyDark),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          blog.excerpt,
                          style: AppTextStyles.bodySM.copyWith(color: AppColors.textSecondary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        const Divider(color: AppColors.borderLight, height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundImage: NetworkImage(blog.authorAvatar.isNotEmpty
                                      ? blog.authorAvatar
                                      : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80'),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  blog.authorName,
                                  style: AppTextStyles.labelSM.copyWith(color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Read Story',
                                  style: AppTextStyles.labelMD.copyWith(
                                    color: _isHovered ? AppColors.royalBlue : AppColors.navy,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: _isHovered ? AppColors.royalBlue : AppColors.navy,
                                ),
                              ],
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

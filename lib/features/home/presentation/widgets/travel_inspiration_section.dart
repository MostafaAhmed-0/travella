import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/animations/animation_widgets.dart';
import '../../../../data/models/blog_model.dart';
import '../../../../data/repositories/hajj_umrah_repository.dart';

class TravelInspirationSection extends StatefulWidget {
  const TravelInspirationSection({super.key});

  @override
  State<TravelInspirationSection> createState() =>
      _TravelInspirationSectionState();
}

class _TravelInspirationSectionState extends State<TravelInspirationSection> {
  final BlogRepository _repository = const BlogRepository();
  List<BlogModel> _blogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBlogs();
  }

  Future<void> _loadBlogs() async {
    final list = await _repository.getBlogs();
    if (mounted) {
      setState(() {
        _blogs = list;
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
      color: AppColors.surfaceLight,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: isMobile ? 60 : 100),
      child: MaxWidthContainer(
        child: Column(
          children: [
            SlideInOnScroll(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: SectionHeader(
                      badge: 'Travel Inspiration & Guides',
                      title: 'Stories From Around the World',
                      subtitle: 'Insider guides, destination tips, and curated travel narratives from our globe-trotting editors.',
                    ),
                  ),
                  if (!isMobile)
                    TravellaButton(
                      label: 'Read All Articles',
                      variant: TravellaButtonVariant.secondary,
                      trailingIcon: Icons.arrow_forward_rounded,
                      onPressed: () => context.goNamed(AppRoutes.blogName),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(color: AppColors.royalBlue),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisExtent: isMobile ? 420 : 450,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                itemCount: _blogs.length,
                itemBuilder: (context, i) {
                  return ScaleInOnScroll(
                    delay: Duration(milliseconds: i * 100),
                    child: _BlogCard(blog: _blogs[i]),
                  );
                },
              ),

            if (isMobile) ...[
              const SizedBox(height: 32),
              TravellaButton(
                label: 'Read All Articles',
                variant: TravellaButtonVariant.secondary,
                fullWidth: true,
                trailingIcon: Icons.arrow_forward_rounded,
                onPressed: () => context.goNamed(AppRoutes.blogName),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BlogCard extends StatefulWidget {
  final BlogModel blog;
  const _BlogCard({required this.blog});

  @override
  State<_BlogCard> createState() => _BlogCardState();
}

class _BlogCardState extends State<_BlogCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final blog = widget.blog;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => context.goNamed(AppRoutes.blogName),
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
                                  backgroundImage: NetworkImage(blog.authorAvatar),
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

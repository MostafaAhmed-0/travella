import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/animations/animation_widgets.dart';
import '../../../../data/models/testimonial_model.dart';
import '../../../../data/repositories/testimonial_repository.dart';

class TestimonialsSection extends StatefulWidget {
  const TestimonialsSection({super.key});

  @override
  State<TestimonialsSection> createState() => _TestimonialsSectionState();
}

class _TestimonialsSectionState extends State<TestimonialsSection> {
  final TestimonialRepository _repository = TestimonialRepository();
  List<TestimonialModel> _testimonials = [];
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadTestimonials();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadTestimonials() async {
    final list = await _repository.getFeaturedTestimonials();
    if (mounted) {
      setState(() {
        _testimonials = list;
      });
    }
  }

  void _nextTestimonial() {
    if (_currentIndex < _testimonials.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _prevTestimonial() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hPad = AppBreakpoints.horizontalPadding(context);
    final isMobile = AppBreakpoints.isMobile(context);

    return Container(
      color: AppColors.white,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: isMobile ? 60 : 100),
      child: MaxWidthContainer(
        child: Column(
          children: [
            SlideInOnScroll(
              child: const SectionHeader(
                badge: 'Traveler Stories',
                title: 'Trusted by Discerning Travelers',
                subtitle: 'Real experiences from VIP travelers, honeymooners, and families who explored the world with Travella.',
                alignment: CrossAxisAlignment.center,
              ),
            ),
            const SizedBox(height: 48),

            if (_testimonials.isEmpty)
              const Center(child: CircularProgressIndicator(color: AppColors.royalBlue))
            else
              SizedBox(
                height: isMobile ? 380 : 300,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentIndex = i),
                  itemCount: _testimonials.length,
                  itemBuilder: (context, i) {
                    final item = _testimonials[i];
                    return _TestimonialCard(testimonial: item, isMobile: isMobile);
                  },
                ),
              ),

            const SizedBox(height: 28),

            // Carousel Navigation Dots & Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: AppColors.navy),
                  onPressed: _prevTestimonial,
                ),
                const SizedBox(width: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_testimonials.length, (index) {
                    final isSelected = _currentIndex == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isSelected ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.gold : AppColors.gray300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.navy),
                  onPressed: _nextTestimonial,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final TestimonialModel testimonial;
  final bool isMobile;

  const _TestimonialCard({
    required this.testimonial,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: EdgeInsets.all(isMobile ? 24 : 36),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundImage: NetworkImage(testimonial.avatarUrl),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            testimonial.clientName,
                            style: AppTextStyles.h5.copyWith(color: AppColors.navyDark),
                          ),
                          if (testimonial.isVerified) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.verified_rounded, size: 16, color: AppColors.royalBlue),
                          ],
                        ],
                      ),
                      Text(
                        '${testimonial.clientRole} • ${testimonial.tripName}',
                        style: AppTextStyles.bodySM.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              if (!isMobile)
                RatingStars(rating: testimonial.rating, size: 18),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Text(
              '“${testimonial.reviewText}”',
              style: AppTextStyles.bodyLG.copyWith(
                color: AppColors.navyDark,
                fontStyle: FontStyle.italic,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

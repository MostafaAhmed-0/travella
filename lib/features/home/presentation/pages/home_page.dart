import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../shared/presentation/widgets/app_navbar.dart';
import '../../../../shared/presentation/widgets/app_footer.dart';

import '../../../../core/responsive/app_breakpoints.dart';

// Modular Home Widgets
import '../widgets/home_hero_section.dart';
import '../widgets/partners_section.dart';
import '../widgets/why_travella_section.dart';
import '../widgets/featured_destinations_section.dart';
import '../widgets/domestic_tours_section.dart';
import '../widgets/international_tours_section.dart';
import '../widgets/visa_services_section.dart';
import '../widgets/luxury_hotels_section.dart';
import '../widgets/hajj_umrah_section.dart';
import '../widgets/customized_trip_section.dart';
import '../widgets/testimonials_section.dart';
import '../widgets/travel_inspiration_section.dart';
import '../widgets/gallery_section.dart';
import '../widgets/final_cta_section.dart';

/// The comprehensive, luxury landing page for Travella Tour & Travel
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        slivers: [
          // ── Sticky / Top Navbar ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: AppNavbar(currentRoute: AppRoutes.home),
          ),

          // ── 1. Hero Section + Logo Flight Animation + Floating Planner ───
          const SliverToBoxAdapter(
            child: HomeHeroSection(),
          ),

          // ── Spacer for Floating Planner Bottom Overhang ──────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: AppBreakpoints.isMobile(context) ? 160 : 70,
            ),
          ),

          // ── 2. Partners Infinite Marquee ─────────────────────────────────
          const SliverToBoxAdapter(
            child: PartnersSection(),
          ),

          // ── 3. Why Travella ──────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: WhyTravellaSection(),
          ),

          // ── 4. Featured Destinations (Filterable Grid) ───────────────────
          const SliverToBoxAdapter(
            child: FeaturedDestinationsSection(),
          ),

          // ── 5. Domestic Tours ("Discover Egypt") ─────────────────────────
          const SliverToBoxAdapter(
            child: DomesticToursSection(),
          ),

          // ── 6. International Tours (Animated Horizontal Carousel) ────────
          const SliverToBoxAdapter(
            child: InternationalToursSection(),
          ),

          // ── 7. Visa Services & Interactive Country Checklist ─────────────
          const SliverToBoxAdapter(
            child: VisaServicesSection(),
          ),

          // ── 8. Luxury Hotels & Resorts ───────────────────────────────────
          const SliverToBoxAdapter(
            child: LuxuryHotelsSection(),
          ),

          // ── 9. Hajj & Umrah Spiritual Journeys ───────────────────────────
          const SliverToBoxAdapter(
            child: HajjUmrahSection(),
          ),

          // ── 10. Customized Trips (Animated 4-Step Timeline) ──────────────
          const SliverToBoxAdapter(
            child: CustomizedTripSection(),
          ),

          // ── 11. Testimonials (VIP Review Carousel) ───────────────────────
          const SliverToBoxAdapter(
            child: TestimonialsSection(),
          ),

          // ── 12. Travel Inspiration & Editorial Guides ────────────────────
          const SliverToBoxAdapter(
            child: TravelInspirationSection(),
          ),

          // ── 13. Gallery with Interactive Lightbox Viewer ─────────────────
          const SliverToBoxAdapter(
            child: GallerySection(),
          ),

          // ── 14. Final Cinematic Call-to-Action ───────────────────────────
          const SliverToBoxAdapter(
            child: FinalCtaSection(),
          ),

          // ── 15. Rich Footer ──────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: AppFooter(),
          ),
        ],
      ),
    );
  }
}

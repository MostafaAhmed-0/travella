import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import 'auth_guard.dart';
import 'route_transitions.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/admin/presentation/pages/admin_shell_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_overview_page.dart';
import '../../features/admin/presentation/pages/admin_tours_page.dart';
import '../../features/admin/presentation/pages/admin_destinations_page.dart';
import '../../features/admin/presentation/pages/admin_hotels_page.dart';
import '../../features/admin/presentation/pages/admin_visa_page.dart';
import '../../features/admin/presentation/pages/admin_hajj_umrah_page.dart';
import '../../features/admin/presentation/pages/admin_gallery_page.dart';
import '../../features/admin/presentation/pages/admin_blogs_page.dart';
import '../../features/admin/presentation/pages/admin_testimonials_page.dart';
import '../../features/admin/presentation/pages/admin_partners_page.dart';
import '../../features/admin/presentation/pages/admin_bookings_page.dart';
import '../../features/admin/presentation/pages/admin_customers_page.dart';
import '../../features/admin/presentation/pages/admin_settings_page.dart';
import '../../features/destinations/presentation/pages/destinations_page.dart';
import '../../features/domestic_tours/presentation/pages/domestic_tours_page.dart';
import '../../features/international_tours/presentation/pages/international_tours_page.dart';
import '../../features/visa_services/presentation/pages/visa_services_page.dart';
import '../../features/hotels/presentation/pages/hotels_page.dart';
import '../../features/hajj_umrah/presentation/pages/hajj_umrah_page.dart';
import '../../features/gallery/presentation/pages/gallery_page.dart';
import '../../features/blogs/presentation/pages/blogs_page.dart';
import '../../features/contact/presentation/pages/contact_page.dart';
import '../../features/bookings/presentation/pages/booking_page.dart';
import '../../features/tours/presentation/pages/tour_details_page.dart';
import '../../shared/presentation/pages/not_found_page.dart';

/// Helper to bridge Stream/Cubit with GoRouter's refreshListenable
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Central router configuration using GoRouter with Auth and Admin route protection
class AppRouter {
  AppRouter._();

  static GoRouter createRouter(AuthCubit authCubit) {
    return GoRouter(
      initialLocation: AppRoutes.login,
      debugLogDiagnostics: false,
      refreshListenable: GoRouterRefreshStream(authCubit.stream),
      errorBuilder: (context, state) => const NotFoundPage(),
      redirect: (context, state) {
        final currentPath = state.matchedLocation;
        return RoleGuard.guardRedirect(context, currentPath, authCubit);
      },
      routes: [
        // ── Public Routes ───────────────────────────────────────────────────
        GoRoute(
          path: AppRoutes.home,
          name: AppRoutes.homeName,
          pageBuilder: (context, state) =>
              buildPageTransition(key: state.pageKey, child: const HomePage()),
        ),
        GoRoute(
          path: AppRoutes.destinations,
          name: AppRoutes.destinationsName,
          pageBuilder: (context, state) => buildPageTransition(
            key: state.pageKey,
            child: const DestinationsPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.domesticTours,
          name: AppRoutes.domesticToursName,
          pageBuilder: (context, state) => buildPageTransition(
            key: state.pageKey,
            child: const DomesticToursPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.internationalTours,
          name: AppRoutes.internationalToursName,
          pageBuilder: (context, state) => buildPageTransition(
            key: state.pageKey,
            child: const InternationalToursPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.visaServices,
          name: AppRoutes.visaServicesName,
          pageBuilder: (context, state) => buildPageTransition(
            key: state.pageKey,
            child: const VisaServicesPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.hotels,
          name: AppRoutes.hotelsName,
          pageBuilder: (context, state) => buildPageTransition(
            key: state.pageKey,
            child: const HotelsPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.hajjUmrah,
          name: AppRoutes.hajjUmrahName,
          pageBuilder: (context, state) => buildPageTransition(
            key: state.pageKey,
            child: const HajjUmrahPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.gallery,
          name: AppRoutes.galleryName,
          pageBuilder: (context, state) => buildPageTransition(
            key: state.pageKey,
            child: const GalleryPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.blog,
          name: AppRoutes.blogName,
          pageBuilder: (context, state) =>
              buildPageTransition(key: state.pageKey, child: const BlogsPage()),
        ),
        GoRoute(
          path: AppRoutes.contact,
          name: AppRoutes.contactName,
          pageBuilder: (context, state) => buildPageTransition(
            key: state.pageKey,
            child: const ContactPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.booking,
          name: AppRoutes.bookingName,
          pageBuilder: (context, state) {
            final tourId = state.uri.queryParameters['tourId'] ??
                (state.extra is String ? state.extra as String : null);
            return buildPageTransition(
              key: state.pageKey,
              child: BookingPage(preselectedTourId: tourId),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.tourDetails,
          name: AppRoutes.tourDetailsName,
          pageBuilder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return buildPageTransition(
              key: state.pageKey,
              child: TourDetailsPage(tourId: id),
            );
          },
        ),

        // ── Auth Routes ─────────────────────────────────────────────────────
        GoRoute(
          path: AppRoutes.login,
          name: AppRoutes.loginName,
          pageBuilder: (context, state) =>
              buildPageTransition(key: state.pageKey, child: const LoginPage()),
        ),

        // ── Admin Shell ─────────────────────────────────────────────────────
        ShellRoute(
          builder: (context, state, child) => AdminShellPage(child: child),
          routes: [
            GoRoute(
              path: AppRoutes.adminDashboard,
              name: AppRoutes.adminDashboardName,
              pageBuilder: (context, state) => buildPageTransition(
                key: state.pageKey,
                child: const AdminDashboardOverviewPage(),
              ),
            ),
            GoRoute(
              path: AppRoutes.adminTours,
              name: AppRoutes.adminToursName,
              pageBuilder: (context, state) => buildPageTransition(
                key: state.pageKey,
                child: const AdminToursPage(),
              ),
            ),
            GoRoute(
              path: AppRoutes.adminDestinations,
              name: AppRoutes.adminDestinationsName,
              pageBuilder: (context, state) => buildPageTransition(
                key: state.pageKey,
                child: const AdminDestinationsPage(),
              ),
            ),
            GoRoute(
              path: AppRoutes.adminHotels,
              name: AppRoutes.adminHotelsName,
              pageBuilder: (context, state) => buildPageTransition(
                key: state.pageKey,
                child: const AdminHotelsPage(),
              ),
            ),
            GoRoute(
              path: AppRoutes.adminVisa,
              name: AppRoutes.adminVisaName,
              pageBuilder: (context, state) => buildPageTransition(
                key: state.pageKey,
                child: const AdminVisaPage(),
              ),
            ),
            GoRoute(
              path: AppRoutes.adminHajjUmrah,
              name: AppRoutes.adminHajjUmrahName,
              pageBuilder: (context, state) => buildPageTransition(
                key: state.pageKey,
                child: const AdminHajjUmrahPage(),
              ),
            ),
            GoRoute(
              path: AppRoutes.adminGallery,
              name: AppRoutes.adminGalleryName,
              pageBuilder: (context, state) => buildPageTransition(
                key: state.pageKey,
                child: const AdminGalleryPage(),
              ),
            ),
            GoRoute(
              path: AppRoutes.adminBlog,
              name: AppRoutes.adminBlogName,
              pageBuilder: (context, state) => buildPageTransition(
                key: state.pageKey,
                child: const AdminBlogsPage(),
              ),
            ),
            GoRoute(
              path: AppRoutes.adminTestimonials,
              name: AppRoutes.adminTestimonialsName,
              pageBuilder: (context, state) => buildPageTransition(
                key: state.pageKey,
                child: const AdminTestimonialsPage(),
              ),
            ),
            GoRoute(
              path: AppRoutes.adminPartners,
              name: AppRoutes.adminPartnersName,
              pageBuilder: (context, state) => buildPageTransition(
                key: state.pageKey,
                child: const AdminPartnersPage(),
              ),
            ),
            GoRoute(
              path: AppRoutes.adminBookings,
              name: AppRoutes.adminBookingsName,
              pageBuilder: (context, state) => buildPageTransition(
                key: state.pageKey,
                child: const AdminBookingsPage(),
              ),
            ),
            GoRoute(
              path: AppRoutes.adminCustomers,
              name: AppRoutes.adminCustomersName,
              pageBuilder: (context, state) => buildPageTransition(
                key: state.pageKey,
                child: const AdminCustomersPage(),
              ),
            ),
            GoRoute(
              path: AppRoutes.adminSettings,
              name: AppRoutes.adminSettingsName,
              pageBuilder: (context, state) => buildPageTransition(
                key: state.pageKey,
                child: const AdminSettingsPage(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

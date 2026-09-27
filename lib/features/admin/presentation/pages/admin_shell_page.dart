import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../data/repositories/tour_repository.dart';
import '../../../../data/repositories/booking_repository.dart';
import '../../../../data/repositories/destination_repository.dart';
import '../../../../data/repositories/hotel_repository.dart';
import '../../../../data/repositories/gallery_repository.dart';
import '../../../../data/repositories/blog_repository.dart';
import '../../../../data/repositories/partner_repository.dart';
import '../../../../data/repositories/testimonial_repository.dart';
import '../../../../data/repositories/visa_repository.dart';
import '../../../../data/repositories/storage_repository.dart';
import '../cubit/admin_stats_cubit.dart';
import '../cubit/admin_tours_cubit.dart';
import '../cubit/admin_destinations_cubit.dart';
import '../cubit/admin_hotels_cubit.dart';
import '../cubit/admin_visa_cubit.dart';
import '../cubit/admin_gallery_cubit.dart';
import '../cubit/admin_blogs_cubit.dart';
import '../cubit/admin_testimonials_cubit.dart';
import '../cubit/admin_partners_cubit.dart';
import '../cubit/admin_bookings_cubit.dart';
import '../widgets/admin_top_bar.dart';
import '../widgets/admin_sidebar.dart';

/// Master Shell for Travella Admin CMS
class AdminShellPage extends StatefulWidget {
  final Widget child;

  const AdminShellPage({super.key, required this.child});

  @override
  State<AdminShellPage> createState() => _AdminShellPageState();
}

class _AdminShellPageState extends State<AdminShellPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _getPageTitle(String? routeName) {
    switch (routeName) {
      case AppRoutes.adminDashboardName:
        return 'Dashboard Overview';
      case AppRoutes.adminToursName:
        return 'Tours Management';
      case AppRoutes.adminDestinationsName:
        return 'Destinations';
      case AppRoutes.adminHotelsName:
        return 'Hotels & Resorts';
      case AppRoutes.adminVisaName:
        return 'Visa Services';
      case AppRoutes.adminHajjUmrahName:
        return 'Hajj & Umrah';
      case AppRoutes.adminGalleryName:
        return 'Media Gallery';
      case AppRoutes.adminBlogName:
        return 'Blog & Articles';
      case AppRoutes.adminTestimonialsName:
        return 'Testimonials & Reviews';
      case AppRoutes.adminPartnersName:
        return 'Partners & Affiliates';
      case AppRoutes.adminBookingsName:
        return 'Bookings & Reservations';
      case AppRoutes.adminCustomersName:
        return 'Customer Directory';
      case AppRoutes.adminSettingsName:
        return 'System Settings';
      default:
        return 'Admin Portal';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppBreakpoints.isDesktop(context);
    final currentRouteName = GoRouterState.of(context).name;
    final pageTitle = _getPageTitle(currentRouteName);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AdminStatsCubit>(
          create: (ctx) => AdminStatsCubit(
            tourRepository: ctx.read<TourRepository>(),
            bookingRepository: ctx.read<BookingRepository>(),
            destinationRepository: ctx.read<DestinationRepository>(),
            hotelRepository: ctx.read<HotelRepository>(),
            galleryRepository: ctx.read<GalleryRepository>(),
            blogRepository: ctx.read<BlogRepository>(),
            partnerRepository: ctx.read<PartnerRepository>(),
            testimonialRepository: ctx.read<TestimonialRepository>(),
          )..loadDashboardStats(),
        ),
        BlocProvider<AdminToursCubit>(
          create: (ctx) => AdminToursCubit(
            tourRepository: ctx.read<TourRepository>(),
          ),
        ),
        BlocProvider<AdminDestinationsCubit>(
          create: (ctx) => AdminDestinationsCubit(
            destinationRepository: ctx.read<DestinationRepository>(),
          ),
        ),
        BlocProvider<AdminHotelsCubit>(
          create: (ctx) => AdminHotelsCubit(
            hotelRepository: ctx.read<HotelRepository>(),
          ),
        ),
        BlocProvider<AdminVisaCubit>(
          create: (ctx) => AdminVisaCubit(
            visaRepository: ctx.read<VisaRepository>(),
          ),
        ),
        BlocProvider<AdminGalleryCubit>(
          create: (ctx) => AdminGalleryCubit(
            galleryRepository: ctx.read<GalleryRepository>(),
            storageRepository: ctx.read<StorageRepository>(),
          ),
        ),
        BlocProvider<AdminBlogsCubit>(
          create: (ctx) => AdminBlogsCubit(
            blogRepository: ctx.read<BlogRepository>(),
          ),
        ),
        BlocProvider<AdminTestimonialsCubit>(
          create: (ctx) => AdminTestimonialsCubit(
            testimonialRepository: ctx.read<TestimonialRepository>(),
          ),
        ),
        BlocProvider<AdminPartnersCubit>(
          create: (ctx) => AdminPartnersCubit(
            partnerRepository: ctx.read<PartnerRepository>(),
          ),
        ),
        BlocProvider<AdminBookingsCubit>(
          create: (ctx) => AdminBookingsCubit(
            bookingRepository: ctx.read<BookingRepository>(),
          ),
        ),
      ],
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.lightGray,
        drawer: isDesktop
            ? null
            : Drawer(
                child: AdminSidebar(
                  onItemTapped: () => _scaffoldKey.currentState?.closeDrawer(),
                ),
              ),
        body: Row(
          children: [
            // Sticky Left Sidebar (Desktop only)
            if (isDesktop) const AdminSidebar(),

            // Main Content Area
            Expanded(
              child: Column(
                children: [
                  AdminTopBar(
                    title: pageTitle,
                    onToggleMenu: isDesktop
                        ? null
                        : () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

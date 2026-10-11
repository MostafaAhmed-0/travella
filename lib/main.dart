import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:travella/core/localization/app_locales.dart';
import 'package:travella/core/routing/app_router.dart';
import 'package:travella/core/theme/app_theme.dart';
import 'package:travella/data/repositories/auth_repository.dart';
import 'package:travella/data/repositories/booking_repository.dart';
import 'package:travella/data/repositories/destination_repository.dart';
import 'package:travella/data/repositories/hotel_repository.dart';
import 'package:travella/data/repositories/tour_repository.dart';
import 'package:travella/data/repositories/visa_repository.dart';
import 'package:travella/data/repositories/gallery_repository.dart';
import 'package:travella/data/repositories/blog_repository.dart';
import 'package:travella/data/repositories/testimonial_repository.dart';
import 'package:travella/data/repositories/partner_repository.dart';
import 'package:travella/data/repositories/storage_repository.dart';
import 'package:travella/data/repositories/site_settings_repository.dart';
import 'package:travella/features/site_settings/presentation/cubit/site_settings_cubit.dart';
import 'package:travella/data/repositories/airport_transfer_repository.dart';
import 'package:travella/data/services/supabase_service.dart';
import 'package:travella/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:travella/features/bookings/presentation/cubit/booking_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase Backend
  await SupabaseService.initialize();

  runApp(const TravellaApp());
}

class TravellaApp extends StatefulWidget {
  const TravellaApp({super.key});

  @override
  State<TravellaApp> createState() => _TravellaAppState();
}

class _TravellaAppState extends State<TravellaApp> {
  final LocaleManager _localeManager = LocaleManager();

  // Core repositories
  late final AuthRepository _authRepository;
  late final BookingRepository _bookingRepository;
  late final DestinationRepository _destinationRepository;
  late final TourRepository _tourRepository;
  late final HotelRepository _hotelRepository;
  late final VisaRepository _visaRepository;
  late final GalleryRepository _galleryRepository;
  late final BlogRepository _blogRepository;
  late final TestimonialRepository _testimonialRepository;
  late final PartnerRepository _partnerRepository;
  late final StorageRepository _storageRepository;
  late final AirportTransferRepository _transferRepository;
  late final SiteSettingsRepository _siteSettingsRepository;

  // Root Cubits
  late final AuthCubit _authCubit;
  late final BookingCubit _bookingCubit;
  late final SiteSettingsCubit _siteSettingsCubit;

  // GoRouter instance with role-based auth protection
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    // Instantiate Repositories
    _authRepository = AuthRepositoryImpl();
    _bookingRepository = BookingRepositoryImpl();
    _destinationRepository = DestinationRepository();
    _tourRepository = TourRepository();
    _hotelRepository = HotelRepository();
    _visaRepository = VisaRepository();
    _galleryRepository = GalleryRepository();
    _blogRepository = BlogRepository();
    _testimonialRepository = TestimonialRepository();
    _partnerRepository = PartnerRepository();
    _storageRepository = StorageRepositoryImpl();
    _transferRepository = AirportTransferRepository();
    _siteSettingsRepository = SiteSettingsRepositoryImpl();

    // Instantiate Cubits
    _authCubit = AuthCubit(authRepository: _authRepository);
    _bookingCubit = BookingCubit(bookingRepository: _bookingRepository);
    _siteSettingsCubit = SiteSettingsCubit(repository: _siteSettingsRepository);

    // Create Router with AuthCubit guard
    _router = AppRouter.createRouter(_authCubit);

    // Check user authentication status on startup
    _authCubit.checkAuth();
  }

  @override
  void dispose() {
    _localeManager.dispose();
    _authCubit.close();
    _bookingCubit.close();
    _siteSettingsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: _authRepository),
        RepositoryProvider<BookingRepository>.value(value: _bookingRepository),
        RepositoryProvider<DestinationRepository>.value(value: _destinationRepository),
        RepositoryProvider<TourRepository>.value(value: _tourRepository),
        RepositoryProvider<HotelRepository>.value(value: _hotelRepository),
        RepositoryProvider<VisaRepository>.value(value: _visaRepository),
        RepositoryProvider<GalleryRepository>.value(value: _galleryRepository),
        RepositoryProvider<BlogRepository>.value(value: _blogRepository),
        RepositoryProvider<TestimonialRepository>.value(value: _testimonialRepository),
        RepositoryProvider<PartnerRepository>.value(value: _partnerRepository),
        RepositoryProvider<StorageRepository>.value(value: _storageRepository),
        RepositoryProvider<AirportTransferRepository>.value(value: _transferRepository),
        RepositoryProvider<SiteSettingsRepository>.value(value: _siteSettingsRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: _authCubit),
          BlocProvider<BookingCubit>.value(value: _bookingCubit),
          BlocProvider<SiteSettingsCubit>.value(value: _siteSettingsCubit),
        ],
        child: ListenableBuilder(
          listenable: _localeManager,
          builder: (context, _) {
            return MaterialApp.router(
              // App Info
              title: 'Travella — Explore a Brighter World',
              debugShowCheckedModeBanner: false,

              // Theme
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.light,

              // Routing protected by Supabase Auth Guard
              routerConfig: _router,

              // Localization
              locale: _localeManager.locale,
              supportedLocales: AppLocales.supportedLocales,
              localizationsDelegates: AppLocales.delegates,

              // Directionality handled by MaterialApp via locale
              builder: (context, child) {
                return Directionality(
                  textDirection: _localeManager.isRtl
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  child: child ?? const SizedBox.shrink(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import '../../core/constants/app_constants.dart';

/// Supabase initialization and client singleton
class SupabaseService {
  SupabaseService._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: Level.info,
  );

  /// Initialize Supabase — must be called before runApp()
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: AppConstants.supabaseAnonKey,
        debug: false,
      );
      _logger.i('[Supabase] Initialized successfully');
    } catch (e, s) {
      _logger.e('[Supabase] Initialization failed', error: e, stackTrace: s);
    }
  }

  /// Supabase client
  static SupabaseClient get client => Supabase.instance.client;

  /// Auth client
  static GoTrueClient get auth => client.auth;

  /// Current session
  static Session? get currentSession => auth.currentSession;

  /// Current user
  static User? get currentUser => auth.currentUser;

  /// Is authenticated
  static bool get isAuthenticated => currentUser != null;

  // ── Storage Helpers ────────────────────────────────────────────────────────

  static String getPublicUrl(String bucket, String path) {
    return client.storage.from(bucket).getPublicUrl(path);
  }

  static String getTourImageUrl(String path) =>
      getPublicUrl(AppConstants.toursBucket, path);

  static String getDestinationImageUrl(String path) =>
      getPublicUrl(AppConstants.destinationsBucket, path);

  static String getHotelImageUrl(String path) =>
      getPublicUrl(AppConstants.hotelsBucket, path);

  static String getGalleryImageUrl(String path) =>
      getPublicUrl(AppConstants.galleryBucket, path);

  static String getBlogImageUrl(String path) =>
      getPublicUrl(AppConstants.blogsBucket, path);

  static String getPartnerLogoUrl(String path) =>
      getPublicUrl(AppConstants.partnersBucket, path);

  // ── Table Names ────────────────────────────────────────────────────────────
  static const String tableProfiles = 'profiles';
  static const String tableDestinations = 'destinations';
  static const String tableTours = 'tours';
  static const String tableTourImages = 'tour_images';
  static const String tableHotels = 'hotels';
  static const String tableVisaServices = 'visa_services';
  static const String tableVisaRequirements = 'visa_requirements';
  static const String tableVisaApplications = 'visa_applications';
  static const String tableBookings = 'bookings';
  static const String tableGallery = 'gallery';
  static const String tableBlogs = 'blogs';
  static const String tableTestimonials = 'testimonials';
  static const String tablePartners = 'partners';

  // ── Error Handler ──────────────────────────────────────────────────────────
  static String handleError(Object e) {
    if (e is PostgrestException) {
      _logger.e('[Supabase] DB Error: ${e.message}');
      return e.message;
    }
    if (e is AuthException) {
      _logger.e('[Supabase] Auth Error: ${e.message}');
      return e.message;
    }
    _logger.e('[Supabase] Unknown Error: $e');
    return 'An unexpected error occurred. Please try again.';
  }
}

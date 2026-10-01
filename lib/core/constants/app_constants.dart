/// App-wide constants for Travella Tour & Travel
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Travella';
  static const String appTagline = 'Explore a Brighter World';
  static const String appFullName = 'Travella Tour & Travel';
  static const String appVersion = '1.0.0';

  // Contact Info
  static const String appEmail = 'info@travella.com';
  static const String appPhone = '+1 (800) TRAVELLA';
  static const String appAddress = 'Your City, Country';
  static const String appWhatsapp = '+1234567890';

  // Social Links
  static const String instagramUrl = 'https://instagram.com/travella';
  static const String facebookUrl = 'https://facebook.com/travella';
  static const String twitterUrl = 'https://twitter.com/travella';
  static const String youtubeUrl = 'https://youtube.com/travella';

  // Supabase
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://gusemyjhonjvgafqaafb.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_NvLGwYeGiqZInT8Vuy_b3Q_d4JC254Z',
  );

  // Storage Buckets (Canonical bucket IDs in Supabase)
  static const String tourImagesBucket = 'tour-images';
  static const String toursBucket = 'tour-images';

  static const String destinationImagesBucket = 'destination-images';
  static const String destinationsBucket = 'destination-images';

  static const String hotelImagesBucket = 'hotel-images';
  static const String hotelsBucket = 'hotel-images';

  static const String galleryImagesBucket = 'gallery-images';
  static const String galleryBucket = 'gallery-images';

  static const String blogImagesBucket = 'blog-images';
  static const String blogsBucket = 'blog-images';

  static const String partnerLogosBucket = 'partner-logos';
  static const String partnersBucket = 'partner-logos';

  // Pagination
  static const int defaultPageSize = 12;
  static const int searchDebounceMs = 400;

  // Animation Durations
  static const int fastAnimationMs = 200;
  static const int normalAnimationMs = 400;
  static const int slowAnimationMs = 700;
  static const int pageTransitionMs = 500;

  // UI Sizes
  static const double navbarHeight = 80.0;
  static const double footerHeight = 320.0;
  static const double heroMinHeight = 600.0;
  static const double sectionPaddingVertical = 96.0;
  static const double sectionPaddingHorizontal = 24.0;
  static const double maxContentWidth = 1280.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  static const double inputBorderRadius = 12.0;

  // Breakpoints (must be in sync with AppBreakpoints)
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopBreakpoint = 1280.0;

  // Cache Keys
  static const String themeKey = 'app_theme';
  static const String localeKey = 'app_locale';
  static const String userKey = 'user_data';
  static const String tokenKey = 'auth_token';

  // Booking & Traveler Constraints
  static const int minAdults = 1;
  static const int maxAdults = 30;
  static const int minChildren = 0;
  static const int maxChildren = 20;
  static const int minChildAge = 0; // 0 = infant / under 1 year
  static const int maxChildAge = 17;
  static const int defaultAdults = 2;
  static const int defaultChildren = 0;
}

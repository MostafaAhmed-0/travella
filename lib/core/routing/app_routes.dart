/// Route path constants for Travella
class AppRoutes {
  AppRoutes._();

  // ── Public ──────────────────────────────────────────────────────────────────
  static const String home = '/';
  static const String homeName = 'home';

  static const String about = '/about';
  static const String aboutName = 'about';

  static const String destinations = '/destinations';
  static const String destinationsName = 'destinations';

  static const String domesticTours = '/domestic-tours';
  static const String domesticToursName = 'domestic-tours';

  static const String internationalTours = '/international-tours';
  static const String internationalToursName = 'international-tours';

  static const String visaServices = '/visa-services';
  static const String visaServicesName = 'visa-services';

  static const String hotels = '/hotels';
  static const String hotelsName = 'hotels';

  static const String hajjUmrah = '/hajj-umrah';
  static const String hajjUmrahName = 'hajj-umrah';

  static const String gallery = '/gallery';
  static const String galleryName = 'gallery';

  static const String blog = '/blog';
  static const String blogName = 'blog';

  static const String contact = '/contact';
  static const String contactName = 'contact';

  static const String booking = '/booking';
  static const String bookingName = 'booking';
  static const String bookingWithTourId = '/booking/:tourId';
  static const String bookingWithTourIdName = 'booking-tour';

  static const String tourDetails = '/tours/:id';
  static const String tourDetailsName = 'tour-details';

  // ── Auth ───────────────────────────────────────────────────────────────────
  static const String login = '/login';
  static const String loginName = 'login';

  // ── Admin ──────────────────────────────────────────────────────────────────
  static const String adminDashboard = '/admin';
  static const String adminDashboardName = 'admin';

  static const String adminTours = '/admin/tours';
  static const String adminToursName = 'admin-tours';

  static const String adminDestinations = '/admin/destinations';
  static const String adminDestinationsName = 'admin-destinations';

  static const String adminHotels = '/admin/hotels';
  static const String adminHotelsName = 'admin-hotels';

  static const String adminVisa = '/admin/visa';
  static const String adminVisaName = 'admin-visa';

  static const String adminHajjUmrah = '/admin/hajj-umrah';
  static const String adminHajjUmrahName = 'admin-hajj-umrah';

  static const String adminGallery = '/admin/gallery';
  static const String adminGalleryName = 'admin-gallery';

  static const String adminBlog = '/admin/blog';
  static const String adminBlogName = 'admin-blog';

  static const String adminTestimonials = '/admin/testimonials';
  static const String adminTestimonialsName = 'admin-testimonials';

  static const String adminPartners = '/admin/partners';
  static const String adminPartnersName = 'admin-partners';

  static const String adminBookings = '/admin/bookings';
  static const String adminBookingsName = 'admin-bookings';

  static const String adminCustomers = '/admin/customers';
  static const String adminCustomersName = 'admin-customers';

  static const String adminSettings = '/admin/settings';
  static const String adminSettingsName = 'admin-settings';
}

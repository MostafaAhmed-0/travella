import 'package:flutter/material.dart';
import 'app_locales.dart';

/// Complete bilingual translation dictionary for Travella (English & Arabic)
class AppTranslations {
  AppTranslations._();

  static const Map<String, Map<String, String>> _values = {
    'en': {
      // App Branding
      'app_name': 'TRAVELLA',
      'app_tagline': 'TOUR & TRAVEL',
      'app_slogan': 'Explore a Brighter World',

      // Navbar & Navigation
      'nav_home': 'Home',
      'nav_flights': 'Flights',
      'nav_destinations': 'Destinations',
      'nav_domestic_tours': 'Domestic Tours',
      'nav_international_tours': 'International',
      'nav_visa_services': 'Visa Services',
      'nav_hotels': 'Hotels',
      'nav_airport_transfers': 'Airport Transfers',
      'nav_hajj_umrah': 'Hajj & Umrah',
      'nav_gallery': 'Gallery',
      'nav_blog': 'Blog',
      'nav_contact': 'Contact',
      'nav_book_now': 'Book Now',
      'nav_admin': 'Admin CMS',
      'nav_menu': 'Menu',

      // Airport Transfers
      'transfers_badge': 'PREMIUM VIP CHAUFFEUR & TRANSFERS',
      'transfers_hero_title': 'Seamless Airport & Luxury Private Transfers',
      'transfers_hero_subtitle':
          'Punctual, executive airport pick-up & drop-off with meet-and-greet service, real-time flight tracking, and transparent fixed pricing.',
      'transfers_search_title': 'Find Your Private Transfer',
      'transfers_pickup_loc': 'Pickup Location',
      'transfers_dropoff_loc': 'Drop-off Location',
      'transfers_pickup_date': 'Pickup Date',
      'transfers_pickup_time': 'Pickup Time',
      'transfers_passengers': 'Passengers',
      'transfers_luggage': 'Luggage Bags',
      'transfers_vehicle_type': 'Vehicle Type',
      'transfers_transfer_type': 'Transfer Route Type',
      'transfer_airport_to_hotel': 'Airport → Hotel',
      'transfer_hotel_to_airport': 'Hotel → Airport',
      'transfer_airport_to_airport': 'Airport → Airport',
      'transfer_custom': 'Custom Transfer',
      'transfers_book_btn': 'Book Transfer',
      'transfers_request_btn': 'Select / Request',
      'transfers_est_duration': 'Est. Duration',
      'transfers_capacity': 'Capacity',
      'transfers_bags': 'Luggage',
      'transfers_passengers_label': 'Seats',
      'transfers_child_ages': 'Child Ages',
      'transfers_special_requests': 'Special Requests / Notes',
      'transfers_flight_no': 'Flight Number (e.g. MS 777 / BA 155)',
      'transfers_booking_success_title': 'Transfer Request Received!',
      'transfers_booking_success_desc':
          'Thank you! Your transfer booking request has been registered. Our operations team will assign your chauffeur and confirm via WhatsApp/Email.',
      'transfers_filter_all': 'All Vehicles',
      'transfers_filter_sedan': 'Sedan',
      'transfers_filter_suv': 'SUV',
      'transfers_filter_van': 'Van',
      'transfers_filter_minibus': 'Minibus',
      'admin_transfers_title': 'Airport Transfers Management',

      // Hero Section
      'hero_badge': 'TRAVELLA TOUR & TRAVEL',
      'hero_title_line1': 'Explore A Brighter',
      'hero_title_line2': 'World With Us',
      'hero_subtitle':
          'Your journey starts here. Discover handpicked global destinations, luxury hotels, bespoke private tours, and complete visa assistance.',
      'hero_explore_btn': 'Explore Destinations',
      'hero_plan_btn': 'Plan Your Trip',

      // Flights Page & Features
      'flights_badge': 'PREMIUM AIR TRAVEL DESK',
      'flights_hero_title': 'World-Class Flights & Bespoke Routes',
      'flights_hero_subtitle':
          'Personalized flight booking desk offering direct airline routes, premium cabin fares, and 24/7 travel concierge assistance worldwide.',
      'trip_round_trip': 'Round Trip',
      'trip_one_way': 'One Way',
      'filter_stops': 'Stops',
      'filter_stops_any': 'Any',
      'filter_stops_nonstop': 'Non-stop',
      'filter_stops_1stop': '1 Stop',
      'filter_stops_2plus': '2+ Stops',
      'filter_airlines': 'Airlines',
      'filter_departure_time': 'Departure Time',
      'filter_arrival_time': 'Arrival Time',
      'filter_price_range': 'Price Range',
      'filter_duration': 'Flight Duration',
      'filter_reset': 'Reset Filters',
      'filter_sort_by': 'Sort By',
      'flight_search_btn': 'Search Flights',
      'flight_card_details': 'View Details',
      'flight_card_select': 'Select / Inquire',
      'flight_card_nonstop': 'Non-stop',
      'flight_card_direct': 'Direct',
      'flight_inquiry_notice': 'Verified Airline Schedule & Bespoke Quotation Desk',
      'flight_inquiry_success_title': 'Flight Request Received',
      'flight_inquiry_success_desc':
          'We received your flight request. Our team will contact you with available options.',

      // Travel Planner Bar
      'tab_flights': 'Flights',
      'tab_hotels': 'Hotels',
      'tab_tours': 'Tours & Packages',
      'tab_visa': 'Visa Services',
      'field_from': 'FROM',
      'field_destination': 'DESTINATION',
      'field_departure': 'DEPARTURE',
      'field_return': 'RETURN',
      'field_checkin': 'CHECK-IN',
      'field_checkout': 'CHECK-OUT',
      'field_travelers': 'TRAVELERS',
      'field_rooms': 'ROOMS & GUESTS',
      'field_tour_type': 'TOUR TYPE',
      'field_country': 'COUNTRY',
      'field_visa_type': 'VISA TYPE',
      'field_applicants': 'APPLICANTS',
      'field_cairo': 'Cairo (CAI)',
      'field_istanbul': 'Istanbul, Turkey',
      'btn_search': 'Search',
      'btn_inquire_flights': 'Inquire Flights',
      'btn_apply_visa': 'Apply Visa',
      'adults_label': 'Adults',
      'kids_label': 'Kids',
      'val_err_dest_empty': 'Please enter or select a destination',
      'val_err_dep_past': 'Departure date cannot be in the past',
      'val_err_ret_before_dep': 'Return date cannot be before departure date',
      'val_err_checkout_before_in': 'Check-out date must be after check-in date',
      'val_err_child_ages': 'Please specify the age for each child',
      'val_err_same_origin_dest': 'Origin and destination cannot be the same',

      // Partners Section
      'partners_title': 'TRUSTED BY GLOBAL AIRLINES & HOSPITALITY LEADERS',

      // Why Travella Section
      'why_badge': 'Why Travella',
      'why_title': 'Redefining Luxury Travel Experiences',
      'why_subtitle':
          'From handcrafted private tours to round-the-clock VIP support, we make every second of your journey extraordinary.',
      'feature_1_title': 'Bespoke Curated Itineraries',
      'feature_1_desc':
          'Every itinerary is crafted by seasoned destination specialists to match your desires.',
      'feature_2_title': '24/7 Dedicated Concierge',
      'feature_2_desc':
          'Direct access to a personal travel advisor before, during, and after your holiday.',
      'feature_3_title': 'Best Luxury Rate Guarantee',
      'feature_3_desc':
          'Preferred partnerships with global airlines and 5-star hotel chains ensuring unmatched value.',
      'feature_4_title': 'End-to-End Visa & VIP Services',
      'feature_4_desc':
          'Seamless fast-track visa processing and airport meet & assist services worldwide.',

      // Domestic Tours
      'domestic_badge': 'Discover Egypt',
      'domestic_title': 'Egypt’s Timeless Wonders',
      'domestic_subtitle':
          'From the Red Sea’s coral reefs and Siwa’s mystical salt lakes to luxury Nile cruises.',
      'all_domestic_btn': 'All Domestic Tours',
      'starting_price': 'STARTING PRICE',
      'per_person': 'per person',
      'view_details': 'Details',
      'book_this_tour': 'Book Now',

      // International Tours
      'international_badge': 'Global Escapes',
      'international_title': 'World-Class International Journeys',
      'international_subtitle':
          'Experience European capitals, Asian tropical havens, and modern Arabian wonders.',
      'all_international_btn': 'Explore All International',

      // Visa Services
      'visa_badge': 'Hassle-Free Travel',
      'visa_title': 'Visa Services',
      'visa_subtitle':
          'Travella helps customers with visa applications, requirements, embassy appointments, and complete travel authorizations with industry-leading approval rates.',
      'apply_visa_btn': 'Apply for a Visa',
      'visa_popular_destinations': 'Popular Visa Destinations',
      'visa_search_title': 'Find Your Visa Requirements & Apply',
      'visa_search_hint': 'Search destination country (e.g. United Kingdom, Japan, Schengen)...',
      'visa_filter_all_types': 'All Visa Types',
      'visa_filter_all_purposes': 'All Travel Purposes',
      'visa_filter_all_processing': 'Any Processing Speed',
      'visa_card_view_details': 'View Details',
      'visa_card_apply_now': 'Apply Now',
      'visa_processing_time': 'Processing Time',
      'visa_starting_from': 'Starting from',
      'visa_validity': 'Validity',
      'visa_stay_duration': 'Stay Duration',
      'visa_requirements': 'Requirements',
      'visa_required_docs': 'Required Documents',
      'visa_important_notes': 'Important Notes',
      'visa_detail_title': 'Visa Information & Application',
      'visa_step_1': 'Destination',
      'visa_step_2': 'Visa Type',
      'visa_step_3': 'Travel Info',
      'visa_step_4': 'Applicant Info',
      'visa_step_5': 'Documents',
      'visa_step_6': 'Review',
      'visa_step_7': 'Submit',
      'visa_select_destination': 'Step 1: Select Destination Country',
      'visa_select_type': 'Step 2: Select Visa Type & Category',
      'visa_travel_info_title': 'Step 3: Travel Schedule & Purpose',
      'visa_applicant_info_title': 'Step 4: Applicant Personal Details',
      'visa_documents_title': 'Step 5: Document Uploads (Passport, Photo & Proofs)',
      'visa_review_title': 'Step 6: Review Application Summary',
      'visa_submit_success_title': 'Visa Application Submitted Successfully!',
      'visa_submit_success_desc':
          'Your visa application has been registered with status "Pending". Our dedicated visa specialist is reviewing your file and documents.',
      'visa_passport_upload': 'Passport Scan / Photo (Required)',
      'visa_personal_photo_upload': 'Personal Photo (White Background) (Required)',
      'visa_supporting_docs_upload': 'Supporting Documents (Bank Statement, Hotel/Flight Voucher, etc.)',
      'visa_upload_cta': 'Upload / Pick Document File',
      'visa_uploading': 'Uploading to Supabase Storage...',
      'visa_upload_success': 'Document uploaded securely',
      'visa_validation_err_passport': 'Please upload a clear copy of your passport',
      'visa_validation_err_photo': 'Please upload a compliant personal photograph',
      'visa_full_name': 'Full Legal Name (as shown in passport) *',
      'visa_email': 'Email Address *',
      'visa_phone': 'Phone / WhatsApp Number *',
      'visa_nationality': 'Nationality / Citizenship *',
      'visa_passport_num': 'Passport Number *',
      'visa_dob': 'Date of Birth *',
      'visa_travel_date': 'Expected Travel Date *',
      'visa_return_date': 'Expected Return Date (Optional)',
      'visa_purpose': 'Purpose of Travel *',
      'visa_notes': 'Additional Inquiries / Notes',
      'visa_admin_dashboard_title': 'Visa Applications Management',
      'visa_admin_dashboard_subtitle': 'Track applicants, review document uploads, verify travel schedules, and update status',

      // Hotels & Resorts
      'hotels_badge': 'LUXURY ACCOMMODATIONS',
      'hotels_title': 'Luxury Hotels & Resorts',
      'hotels_subtitle':
          'Handpicked 5-star beachfront resorts, overwater villas, and historic palace sanctuaries verified by Travella.',
      'hotel_search_btn': 'Search Hotels',
      'hotel_filter_destination': 'Destination / Hotel Name',
      'hotel_filter_price': 'Price Range',
      'hotel_filter_stars': 'Star Rating',
      'hotel_filter_amenities': 'Amenities',
      'hotel_filter_sort': 'Sort By',
      'hotel_sort_recommended': 'Recommended',
      'hotel_sort_price_asc': 'Price: Low to High',
      'hotel_sort_price_desc': 'Price: High to Low',
      'hotel_sort_rating': 'Rating: High to Low',
      'hotel_star_3': '3 Stars',
      'hotel_star_4': '4 Stars',
      'hotel_star_5': '5 Stars',
      'hotel_card_details': 'View Details',
      'hotel_card_book': 'Book / Request',
      'hotel_per_night': 'night',
      'hotel_starting_from': 'STARTING FROM',
      'hotel_empty_title': 'No Matching Hotels Found',
      'hotel_empty_desc': 'Try adjusting your destination, price range, or amenities filters.',
      'hotel_error_title': 'Failed to Load Hotels',
      'hotel_booking_title': 'Hotel Reservation Request',
      'night': 'night',

      // Hajj & Umrah
      'hajj_badge': 'Spiritual Journeys',
      'hajj_title': 'Hajj & Umrah Sacred Packages',
      'hajj_subtitle':
          'Exceptional spiritual journeys with 5-star proximity to the Holy Harams.',

      // Final CTA
      'cta_badge': 'Explore A Brighter World',
      'cta_title': 'Ready To Explore\nA Brighter World?',
      'cta_subtitle':
          'Your dream journey starts here. Speak with a dedicated travel designer or plan your customized itinerary today.',
      'cta_plan_trip': 'Plan Your Trip',
      'cta_contact_expert': 'Contact Travel Expert',

      // Booking Page
      'booking_hero_badge': 'VIP Travel Booking Concierge',
      'booking_hero_title': 'Reserve Your Unforgettable Journey',
      'booking_hero_subtitle':
          'Fast 5-step booking request with zero upfront commitment. Our travel concierge will verify availability and confirm your personalized itinerary.',
      'step_1_title': 'Step 1: Primary Traveler Contact Details',
      'step_1_subtitle':
          'Please provide your official contact information for itinerary confirmations.',
      'full_name_label': 'Full Legal Name *',
      'email_label': 'Email Address *',
      'phone_label': 'Phone / WhatsApp Number *',
      'btn_next_tour': 'Next: Tour & Dates',

      'step_2_title': 'Step 2: Tour Selection & Travel Schedule',
      'step_2_subtitle':
          'Choose your desired package, travel dates, and party size.',
      'select_tour_label': 'Select Tour Package *',
      'travel_date_label': 'Travel Date *',
      'travelers_label': 'Travelers *',
      'adults_count_title': 'Adults',
      'adults_count_subtitle': 'Age 18+ years',
      'children_count_title': 'Children',
      'children_count_subtitle': 'Age 0 – 17 years (Infants & Kids)',
      'child_age_missing_err': 'Please select the age for each child',
      'child_infant_label': 'Under 1 yr (Infant)',
      'child_single_year': 'year',
      'child_plural_years': 'years',
      'children_ages_title': 'Child Ages (Required)',
      'travelers_count_summary': 'Travelers Breakdown',
      'children_ages_summary': 'Child Ages',
      'estimated_total': 'ESTIMATED TOTAL (ZERO UPFRONT)',
      'btn_back': 'Back',
      'btn_next_requests': 'Next: Special Requests',

      'step_3_title': 'Step 3: Special Requests & Preferences',
      'step_3_subtitle':
          'Personalize your journey with tailored amenities, dietary preferences, or VIP services.',
      'popular_prefs': 'Popular Travel Preferences',
      'additional_notes': 'Additional Notes / Custom Inquiries (Optional)',
      'btn_next_review': 'Next: Review Booking',

      'step_4_title': 'Step 4: Review Your Booking Request',
      'step_4_subtitle':
          'Please verify your travel itinerary and contact details before submitting.',
      'traveler_details': 'Traveler Details',
      'tour_schedule': 'Tour & Schedule',
      'special_requests_title': 'Special Requests & Preferences',
      'total_estimate_price': 'Total Estimated Price',
      'payment_arch_note':
          'Booking Status: Pending. No immediate charge. Future online gateways (Stripe, Paymob, Fawry) ready.',
      'btn_submit_booking': 'Confirm & Submit Booking',

      'step_5_confirmed_title': 'Booking Request Submitted Successfully',
      'step_5_confirmed_subtitle':
          'Thank you! Your booking request has been submitted and is currently pending review. A dedicated travel advisor will contact you shortly to confirm your reservation and review itinerary details.',
      'booking_ref_label': 'BOOKING REFERENCE',
      'status_pending': 'PENDING',
      'whatsapp_btn_label': 'Contact us on WhatsApp',
      'whatsapp_concierge_title': 'Instant VIP Concierge Assistance',
      'whatsapp_concierge_desc':
          'Want immediate confirmation or have special questions? Chat directly with our travel desk on WhatsApp.',
      'btn_book_another': 'Book Another Tour',
      'btn_back_home': 'Back to Home',

      // Footer
      'footer_about':
          'Travella is a premier luxury travel agency dedicated to crafting unforgettable bespoke itineraries, 5-star hotel stays, and hassle-free worldwide visa services.',
      'footer_quick_links': 'Quick Navigation',
      'footer_top_destinations': 'Top Destinations',
      'footer_contact_info': 'Concierge Desk',
      'footer_rights': 'All rights reserved.',
      'footer_cairo_address': 'Zamalek, Cairo, Egypt',

      // General / Common
      'language_name': 'English',
      'switch_language': 'العربية',
    },

    'ar': {
      // App Branding
      'app_name': 'ترافيلا',
      'app_tagline': 'للسياحة والسفر',
      'app_slogan': 'اكتشف عالماً أكثر إشراقاً',

      // Navbar & Navigation
      'nav_home': 'الرئيسية',
      'nav_flights': 'رحلات الطيران',
      'nav_destinations': 'الوجهات',
      'nav_domestic_tours': 'رحلات مصر الداخلية',
      'nav_international_tours': 'الرحلات الدولية',
      'nav_visa_services': 'خدمات التأشيرات',
      'nav_hotels': 'الفنادق والمنتجعات',
      'nav_airport_transfers': 'توصيل المطار VIP',
      'nav_hajj_umrah': 'الحج والعمرة',
      'nav_gallery': 'معرض الصور',
      'nav_blog': 'المدونة السياحية',
      'nav_contact': 'تواصل معنا',
      'nav_book_now': 'احجز الآن',
      'nav_admin': 'لوحة الإدارة',
      'nav_menu': 'القائمة',

      // Airport Transfers
      'transfers_badge': 'خدمات استقبال وتوصيل المطار VIP الفاخرة',
      'transfers_hero_title': 'خدمات توصيل المطار الفاخرة والاستقبال الخاص',
      'transfers_hero_subtitle':
          'استمتع بأعلى معايير الدقة والراحة في النقل من وإلى المطار مع خدمة الاستقبال بالاسم، متابعة الرحلات الجوية، وأسعار شفافة وثابتة.',
      'transfers_search_title': 'ابحث عن وسيلة التوصيل المناسبة',
      'transfers_pickup_loc': 'مكان الاستلام',
      'transfers_dropoff_loc': 'مكان التوصيل والوصول',
      'transfers_pickup_date': 'تاريخ الاستلام',
      'transfers_pickup_time': 'وقت الاستلام',
      'transfers_passengers': 'الركاب',
      'transfers_luggage': 'عدد الحقائب والأمتعة',
      'transfers_vehicle_type': 'نوع السيارة',
      'transfers_transfer_type': 'نوع مسار التوصيل',
      'transfer_airport_to_hotel': 'من المطار إلى الفندق',
      'transfer_hotel_to_airport': 'من الفندق إلى المطار',
      'transfer_airport_to_airport': 'من مطار إلى مطار',
      'transfer_custom': 'توصيل مخصص',
      'transfers_book_btn': 'حجز التوصيل',
      'transfers_request_btn': 'اختيار / طلب الحجز',
      'transfers_est_duration': 'الوقت المتوقع',
      'transfers_capacity': 'السعة',
      'transfers_bags': 'حقائب',
      'transfers_passengers_label': 'مقاعد',
      'transfers_child_ages': 'أعمار الأطفال',
      'transfers_special_requests': 'طلبات خاصة / رقم الرحلة',
      'transfers_flight_no': 'رقم رحلة الطيران (مثال: MS 777)',
      'transfers_booking_success_title': 'تم استلام طلب التوصيل بنجاح!',
      'transfers_booking_success_desc':
          'شكراً لك! تم تسجيل طلب حجز التوصيل. سيقوم فريق العمليات بتعيين السائق والتواصل معك فوراً عبر الواتساب أو البريد الإلكتروني.',
      'transfers_filter_all': 'جميع السيارات',
      'transfers_filter_sedan': 'سيدان',
      'transfers_filter_suv': 'دفع رباعي SUV',
      'transfers_filter_van': 'فان عائلي',
      'transfers_filter_minibus': 'ميني باص',
      'admin_transfers_title': 'إدارة خدمات وتوصيلات المطار',

      // Hero Section
      'hero_badge': 'ترافيلا للسياحة والسفر الفاخر',
      'hero_title_line1': 'اكتشف عالماً أكثر',
      'hero_title_line2': 'إشراقاً وتميزاً معنا',
      'hero_subtitle':
          'رحلتك الاستثنائية تبدأ هنا. استكشف وجهات عالمية مختارة، فنادق فاخرة، رحلات خاصة مخصصة، وخدمات تأشيرات متكاملة.',
      'hero_explore_btn': 'استكشف الوجهات',
      'hero_plan_btn': 'خطط لرحلتك',

      // Flights Page & Features
      'flights_badge': 'مكتب حجوزات واستشارات الطيران الفاخر',
      'flights_hero_title': 'رحلات طيران عالمية ومسارات مخصصة',
      'flights_hero_subtitle':
          'مكتب استشارات وحجوزات طيران مخصص يبحث لك عن أفضل المسارات المباشرة والدرجات الفاخرة على كبرى خطوط الطيران العالمية مع دعم 24/7.',
      'trip_round_trip': 'ذهاب وعودة',
      'trip_one_way': 'اتجاه واحد',
      'filter_stops': 'عدد التوقفات',
      'filter_stops_any': 'الكل',
      'filter_stops_nonstop': 'مباشر فقط',
      'filter_stops_1stop': 'توقف واحد',
      'filter_stops_2plus': 'توقفان فأكثر',
      'filter_airlines': 'شركات الطيران',
      'filter_departure_time': 'وقت الإقلاع',
      'filter_arrival_time': 'وقت الوصول',
      'filter_price_range': 'نطاق السعر',
      'filter_duration': 'مدة الرحلة',
      'filter_reset': 'إعادة ضبط الفلاتر',
      'filter_sort_by': 'الترتيب حسب',
      'flight_search_btn': 'بحث عن رحلات الطيران',
      'flight_card_details': 'تفاصيل الرحلة',
      'flight_card_select': 'طلب حجز واستفسار',
      'flight_card_nonstop': 'مباشر بدون توقف',
      'flight_card_direct': 'مباشر',
      'flight_inquiry_notice': 'جداول معتمدة من كبرى خطوط الطيران وعروض أسعار حصرية ومخصصة',
      'flight_inquiry_success_title': 'تم استلام طلب حجز واستفسار الطيران',
      'flight_inquiry_success_desc':
          'We received your flight request. Our team will contact you with available options.',

      // Travel Planner Bar
      'tab_flights': 'طيران',
      'tab_hotels': 'فنادق',
      'tab_tours': 'رحلات وبرامج',
      'tab_visa': 'تأشيرات سياحية',
      'field_from': 'المغادرة من',
      'field_destination': 'وجهة السفر',
      'field_departure': 'تاريخ السفر',
      'field_return': 'تاريخ العودة',
      'field_checkin': 'تاريخ الوصول',
      'field_checkout': 'تاريخ المغادرة',
      'field_travelers': 'عدد المسافرين',
      'field_rooms': 'الغرف والضيوف',
      'field_tour_type': 'نوع البرنامج',
      'field_country': 'دولة التأشيرة',
      'field_visa_type': 'نوع التأشيرة',
      'field_applicants': 'المتقدمين',
      'field_cairo': 'القاهرة (CAI)',
      'field_istanbul': 'إسطنبول، تركيا',
      'btn_search': 'بحث',
      'btn_inquire_flights': 'طلب حجز طيران',
      'btn_apply_visa': 'طلب تأشيرة',
      'adults_label': 'بالغين',
      'kids_label': 'أطفال',
      'val_err_dest_empty': 'يرجى إدخال أو اختيار وجهة السفر',
      'val_err_dep_past': 'تاريخ السفر لا يمكن أن يكون في الماضي',
      'val_err_ret_before_dep': 'تاريخ العودة يجب أن يكون بعد تاريخ الذهاب',
      'val_err_checkout_before_in': 'تاريخ المغادرة يجب أن يكون بعد تاريخ الوصول',
      'val_err_child_ages': 'يرجى تحديد عمر كل طفل',
      'val_err_same_origin_dest': 'لا يمكن أن تكون نقطة الانطلاق والوجهة متطابقتين',

      // Partners Section
      'partners_title': 'شركاء النجاح من كبرى شركات الطيران وسلاسل الفنادق العالمية',

      // Why Travella Section
      'why_badge': 'لماذا ترافيلا؟',
      'why_title': 'نعيد صياغة تجارب السفر الفاخر',
      'why_subtitle':
          'من الرحلات الخاصة المصممة خصيصاً إلى الدعم الفاخر على مدار الساعة، نجعل كل لحظة من عطلتك ذكرى لا تُنسى.',
      'feature_1_title': 'برامج سياحية مصممة خصيصاً',
      'feature_1_desc':
          'كل برنامج سياحي يصممه خبراء متخصصون في الوجهات ليناسب رغباتك وتطلعاتك بدقة.',
      'feature_2_title': 'مستشار سفر خاص 24/7',
      'feature_2_desc':
          'تواصل مباشر مع مستشارك السياحي الخاص قبل وأثناء وبعد رحلتك لضمان راحتك التامة.',
      'feature_3_title': 'أفضل الأسعار الفاخرة المضمونة',
      'feature_3_desc':
          'شراكات مميزة مع كبرى خطوط الطيران وسلاسل الفنادق العالمية تضمن لك أرقى قيمة.',
      'feature_4_title': 'خدمات التأشيرات وكبار الشخصيات VIP',
      'feature_4_desc':
          'استخراج سريع ومضمون للتأشيرات وخدمات الاستقبال والتوديع في المطارات حول العالم.',

      // Domestic Tours
      'domestic_badge': 'اكتشف سحر مصر',
      'domestic_title': 'عجائب مصر الخالدة',
      'domestic_subtitle':
          'من شعاب البحر الأحمر المرجانية وبحيرات سيوة الساحرة إلى أفخم الرحلات النيلية بين الأقصر وأسوان.',
      'all_domestic_btn': 'جميع رحلات مصر الداخلية',
      'starting_price': 'يبدأ السعر من',
      'per_person': 'للشخص الواحد',
      'view_details': 'التفاصيل',
      'book_this_tour': 'احجز الآن',

      // International Tours
      'international_badge': 'عطلات عالمية',
      'international_title': 'أروع الرحلات والوجهات الدولية',
      'international_subtitle':
          'عش تجربة العواصم الأوروبية الساحرة، جزر آسيا الاستوائية، وأفخم المدن العالمية الحديثة.',
      'all_international_btn': 'استكشف كافة الرحلات الدولية',

      // Visa Services
      'visa_badge': 'سفر بلا تعقيدات',
      'visa_title': 'خدمات التأشيرات',
      'visa_subtitle':
          'تساعد ترافيلا عملاءها في استخراج التأشيرات، استيفاء المتطلبات، حجز مواعيد السفارات وتجهيز ملفات السفر بأعلى نسب قبول.',
      'apply_visa_btn': 'التقديم على تأشيرة',
      'visa_popular_destinations': 'أشهر وجهات التأشيرات المطلوبة',
      'visa_search_title': 'ابحث عن متطلبات تأشيرتك وقدّم الآن',
      'visa_search_hint': 'ابحث باسم دولة الوجهة (مثل: بريطانيا، اليابان، الشنغن)...',
      'visa_filter_all_types': 'جميع أنواع التأشيرات',
      'visa_filter_all_purposes': 'جميع أغراض السفر',
      'visa_filter_all_processing': 'جميع فترات المعالجة',
      'visa_card_view_details': 'عرض التفاصيل',
      'visa_card_apply_now': 'قدّم الآن',
      'visa_processing_time': 'مدة الإنجاز والمعالجة',
      'visa_starting_from': 'يبدأ السعر من',
      'visa_validity': 'مدة الصلاحية',
      'visa_stay_duration': 'مدة الإقامة المسموحة',
      'visa_requirements': 'المتطلبات والشروط',
      'visa_required_docs': 'المستندات والأوراق المطلوبة',
      'visa_important_notes': 'ملاحظات وإرشادات هامة',
      'visa_detail_title': 'تفاصيل التأشيرة والتقديم',
      'visa_step_1': 'الوجهة',
      'visa_step_2': 'نوع التأشيرة',
      'visa_step_3': 'بيانات السفر',
      'visa_step_4': 'بيانات المتقدم',
      'visa_step_5': 'المستندات',
      'visa_step_6': 'المراجعة',
      'visa_step_7': 'الإرسال',
      'visa_select_destination': 'الخطوة 1: اختيار دولة الوجهة',
      'visa_select_type': 'الخطوة 2: اختيار نوع وفئة التأشيرة',
      'visa_travel_info_title': 'الخطوة 3: جدول ومواعيد وغرض السفر',
      'visa_applicant_info_title': 'الخطوة 4: البيانات الشخصية لمقدم الطلب',
      'visa_documents_title': 'الخطوة 5: رفع المستندات المطلوبة (الجواز، الصورة والإثباتات)',
      'visa_review_title': 'الخطوة 6: مراجعة ملخص وتفاصيل الطلب',
      'visa_submit_success_title': 'تم إرسال طلب التأشيرة بنجاح!',
      'visa_submit_success_desc':
          'تم تسجيل طلب التأشيرة بحالة "قيد الانتظار". يقوم مستشار التأشيرات المتخصص بمراجعة بياناتك ومستنداتك وسيتواصل معك فوراً.',
      'visa_passport_upload': 'صورة / مسح ضوئي لجواز السفر (مطلوب)',
      'visa_personal_photo_upload': 'صورة شخصية حديثة بخلفية بيضاء (مطلوب)',
      'visa_supporting_docs_upload': 'مستندات داعمة (كشف حساب بنكي، حجز طيران/فندق، خطاب عمل)',
      'visa_upload_cta': 'رفع / اختيار ملف المستند',
      'visa_uploading': 'جاري الرفع إلى تخزين سوبابيس...',
      'visa_upload_success': 'تم رفع المستند بأمان',
      'visa_validation_err_passport': 'يرجى رفع صورة واضحة لجواز السفر',
      'visa_validation_err_photo': 'يرجى رفع صورة شخصية مطابقة للمواصفات',
      'visa_full_name': 'الاسم الكامل بالإنجليزية (كما في الجواز) *',
      'visa_email': 'البريد الإلكتروني *',
      'visa_phone': 'رقم الهاتف / واتساب *',
      'visa_nationality': 'الجنسية / الدولة المصدرة للجواز *',
      'visa_passport_num': 'رقم جواز السفر *',
      'visa_dob': 'تاريخ الميلاد *',
      'visa_travel_date': 'تاريخ السفر المتوقع *',
      'visa_return_date': 'تاريخ العودة المتوقع (اختياري)',
      'visa_purpose': 'الغرض من السفر *',
      'visa_notes': 'ملاحظات أو استفسارات إضافية',
      'visa_admin_dashboard_title': 'إدارة طلبات التأشيرات',
      'visa_admin_dashboard_subtitle': 'متابعة المتقدمين، مراجعة المستندات المرفوعة، التحقق من الجداول وتحديث حالة الطلبات',

      // Hotels & Resorts
      'hotels_badge': 'إقامات ومنتجعات فاخرة',
      'hotels_title': 'أفخم الفنادق والمنتجعات العالمية',
      'hotels_subtitle':
          'باقة مختارة بعناية من أرقى المنتجعات الشاطئية والفلل المائية وقصور الضيافة التاريخية حول العالم.',
      'hotel_search_btn': 'بحث عن الفنادق',
      'hotel_filter_destination': 'الوجهة / اسم الفندق',
      'hotel_filter_price': 'نطاق السعر',
      'hotel_filter_stars': 'تصنيف النجوم',
      'hotel_filter_amenities': 'المرافق والخدمات',
      'hotel_filter_sort': 'ترتيب النتائج',
      'hotel_sort_recommended': 'الموصى به',
      'hotel_sort_price_asc': 'السعر: من الأقل للأعلى',
      'hotel_sort_price_desc': 'السعر: من الأعلى للأقل',
      'hotel_sort_rating': 'التقييم: من الأعلى للأقل',
      'hotel_star_3': '3 نجوم',
      'hotel_star_4': '4 نجوم',
      'hotel_star_5': '5 نجوم',
      'hotel_card_details': 'عرض التفاصيل',
      'hotel_card_book': 'حجز / طلب عرض سعر',
      'hotel_per_night': 'ليلة',
      'hotel_starting_from': 'ابتداءً من',
      'hotel_empty_title': 'لا توجد فنادق مطابقة للبحث',
      'hotel_empty_desc': 'جرّب تعديل الوجهة أو نطاق السعر أو اختيار مرافق أخرى.',
      'hotel_error_title': 'فشل تحميل بيانات الفنادق',
      'hotel_booking_title': 'طلب حجز واستشارة فندقية',
      'night': 'ليلة',

      // Hajj & Umrah
      'hajj_badge': 'رحلات إيمانية',
      'hajj_title': 'برامج الحج والعمرة المميزة',
      'hajj_subtitle':
          'رحلات روحانية استثنائية مع إقامة فاخرة 5 نجوم بإطلالات مباشرة وقريبة من الحرمين الشريفين.',

      // Final CTA
      'cta_badge': 'اكتشف عالماً أكثر إشراقاً',
      'cta_title': 'هل أنت مستعد لبدء\nرحلتك الاستثنائية القادمة؟',
      'cta_subtitle':
          'عطلة أحلامك تبدأ الآن. تواصل مع مستشاري السفر لدينا وصمّم برنامجك السياحي الخاص اليوم.',
      'cta_plan_trip': 'خطط لرحلتك الآن',
      'cta_contact_expert': 'تحدث مع خبير السفر',

      // Booking Page
      'booking_hero_badge': 'خدمة الحجز والاستشارة الفاخرة',
      'booking_hero_title': 'احجز رحلتك التي لا تُنسى',
      'booking_hero_subtitle':
          'طلب حجز سريع في 5 خطوات دون أي دفع مسبق. سيقوم مستشار السفر بالتحقق من التوافر وتأكيد برنامجك المخصص.',
      'step_1_title': 'الخطوة 1: بيانات المسافر الأساسي للتواصل',
      'step_1_subtitle':
          'يرجى إدخال معلومات التواصل الرسمية لتأكيد حجز البرنامج السياحي.',
      'full_name_label': 'الاسم الكامل باللغة الإنجليزية/العربية *',
      'email_label': 'البريد الإلكتروني *',
      'phone_label': 'رقم الهاتف / واتساب *',
      'btn_next_tour': 'التالي: اختيار الرحلة والمواعيد',

      'step_2_title': 'الخطوة 2: اختيار البرنامج وتاريخ السفر',
      'step_2_subtitle':
          'اختر البرنامج السياحي المناسب، وتاريخ المغادرة، وعدد المسافرين.',
      'select_tour_label': 'اختر البرنامج السياحي *',
      'travel_date_label': 'تاريخ السفر *',
      'travelers_label': 'عدد المسافرين *',
      'adults_count_title': 'عدد البالغين',
      'adults_count_subtitle': 'من عمر 18 سنة فأكثر',
      'children_count_title': 'عدد الأطفال',
      'children_count_subtitle': 'من عمر 0 حتى 17 سنة (أطفال ورُضّع)',
      'child_age_missing_err': 'يرجى تحديد سن كل طفل',
      'child_infant_label': 'أقل من سنة (رضيع)',
      'child_single_year': 'سنة',
      'child_plural_years': 'سنوات',
      'children_ages_title': 'تحديد سن الأطفال (مطلوب)',
      'travelers_count_summary': 'تفاصيل المسافرين',
      'children_ages_summary': 'أعمار الأطفال',
      'estimated_total': 'إجمالي السعر التقديري (دون دفع مسبق)',
      'btn_back': 'السابق',
      'btn_next_requests': 'التالي: الطلبات الخاصة',

      'step_3_title': 'الخطوة 3: الطلبات والتفضيلات الخاصة',
      'step_3_subtitle':
          'خصّص رحلتك بمزيد من الراحة، كالوجبات الخاصة، خدمات كبار الشخصيات، أو الترتيبات الاحتفالية.',
      'popular_prefs': 'أشهر التفضيلات السياحية',
      'additional_notes': 'ملاحظات إضافية أو استفسارات خاصة (اختياري)',
      'btn_next_review': 'التالي: مراجعة تفاصيل الحجز',

      'step_4_title': 'الخطوة 4: مراجعة وتأكيد طلب الحجز',
      'step_4_subtitle':
          'يرجى مراجعة بيانات المسافر والبرنامج السياحي قبل إرسال الطلب.',
      'traveler_details': 'بيانات المسافر',
      'tour_schedule': 'تفاصيل الرحلة والجدول',
      'special_requests_title': 'الطلبات والتفضيلات الخاصة',
      'total_estimate_price': 'إجمالي السعر التقديري',
      'payment_arch_note':
          'حالة الحجز: قيد المراجعة. لا يوجد أي خصم مسبق. بوابات الدفع الإلكتروني (Stripe, Paymob, Fawry) جاهزة مستقبلاً.',
      'btn_submit_booking': 'تأكيد وإرسال طلب الحجز',

      'step_5_confirmed_title': 'تم إرسال طلب الحجز بنجاح',
      'step_5_confirmed_subtitle':
          'شكراً لاختيارك ترافيلا! تم إرسال طلب حجزك بنجاح وحفظه في النظام بحالة "قيد المراجعة". سيقوم مستشارك السياحي بالتواصل مع حضرتك في أقرب وقت لتأكيد الحجز ومراجعة تفاصيل البرنامج.',
      'booking_ref_label': 'الرقم المرجعي للحجز',
      'status_pending': 'قيد المراجعة',
      'whatsapp_btn_label': 'تواصل معنا عبر واتساب',
      'whatsapp_concierge_title': 'خدمة الاستفسار الفوري VIP',
      'whatsapp_concierge_desc':
          'هل ترغب في تأكيد فوري أو لديك أي استفسارات خاصة؟ تواصل مباشرة مع فريق الحجوزات عبر واتساب.',
      'btn_book_another': 'حجز رحلة أخرى',
      'btn_back_home': 'العودة للرئيسية',

      // Footer
      'footer_about':
          'ترافيلا هي شركة رائدة في مجال السياحة والسفر الفاخر، متخصصة في تقديم برامج سياحية استثنائية، حجوزات فنادق 5 نجوم، وخدمات تأشيرات سريعة لجميع أنحاء العالم.',
      'footer_quick_links': 'روابط سريعة',
      'footer_top_destinations': 'أبرز الوجهات',
      'footer_contact_info': 'مكتب الحجوزات والاستشارات',
      'footer_rights': 'جميع الحقوق محفوظة.',
      'footer_cairo_address': 'الزمالك، القاهرة، جمهورية مصر العربية',

      // General / Common
      'language_name': 'العربية',
      'switch_language': 'English',
    },
  };

  /// Translate key according to given or active locale
  static String text(String key, {Locale? locale, BuildContext? context}) {
    Locale activeLocale = locale ?? AppLocales.english;
    if (context != null) {
      activeLocale = Localizations.localeOf(context);
    }
    final langCode = activeLocale.languageCode == 'ar' ? 'ar' : 'en';
    final dict = _values[langCode] ?? _values['en']!;
    return dict[key] ?? _values['en']![key] ?? key;
  }
}

/// Extension for fast concise translations in BuildContext
extension TranslationExtension on BuildContext {
  String tr(String key) {
    return AppTranslations.text(key, context: this);
  }

  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';
}

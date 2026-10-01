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
      'nav_destinations': 'Destinations',
      'nav_domestic_tours': 'Domestic Tours',
      'nav_international_tours': 'International',
      'nav_visa_services': 'Visa Services',
      'nav_hotels': 'Hotels',
      'nav_hajj_umrah': 'Hajj & Umrah',
      'nav_gallery': 'Gallery',
      'nav_blog': 'Blog',
      'nav_contact': 'Contact',
      'nav_book_now': 'Book Now',
      'nav_admin': 'Admin CMS',
      'nav_menu': 'Menu',

      // Hero Section
      'hero_badge': 'TRAVELLA TOUR & TRAVEL',
      'hero_title_line1': 'Explore A Brighter',
      'hero_title_line2': 'World With Us',
      'hero_subtitle':
          'Your journey starts here. Discover handpicked global destinations, luxury hotels, bespoke private tours, and complete visa assistance.',
      'hero_explore_btn': 'Explore Destinations',
      'hero_plan_btn': 'Plan Your Trip',

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
      'visa_title': 'VIP Visa Concierge Services',
      'visa_subtitle':
          'Fast, guaranteed, and transparent visa processing for over 50+ countries worldwide.',
      'apply_visa_btn': 'Apply For Visa',

      // Hotels & Resorts
      'hotels_badge': 'Luxury Stays',
      'hotels_title': 'Handpicked 5-Star Accommodations',
      'hotels_subtitle':
          'World-class luxury resorts, heritage palaces, and boutique desert lodges.',
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
      'nav_destinations': 'الوجهات',
      'nav_domestic_tours': 'رحلات مصر الداخلية',
      'nav_international_tours': 'الرحلات الدولية',
      'nav_visa_services': 'خدمات التأشيرات',
      'nav_hotels': 'الفنادق والمنتجعات',
      'nav_hajj_umrah': 'الحج والعمرة',
      'nav_gallery': 'معرض الصور',
      'nav_blog': 'المدونة السياحية',
      'nav_contact': 'تواصل معنا',
      'nav_book_now': 'احجز الآن',
      'nav_admin': 'لوحة الإدارة',
      'nav_menu': 'القائمة',

      // Hero Section
      'hero_badge': 'ترافيلا للسياحة والسفر الفاخر',
      'hero_title_line1': 'اكتشف عالماً أكثر',
      'hero_title_line2': 'إشراقاً وتميزاً معنا',
      'hero_subtitle':
          'رحلتك الاستثنائية تبدأ هنا. استكشف وجهات عالمية مختارة، فنادق فاخرة، رحلات خاصة مخصصة، وخدمات تأشيرات متكاملة.',
      'hero_explore_btn': 'استكشف الوجهات',
      'hero_plan_btn': 'خطط لرحلتك',

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
      'visa_title': 'خدمات استخراج التأشيرات السياحية VIP',
      'visa_subtitle':
          'إجراءات سريعة ومضمونة وبأعلى درجات الشفافية لأكثر من 50 دولة حول العالم.',
      'apply_visa_btn': 'قدّم على التأشيرة الآن',

      // Hotels & Resorts
      'hotels_badge': 'إقامات ملكية',
      'hotels_title': 'فنادق ومنتجعات 5 نجوم مختارة',
      'hotels_subtitle':
          'أفخم المنتجعات العالمية، القصور التراثية، والأجنحة الفندقية الراقية.',
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

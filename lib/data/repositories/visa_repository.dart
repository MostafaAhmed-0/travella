import '../models/visa_model.dart';

/// Repository for Visa services and supported destinations
class VisaRepository {
  const VisaRepository();

  static const List<VisaServiceFeature> features = [
    VisaServiceFeature(
      title: 'Visa Consultation',
      description: 'Expert personalized assessment of your travel profile and visa requirements.',
      iconCode: 'support_agent',
    ),
    VisaServiceFeature(
      title: 'Document Preparation',
      description: 'Meticulous verification, translations, and structuring of all required supporting files.',
      iconCode: 'fact_check',
    ),
    VisaServiceFeature(
      title: 'Application Assistance',
      description: 'Step-by-step guidance and submission through official consular portals.',
      iconCode: 'assignment_turned_in',
    ),
    VisaServiceFeature(
      title: 'Appointment Support',
      description: 'Securing the earliest biometric and interview appointments at VFS/TLS/Embassies.',
      iconCode: 'event_available',
    ),
    VisaServiceFeature(
      title: 'Travel Insurance',
      description: 'Schengen & global compliant accredited medical travel insurance coverage.',
      iconCode: 'health_and_safety',
    ),
    VisaServiceFeature(
      title: 'Application Follow-up',
      description: 'Real-time tracking of passport status and prompt embassy response handling.',
      iconCode: 'published_with_changes',
    ),
  ];

  static const List<VisaCountryModel> countries = [
    VisaCountryModel(
      id: 'visa-schengen',
      countryName: 'Schengen Area (Europe)',
      region: 'Europe',
      flagEmoji: '🇪🇺',
      processingTime: '15-20 Days',
      validity: 'Up to 5 Years',
      fee: 140,
      iconUrl: 'https://images.unsplash.com/photo-1467269204594-9661b134dd2b?auto=format&fit=crop&w=600&q=80',
      requirements: ['Valid Passport (6+ mos)', 'Bank Statements (6 mos)', 'HR Letter', 'Travel Insurance'],
      isPopular: true,
    ),
    VisaCountryModel(
      id: 'visa-uk',
      countryName: 'United Kingdom',
      region: 'UK & USA',
      flagEmoji: '🇬🇧',
      processingTime: '15-25 Days',
      validity: '6 Mos - 10 Yrs',
      fee: 190,
      iconUrl: 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?auto=format&fit=crop&w=600&q=80',
      requirements: ['Passport', 'Financial Proof', 'Employment Proof', 'Accommodation Booking'],
      isPopular: true,
    ),
    VisaCountryModel(
      id: 'visa-usa',
      countryName: 'United States (B1/B2)',
      region: 'UK & USA',
      flagEmoji: '🇺🇸',
      processingTime: 'Appointment Based',
      validity: '5-10 Years',
      fee: 220,
      iconUrl: 'https://images.unsplash.com/photo-1485738422979-f5c462d49f74?auto=format&fit=crop&w=600&q=80',
      requirements: ['DS-160 Form Assistance', 'Interview Prep Mock Session', 'Ties Documentation'],
      isPopular: true,
    ),
    VisaCountryModel(
      id: 'visa-uae',
      countryName: 'Dubai / UAE (eVisa)',
      region: 'Middle East',
      flagEmoji: '🇦🇪',
      processingTime: '24-48 Hours',
      validity: '30 or 60 Days',
      fee: 95,
      iconUrl: 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?auto=format&fit=crop&w=600&q=80',
      requirements: ['Passport Copy', 'Personal Photo', 'Confirmed Return Flight'],
      isPopular: true,
    ),
    VisaCountryModel(
      id: 'visa-turkey',
      countryName: 'Turkey (Sticker / eVisa)',
      region: 'Europe & Asia',
      flagEmoji: '🇹🇷',
      processingTime: '5-7 Days',
      validity: '90 Days / Multiple',
      fee: 110,
      iconUrl: 'https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?auto=format&fit=crop&w=600&q=80',
      requirements: ['Passport', 'HR Letter', 'Bank Statement', 'Travel Itinerary'],
      isPopular: true,
    ),
    VisaCountryModel(
      id: 'visa-japan',
      countryName: 'Japan & East Asia',
      region: 'Asia',
      flagEmoji: '🇯🇵',
      processingTime: '7-10 Days',
      validity: 'Single / Multi',
      fee: 120,
      iconUrl: 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&w=600&q=80',
      requirements: ['Passport', 'Detailed Day-by-Day Schedule', 'Bank Statement', 'Employment Letter'],
      isPopular: false,
    ),
  ];

  Future<List<VisaCountryModel>> getVisaCountries() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return countries;
  }
}

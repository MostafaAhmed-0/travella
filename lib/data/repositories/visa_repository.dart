import '../datasources/visa_remote_data_source.dart';
import '../models/visa_model.dart';

/// Repository for visa services connecting to Supabase
class VisaRepository {
  final VisaRemoteDataSource _remoteDataSource;

  VisaRepository({VisaRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? VisaRemoteDataSourceImpl();

  static const List<VisaServiceModel> _mockVisaCountries = [
    VisaServiceModel(
      id: 'v1111111-1111-1111-1111-111111111111',
      country: 'Schengen Area (Europe)',
      countryAr: 'منطقة الشنغن (أوروبا)',
      visaType: 'Tourist / Business Visa',
      region: 'Europe (Schengen)',
      flagEmoji: '🇪🇺',
      processingTime: '10-15 Days',
      validity: '90 Days',
      price: 180,
      description: 'Complete application assistance, appointment booking, file audit, and flight/hotel reservation voucher support.',
      descriptionAr: 'مساعدة كاملة في تقديم الطلب، وحجز المواعيد، ومراجعة المستندات، وتوفير حجوزات الطيران والفنادق المعتمدة.',
      iconUrl: 'https://images.unsplash.com/photo-1516483638261-f4dbaf036963?auto=format&fit=crop&w=400&q=80',
      requirements: [
        VisaRequirementModel(id: 'r1', visaServiceId: 'v1111111-1111-1111-1111-111111111111', requirement: 'Original Passport (valid 6+ months)'),
        VisaRequirementModel(id: 'r2', visaServiceId: 'v1111111-1111-1111-1111-111111111111', requirement: 'Bank statement for last 6 months'),
        VisaRequirementModel(id: 'r3', visaServiceId: 'v1111111-1111-1111-1111-111111111111', requirement: 'HR letter / Commercial Register'),
      ],
      isPopular: true,
    ),
    VisaServiceModel(
      id: 'v2222222-2222-2222-2222-222222222222',
      country: 'United Kingdom',
      countryAr: 'المملكة المتحدة',
      visaType: 'Standard Visitor Visa',
      region: 'UK & USA',
      flagEmoji: '🇬🇧',
      processingTime: '15-20 Days',
      validity: '6 Months (Multiple)',
      price: 220,
      description: 'Online application completion, biometric appointment scheduling, and document translation checks.',
      descriptionAr: 'تعبئة استمارة التقديم الإلكترونية، وحجز موعد البصمة، وتدقيق الوثائق والمستندات المترجمة.',
      iconUrl: 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?auto=format&fit=crop&w=400&q=80',
      requirements: [
        VisaRequirementModel(id: 'r4', visaServiceId: 'v2222222-2222-2222-2222-222222222222', requirement: 'Current & expired passports'),
        VisaRequirementModel(id: 'r5', visaServiceId: 'v2222222-2222-2222-2222-222222222222', requirement: '6 months bank statement & salary slips'),
      ],
      isPopular: true,
    ),
    VisaServiceModel(
      id: 'v3333333-3333-3333-3333-333333333333',
      country: 'United States',
      countryAr: 'الولايات المتحدة الأمريكية',
      visaType: 'B1/B2 Tourist & Business',
      region: 'UK & USA',
      flagEmoji: '🇺🇸',
      processingTime: '20-30 Days',
      validity: '5 Years (Multiple)',
      price: 250,
      description: 'DS-160 application form filing, fee payment, earlier appointment tracking, and interview coaching.',
      descriptionAr: 'تعبئة نموذج DS-160، ودفع الرسوم، وتتبع المواعيد المبكرة، والتدريب على مقابلة السفارة.',
      iconUrl: 'https://images.unsplash.com/photo-1508433957232-3107f5fd5995?auto=format&fit=crop&w=400&q=80',
      requirements: [
        VisaRequirementModel(id: 'r6', visaServiceId: 'v3333333-3333-3333-3333-333333333333', requirement: 'DS-160 application form confirmation'),
        VisaRequirementModel(id: 'r7', visaServiceId: 'v3333333-3333-3333-3333-333333333333', requirement: 'Interview appointment confirmation'),
      ],
      isPopular: true,
    ),
    VisaServiceModel(
      id: 'v4444444-4444-4444-4444-444444444444',
      country: 'United Arab Emirates (Dubai)',
      countryAr: 'الإمارات العربية المتحدة (دبي)',
      visaType: 'Tourist eVisa',
      region: 'Middle East',
      flagEmoji: '🇦🇪',
      processingTime: '24-48 Hours',
      validity: '30 / 60 Days',
      price: 110,
      description: 'Fast-track electronic visa issuance within 24 to 48 hours directly into your email with health insurance.',
      descriptionAr: 'إصدار التأشيرة الإلكترونية السريعة خلال 24 إلى 48 ساعة مباشرة على بريدك الإلكتروني مع التأمين الصحي.',
      iconUrl: 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?auto=format&fit=crop&w=400&q=80',
      requirements: [
        VisaRequirementModel(id: 'r8', visaServiceId: 'v4444444-4444-4444-4444-444444444444', requirement: 'Passport bio-page color copy'),
        VisaRequirementModel(id: 'r9', visaServiceId: 'v4444444-4444-4444-4444-444444444444', requirement: 'Passport size photo'),
      ],
      isPopular: true,
    ),
  ];

  static const List<VisaServiceFeature> _features = [
    VisaServiceFeature(
      title: '99.4% Approval Rate',
      description: 'Meticulous document verification by seasoned visa specialists.',
      iconCode: 'verified_user_rounded',
    ),
    VisaServiceFeature(
      title: 'Express Processing',
      description: 'Priority appointment scheduling and fast-track submission.',
      iconCode: 'bolt_rounded',
    ),
    VisaServiceFeature(
      title: 'End-to-End Assistance',
      description: 'Form filling, translations, hotel/flight vouchers, and mock interviews.',
      iconCode: 'support_agent_rounded',
    ),
    VisaServiceFeature(
      title: 'Doorstep Collection',
      description: 'Secure passport and document pickup & return service available.',
      iconCode: 'local_shipping_rounded',
    ),
  ];

  Future<List<VisaServiceModel>> getPopularCountries() async {
    try {
      final list = await _remoteDataSource.getVisaServices();
      if (list.isNotEmpty) return list;
    } catch (_) {
      // Fallback
    }
    return _mockVisaCountries;
  }

  Future<List<VisaServiceModel>> getAllCountries() async {
    try {
      final list = await _remoteDataSource.getVisaServices();
      if (list.isNotEmpty) return list;
    } catch (_) {
      // Fallback
    }
    return _mockVisaCountries;
  }

  List<VisaServiceFeature> getFeatures() => _features;

  Future<VisaServiceModel> createVisaService(VisaServiceModel service) =>
      _remoteDataSource.createVisaService(service);

  Future<VisaServiceModel> updateVisaService(VisaServiceModel service) =>
      _remoteDataSource.updateVisaService(service);

  Future<void> deleteVisaService(String id) =>
      _remoteDataSource.deleteVisaService(id);
}

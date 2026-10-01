import '../datasources/visa_remote_data_source.dart';
import '../models/visa_model.dart';

/// Repository for visa services connecting to Supabase
class VisaRepository {
  final VisaRemoteDataSource _remoteDataSource;

  VisaRepository({VisaRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? VisaRemoteDataSourceImpl();

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
    return _remoteDataSource.getVisaServices(activeOnly: true);
  }

  Future<List<VisaServiceModel>> getAllCountries({bool activeOnly = true}) async {
    return _remoteDataSource.getVisaServices(activeOnly: activeOnly);
  }

  Future<VisaServiceModel?> getVisaServiceById(String id) async {
    return _remoteDataSource.getVisaServiceById(id);
  }

  List<VisaServiceFeature> getFeatures() => _features;

  Future<VisaServiceModel> createVisaService(VisaServiceModel service) =>
      _remoteDataSource.createVisaService(service);

  Future<VisaServiceModel> updateVisaService(VisaServiceModel service) =>
      _remoteDataSource.updateVisaService(service);

  Future<void> deleteVisaService(String id) =>
      _remoteDataSource.deleteVisaService(id);

  // ── Visa Applications ──────────────────────────────────────────────────────
  Future<List<VisaApplicationModel>> getVisaApplications({String? userId, String? status}) =>
      _remoteDataSource.getVisaApplications(userId: userId, status: status);

  Future<VisaApplicationModel?> getVisaApplicationById(String id) =>
      _remoteDataSource.getVisaApplicationById(id);

  Future<VisaApplicationModel> submitVisaApplication(VisaApplicationModel application) =>
      _remoteDataSource.createVisaApplication(application);

  Future<VisaApplicationModel> updateVisaApplicationStatus(String id, String status, {String? adminNotes}) =>
      _remoteDataSource.updateVisaApplicationStatus(id, status, adminNotes: adminNotes);

  Future<void> deleteVisaApplication(String id) =>
      _remoteDataSource.deleteVisaApplication(id);
}

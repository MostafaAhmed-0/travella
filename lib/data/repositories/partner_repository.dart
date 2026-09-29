import '../datasources/partner_remote_data_source.dart';
import '../models/partner_model.dart';

/// Repository for airline & hotel partners connected to Supabase
class PartnerRepository {
  final PartnerRemoteDataSource _remoteDataSource;

  PartnerRepository({PartnerRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? PartnerRemoteDataSourceImpl();

  Future<List<PartnerModel>> getPartners({bool activeOnly = true}) async {
    return _remoteDataSource.getPartners(activeOnly: activeOnly);
  }

  Future<PartnerModel> createPartner(PartnerModel partner) =>
      _remoteDataSource.createPartner(partner);

  Future<PartnerModel> updatePartner(PartnerModel partner) =>
      _remoteDataSource.updatePartner(partner);

  Future<void> deletePartner(String id) =>
      _remoteDataSource.deletePartner(id);
}

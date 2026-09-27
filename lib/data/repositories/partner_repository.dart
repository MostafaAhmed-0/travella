import '../datasources/partner_remote_data_source.dart';
import '../models/partner_model.dart';

/// Repository for partners
class PartnerRepository {
  final PartnerRemoteDataSource _remoteDataSource;

  PartnerRepository({PartnerRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? PartnerRemoteDataSourceImpl();

  static const List<PartnerModel> _mockPartners = [
    PartnerModel(
      id: 'p1',
      name: 'Emirates Airlines',
      category: 'Airlines',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/d/d0/Emirates_logo.svg',
      website: 'https://www.emirates.com',
    ),
    PartnerModel(
      id: 'p2',
      name: 'EgyptAir',
      category: 'Airlines',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/a/a2/EgyptAir_logo.svg',
      website: 'https://www.egyptair.com',
    ),
    PartnerModel(
      id: 'p3',
      name: 'Turkish Airlines',
      category: 'Airlines',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/0/00/Turkish_Airlines_logo_2019.svg',
      website: 'https://www.turkishairlines.com',
    ),
    PartnerModel(
      id: 'p4',
      name: 'Four Seasons Hotels',
      category: 'Hotels',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/1/1b/Four_Seasons_Hotels_and_Resorts_logo.svg',
      website: 'https://www.fourseasons.com',
    ),
    PartnerModel(
      id: 'p5',
      name: 'Marriott International',
      category: 'Hotels',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/2/20/Marriott_International_Logo.svg',
      website: 'https://www.marriott.com',
    ),
  ];

  Future<List<PartnerModel>> getPartners() async {
    try {
      final list = await _remoteDataSource.getPartners();
      if (list.isNotEmpty) return list;
    } catch (_) {
      // Fallback
    }
    return _mockPartners;
  }

  Future<PartnerModel> createPartner(PartnerModel partner) =>
      _remoteDataSource.createPartner(partner);

  Future<PartnerModel> updatePartner(PartnerModel partner) =>
      _remoteDataSource.updatePartner(partner);

  Future<void> deletePartner(String id) =>
      _remoteDataSource.deletePartner(id);
}

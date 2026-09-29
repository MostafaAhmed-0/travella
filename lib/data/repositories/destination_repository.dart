import '../datasources/destination_remote_data_source.dart';
import '../models/destination_model.dart';

/// Repository for Destination data connecting directly to Supabase
class DestinationRepository {
  final DestinationRemoteDataSource _remoteDataSource;

  DestinationRepository({DestinationRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? DestinationRemoteDataSourceImpl();

  Future<List<DestinationModel>> getDestinations({String? region, bool? featuredOnly}) async {
    final items = await _remoteDataSource.getDestinations(featuredOnly: featuredOnly);
    if (region == null || region == 'All') return items;
    return items.where((d) => d.region.toLowerCase() == region.toLowerCase() || d.tags.any((t) => t.toLowerCase() == region.toLowerCase()) || d.country.toLowerCase().contains(region.toLowerCase())).toList();
  }

  Future<List<DestinationModel>> getFeaturedDestinations() async {
    return _remoteDataSource.getDestinations(featuredOnly: true);
  }

  Future<DestinationModel?> getDestinationById(String id) async {
    return _remoteDataSource.getDestinationById(id);
  }

  Future<DestinationModel> createDestination(DestinationModel destination) async {
    return _remoteDataSource.createDestination(destination);
  }

  Future<DestinationModel> updateDestination(DestinationModel destination) async {
    return _remoteDataSource.updateDestination(destination);
  }

  Future<void> deleteDestination(String id) async {
    return _remoteDataSource.deleteDestination(id);
  }
}

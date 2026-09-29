import '../datasources/hotel_remote_data_source.dart';
import '../models/hotel_model.dart';

/// Repository for luxury hotels and resorts connecting to Supabase
class HotelRepository {
  final HotelRemoteDataSource _remoteDataSource;

  HotelRepository({HotelRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? HotelRemoteDataSourceImpl();

  Future<List<HotelModel>> getFeaturedHotels() async {
    return _remoteDataSource.getHotels(featuredOnly: true, activeOnly: true);
  }

  Future<List<HotelModel>> getAllHotels({bool activeOnly = true}) async {
    return _remoteDataSource.getHotels(activeOnly: activeOnly);
  }

  Future<HotelModel?> getHotelById(String id) async {
    return _remoteDataSource.getHotelById(id);
  }

  Future<HotelModel> createHotel(HotelModel hotel) => _remoteDataSource.createHotel(hotel);
  Future<HotelModel> updateHotel(HotelModel hotel) => _remoteDataSource.updateHotel(hotel);
  Future<void> deleteHotel(String id) => _remoteDataSource.deleteHotel(id);
}

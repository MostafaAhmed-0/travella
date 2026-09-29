import '../datasources/tour_remote_data_source.dart';
import '../models/tour_model.dart';

/// Repository for tours connecting to Supabase
class TourRepository {
  final TourRemoteDataSource _remoteDataSource;

  TourRepository({TourRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? TourRemoteDataSourceImpl();

  Future<List<TourModel>> getDomesticTours({bool? featuredOnly, bool activeOnly = true}) async {
    return _remoteDataSource.getTours(
      type: TourType.domestic,
      featuredOnly: featuredOnly,
      activeOnly: activeOnly,
    );
  }

  Future<List<TourModel>> getInternationalTours({bool? featuredOnly, bool activeOnly = true}) async {
    return _remoteDataSource.getTours(
      type: TourType.international,
      featuredOnly: featuredOnly,
      activeOnly: activeOnly,
    );
  }

  Future<List<TourModel>> getHajjTours({bool? featuredOnly, bool activeOnly = true}) async {
    return _remoteDataSource.getTours(
      type: TourType.hajj,
      featuredOnly: featuredOnly,
      activeOnly: activeOnly,
    );
  }

  Future<List<TourModel>> getUmrahTours({bool? featuredOnly, bool activeOnly = true}) async {
    return _remoteDataSource.getTours(
      type: TourType.umrah,
      featuredOnly: featuredOnly,
      activeOnly: activeOnly,
    );
  }

  Future<List<TourModel>> getHajjUmrahTours({bool? featuredOnly, bool activeOnly = true}) async {
    final hajj = await getHajjTours(featuredOnly: featuredOnly, activeOnly: activeOnly);
    final umrah = await getUmrahTours(featuredOnly: featuredOnly, activeOnly: activeOnly);
    return [...hajj, ...umrah];
  }

  Future<List<TourModel>> getFeaturedTours({bool activeOnly = true}) async {
    return _remoteDataSource.getTours(
      featuredOnly: true,
      activeOnly: activeOnly,
    );
  }

  Future<List<TourModel>> getAllTours({bool activeOnly = true}) async {
    return _remoteDataSource.getTours(activeOnly: activeOnly);
  }

  Future<TourModel?> getTourById(String id) async {
    return _remoteDataSource.getTourById(id);
  }

  Future<TourModel> createTour(TourModel tour) => _remoteDataSource.createTour(tour);
  Future<TourModel> updateTour(TourModel tour) => _remoteDataSource.updateTour(tour);
  Future<void> deleteTour(String id) => _remoteDataSource.deleteTour(id);
}

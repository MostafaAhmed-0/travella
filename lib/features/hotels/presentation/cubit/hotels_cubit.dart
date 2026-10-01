import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/traveler_selector.dart';
import '../../../../data/models/hotel_model.dart';
import '../../../../data/repositories/hotel_repository.dart';
import 'hotels_state.dart';

class HotelsCubit extends Cubit<HotelsState> {
  final HotelRepository _hotelRepository;

  HotelsCubit({HotelRepository? hotelRepository})
      : _hotelRepository = hotelRepository ?? HotelRepository(),
        super(const HotelsState());

  /// Load hotels directly from Supabase
  Future<void> loadHotels({
    String? destination,
    DateTime? checkIn,
    DateTime? checkOut,
    TravelerSelection? travelers,
  }) async {
    emit(state.copyWith(
      status: HotelsStatus.loading,
      destination: destination ?? state.destination,
      checkIn: checkIn ?? state.checkIn,
      checkOut: checkOut ?? state.checkOut,
      travelers: travelers ?? state.travelers,
    ));

    try {
      final hotels = await _hotelRepository.getAllHotels(activeOnly: true);

      if (hotels.isEmpty) {
        emit(state.copyWith(
          status: HotelsStatus.noResults,
          allHotels: [],
          filteredHotels: [],
        ));
        return;
      }

      // Determine price limits dynamically from real data
      double minP = hotels.first.price;
      double maxP = hotels.first.price;
      for (final h in hotels) {
        if (h.price < minP) minP = h.price;
        if (h.price > maxP) maxP = h.price;
      }

      final updatedState = state.copyWith(
        status: HotelsStatus.loaded,
        allHotels: hotels,
        minPrice: minP.floorToDouble(),
        maxPrice: (maxP > minP ? maxP : minP + 100).ceilToDouble(),
      );

      _applyFiltersAndSort(updatedState);
    } catch (e) {
      emit(state.copyWith(
        status: HotelsStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// Update destination query from search bar
  void updateDestination(String query) {
    final updated = state.copyWith(destination: query);
    _applyFiltersAndSort(updated);
  }

  /// Update check-in and check-out dates
  void updateDates(DateTime? checkIn, DateTime? checkOut) {
    emit(state.copyWith(checkIn: checkIn, checkOut: checkOut));
  }

  /// Update travelers selection (Adults, Children, Child Ages, Rooms)
  void updateTravelers(TravelerSelection selection) {
    emit(state.copyWith(travelers: selection));
  }

  /// Update price range filter
  void updatePriceRange(double min, double max) {
    final updated = state.copyWith(
      activeMinPrice: min,
      activeMaxPrice: max,
    );
    _applyFiltersAndSort(updated);
  }

  /// Toggle star rating filter (e.g. 3, 4, 5)
  void toggleStarRating(int stars) {
    final starsSet = Set<int>.from(state.selectedStars);
    if (starsSet.contains(stars)) {
      starsSet.remove(stars);
    } else {
      starsSet.add(stars);
    }
    final updated = state.copyWith(selectedStars: starsSet);
    _applyFiltersAndSort(updated);
  }

  /// Toggle amenity filter (e.g. 'Wi-Fi', 'Swimming Pool', 'Spa', 'Breakfast', 'Gym', 'Parking', 'All Inclusive')
  void toggleAmenity(String amenity) {
    final amenitiesSet = Set<String>.from(state.selectedAmenities);
    if (amenitiesSet.contains(amenity)) {
      amenitiesSet.remove(amenity);
    } else {
      amenitiesSet.add(amenity);
    }
    final updated = state.copyWith(selectedAmenities: amenitiesSet);
    _applyFiltersAndSort(updated);
  }

  /// Update sorting option
  void updateSortBy(HotelSortOption sortOption) {
    final updated = state.copyWith(sortBy: sortOption);
    _applyFiltersAndSort(updated);
  }

  /// Reset all filters to default
  void resetFilters() {
    final updated = state.copyWith(
      destination: '',
      resetActiveMinPrice: true,
      resetActiveMaxPrice: true,
      selectedStars: const {},
      selectedAmenities: const {},
      sortBy: HotelSortOption.recommended,
    );
    _applyFiltersAndSort(updated);
  }

  /// Core filter & sort engine
  void _applyFiltersAndSort(HotelsState currentState) {
    if (currentState.allHotels.isEmpty) {
      emit(currentState.copyWith(
        status: HotelsStatus.noResults,
        filteredHotels: const [],
      ));
      return;
    }

    var result = List<HotelModel>.from(currentState.allHotels);

    // 1. Destination / Name / City filter
    final q = currentState.destination.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result.where((h) {
        final name = h.name.toLowerCase();
        final nameAr = (h.nameAr ?? '').toLowerCase();
        final location = h.location.toLowerCase();
        final city = h.city.toLowerCase();
        final country = h.country.toLowerCase();
        final desc = h.description.toLowerCase();
        final room = h.roomType.toLowerCase();
        return name.contains(q) ||
            nameAr.contains(q) ||
            location.contains(q) ||
            city.contains(q) ||
            country.contains(q) ||
            desc.contains(q) ||
            room.contains(q);
      }).toList();
    }

    // 2. Star ratings filter (3, 4, 5)
    if (currentState.selectedStars.isNotEmpty) {
      result = result.where((h) => currentState.selectedStars.contains(h.stars)).toList();
    }

    // 3. Price range filter
    if (currentState.activeMinPrice != null) {
      result = result.where((h) => h.price >= currentState.activeMinPrice!).toList();
    }
    if (currentState.activeMaxPrice != null) {
      result = result.where((h) => h.price <= currentState.activeMaxPrice!).toList();
    }

    // 4. Amenities filter
    if (currentState.selectedAmenities.isNotEmpty) {
      result = result.where((h) {
        final hotelAmenitiesLower = h.amenities.map((a) => a.toLowerCase()).toList();
        for (final reqAmenity in currentState.selectedAmenities) {
          final reqLower = reqAmenity.toLowerCase();
          final matches = hotelAmenitiesLower.any((ha) =>
              ha.contains(reqLower) ||
              (reqLower.contains('wi-fi') && (ha.contains('wifi') || ha.contains('internet'))) ||
              (reqLower.contains('pool') && ha.contains('pool')) ||
              (reqLower.contains('spa') && (ha.contains('spa') || ha.contains('wellness'))) ||
              (reqLower.contains('breakfast') && ha.contains('breakfast')) ||
              (reqLower.contains('gym') && (ha.contains('gym') || ha.contains('fitness'))) ||
              (reqLower.contains('parking') && ha.contains('parking')) ||
              (reqLower.contains('inclusive') && (ha.contains('all inclusive') || ha.contains('inclusive'))));
          if (!matches) {
            return false;
          }
        }
        return true;
      }).toList();
    }

    // 5. Sorting
    switch (currentState.sortBy) {
      case HotelSortOption.recommended:
        result.sort((a, b) {
          if (a.featured != b.featured) {
            return a.featured ? -1 : 1;
          }
          return b.rating.compareTo(a.rating);
        });
        break;
      case HotelSortOption.priceLowToHigh:
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case HotelSortOption.priceHighToLow:
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case HotelSortOption.rating:
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }

    emit(currentState.copyWith(
      status: result.isEmpty ? HotelsStatus.noResults : HotelsStatus.loaded,
      filteredHotels: result,
    ));
  }
}

import 'package:equatable/equatable.dart';
import '../../../../core/widgets/traveler_selector.dart';
import '../../../../data/models/hotel_model.dart';

enum HotelsStatus { initial, loading, loaded, noResults, error }

enum HotelSortOption {
  recommended,
  priceLowToHigh,
  priceHighToLow,
  rating,
}

class HotelsState extends Equatable {
  final HotelsStatus status;
  final List<HotelModel> allHotels;
  final List<HotelModel> filteredHotels;
  final String? errorMessage;

  // Search criteria
  final String destination;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final TravelerSelection travelers;

  // Filter criteria
  final double minPrice;
  final double maxPrice;
  final double? activeMinPrice;
  final double? activeMaxPrice;
  final Set<int> selectedStars;
  final Set<String> selectedAmenities;
  final HotelSortOption sortBy;

  const HotelsState({
    this.status = HotelsStatus.initial,
    this.allHotels = const [],
    this.filteredHotels = const [],
    this.errorMessage,
    this.destination = '',
    this.checkIn,
    this.checkOut,
    this.travelers = const TravelerSelection(adults: 2, children: 0, childAges: [], rooms: 1),
    this.minPrice = 0.0,
    this.maxPrice = 5000.0,
    this.activeMinPrice,
    this.activeMaxPrice,
    this.selectedStars = const {},
    this.selectedAmenities = const {},
    this.sortBy = HotelSortOption.recommended,
  });

  bool get isLoading => status == HotelsStatus.loading;
  bool get hasError => status == HotelsStatus.error;
  bool get isNoResults => status == HotelsStatus.noResults;
  bool get isLoaded => status == HotelsStatus.loaded;

  int get totalActiveFiltersCount {
    int count = 0;
    if (selectedStars.isNotEmpty) count += selectedStars.length;
    if (selectedAmenities.isNotEmpty) count += selectedAmenities.length;
    if (activeMinPrice != null || activeMaxPrice != null) count += 1;
    if (sortBy != HotelSortOption.recommended) count += 1;
    return count;
  }

  HotelsState copyWith({
    HotelsStatus? status,
    List<HotelModel>? allHotels,
    List<HotelModel>? filteredHotels,
    String? errorMessage,
    String? destination,
    DateTime? checkIn,
    DateTime? checkOut,
    TravelerSelection? travelers,
    double? minPrice,
    double? maxPrice,
    double? activeMinPrice,
    bool resetActiveMinPrice = false,
    double? activeMaxPrice,
    bool resetActiveMaxPrice = false,
    Set<int>? selectedStars,
    Set<String>? selectedAmenities,
    HotelSortOption? sortBy,
  }) {
    return HotelsState(
      status: status ?? this.status,
      allHotels: allHotels ?? this.allHotels,
      filteredHotels: filteredHotels ?? this.filteredHotels,
      errorMessage: errorMessage,
      destination: destination ?? this.destination,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      travelers: travelers ?? this.travelers,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      activeMinPrice: resetActiveMinPrice ? null : (activeMinPrice ?? this.activeMinPrice),
      activeMaxPrice: resetActiveMaxPrice ? null : (activeMaxPrice ?? this.activeMaxPrice),
      selectedStars: selectedStars ?? this.selectedStars,
      selectedAmenities: selectedAmenities ?? this.selectedAmenities,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allHotels,
        filteredHotels,
        errorMessage,
        destination,
        checkIn,
        checkOut,
        travelers,
        minPrice,
        maxPrice,
        activeMinPrice,
        activeMaxPrice,
        selectedStars,
        selectedAmenities,
        sortBy,
      ];
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../data/models/hotel_model.dart';
import '../../../../data/repositories/hotel_repository.dart';

class AdminHotelsState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;
  final List<HotelModel> allHotels;
  final List<HotelModel> filteredHotels;
  final String searchQuery;
  final bool? filterActive;
  final bool? filterFeatured;

  const AdminHotelsState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.allHotels = const [],
    this.filteredHotels = const [],
    this.searchQuery = '',
    this.filterActive,
    this.filterFeatured,
  });

  AdminHotelsState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    List<HotelModel>? allHotels,
    List<HotelModel>? filteredHotels,
    String? searchQuery,
    bool? filterActive,
    bool? filterFeatured,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AdminHotelsState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      allHotels: allHotels ?? this.allHotels,
      filteredHotels: filteredHotels ?? this.filteredHotels,
      searchQuery: searchQuery ?? this.searchQuery,
      filterActive: filterActive ?? this.filterActive,
      filterFeatured: filterFeatured ?? this.filterFeatured,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSaving,
        errorMessage,
        successMessage,
        allHotels,
        filteredHotels,
        searchQuery,
        filterActive,
        filterFeatured,
      ];
}

class AdminHotelsCubit extends Cubit<AdminHotelsState> {
  final HotelRepository _hotelRepository;

  AdminHotelsCubit({required HotelRepository hotelRepository})
      : _hotelRepository = hotelRepository,
        super(const AdminHotelsState());

  Future<void> loadHotels() async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      final list = await _hotelRepository.getAllHotels();
      final filtered = _applyFilters(list, state.searchQuery, state.filterActive, state.filterFeatured);
      emit(state.copyWith(
        isLoading: false,
        allHotels: list,
        filteredHotels: filtered,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load hotels: ${e.toString().replaceAll('Exception: ', '')}',
      ));
    }
  }

  void searchHotels(String query) {
    final filtered = _applyFilters(state.allHotels, query, state.filterActive, state.filterFeatured);
    emit(state.copyWith(searchQuery: query, filteredHotels: filtered));
  }

  void filterByActive(bool? active) {
    final filtered = _applyFilters(state.allHotels, state.searchQuery, active, state.filterFeatured);
    emit(state.copyWith(filterActive: active, filteredHotels: filtered));
  }

  void filterByFeatured(bool? featured) {
    final filtered = _applyFilters(state.allHotels, state.searchQuery, state.filterActive, featured);
    emit(state.copyWith(filterFeatured: featured, filteredHotels: filtered));
  }

  Future<bool> createHotel(HotelModel hotel) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));
    try {
      final created = await _hotelRepository.createHotel(hotel);
      final updatedList = [created, ...state.allHotels];
      final filtered = _applyFilters(updatedList, state.searchQuery, state.filterActive, state.filterFeatured);
      emit(state.copyWith(
        isSaving: false,
        allHotels: updatedList,
        filteredHotels: filtered,
        successMessage: 'Hotel "${created.name}" created successfully.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to create hotel: ${e.toString().replaceAll('Exception: ', '')}',
      ));
      return false;
    }
  }

  Future<bool> updateHotel(HotelModel hotel) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));
    try {
      final updated = await _hotelRepository.updateHotel(hotel);
      final updatedList = state.allHotels.map((h) => h.id == updated.id ? updated : h).toList();
      final filtered = _applyFilters(updatedList, state.searchQuery, state.filterActive, state.filterFeatured);
      emit(state.copyWith(
        isSaving: false,
        allHotels: updatedList,
        filteredHotels: filtered,
        successMessage: 'Hotel "${updated.name}" updated successfully.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to update hotel: ${e.toString().replaceAll('Exception: ', '')}',
      ));
      return false;
    }
  }

  Future<bool> deleteHotel(String id) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));
    try {
      await _hotelRepository.deleteHotel(id);
      final updatedList = state.allHotels.where((h) => h.id != id).toList();
      final filtered = _applyFilters(updatedList, state.searchQuery, state.filterActive, state.filterFeatured);
      emit(state.copyWith(
        isSaving: false,
        allHotels: updatedList,
        filteredHotels: filtered,
        successMessage: 'Hotel deleted successfully.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to delete hotel: ${e.toString().replaceAll('Exception: ', '')}',
      ));
      return false;
    }
  }

  Future<void> toggleActive(HotelModel hotel) async {
    final updated = hotel.copyWith(active: !hotel.active);
    await updateHotel(updated);
  }

  Future<void> toggleFeatured(HotelModel hotel) async {
    final updated = hotel.copyWith(featured: !hotel.featured);
    await updateHotel(updated);
  }

  Future<bool> updatePrice(String hotelId, double newPrice, {String currency = 'USD'}) async {
    final hotel = state.allHotels.firstWhere((h) => h.id == hotelId);
    final updated = hotel.copyWith(price: newPrice, currency: currency);
    return await updateHotel(updated);
  }

  List<HotelModel> _applyFilters(
    List<HotelModel> list,
    String query,
    bool? active,
    bool? featured,
  ) {
    return list.where((item) {
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        final matchName = item.name.toLowerCase().contains(q);
        final matchNameAr = item.nameAr?.toLowerCase().contains(q) ?? false;
        final matchLoc = item.location.toLowerCase().contains(q);
        if (!matchName && !matchNameAr && !matchLoc) return false;
      }
      if (active != null && item.active != active) return false;
      if (featured != null && item.featured != featured) return false;
      return true;
    }).toList();
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../data/models/tour_model.dart';
import '../../../../data/repositories/tour_repository.dart';

class AdminToursState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;
  final List<TourModel> allTours;
  final List<TourModel> filteredTours;
  final String searchQuery;
  final String? selectedType; // 'all', 'domestic', 'international', 'hajj', 'umrah'
  final bool? filterActive;
  final bool? filterFeatured;

  const AdminToursState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.allTours = const [],
    this.filteredTours = const [],
    this.searchQuery = '',
    this.selectedType,
    this.filterActive,
    this.filterFeatured,
  });

  AdminToursState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    List<TourModel>? allTours,
    List<TourModel>? filteredTours,
    String? searchQuery,
    String? selectedType,
    bool? filterActive,
    bool? filterFeatured,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AdminToursState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      allTours: allTours ?? this.allTours,
      filteredTours: filteredTours ?? this.filteredTours,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedType: selectedType ?? this.selectedType,
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
        allTours,
        filteredTours,
        searchQuery,
        selectedType,
        filterActive,
        filterFeatured,
      ];
}

class AdminToursCubit extends Cubit<AdminToursState> {
  final TourRepository _tourRepository;

  AdminToursCubit({required TourRepository tourRepository})
      : _tourRepository = tourRepository,
        super(const AdminToursState());

  Future<void> loadTours() async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      final tours = await _tourRepository.getAllTours();
      final filtered = _applyFilters(
        tours,
        state.searchQuery,
        state.selectedType,
        state.filterActive,
        state.filterFeatured,
      );
      emit(state.copyWith(
        isLoading: false,
        allTours: tours,
        filteredTours: filtered,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load tours: ${e.toString().replaceAll('Exception: ', '')}',
      ));
    }
  }

  void searchTours(String query) {
    final filtered = _applyFilters(
      state.allTours,
      query,
      state.selectedType,
      state.filterActive,
      state.filterFeatured,
    );
    emit(state.copyWith(searchQuery: query, filteredTours: filtered));
  }

  void filterByType(String? type) {
    final filtered = _applyFilters(
      state.allTours,
      state.searchQuery,
      type,
      state.filterActive,
      state.filterFeatured,
    );
    emit(state.copyWith(selectedType: type, filteredTours: filtered));
  }

  void filterByActive(bool? active) {
    final filtered = _applyFilters(
      state.allTours,
      state.searchQuery,
      state.selectedType,
      active,
      state.filterFeatured,
    );
    emit(state.copyWith(filterActive: active, filteredTours: filtered));
  }

  void filterByFeatured(bool? featured) {
    final filtered = _applyFilters(
      state.allTours,
      state.searchQuery,
      state.selectedType,
      state.filterActive,
      featured,
    );
    emit(state.copyWith(filterFeatured: featured, filteredTours: filtered));
  }

  Future<bool> createTour(TourModel tour) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));
    try {
      final created = await _tourRepository.createTour(tour);
      final updatedList = [created, ...state.allTours];
      final filtered = _applyFilters(
        updatedList,
        state.searchQuery,
        state.selectedType,
        state.filterActive,
        state.filterFeatured,
      );
      emit(state.copyWith(
        isSaving: false,
        allTours: updatedList,
        filteredTours: filtered,
        successMessage: 'Tour "${created.title}" created successfully.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to create tour: ${e.toString().replaceAll('Exception: ', '')}',
      ));
      return false;
    }
  }

  Future<bool> updateTour(TourModel tour) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));
    try {
      final updated = await _tourRepository.updateTour(tour);
      final updatedList = state.allTours.map((t) => t.id == updated.id ? updated : t).toList();
      final filtered = _applyFilters(
        updatedList,
        state.searchQuery,
        state.selectedType,
        state.filterActive,
        state.filterFeatured,
      );
      emit(state.copyWith(
        isSaving: false,
        allTours: updatedList,
        filteredTours: filtered,
        successMessage: 'Tour "${updated.title}" updated successfully.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to update tour: ${e.toString().replaceAll('Exception: ', '')}',
      ));
      return false;
    }
  }

  Future<bool> deleteTour(String id) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));
    try {
      await _tourRepository.deleteTour(id);
      final updatedList = state.allTours.where((t) => t.id != id).toList();
      final filtered = _applyFilters(
        updatedList,
        state.searchQuery,
        state.selectedType,
        state.filterActive,
        state.filterFeatured,
      );
      emit(state.copyWith(
        isSaving: false,
        allTours: updatedList,
        filteredTours: filtered,
        successMessage: 'Tour deleted successfully.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to delete tour: ${e.toString().replaceAll('Exception: ', '')}',
      ));
      return false;
    }
  }

  Future<void> toggleActive(TourModel tour) async {
    final updated = tour.copyWith(active: !tour.active);
    await updateTour(updated);
  }

  Future<void> toggleFeatured(TourModel tour) async {
    final updated = tour.copyWith(featured: !tour.featured);
    await updateTour(updated);
  }

  Future<bool> updatePrice(String tourId, double newPrice, {String currency = 'USD'}) async {
    final tour = state.allTours.firstWhere((t) => t.id == tourId);
    final updated = tour.copyWith(price: newPrice, currency: currency);
    return await updateTour(updated);
  }

  List<TourModel> _applyFilters(
    List<TourModel> tours,
    String query,
    String? type,
    bool? active,
    bool? featured,
  ) {
    return tours.where((tour) {
      // Search
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        final matchTitle = tour.title.toLowerCase().contains(q);
        final matchTitleAr = tour.titleAr?.toLowerCase().contains(q) ?? false;
        final matchDest = tour.destination.toLowerCase().contains(q);
        final matchCountry = tour.country.toLowerCase().contains(q);
        if (!matchTitle && !matchTitleAr && !matchDest && !matchCountry) {
          return false;
        }
      }

      // Type
      if (type != null && type != 'all') {
        if (tour.type.toDbString() != type) return false;
      }

      // Active
      if (active != null && tour.active != active) return false;

      // Featured
      if (featured != null && tour.featured != featured) return false;

      return true;
    }).toList();
  }
}

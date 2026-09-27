import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../data/models/destination_model.dart';
import '../../../../data/repositories/destination_repository.dart';

class AdminDestinationsState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;
  final List<DestinationModel> allDestinations;
  final List<DestinationModel> filteredDestinations;
  final String searchQuery;
  final bool? filterFeatured;

  const AdminDestinationsState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.allDestinations = const [],
    this.filteredDestinations = const [],
    this.searchQuery = '',
    this.filterFeatured,
  });

  AdminDestinationsState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    List<DestinationModel>? allDestinations,
    List<DestinationModel>? filteredDestinations,
    String? searchQuery,
    bool? filterFeatured,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AdminDestinationsState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      allDestinations: allDestinations ?? this.allDestinations,
      filteredDestinations: filteredDestinations ?? this.filteredDestinations,
      searchQuery: searchQuery ?? this.searchQuery,
      filterFeatured: filterFeatured ?? this.filterFeatured,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSaving,
        errorMessage,
        successMessage,
        allDestinations,
        filteredDestinations,
        searchQuery,
        filterFeatured,
      ];
}

class AdminDestinationsCubit extends Cubit<AdminDestinationsState> {
  final DestinationRepository _destinationRepository;

  AdminDestinationsCubit({required DestinationRepository destinationRepository})
      : _destinationRepository = destinationRepository,
        super(const AdminDestinationsState());

  Future<void> loadDestinations() async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      final list = await _destinationRepository.getDestinations();
      final filtered = _applyFilters(list, state.searchQuery, state.filterFeatured);
      emit(state.copyWith(
        isLoading: false,
        allDestinations: list,
        filteredDestinations: filtered,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load destinations: ${e.toString().replaceAll('Exception: ', '')}',
      ));
    }
  }

  void searchDestinations(String query) {
    final filtered = _applyFilters(state.allDestinations, query, state.filterFeatured);
    emit(state.copyWith(searchQuery: query, filteredDestinations: filtered));
  }

  void filterByFeatured(bool? featured) {
    final filtered = _applyFilters(state.allDestinations, state.searchQuery, featured);
    emit(state.copyWith(filterFeatured: featured, filteredDestinations: filtered));
  }

  Future<bool> createDestination(DestinationModel destination) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));
    try {
      final created = await _destinationRepository.createDestination(destination);
      final updatedList = [created, ...state.allDestinations];
      final filtered = _applyFilters(updatedList, state.searchQuery, state.filterFeatured);
      emit(state.copyWith(
        isSaving: false,
        allDestinations: updatedList,
        filteredDestinations: filtered,
        successMessage: 'Destination "${created.name}" created successfully.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to create destination: ${e.toString().replaceAll('Exception: ', '')}',
      ));
      return false;
    }
  }

  Future<bool> updateDestination(DestinationModel destination) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));
    try {
      final updated = await _destinationRepository.updateDestination(destination);
      final updatedList = state.allDestinations.map((d) => d.id == updated.id ? updated : d).toList();
      final filtered = _applyFilters(updatedList, state.searchQuery, state.filterFeatured);
      emit(state.copyWith(
        isSaving: false,
        allDestinations: updatedList,
        filteredDestinations: filtered,
        successMessage: 'Destination "${updated.name}" updated successfully.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to update destination: ${e.toString().replaceAll('Exception: ', '')}',
      ));
      return false;
    }
  }

  Future<bool> deleteDestination(String id) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));
    try {
      await _destinationRepository.deleteDestination(id);
      final updatedList = state.allDestinations.where((d) => d.id != id).toList();
      final filtered = _applyFilters(updatedList, state.searchQuery, state.filterFeatured);
      emit(state.copyWith(
        isSaving: false,
        allDestinations: updatedList,
        filteredDestinations: filtered,
        successMessage: 'Destination deleted successfully.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to delete destination: ${e.toString().replaceAll('Exception: ', '')}',
      ));
      return false;
    }
  }

  Future<void> toggleFeatured(DestinationModel destination) async {
    final updated = destination.copyWith(featured: !destination.featured);
    await updateDestination(updated);
  }

  List<DestinationModel> _applyFilters(
    List<DestinationModel> list,
    String query,
    bool? featured,
  ) {
    return list.where((item) {
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        final matchName = item.name.toLowerCase().contains(q);
        final matchNameAr = item.nameAr?.toLowerCase().contains(q) ?? false;
        final matchCountry = item.country.toLowerCase().contains(q);
        if (!matchName && !matchNameAr && !matchCountry) return false;
      }
      if (featured != null && item.featured != featured) return false;
      return true;
    }).toList();
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../data/models/visa_model.dart';
import '../../../../data/repositories/visa_repository.dart';

class AdminVisaState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;
  final List<VisaServiceModel> allServices;
  final List<VisaServiceModel> filteredServices;
  final String searchQuery;
  final bool? filterActive;

  const AdminVisaState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.allServices = const [],
    this.filteredServices = const [],
    this.searchQuery = '',
    this.filterActive,
  });

  AdminVisaState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    List<VisaServiceModel>? allServices,
    List<VisaServiceModel>? filteredServices,
    String? searchQuery,
    bool? filterActive,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AdminVisaState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      allServices: allServices ?? this.allServices,
      filteredServices: filteredServices ?? this.filteredServices,
      searchQuery: searchQuery ?? this.searchQuery,
      filterActive: filterActive ?? this.filterActive,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSaving,
        errorMessage,
        successMessage,
        allServices,
        filteredServices,
        searchQuery,
        filterActive,
      ];
}

class AdminVisaCubit extends Cubit<AdminVisaState> {
  final VisaRepository _visaRepository;

  AdminVisaCubit({required VisaRepository visaRepository})
      : _visaRepository = visaRepository,
        super(const AdminVisaState());

  Future<void> loadVisaServices() async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      final list = await _visaRepository.getAllCountries();
      final filtered = _applyFilters(list, state.searchQuery, state.filterActive);
      emit(state.copyWith(
        isLoading: false,
        allServices: list,
        filteredServices: filtered,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load visa services: ${e.toString().replaceAll('Exception: ', '')}',
      ));
    }
  }

  void searchVisa(String query) {
    final filtered = _applyFilters(state.allServices, query, state.filterActive);
    emit(state.copyWith(searchQuery: query, filteredServices: filtered));
  }

  void filterByActive(bool? active) {
    final filtered = _applyFilters(state.allServices, state.searchQuery, active);
    emit(state.copyWith(filterActive: active, filteredServices: filtered));
  }

  Future<bool> createVisaService(VisaServiceModel service) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));
    try {
      final created = await _visaRepository.createVisaService(service);
      final updatedList = [created, ...state.allServices];
      final filtered = _applyFilters(updatedList, state.searchQuery, state.filterActive);
      emit(state.copyWith(
        isSaving: false,
        allServices: updatedList,
        filteredServices: filtered,
        successMessage: 'Visa service for "${created.country}" created successfully.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to create visa service: ${e.toString().replaceAll('Exception: ', '')}',
      ));
      return false;
    }
  }

  Future<bool> updateVisaService(VisaServiceModel service) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));
    try {
      final updated = await _visaRepository.updateVisaService(service);
      final updatedList = state.allServices.map((s) => s.id == updated.id ? updated : s).toList();
      final filtered = _applyFilters(updatedList, state.searchQuery, state.filterActive);
      emit(state.copyWith(
        isSaving: false,
        allServices: updatedList,
        filteredServices: filtered,
        successMessage: 'Visa service for "${updated.country}" updated successfully.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to update visa service: ${e.toString().replaceAll('Exception: ', '')}',
      ));
      return false;
    }
  }

  Future<bool> deleteVisaService(String id) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));
    try {
      await _visaRepository.deleteVisaService(id);
      final updatedList = state.allServices.where((s) => s.id != id).toList();
      final filtered = _applyFilters(updatedList, state.searchQuery, state.filterActive);
      emit(state.copyWith(
        isSaving: false,
        allServices: updatedList,
        filteredServices: filtered,
        successMessage: 'Visa service deleted successfully.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to delete visa service: ${e.toString().replaceAll('Exception: ', '')}',
      ));
      return false;
    }
  }

  Future<void> toggleActive(VisaServiceModel service) async {
    final updated = service.copyWith(active: !service.active);
    await updateVisaService(updated);
  }

  Future<bool> updatePrice(String serviceId, double newPrice) async {
    final service = state.allServices.firstWhere((s) => s.id == serviceId);
    final updated = service.copyWith(price: newPrice);
    return await updateVisaService(updated);
  }

  List<VisaServiceModel> _applyFilters(
    List<VisaServiceModel> list,
    String query,
    bool? active,
  ) {
    return list.where((item) {
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        final matchCountry = item.country.toLowerCase().contains(q);
        final matchCountryAr = item.countryAr?.toLowerCase().contains(q) ?? false;
        final matchType = item.visaType.toLowerCase().contains(q);
        if (!matchCountry && !matchCountryAr && !matchType) return false;
      }
      if (active != null && item.active != active) return false;
      return true;
    }).toList();
  }
}

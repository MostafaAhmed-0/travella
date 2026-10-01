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

  // Visa Applications
  final List<VisaApplicationModel> allApplications;
  final List<VisaApplicationModel> filteredApplications;
  final String applicationSearchQuery;
  final String selectedStatusFilter; // 'All', 'pending', 'under_review', 'missing_documents', 'approved', 'rejected', 'completed'
  final int selectedTab; // 0 = Services, 1 = Applications

  const AdminVisaState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.allServices = const [],
    this.filteredServices = const [],
    this.searchQuery = '',
    this.filterActive,
    this.allApplications = const [],
    this.filteredApplications = const [],
    this.applicationSearchQuery = '',
    this.selectedStatusFilter = 'All',
    this.selectedTab = 0,
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
    List<VisaApplicationModel>? allApplications,
    List<VisaApplicationModel>? filteredApplications,
    String? applicationSearchQuery,
    String? selectedStatusFilter,
    int? selectedTab,
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
      allApplications: allApplications ?? this.allApplications,
      filteredApplications: filteredApplications ?? this.filteredApplications,
      applicationSearchQuery: applicationSearchQuery ?? this.applicationSearchQuery,
      selectedStatusFilter: selectedStatusFilter ?? this.selectedStatusFilter,
      selectedTab: selectedTab ?? this.selectedTab,
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
        allApplications,
        filteredApplications,
        applicationSearchQuery,
        selectedStatusFilter,
        selectedTab,
      ];
}

class AdminVisaCubit extends Cubit<AdminVisaState> {
  final VisaRepository _visaRepository;

  AdminVisaCubit({required VisaRepository visaRepository})
      : _visaRepository = visaRepository,
        super(const AdminVisaState());

  Future<void> loadVisaData() async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      final servicesFuture = _visaRepository.getAllCountries();
      final applicationsFuture = _visaRepository.getVisaApplications();

      final results = await Future.wait([servicesFuture, applicationsFuture]);
      final services = results[0] as List<VisaServiceModel>;
      final applications = results[1] as List<VisaApplicationModel>;

      final filteredServices = _applyFilters(services, state.searchQuery, state.filterActive);
      final filteredApplications = _applyAppFilters(applications, state.applicationSearchQuery, state.selectedStatusFilter);

      emit(state.copyWith(
        isLoading: false,
        allServices: services,
        filteredServices: filteredServices,
        allApplications: applications,
        filteredApplications: filteredApplications,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load visa data: ${e.toString().replaceAll('Exception: ', '')}',
      ));
    }
  }

  Future<void> loadVisaServices() => loadVisaData();

  void setTab(int tabIndex) {
    emit(state.copyWith(selectedTab: tabIndex));
  }

  void searchVisa(String query) {
    final filtered = _applyFilters(state.allServices, query, state.filterActive);
    emit(state.copyWith(searchQuery: query, filteredServices: filtered));
  }

  void filterByActive(bool? active) {
    final filtered = _applyFilters(state.allServices, state.searchQuery, active);
    emit(state.copyWith(filterActive: active, filteredServices: filtered));
  }

  void searchApplications(String query) {
    final filtered = _applyAppFilters(state.allApplications, query, state.selectedStatusFilter);
    emit(state.copyWith(applicationSearchQuery: query, filteredApplications: filtered));
  }

  void filterApplicationsByStatus(String status) {
    final filtered = _applyAppFilters(state.allApplications, state.applicationSearchQuery, status);
    emit(state.copyWith(selectedStatusFilter: status, filteredApplications: filtered));
  }

  Future<bool> updateApplicationStatus(String applicationId, String newStatus, {String? adminNotes}) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));
    try {
      final updated = await _visaRepository.updateVisaApplicationStatus(
        applicationId,
        newStatus,
        adminNotes: adminNotes,
      );
      final updatedList = state.allApplications.map((a) => a.id == updated.id ? updated : a).toList();
      final filtered = _applyAppFilters(updatedList, state.applicationSearchQuery, state.selectedStatusFilter);
      emit(state.copyWith(
        isSaving: false,
        allApplications: updatedList,
        filteredApplications: filtered,
        successMessage: 'Application ${updated.referenceNumber} status updated to "$newStatus".',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to update application status: ${e.toString().replaceAll('Exception: ', '')}',
      ));
      return false;
    }
  }

  Future<bool> deleteApplication(String id) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));
    try {
      await _visaRepository.deleteVisaApplication(id);
      final updatedList = state.allApplications.where((a) => a.id != id).toList();
      final filtered = _applyAppFilters(updatedList, state.applicationSearchQuery, state.selectedStatusFilter);
      emit(state.copyWith(
        isSaving: false,
        allApplications: updatedList,
        filteredApplications: filtered,
        successMessage: 'Visa application deleted successfully.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to delete visa application: ${e.toString().replaceAll('Exception: ', '')}',
      ));
      return false;
    }
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

  List<VisaApplicationModel> _applyAppFilters(
    List<VisaApplicationModel> list,
    String query,
    String status,
  ) {
    return list.where((item) {
      if (status != 'All' && item.status.toLowerCase() != status.toLowerCase()) {
        return false;
      }
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        final matchRef = item.referenceNumber.toLowerCase().contains(q);
        final matchName = item.fullName.toLowerCase().contains(q);
        final matchEmail = item.email.toLowerCase().contains(q);
        final matchCountry = item.country.toLowerCase().contains(q);
        final matchPassport = item.passportNumber.toLowerCase().contains(q);
        if (!matchRef && !matchName && !matchEmail && !matchCountry && !matchPassport) return false;
      }
      return true;
    }).toList();
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../data/models/partner_model.dart';
import '../../../../data/repositories/partner_repository.dart';

class AdminPartnersState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;
  final List<PartnerModel> allPartners;
  final List<PartnerModel> filteredPartners;
  final String searchQuery;
  final bool? filterActive;

  const AdminPartnersState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.allPartners = const [],
    this.filteredPartners = const [],
    this.searchQuery = '',
    this.filterActive,
  });

  AdminPartnersState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    List<PartnerModel>? allPartners,
    List<PartnerModel>? filteredPartners,
    String? searchQuery,
    bool? filterActive,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AdminPartnersState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      allPartners: allPartners ?? this.allPartners,
      filteredPartners: filteredPartners ?? this.filteredPartners,
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
        allPartners,
        filteredPartners,
        searchQuery,
        filterActive,
      ];
}

class AdminPartnersCubit extends Cubit<AdminPartnersState> {
  final PartnerRepository _partnerRepository;

  AdminPartnersCubit({required PartnerRepository partnerRepository})
      : _partnerRepository = partnerRepository,
        super(const AdminPartnersState());

  Future<void> loadPartners() async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      final list = await _partnerRepository.getPartners();
      final filtered = _applyFilters(list, state.searchQuery, state.filterActive);
      emit(state.copyWith(
        isLoading: false,
        allPartners: list,
        filteredPartners: filtered,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load partners: ${e.toString().replaceAll('Exception: ', '')}',
      ));
    }
  }

  void searchPartners(String query) {
    final filtered = _applyFilters(state.allPartners, query, state.filterActive);
    emit(state.copyWith(searchQuery: query, filteredPartners: filtered));
  }

  void filterByActive(bool? active) {
    final filtered = _applyFilters(state.allPartners, state.searchQuery, active);
    emit(state.copyWith(filterActive: active, filteredPartners: filtered));
  }

  Future<bool> createPartner(PartnerModel partner) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));
    try {
      final created = await _partnerRepository.createPartner(partner);
      final updatedList = [created, ...state.allPartners];
      final filtered = _applyFilters(updatedList, state.searchQuery, state.filterActive);
      emit(state.copyWith(
        isSaving: false,
        allPartners: updatedList,
        filteredPartners: filtered,
        successMessage: 'Partner "${created.name}" created successfully.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to create partner: ${e.toString().replaceAll('Exception: ', '')}',
      ));
      return false;
    }
  }

  Future<bool> updatePartner(PartnerModel partner) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));
    try {
      final updated = await _partnerRepository.updatePartner(partner);
      final updatedList = state.allPartners.map((p) => p.id == updated.id ? updated : p).toList();
      final filtered = _applyFilters(updatedList, state.searchQuery, state.filterActive);
      emit(state.copyWith(
        isSaving: false,
        allPartners: updatedList,
        filteredPartners: filtered,
        successMessage: 'Partner "${updated.name}" updated successfully.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to update partner: ${e.toString().replaceAll('Exception: ', '')}',
      ));
      return false;
    }
  }

  Future<bool> deletePartner(String id) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));
    try {
      await _partnerRepository.deletePartner(id);
      final updatedList = state.allPartners.where((p) => p.id != id).toList();
      final filtered = _applyFilters(updatedList, state.searchQuery, state.filterActive);
      emit(state.copyWith(
        isSaving: false,
        allPartners: updatedList,
        filteredPartners: filtered,
        successMessage: 'Partner deleted successfully.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to delete partner: ${e.toString().replaceAll('Exception: ', '')}',
      ));
      return false;
    }
  }

  Future<void> toggleActive(PartnerModel partner) async {
    final updated = partner.copyWith(active: !partner.active);
    await updatePartner(updated);
  }

  List<PartnerModel> _applyFilters(
    List<PartnerModel> list,
    String query,
    bool? active,
  ) {
    return list.where((item) {
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        final matchName = item.name.toLowerCase().contains(q);
        final matchCat = item.category.toLowerCase().contains(q);
        if (!matchName && !matchCat) return false;
      }
      if (active != null && item.active != active) return false;
      return true;
    }).toList();
  }
}

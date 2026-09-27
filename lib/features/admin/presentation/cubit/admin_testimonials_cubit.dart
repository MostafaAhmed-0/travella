import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../data/models/testimonial_model.dart';
import '../../../../data/repositories/testimonial_repository.dart';

class AdminTestimonialsState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;
  final List<TestimonialModel> allTestimonials;
  final List<TestimonialModel> filteredTestimonials;
  final String searchQuery;
  final bool? filterActive;

  const AdminTestimonialsState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.allTestimonials = const [],
    this.filteredTestimonials = const [],
    this.searchQuery = '',
    this.filterActive,
  });

  AdminTestimonialsState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    List<TestimonialModel>? allTestimonials,
    List<TestimonialModel>? filteredTestimonials,
    String? searchQuery,
    bool? filterActive,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AdminTestimonialsState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      allTestimonials: allTestimonials ?? this.allTestimonials,
      filteredTestimonials: filteredTestimonials ?? this.filteredTestimonials,
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
        allTestimonials,
        filteredTestimonials,
        searchQuery,
        filterActive,
      ];
}

class AdminTestimonialsCubit extends Cubit<AdminTestimonialsState> {
  final TestimonialRepository _testimonialRepository;

  AdminTestimonialsCubit({required TestimonialRepository testimonialRepository})
      : _testimonialRepository = testimonialRepository,
        super(const AdminTestimonialsState());

  Future<void> loadTestimonials() async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      final list = await _testimonialRepository.getFeaturedTestimonials();
      final filtered = _applyFilters(list, state.searchQuery, state.filterActive);
      emit(state.copyWith(
        isLoading: false,
        allTestimonials: list,
        filteredTestimonials: filtered,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load testimonials: ${e.toString().replaceAll('Exception: ', '')}',
      ));
    }
  }

  void searchTestimonials(String query) {
    final filtered = _applyFilters(state.allTestimonials, query, state.filterActive);
    emit(state.copyWith(searchQuery: query, filteredTestimonials: filtered));
  }

  void filterByActive(bool? active) {
    final filtered = _applyFilters(state.allTestimonials, state.searchQuery, active);
    emit(state.copyWith(filterActive: active, filteredTestimonials: filtered));
  }

  Future<bool> createTestimonial(TestimonialModel testimonial) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));
    try {
      final created = await _testimonialRepository.createTestimonial(testimonial);
      final updatedList = [created, ...state.allTestimonials];
      final filtered = _applyFilters(updatedList, state.searchQuery, state.filterActive);
      emit(state.copyWith(
        isSaving: false,
        allTestimonials: updatedList,
        filteredTestimonials: filtered,
        successMessage: 'Testimonial from "${created.name}" created successfully.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to create testimonial: ${e.toString().replaceAll('Exception: ', '')}',
      ));
      return false;
    }
  }

  Future<bool> updateTestimonial(TestimonialModel testimonial) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));
    try {
      final updated = await _testimonialRepository.updateTestimonial(testimonial);
      final updatedList = state.allTestimonials.map((t) => t.id == updated.id ? updated : t).toList();
      final filtered = _applyFilters(updatedList, state.searchQuery, state.filterActive);
      emit(state.copyWith(
        isSaving: false,
        allTestimonials: updatedList,
        filteredTestimonials: filtered,
        successMessage: 'Testimonial updated successfully.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to update testimonial: ${e.toString().replaceAll('Exception: ', '')}',
      ));
      return false;
    }
  }

  Future<bool> deleteTestimonial(String id) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));
    try {
      await _testimonialRepository.deleteTestimonial(id);
      final updatedList = state.allTestimonials.where((t) => t.id != id).toList();
      final filtered = _applyFilters(updatedList, state.searchQuery, state.filterActive);
      emit(state.copyWith(
        isSaving: false,
        allTestimonials: updatedList,
        filteredTestimonials: filtered,
        successMessage: 'Testimonial deleted successfully.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to delete testimonial: ${e.toString().replaceAll('Exception: ', '')}',
      ));
      return false;
    }
  }

  List<TestimonialModel> _applyFilters(
    List<TestimonialModel> list,
    String query,
    bool? active,
  ) {
    return list.where((item) {
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        final matchName = item.name.toLowerCase().contains(q);
        final matchTrip = item.trip.toLowerCase().contains(q);
        final matchCountry = item.country.toLowerCase().contains(q);
        if (!matchName && !matchTrip && !matchCountry) return false;
      }
      return true;
    }).toList();
  }
}

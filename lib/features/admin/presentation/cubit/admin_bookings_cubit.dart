import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../data/models/booking_model.dart';
import '../../../../data/repositories/booking_repository.dart';

enum BookingSortOption {
  newest,
  oldest,
  travelersHigh,
  travelersLow,
}

class AdminBookingsState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;
  final List<BookingModel> allBookings;
  final List<BookingModel> filteredBookings;
  final String searchQuery;
  final BookingStatus? statusFilter;
  final BookingSortOption sortOption;
  final int currentPage;
  final int pageSize;

  const AdminBookingsState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.allBookings = const [],
    this.filteredBookings = const [],
    this.searchQuery = '',
    this.statusFilter,
    this.sortOption = BookingSortOption.newest,
    this.currentPage = 1,
    this.pageSize = 10,
  });

  int get totalPages => (filteredBookings.length / pageSize).ceil().clamp(1, 999);

  List<BookingModel> get pagedBookings {
    final start = (currentPage - 1) * pageSize;
    if (start >= filteredBookings.length) {
      return [];
    }
    final end = (start + pageSize).clamp(0, filteredBookings.length);
    return filteredBookings.sublist(start, end);
  }

  AdminBookingsState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    List<BookingModel>? allBookings,
    List<BookingModel>? filteredBookings,
    String? searchQuery,
    BookingStatus? statusFilter,
    BookingSortOption? sortOption,
    int? currentPage,
    int? pageSize,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearStatusFilter = false,
  }) {
    return AdminBookingsState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      allBookings: allBookings ?? this.allBookings,
      filteredBookings: filteredBookings ?? this.filteredBookings,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      sortOption: sortOption ?? this.sortOption,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSaving,
        errorMessage,
        successMessage,
        allBookings,
        filteredBookings,
        searchQuery,
        statusFilter,
        sortOption,
        currentPage,
        pageSize,
      ];
}

class AdminBookingsCubit extends Cubit<AdminBookingsState> {
  final BookingRepository _bookingRepository;

  AdminBookingsCubit({required BookingRepository bookingRepository})
      : _bookingRepository = bookingRepository,
        super(const AdminBookingsState());

  Future<void> loadBookings() async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      final list = await _bookingRepository.getBookings();
      final filtered = _applyFiltersAndSort(
        list,
        state.searchQuery,
        state.statusFilter,
        state.sortOption,
      );
      emit(state.copyWith(
        isLoading: false,
        allBookings: list,
        filteredBookings: filtered,
        currentPage: 1,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load bookings: ${e.toString().replaceAll('Exception: ', '')}',
      ));
    }
  }

  void searchBookings(String query) {
    final filtered = _applyFiltersAndSort(
      state.allBookings,
      query,
      state.statusFilter,
      state.sortOption,
    );
    emit(state.copyWith(
      searchQuery: query,
      filteredBookings: filtered,
      currentPage: 1,
    ));
  }

  void filterByStatus(BookingStatus? status) {
    final filtered = _applyFiltersAndSort(
      state.allBookings,
      state.searchQuery,
      status,
      state.sortOption,
    );
    emit(state.copyWith(
      statusFilter: status,
      clearStatusFilter: status == null,
      filteredBookings: filtered,
      currentPage: 1,
    ));
  }

  void setSortOption(BookingSortOption option) {
    final filtered = _applyFiltersAndSort(
      state.allBookings,
      state.searchQuery,
      state.statusFilter,
      option,
    );
    emit(state.copyWith(
      sortOption: option,
      filteredBookings: filtered,
      currentPage: 1,
    ));
  }

  void setPage(int page) {
    if (page >= 1 && page <= state.totalPages) {
      emit(state.copyWith(currentPage: page));
    }
  }

  void setPageSize(int size) {
    emit(state.copyWith(pageSize: size, currentPage: 1));
  }

  Future<bool> updateStatus(String bookingId, BookingStatus newStatus) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));
    try {
      final updated = await _bookingRepository.updateBookingStatus(bookingId, newStatus);
      final updatedList = state.allBookings.map((b) => b.id == updated.id ? updated : b).toList();
      final filtered = _applyFiltersAndSort(
        updatedList,
        state.searchQuery,
        state.statusFilter,
        state.sortOption,
      );
      emit(state.copyWith(
        isSaving: false,
        allBookings: updatedList,
        filteredBookings: filtered,
        successMessage: 'Booking status changed to ${newStatus.label}.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to update booking status: ${e.toString().replaceAll('Exception: ', '')}',
      ));
      return false;
    }
  }

  Future<bool> deleteBooking(String bookingId) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));
    try {
      await _bookingRepository.deleteBooking(bookingId);
      final updatedList = state.allBookings.where((b) => b.id != bookingId).toList();
      final filtered = _applyFiltersAndSort(
        updatedList,
        state.searchQuery,
        state.statusFilter,
        state.sortOption,
      );
      emit(state.copyWith(
        isSaving: false,
        allBookings: updatedList,
        filteredBookings: filtered,
        successMessage: 'Booking record deleted.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to delete booking: ${e.toString().replaceAll('Exception: ', '')}',
      ));
      return false;
    }
  }

  List<BookingModel> _applyFiltersAndSort(
    List<BookingModel> list,
    String query,
    BookingStatus? status,
    BookingSortOption sort,
  ) {
    var result = list.where((b) {
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        final matchCustomer = b.customerName.toLowerCase().contains(q);
        final matchEmail = b.email.toLowerCase().contains(q);
        final matchPhone = b.phone.toLowerCase().contains(q);
        final matchTour = b.tourTitle?.toLowerCase().contains(q) ?? false;
        if (!matchCustomer && !matchEmail && !matchPhone && !matchTour) return false;
      }
      if (status != null && b.status != status) return false;
      return true;
    }).toList();

    switch (sort) {
      case BookingSortOption.newest:
        result.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
        break;
      case BookingSortOption.oldest:
        result.sort((a, b) => (a.createdAt ?? DateTime.now()).compareTo(b.createdAt ?? DateTime.now()));
        break;
      case BookingSortOption.travelersHigh:
        result.sort((a, b) => b.travelers.compareTo(a.travelers));
        break;
      case BookingSortOption.travelersLow:
        result.sort((a, b) => a.travelers.compareTo(b.travelers));
        break;
    }

    return result;
  }
}

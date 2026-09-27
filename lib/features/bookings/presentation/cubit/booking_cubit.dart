import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/models/booking_model.dart';
import '../../../../data/repositories/booking_repository.dart';
import 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingRepository _bookingRepository;

  BookingCubit({required BookingRepository bookingRepository})
      : _bookingRepository = bookingRepository,
        super(const BookingInitial());

  /// Public user submits a booking
  Future<bool> submitBooking({
    required String customerName,
    required String email,
    required String phone,
    String? tourId,
    DateTime? travelDate,
    int travelers = 1,
    String? notes,
  }) async {
    emit(const BookingLoading());
    try {
      final booking = BookingModel(
        id: '',
        customerName: customerName.trim(),
        email: email.trim(),
        phone: phone.trim(),
        tourId: tourId,
        travelDate: travelDate,
        travelers: travelers,
        status: BookingStatus.pending,
        notes: notes?.trim(),
      );

      final created = await _bookingRepository.createBooking(booking);
      emit(BookingSubmittedSuccess(created));
      return true;
    } catch (e) {
      emit(BookingError(e.toString().replaceAll('Exception: ', '')));
      return false;
    }
  }

  /// Admin loads bookings
  Future<void> loadBookings({BookingStatus? status}) async {
    emit(const BookingLoading());
    try {
      final list = await _bookingRepository.getBookings(status: status);
      emit(BookingsLoaded(bookings: list, filterStatus: status));
    } catch (e) {
      emit(BookingError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Admin updates status
  Future<void> updateStatus(String bookingId, BookingStatus newStatus) async {
    try {
      await _bookingRepository.updateBookingStatus(bookingId, newStatus);
      // Reload current view
      final currentFilter = state is BookingsLoaded ? (state as BookingsLoaded).filterStatus : null;
      loadBookings(status: currentFilter);
    } catch (e) {
      emit(BookingError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Admin deletes booking
  Future<void> deleteBooking(String bookingId) async {
    try {
      await _bookingRepository.deleteBooking(bookingId);
      final currentFilter = state is BookingsLoaded ? (state as BookingsLoaded).filterStatus : null;
      loadBookings(status: currentFilter);
    } catch (e) {
      emit(BookingError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

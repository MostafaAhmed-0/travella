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
    int adultsCount = 1,
    int childrenCount = 0,
    List<int> childrenAges = const [],
    String? notes,
  }) async {
    emit(const BookingLoading());
    try {
      final cleanName = customerName.trim();
      final cleanEmail = email.trim();
      final cleanPhone = phone.trim();

      if (cleanName.isEmpty) {
        throw Exception('Customer full name is required.');
      }
      if (cleanEmail.isEmpty) {
        throw Exception('Email address is required.');
      }
      if (cleanPhone.isEmpty) {
        throw Exception('Phone number is required.');
      }
      if (adultsCount < 1) {
        throw Exception('At least 1 adult is required for booking.');
      }
      if (childrenCount < 0) {
        throw Exception('Children count cannot be negative.');
      }
      if (childrenCount > 0) {
        if (childrenAges.length != childrenCount) {
          throw Exception('Please specify an age for each child ($childrenCount children).');
        }
        for (int i = 0; i < childrenAges.length; i++) {
          final age = childrenAges[i];
          if (age < 0 || age > 17) {
            throw Exception('Invalid child age: $age (must be between 0 and 17).');
          }
        }
      }

      final totalTravelers = adultsCount + childrenCount > 0
          ? adultsCount + childrenCount
          : (travelers > 0 ? travelers : 1);

      final booking = BookingModel(
        id: '',
        customerName: cleanName,
        email: cleanEmail,
        phone: cleanPhone,
        tourId: tourId,
        travelDate: travelDate,
        travelers: totalTravelers,
        adultsCount: adultsCount,
        childrenCount: childrenCount,
        childrenAges: childrenCount > 0 ? childrenAges : const [],
        status: BookingStatus.pending, // Always pending on public submission
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

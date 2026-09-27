import '../datasources/booking_remote_data_source.dart';
import '../models/booking_model.dart';

/// Repository for handling customer bookings
abstract class BookingRepository {
  Future<BookingModel> createBooking(BookingModel booking);
  Future<List<BookingModel>> getBookings({BookingStatus? status});
  Future<BookingModel> updateBookingStatus(String bookingId, BookingStatus status);
  Future<void> deleteBooking(String bookingId);
}

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource _remoteDataSource;

  BookingRepositoryImpl({BookingRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? BookingRemoteDataSourceImpl();

  @override
  Future<BookingModel> createBooking(BookingModel booking) async {
    try {
      return await _remoteDataSource.createBooking(booking);
    } catch (e) {
      // Return optimistic local booking for demo/offline resilience
      return booking.copyWith(
        id: 'booking-${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        status: BookingStatus.pending,
      );
    }
  }

  @override
  Future<List<BookingModel>> getBookings({BookingStatus? status}) async {
    try {
      return await _remoteDataSource.getBookings(status: status);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<BookingModel> updateBookingStatus(String bookingId, BookingStatus status) async {
    return await _remoteDataSource.updateBookingStatus(bookingId, status);
  }

  @override
  Future<void> deleteBooking(String bookingId) async {
    await _remoteDataSource.deleteBooking(bookingId);
  }
}

import 'package:equatable/equatable.dart';
import '../../../../data/models/booking_model.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {
  const BookingInitial();
}

class BookingLoading extends BookingState {
  const BookingLoading();
}

class BookingSubmittedSuccess extends BookingState {
  final BookingModel booking;
  const BookingSubmittedSuccess(this.booking);

  @override
  List<Object?> get props => [booking];
}

class BookingsLoaded extends BookingState {
  final List<BookingModel> bookings;
  final BookingStatus? filterStatus;

  const BookingsLoaded({
    required this.bookings,
    this.filterStatus,
  });

  @override
  List<Object?> get props => [bookings, filterStatus];
}

class BookingError extends BookingState {
  final String message;
  const BookingError(this.message);

  @override
  List<Object?> get props => [message];
}

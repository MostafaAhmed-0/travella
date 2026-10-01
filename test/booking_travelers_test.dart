import 'package:flutter_test/flutter_test.dart';
import 'package:travella/data/models/booking_model.dart';
import 'package:travella/data/repositories/booking_repository.dart';
import 'package:travella/features/bookings/presentation/cubit/booking_cubit.dart';
import 'package:travella/features/bookings/presentation/cubit/booking_state.dart';

class MockBookingRepository implements BookingRepository {
  BookingModel? lastCreatedBooking;

  @override
  Future<BookingModel> createBooking(BookingModel booking) async {
    lastCreatedBooking = booking.copyWith(
      id: 'mock-id-1234',
      createdAt: DateTime.now(),
    );
    return lastCreatedBooking!;
  }

  @override
  Future<List<BookingModel>> getBookings({BookingStatus? status}) async {
    return [];
  }

  @override
  Future<BookingModel> updateBookingStatus(String bookingId, BookingStatus status) async {
    return lastCreatedBooking!.copyWith(status: status);
  }

  @override
  Future<void> deleteBooking(String bookingId) async {}
}

void main() {
  group('Advanced Booking Traveler Structure & Scenarios', () {
    test('Scenario 1: 2 adults, 0 children', () {
      final booking = BookingModel(
        id: '1',
        customerName: 'Ahmed Ali',
        email: 'ahmed@example.com',
        phone: '+201001234567',
        adultsCount: 2,
        childrenCount: 0,
        childrenAges: const [],
      );

      expect(booking.travelers, 2);
      expect(booking.adultsCount, 2);
      expect(booking.childrenCount, 0);
      expect(booking.hasChildren, isFalse);
      expect(booking.formattedTravelersSummary(isArabic: false), '2 Adults');
      expect(booking.formattedTravelersSummary(isArabic: true), '2 بالغين');
      expect(booking.formattedChildAges(isArabic: false), 'None');
      expect(booking.formattedChildAges(isArabic: true), 'لا يوجد أطفال');
    });

    test('Scenario 2: 2 adults, 1 child (age 5)', () {
      final booking = BookingModel(
        id: '2',
        customerName: 'Sarah Smith',
        email: 'sarah@example.com',
        phone: '+12025550143',
        adultsCount: 2,
        childrenCount: 1,
        childrenAges: const [5],
      );

      expect(booking.travelers, 3);
      expect(booking.adultsCount, 2);
      expect(booking.childrenCount, 1);
      expect(booking.hasChildren, isTrue);
      expect(booking.childrenAges, [5]);
      expect(booking.formattedTravelersSummary(isArabic: false), '2 Adults, 1 Child (Ages: 5)');
      expect(booking.formattedTravelersSummary(isArabic: true), '2 بالغين، 1 طفل (أعمار: 5)');
      expect(booking.formattedChildAges(isArabic: false), '5 yrs');
      expect(booking.formattedChildAges(isArabic: true), '5 سنوات');
    });

    test('Scenario 3: 2 adults, 2 children (ages 4, 9)', () {
      final booking = BookingModel(
        id: '3',
        customerName: 'Mohamed Tarek',
        email: 'mohamed@example.com',
        phone: '+201009876543',
        adultsCount: 2,
        childrenCount: 2,
        childrenAges: const [4, 9],
      );

      expect(booking.travelers, 4);
      expect(booking.adultsCount, 2);
      expect(booking.childrenCount, 2);
      expect(booking.hasChildren, isTrue);
      expect(booking.childrenAges, [4, 9]);
      expect(booking.formattedTravelersSummary(isArabic: false), '2 Adults, 2 Children (Ages: 4, 9)');
      expect(booking.formattedTravelersSummary(isArabic: true), '2 بالغين، 2 أطفال (أعمار: 4, 9)');
      expect(booking.formattedChildAges(isArabic: false), '4 yrs, 9 yrs');
      expect(booking.formattedChildAges(isArabic: true), '4 سنوات، 9 سنوات');
    });

    test('Scenario 4: 1 adult, 3 children (ages 2, 7, 12)', () {
      final booking = BookingModel(
        id: '4',
        customerName: 'Elena Rostova',
        email: 'elena@example.com',
        phone: '+447911123456',
        adultsCount: 1,
        childrenCount: 3,
        childrenAges: const [2, 7, 12],
      );

      expect(booking.travelers, 4);
      expect(booking.adultsCount, 1);
      expect(booking.childrenCount, 3);
      expect(booking.hasChildren, isTrue);
      expect(booking.childrenAges, [2, 7, 12]);
      expect(booking.formattedTravelersSummary(isArabic: false), '1 Adult, 3 Children (Ages: 2, 7, 12)');
      expect(booking.formattedTravelersSummary(isArabic: true), '1 بالغ، 3 أطفال (أعمار: 2, 7, 12)');
      expect(booking.formattedChildAges(isArabic: false), '2 yrs, 7 yrs, 12 yrs');
      expect(booking.formattedChildAges(isArabic: true), 'سنتان، 7 سنوات، 12 سنة');
    });

    test('Scenario with Infant (0 years)', () {
      final booking = BookingModel(
        id: '5',
        customerName: 'Family Doe',
        email: 'doe@example.com',
        phone: '+15551234567',
        adultsCount: 2,
        childrenCount: 1,
        childrenAges: const [0],
      );

      expect(booking.childrenAges, [0]);
      expect(booking.formattedChildAges(isArabic: false), '< 1 yr (Infant)');
      expect(booking.formattedChildAges(isArabic: true), 'أقل من سنة (رضيع)');
    });

    test('PostgreSQL JSON serialization & deserialization compatibility', () {
      final original = BookingModel(
        id: 'a0000000-0000-0000-0000-000000000001',
        customerName: 'Kareem Mostafa',
        email: 'kareem@example.com',
        phone: '+201099887766',
        adultsCount: 3,
        childrenCount: 2,
        childrenAges: const [6, 11],
        status: BookingStatus.pending,
      );

      final json = original.toJson();
      expect(json['adults_count'], 3);
      expect(json['children_count'], 2);
      expect(json['children_ages'], [6, 11]);
      expect(json['travelers'], 5);
      expect(json['status'], 'pending');

      final fromJson = BookingModel.fromJson(json);
      expect(fromJson.adultsCount, 3);
      expect(fromJson.childrenCount, 2);
      expect(fromJson.childrenAges, [6, 11]);
      expect(fromJson.travelers, 5);
      expect(fromJson.status, BookingStatus.pending);
    });

    test('BookingCubit submission validation for children ages and public pending status', () async {
      final mockRepo = MockBookingRepository();
      final cubit = BookingCubit(bookingRepository: mockRepo);

      // Missing child age error test
      final failResult = await cubit.submitBooking(
        customerName: 'Tarek Zaid',
        email: 'tarek@example.com',
        phone: '+201011223344',
        adultsCount: 2,
        childrenCount: 2,
        childrenAges: const [5], // Only 1 age provided for 2 children
      );

      expect(failResult, isFalse);
      expect(cubit.state, isA<BookingError>());

      // Successful submission with all ages
      final successResult = await cubit.submitBooking(
        customerName: 'Tarek Zaid',
        email: 'tarek@example.com',
        phone: '+201011223344',
        adultsCount: 2,
        childrenCount: 2,
        childrenAges: const [5, 10],
      );

      expect(successResult, isTrue);
      expect(cubit.state, isA<BookingSubmittedSuccess>());
      expect(mockRepo.lastCreatedBooking?.status, BookingStatus.pending);
      expect(mockRepo.lastCreatedBooking?.adultsCount, 2);
      expect(mockRepo.lastCreatedBooking?.childrenCount, 2);
      expect(mockRepo.lastCreatedBooking?.childrenAges, [5, 10]);

      cubit.close();
    });
  });
}

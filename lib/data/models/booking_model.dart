import 'package:equatable/equatable.dart';

/// Status of a booking
enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  completed;

  static BookingStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'completed':
        return BookingStatus.completed;
      case 'pending':
      default:
        return BookingStatus.pending;
    }
  }

  String toDbString() {
    switch (this) {
      case BookingStatus.pending:
        return 'pending';
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.cancelled:
        return 'cancelled';
      case BookingStatus.completed:
        return 'completed';
    }
  }

  String get label {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
    }
  }
}

/// Model matching Supabase public.bookings table
class BookingModel extends Equatable {
  final String id;
  final String customerName;
  final String email;
  final String phone;
  final String? tourId;
  final DateTime? travelDate;
  final int travelers;
  final BookingStatus status;
  final String? notes;
  final DateTime? createdAt;

  // Joined/populated info
  final String? tourTitle;

  const BookingModel({
    required this.id,
    required this.customerName,
    required this.email,
    required this.phone,
    this.tourId,
    this.travelDate,
    this.travelers = 1,
    this.status = BookingStatus.pending,
    this.notes,
    this.createdAt,
    this.tourTitle,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    String? tourName;
    if (json['tours'] != null && json['tours'] is Map) {
      tourName = json['tours']['title'] as String?;
    }

    return BookingModel(
      id: json['id'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      tourId: json['tour_id'] as String?,
      travelDate: json['travel_date'] != null
          ? DateTime.tryParse(json['travel_date'].toString())
          : null,
      travelers: (json['travelers'] as num?)?.toInt() ?? 1,
      status: BookingStatus.fromString(json['status'] as String?),
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      tourTitle: tourName ?? json['tour_title'] as String?,
    );
  }

  static bool isValidUuid(String? id) {
    if (id == null || id.trim().isEmpty) return false;
    final uuidRegex = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    return uuidRegex.hasMatch(id.trim());
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'email': email,
      'phone': phone,
      'tour_id': isValidUuid(tourId) ? tourId!.trim() : null,
      if (travelDate != null)
        'travel_date':
            "${travelDate!.year.toString().padLeft(4, '0')}-${travelDate!.month.toString().padLeft(2, '0')}-${travelDate!.day.toString().padLeft(2, '0')}",
      'travelers': travelers,
      'status': status.toDbString(),
      'notes': notes,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  BookingModel copyWith({
    String? id,
    String? customerName,
    String? email,
    String? phone,
    String? tourId,
    DateTime? travelDate,
    int? travelers,
    BookingStatus? status,
    String? notes,
    DateTime? createdAt,
    String? tourTitle,
  }) {
    return BookingModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      tourId: tourId ?? this.tourId,
      travelDate: travelDate ?? this.travelDate,
      travelers: travelers ?? this.travelers,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      tourTitle: tourTitle ?? this.tourTitle,
    );
  }

  String get bookingReference {
    if (id.isEmpty) {
      return 'TRV-${DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase()}';
    }
    final cleanId = id.replaceAll('-', '').toUpperCase();
    if (cleanId.length >= 8) {
      return 'TRV-${cleanId.substring(0, 8)}';
    }
    return 'TRV-$cleanId';
  }

  @override
  List<Object?> get props => [
        id,
        customerName,
        email,
        phone,
        tourId,
        travelDate,
        travelers,
        status,
        notes,
        createdAt,
      ];
}

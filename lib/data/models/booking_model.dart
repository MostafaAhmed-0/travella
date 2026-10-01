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

/// Model matching Supabase public.bookings table with support for adults, children, and child ages
class BookingModel extends Equatable {
  final String id;
  final String customerName;
  final String email;
  final String phone;
  final String? tourId;
  final DateTime? travelDate;
  final int travelers;
  final int adultsCount;
  final int childrenCount;
  final List<int> childrenAges;
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
    int? travelers,
    this.adultsCount = 1,
    this.childrenCount = 0,
    this.childrenAges = const [],
    this.status = BookingStatus.pending,
    this.notes,
    this.createdAt,
    this.tourTitle,
  }) : travelers =
           travelers ??
           (adultsCount + childrenCount > 0 ? adultsCount + childrenCount : 1);

  bool get hasChildren => childrenCount > 0 && childrenAges.isNotEmpty;

  String get travelersSummary => formattedTravelersSummary();
  String get childAgesSummary => formattedChildAges();

  String formattedTravelersSummary({bool isArabic = false}) {
    final adultsText = isArabic
        ? '$adultsCount ${adultsCount == 1 ? 'بالغ' : 'بالغين'}'
        : '$adultsCount ${adultsCount == 1 ? 'Adult' : 'Adults'}';

    if (childrenCount > 0) {
      final agesStr = childrenAges.isNotEmpty ? childrenAges.join(', ') : '';
      final agesSuffix = agesStr.isNotEmpty
          ? (isArabic ? ' (أعمار: $agesStr)' : ' (Ages: $agesStr)')
          : '';
      final kidsText = isArabic
          ? '، $childrenCount ${childrenCount == 1 ? 'طفل' : 'أطفال'}$agesSuffix'
          : ', $childrenCount ${childrenCount == 1 ? 'Child' : 'Children'}$agesSuffix';
      return '$adultsText$kidsText';
    }
    return adultsText;
  }

  String formattedChildAges({bool isArabic = false}) {
    if (childrenAges.isEmpty) {
      return isArabic ? 'لا يوجد أطفال' : 'None';
    }
    return childrenAges
        .map((a) {
          if (a == 0) return isArabic ? 'أقل من سنة (رضيع)' : '< 1 yr (Infant)';
          if (a == 1) return isArabic ? 'سنة واحدة' : '1 yr';
          if (a == 2) return isArabic ? 'سنتان' : '2 yrs';
          if (a >= 3 && a <= 10) return isArabic ? '$a سنوات' : '$a yrs';
          return isArabic ? '$a سنة' : '$a yrs';
        })
        .join(isArabic ? '، ' : ', ');
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    String? tourName;
    if (json['tours'] != null && json['tours'] is Map) {
      tourName = json['tours']['title'] as String?;
    }

    final rawTravelers = (json['travelers'] as num?)?.toInt() ?? 1;
    int parsedAdults =
        (json['adults_count'] as num?)?.toInt() ??
        (json['adults'] as num?)?.toInt() ??
        0;
    int parsedChildren =
        (json['children_count'] as num?)?.toInt() ??
        (json['children'] as num?)?.toInt() ??
        0;

    List<int> parsedAges = [];
    final rawAges = json['children_ages'] ?? json['child_ages'];
    if (rawAges is List) {
      parsedAges = rawAges.map((e) => int.tryParse(e.toString()) ?? 0).toList();
    } else if (rawAges is String && rawAges.trim().isNotEmpty) {
      parsedAges = rawAges
          .replaceAll('[', '')
          .replaceAll(']', '')
          .split(',')
          .map((e) => int.tryParse(e.trim()))
          .whereType<int>()
          .toList();
    }

    // Fallback: If adults_count is not explicitly set in JSON, check notes or fallback to travelers
    if (parsedAdults == 0 && parsedChildren == 0) {
      final notesText = json['notes'] as String? ?? '';
      final match = RegExp(
        r'Travelers:\s*(\d+)\s*Adults?(?:,\s*(\d+)\s*Child(?:ren)?)?(?:\s*\[Ages:\s*([^\]]+)\])?',
        caseSensitive: false,
      ).firstMatch(notesText);

      if (match != null) {
        parsedAdults = int.tryParse(match.group(1) ?? '1') ?? 1;
        parsedChildren = int.tryParse(match.group(2) ?? '0') ?? 0;
        final agesRaw = match.group(3);
        if (agesRaw != null && parsedAges.isEmpty) {
          parsedAges = agesRaw
              .split(',')
              .map((e) => int.tryParse(e.trim()))
              .whereType<int>()
              .toList();
        }
      } else {
        parsedAdults = rawTravelers;
        parsedChildren = 0;
      }
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
      travelers: rawTravelers,
      adultsCount: parsedAdults > 0 ? parsedAdults : 1,
      childrenCount: parsedChildren,
      childrenAges: parsedAges,
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
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidRegex.hasMatch(id.trim());
  }

  Map<String, dynamic> toJson() {
    final total = adultsCount + childrenCount;
    return {
      'id': id,
      'customer_name': customerName,
      'email': email,
      'phone': phone,
      'tour_id': isValidUuid(tourId) ? tourId!.trim() : null,
      if (travelDate != null)
        'travel_date':
            "${travelDate!.year.toString().padLeft(4, '0')}-${travelDate!.month.toString().padLeft(2, '0')}-${travelDate!.day.toString().padLeft(2, '0')}",
      'travelers': total > 0 ? total : travelers,
      'adults_count': adultsCount,
      'children_count': childrenCount,
      'children_ages': childrenAges,
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
    int? adultsCount,
    int? childrenCount,
    List<int>? childrenAges,
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
      adultsCount: adultsCount ?? this.adultsCount,
      childrenCount: childrenCount ?? this.childrenCount,
      childrenAges: childrenAges ?? this.childrenAges,
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
    adultsCount,
    childrenCount,
    childrenAges,
    status,
    notes,
    createdAt,
  ];
}

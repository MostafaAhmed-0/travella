import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Supported types of airport & city transfers
enum TransferType {
  airportToHotel('airport_to_hotel', 'Airport → Hotel', 'من المطار إلى الفندق', Icons.flight_land_rounded),
  hotelToAirport('hotel_to_airport', 'Hotel → Airport', 'من الفندق إلى المطار', Icons.flight_takeoff_rounded),
  airportToAirport('airport_to_airport', 'Airport → Airport', 'من مطار إلى مطار', Icons.sync_alt_rounded),
  custom('custom', 'Custom Transfer', 'توصيل مخصص', Icons.alt_route_rounded);

  final String dbValue;
  final String label;
  final String labelAr;
  final IconData icon;

  const TransferType(this.dbValue, this.label, this.labelAr, this.icon);

  static TransferType fromString(String? value) {
    if (value == null) return TransferType.airportToHotel;
    final normalized = value.toLowerCase().trim();
    for (final type in TransferType.values) {
      if (type.dbValue == normalized || type.name.toLowerCase() == normalized) {
        return type;
      }
    }
    return TransferType.airportToHotel;
  }

  String getLocalizedLabel(bool isArabic) => isArabic ? labelAr : label;
}

/// Lifecycle status for airport transfer booking requests
enum TransferStatus {
  pending('pending', 'Pending', 'قيد الانتظار', AppColors.warning),
  confirmed('confirmed', 'Confirmed', 'مؤكد', AppColors.royalBlueLight),
  inProgress('in_progress', 'In Progress', 'قيد التنفيذ', Color(0xFF8B5CF6)),
  completed('completed', 'Completed', 'مكتمل', AppColors.success),
  cancelled('cancelled', 'Cancelled', 'ملغي', AppColors.error);

  final String dbValue;
  final String label;
  final String labelAr;
  final Color color;

  const TransferStatus(this.dbValue, this.label, this.labelAr, this.color);

  static TransferStatus fromString(String? value) {
    if (value == null) return TransferStatus.pending;
    final normalized = value.toLowerCase().trim();
    for (final status in TransferStatus.values) {
      if (status.dbValue == normalized || status.name.toLowerCase() == normalized) {
        return status;
      }
    }
    return TransferStatus.pending;
  }

  String getLocalizedLabel(bool isArabic) => isArabic ? labelAr : label;
}

/// Vehicle offering configured by Admin in Supabase
class TransferVehicleModel {
  final String id;
  final String vehicleName;
  final String? vehicleNameAr;
  final String vehicleType; // sedan, luxury_sedan, suv, van, minibus
  final String? imageUrl;
  final int passengerCapacity;
  final int luggageCapacity;
  final List<String> supportedTransferTypes;
  final double basePrice;
  final String currency;
  final String estimatedDuration;
  final List<String> features;
  final List<String>? featuresAr;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TransferVehicleModel({
    required this.id,
    required this.vehicleName,
    this.vehicleNameAr,
    required this.vehicleType,
    this.imageUrl,
    this.passengerCapacity = 3,
    this.luggageCapacity = 2,
    this.supportedTransferTypes = const [
      'airport_to_hotel',
      'hotel_to_airport',
      'airport_to_airport',
      'custom',
    ],
    this.basePrice = 45.0,
    this.currency = 'USD',
    this.estimatedDuration = '45-60 mins',
    this.features = const [
      'Flight Tracking',
      'Meet & Greet with Name Board',
      'Free 60 min Wait Time',
      'Air Conditioned',
      'Complimentary Bottled Water',
    ],
    this.featuresAr,
    this.active = true,
    this.createdAt,
    this.updatedAt,
  });

  String getLocalizedName(bool isArabic) {
    if (isArabic && vehicleNameAr != null && vehicleNameAr!.isNotEmpty) {
      return vehicleNameAr!;
    }
    return vehicleName;
  }

  String get vehicleTypeDisplay {
    switch (vehicleType.toLowerCase()) {
      case 'sedan':
        return 'Standard Sedan';
      case 'luxury_sedan':
      case 'executive_sedan':
        return 'Luxury Sedan';
      case 'suv':
      case 'luxury_suv':
        return 'Executive SUV';
      case 'van':
      case 'family_van':
        return 'Spacious Van';
      case 'minibus':
      case 'group_minibus':
        return 'Group Minibus';
      default:
        return vehicleType.replaceAll('_', ' ').toUpperCase();
    }
  }

  String getVehicleTypeDisplayAr(bool isArabic) {
    if (!isArabic) return vehicleTypeDisplay;
    switch (vehicleType.toLowerCase()) {
      case 'sedan':
        return 'سيدان اقتصادية';
      case 'luxury_sedan':
      case 'executive_sedan':
        return 'سيدان فاخرة (VIP)';
      case 'suv':
      case 'luxury_suv':
        return 'دفع رباعي فاخر (SUV)';
      case 'van':
      case 'family_van':
        return 'فان عائلي سياحي';
      case 'minibus':
      case 'group_minibus':
        return 'ميني باص للمجموعات';
      default:
        return vehicleType;
    }
  }

  factory TransferVehicleModel.fromJson(Map<String, dynamic> json) {
    List<String> parseStringList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString()).toList();
      }
      return [];
    }

    return TransferVehicleModel(
      id: json['id'] as String? ?? '',
      vehicleName: json['vehicle_name'] as String? ?? 'Private Transfer',
      vehicleNameAr: json['vehicle_name_ar'] as String?,
      vehicleType: json['vehicle_type'] as String? ?? 'sedan',
      imageUrl: json['image_url'] as String?,
      passengerCapacity: (json['passenger_capacity'] as num?)?.toInt() ?? 3,
      luggageCapacity: (json['luggage_capacity'] as num?)?.toInt() ?? 2,
      supportedTransferTypes: json['supported_transfer_types'] != null
          ? parseStringList(json['supported_transfer_types'])
          : const ['airport_to_hotel', 'hotel_to_airport', 'airport_to_airport', 'custom'],
      basePrice: (json['base_price'] as num?)?.toDouble() ?? 45.0,
      currency: json['currency'] as String? ?? 'USD',
      estimatedDuration: json['estimated_duration'] as String? ?? '45-60 mins',
      features: json['features'] != null
          ? parseStringList(json['features'])
          : const [
              'Flight Tracking',
              'Meet & Greet with Name Board',
              'Free 60 min Wait Time',
              'Air Conditioned',
              'Complimentary Bottled Water',
            ],
      featuresAr: json['features_ar'] != null ? parseStringList(json['features_ar']) : null,
      active: json['active'] as bool? ?? true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'vehicle_name': vehicleName,
      'vehicle_name_ar': vehicleNameAr,
      'vehicle_type': vehicleType,
      'image_url': imageUrl,
      'passenger_capacity': passengerCapacity,
      'luggage_capacity': luggageCapacity,
      'supported_transfer_types': supportedTransferTypes,
      'base_price': basePrice,
      'currency': currency,
      'estimated_duration': estimatedDuration,
      'features': features,
      'features_ar': featuresAr,
      'active': active,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  TransferVehicleModel copyWith({
    String? id,
    String? vehicleName,
    String? vehicleNameAr,
    String? vehicleType,
    String? imageUrl,
    int? passengerCapacity,
    int? luggageCapacity,
    List<String>? supportedTransferTypes,
    double? basePrice,
    String? currency,
    String? estimatedDuration,
    List<String>? features,
    List<String>? featuresAr,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransferVehicleModel(
      id: id ?? this.id,
      vehicleName: vehicleName ?? this.vehicleName,
      vehicleNameAr: vehicleNameAr ?? this.vehicleNameAr,
      vehicleType: vehicleType ?? this.vehicleType,
      imageUrl: imageUrl ?? this.imageUrl,
      passengerCapacity: passengerCapacity ?? this.passengerCapacity,
      luggageCapacity: luggageCapacity ?? this.luggageCapacity,
      supportedTransferTypes: supportedTransferTypes ?? this.supportedTransferTypes,
      basePrice: basePrice ?? this.basePrice,
      currency: currency ?? this.currency,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      features: features ?? this.features,
      featuresAr: featuresAr ?? this.featuresAr,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Default mock vehicles fallback for smooth offline / freshly-provisioned databases
  static List<TransferVehicleModel> get sampleVehicles => [
    const TransferVehicleModel(
      id: 'mock-transfer-sedan',
      vehicleName: 'Toyota Camry / Skoda Superb',
      vehicleNameAr: 'تويوتا كامري / سكودا سوبيرب',
      vehicleType: 'sedan',
      imageUrl: 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?auto=format&fit=crop&w=1000&q=80',
      passengerCapacity: 3,
      luggageCapacity: 2,
      basePrice: 40.0,
      currency: 'USD',
      estimatedDuration: '40-50 mins',
      features: [
        'Free 60-min Airport Wait',
        'Flight Tracking Included',
        'Professional Chauffeur',
        'Air Conditioned & Clean',
        'Free Cancellation (24h)',
      ],
      featuresAr: [
        'انتظار مجاني 60 دقيقة بالمطار',
        'متابعة رحلة الطيران',
        'سائق محترف ولبق',
        'سيارة مكيفة ونظيفة تماماً',
        'إلغاء مجاني حتى 24 ساعة',
      ],
      active: true,
    ),
    const TransferVehicleModel(
      id: 'mock-transfer-luxury-sedan',
      vehicleName: 'Mercedes-Benz E-Class / BMW 5 Series',
      vehicleNameAr: 'مرسيدس بنز الفئة E / بي إم دبليو الفئة 5',
      vehicleType: 'luxury_sedan',
      imageUrl: 'https://images.unsplash.com/photo-1563720223185-11003d516935?auto=format&fit=crop&w=1000&q=80',
      passengerCapacity: 3,
      luggageCapacity: 3,
      basePrice: 85.0,
      currency: 'USD',
      estimatedDuration: '40-50 mins',
      features: [
        'VIP Meet & Greet at Terminal',
        'Leather Executive Interior',
        'High-Speed Onboard Wi-Fi',
        'Complimentary Evian Water',
        'Priority Route Navigation',
      ],
      featuresAr: [
        'استقبال VIP داخل صالة الوصول',
        'مقاعد جلدية فاخرة',
        'إنترنت واي فاي فائق السرعة',
        'مياه ومشروبات مجانية',
        'تتبع مباشر وتحديد أسرع المسارات',
      ],
      active: true,
    ),
    const TransferVehicleModel(
      id: 'mock-transfer-suv',
      vehicleName: 'Chevrolet Tahoe / Cadillac Escalade',
      vehicleNameAr: 'شفروليه تاهو / كاديلاك إسكاليد',
      vehicleType: 'suv',
      imageUrl: 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=1000&q=80',
      passengerCapacity: 6,
      luggageCapacity: 5,
      basePrice: 110.0,
      currency: 'USD',
      estimatedDuration: '45-60 mins',
      features: [
        'Spacious 4x4 Luxury Ride',
        'Large Trunk for Heavy Luggage',
        'Child Safety Seats on Request',
        'Chilled Refreshments Onboard',
        'Flight Delay Shield',
      ],
      featuresAr: [
        'سيارة دفع رباعي فخمة وفسيحة',
        'مساحة أمتعة كبيرة جداً',
        'كراسي أطفال متوفرة عند الطلب',
        'مرطبات ومشروبات باردة',
        'حماية وضمان عند تأخر الرحلات',
      ],
      active: true,
    ),
    const TransferVehicleModel(
      id: 'mock-transfer-van',
      vehicleName: 'Mercedes-Benz V-Class / Toyota HiAce VIP',
      vehicleNameAr: 'مرسيدس بنز الفئة V / تويوتا هايس VIP',
      vehicleType: 'van',
      imageUrl: 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=1000&q=80',
      passengerCapacity: 8,
      luggageCapacity: 8,
      basePrice: 135.0,
      currency: 'USD',
      estimatedDuration: '45-60 mins',
      features: [
        'Ideal for Families & Groups',
        'Captain Leather Chairs',
        'USB Charging at Each Seat',
        'Dual-Zone Air Conditioning',
        'Dedicated Luggage Assistant',
      ],
      featuresAr: [
        'مثالية للعائلات والمجموعات',
        'مقاعد كابتن جلدية منفصلة',
        'منافذ شحن USB لكل مقعد',
        'تكييف مركزي مزدوج',
        'مساعدة كاملة في الأمتعة',
      ],
      active: true,
    ),
    const TransferVehicleModel(
      id: 'mock-transfer-minibus',
      vehicleName: 'Mercedes Sprinter VIP Minibus',
      vehicleNameAr: 'ميني باص مرسيدس سبرينتر VIP',
      vehicleType: 'minibus',
      imageUrl: 'https://images.unsplash.com/photo-1570125909232-eb263c188f7e?auto=format&fit=crop&w=1000&q=80',
      passengerCapacity: 16,
      luggageCapacity: 16,
      basePrice: 195.0,
      currency: 'USD',
      estimatedDuration: '50-65 mins',
      features: [
        'Grand Group Travel Luxury',
        'Microphone & Sound System',
        'High Roof & Panoramic Windows',
        'Extra-Large Luggage Bay',
        'English & Arabic Speaking Driver',
      ],
      featuresAr: [
        'رحلات مجموعات فاخرة ومريحة',
        'نظام صوتي ومايكروفون مرشد',
        'سقف مرتفع ونوافذ بانورامية',
        'مستودع أمتعة ضخم مخصص',
        'سائق يتحدث العربية والإنجليزية',
      ],
      active: true,
    ),
  ];
}

/// User Booking Request saved to Supabase
class TransferBookingModel {
  final String id;
  final String? vehicleId;
  final String vehicleType;
  final String? vehicleName;
  final TransferType transferType;
  final String pickupLocation;
  final String dropoffLocation;
  final DateTime pickupDate;
  final String pickupTime;
  final int passengersCount;
  final int adultsCount;
  final int childrenCount;
  final List<int> childrenAges;
  final int luggageCount;
  final double totalPrice;
  final String currency;
  final String customerName;
  final String email;
  final String phone;
  final String? flightNumber;
  final String? specialRequests;
  final TransferStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TransferBookingModel({
    required this.id,
    this.vehicleId,
    required this.vehicleType,
    this.vehicleName,
    required this.transferType,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.pickupDate,
    required this.pickupTime,
    required this.passengersCount,
    this.adultsCount = 1,
    this.childrenCount = 0,
    this.childrenAges = const [],
    this.luggageCount = 1,
    required this.totalPrice,
    this.currency = 'USD',
    required this.customerName,
    required this.email,
    required this.phone,
    this.flightNumber,
    this.specialRequests,
    this.status = TransferStatus.pending,
    this.createdAt,
    this.updatedAt,
  });

  String get passengersSummary {
    if (childrenCount > 0) {
      final ages = childrenAges.isNotEmpty ? ' (Ages: ${childrenAges.join(", ")})' : '';
      return '$adultsCount Adults, $childrenCount Children$ages';
    }
    return '$adultsCount Adults';
  }

  String getPassengersSummaryAr(bool isArabic) {
    if (!isArabic) return passengersSummary;
    if (childrenCount > 0) {
      final ages = childrenAges.isNotEmpty ? ' (أعمار: ${childrenAges.join("، ")})' : '';
      return '$adultsCount بالغ، $childrenCount أطفال$ages';
    }
    return '$adultsCount بالغ';
  }

  factory TransferBookingModel.fromJson(Map<String, dynamic> json) {
    List<int> parseAges(dynamic raw) {
      if (raw is List) {
        return raw.map((e) => int.tryParse(e.toString()) ?? 0).toList();
      }
      return [];
    }

    return TransferBookingModel(
      id: json['id'] as String? ?? '',
      vehicleId: json['vehicle_id'] as String?,
      vehicleType: json['vehicle_type'] as String? ?? 'sedan',
      vehicleName: json['vehicle_name'] as String?,
      transferType: TransferType.fromString(json['transfer_type'] as String?),
      pickupLocation: json['pickup_location'] as String? ?? '',
      dropoffLocation: json['dropoff_location'] as String? ?? '',
      pickupDate: json['pickup_date'] != null
          ? DateTime.tryParse(json['pickup_date'] as String) ?? DateTime.now()
          : DateTime.now(),
      pickupTime: json['pickup_time'] as String? ?? '12:00 PM',
      passengersCount: (json['passengers_count'] as num?)?.toInt() ?? 1,
      adultsCount: (json['adults_count'] as num?)?.toInt() ?? 1,
      childrenCount: (json['children_count'] as num?)?.toInt() ?? 0,
      childrenAges: parseAges(json['children_ages']),
      luggageCount: (json['luggage_count'] as num?)?.toInt() ?? 1,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      customerName: json['customer_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      flightNumber: json['flight_number'] as String?,
      specialRequests: json['special_requests'] as String?,
      status: TransferStatus.fromString(json['status'] as String?),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'vehicle_id': vehicleId,
      'vehicle_type': vehicleType,
      'vehicle_name': vehicleName,
      'transfer_type': transferType.dbValue,
      'pickup_location': pickupLocation,
      'dropoff_location': dropoffLocation,
      'pickup_date': pickupDate.toIso8601String().split('T').first,
      'pickup_time': pickupTime,
      'passengers_count': passengersCount,
      'adults_count': adultsCount,
      'children_count': childrenCount,
      'children_ages': childrenAges,
      'luggage_count': luggageCount,
      'total_price': totalPrice,
      'currency': currency,
      'customer_name': customerName,
      'email': email,
      'phone': phone,
      'flight_number': flightNumber,
      'special_requests': specialRequests,
      'status': status.dbValue,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  TransferBookingModel copyWith({
    String? id,
    String? vehicleId,
    String? vehicleType,
    String? vehicleName,
    TransferType? transferType,
    String? pickupLocation,
    String? dropoffLocation,
    DateTime? pickupDate,
    String? pickupTime,
    int? passengersCount,
    int? adultsCount,
    int? childrenCount,
    List<int>? childrenAges,
    int? luggageCount,
    double? totalPrice,
    String? currency,
    String? customerName,
    String? email,
    String? phone,
    String? flightNumber,
    String? specialRequests,
    TransferStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransferBookingModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleName: vehicleName ?? this.vehicleName,
      transferType: transferType ?? this.transferType,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      pickupDate: pickupDate ?? this.pickupDate,
      pickupTime: pickupTime ?? this.pickupTime,
      passengersCount: passengersCount ?? this.passengersCount,
      adultsCount: adultsCount ?? this.adultsCount,
      childrenCount: childrenCount ?? this.childrenCount,
      childrenAges: childrenAges ?? this.childrenAges,
      luggageCount: luggageCount ?? this.luggageCount,
      totalPrice: totalPrice ?? this.totalPrice,
      currency: currency ?? this.currency,
      customerName: customerName ?? this.customerName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      flightNumber: flightNumber ?? this.flightNumber,
      specialRequests: specialRequests ?? this.specialRequests,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

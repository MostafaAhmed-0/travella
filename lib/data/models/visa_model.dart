import 'package:equatable/equatable.dart';

/// Model for visa requirement items matching Supabase public.visa_requirements table
class VisaRequirementModel extends Equatable {
  final String id;
  final String visaServiceId;
  final String requirement;
  final String? requirementAr;

  const VisaRequirementModel({
    required this.id,
    required this.visaServiceId,
    required this.requirement,
    this.requirementAr,
  });

  String localizedRequirement(bool isArabic) {
    if (isArabic && requirementAr != null && requirementAr!.isNotEmpty) {
      return requirementAr!;
    }
    return requirement;
  }

  factory VisaRequirementModel.fromJson(Map<String, dynamic> json) {
    return VisaRequirementModel(
      id: json['id'] as String? ?? '',
      visaServiceId: json['visa_service_id'] as String? ?? '',
      requirement: json['requirement'] as String? ?? '',
      requirementAr: json['requirement_ar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'visa_service_id': visaServiceId,
      'requirement': requirement,
      'requirement_ar': requirementAr,
    };
  }

  @override
  List<Object?> get props => [id, visaServiceId, requirement, requirementAr];
}

/// Model for visa assistance services matching Supabase public.visa_services table
class VisaServiceModel extends Equatable {
  final String id;
  final String country;
  final String? countryAr;
  final String visaType;
  final String description;
  final String? descriptionAr;
  final String processingTime;
  final double price;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<VisaRequirementModel> requirements;

  // Additional UI fields
  final String region;
  final String flagEmoji;
  final String validity;
  final String iconUrl;
  final bool isPopular;

  const VisaServiceModel({
    required this.id,
    required this.country,
    this.countryAr,
    required this.visaType,
    this.description = '',
    this.descriptionAr,
    required this.processingTime,
    this.price = 0.0,
    this.active = true,
    this.createdAt,
    this.updatedAt,
    this.requirements = const [],
    this.region = 'International',
    this.flagEmoji = '✈️',
    this.validity = '90 Days',
    this.stayDuration = '30 Days',
    this.requiredDocuments = const [
      'Valid Passport (6+ months validity)',
      '2 Recent Passport Photographs',
      'Bank Statement (last 3-6 months)',
      'Flight Reservation & Hotel Booking',
      'Employment Letter / Commercial Register',
    ],
    this.importantNotes = const [
      'Processing times are estimates provided by embassy consular sections and may vary.',
      'All uploaded documents must be clear, high-resolution scans or photos.',
      'Visa approval is at the sole discretion of the respective embassy/consulate.',
    ],
    this.iconUrl = '',
    this.isPopular = false,
  });

  final String stayDuration;
  final List<String> requiredDocuments;
  final List<String> importantNotes;

  /// Backward-compatibility getter for `countryName`
  String get countryName => country;

  /// Backward-compatibility getter for `fee`
  double get fee => price;

  /// Localized country helper
  String localizedCountry(bool isArabic) {
    if (isArabic && countryAr != null && countryAr!.isNotEmpty) {
      return countryAr!;
    }
    return country;
  }

  /// Localized description helper
  String localizedDescription(bool isArabic) {
    if (isArabic && descriptionAr != null && descriptionAr!.isNotEmpty) {
      return descriptionAr!;
    }
    return description;
  }

  factory VisaServiceModel.fromJson(Map<String, dynamic> json) {
    List<VisaRequirementModel> reqs = [];
    if (json['visa_requirements'] != null && json['visa_requirements'] is List) {
      reqs = (json['visa_requirements'] as List)
          .map((e) => VisaRequirementModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (json['requirements'] != null && json['requirements'] is List) {
      reqs = (json['requirements'] as List)
          .map((e) => e is Map<String, dynamic>
              ? VisaRequirementModel.fromJson(e)
              : VisaRequirementModel(
                  id: '',
                  visaServiceId: json['id'] as String? ?? '',
                  requirement: e.toString(),
                ))
          .toList();
    }

    List<String> docList = [];
    if (json['required_documents'] != null && json['required_documents'] is List) {
      docList = (json['required_documents'] as List).map((e) => e.toString()).toList();
    } else {
      docList = const [
        'Valid Passport (6+ months validity)',
        '2 Recent Passport Photographs',
        'Bank Statement (last 3-6 months)',
        'Flight Reservation & Hotel Booking',
        'Employment Letter / Commercial Register',
      ];
    }

    List<String> notesList = [];
    if (json['important_notes'] != null && json['important_notes'] is List) {
      notesList = (json['important_notes'] as List).map((e) => e.toString()).toList();
    } else {
      notesList = const [
        'Processing times are estimates provided by embassy consular sections and may vary.',
        'All uploaded documents must be clear, high-resolution scans or photos.',
        'Visa approval is at the sole discretion of the respective embassy/consulate.',
      ];
    }

    return VisaServiceModel(
      id: json['id'] as String? ?? '',
      country: json['country'] as String? ?? json['country_name'] as String? ?? '',
      countryAr: json['country_ar'] as String?,
      visaType: json['visa_type'] as String? ?? 'Tourist Visa',
      description: json['description'] as String? ?? '',
      descriptionAr: json['description_ar'] as String?,
      processingTime: json['processing_time'] as String? ?? '10-15 Days',
      price: (json['price'] as num?)?.toDouble() ?? (json['fee'] as num?)?.toDouble() ?? 0.0,
      active: (json['active'] as bool?) ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      requirements: reqs,
      region: json['region'] as String? ?? 'International',
      flagEmoji: json['flag_emoji'] as String? ?? '✈️',
      validity: json['validity'] as String? ?? '90 Days',
      stayDuration: json['stay_duration'] as String? ?? '30 Days',
      requiredDocuments: docList,
      importantNotes: notesList,
      iconUrl: json['icon_url'] as String? ?? '',
      isPopular: (json['is_popular'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'country': country,
      'country_ar': countryAr,
      'visa_type': visaType,
      'description': description,
      'description_ar': descriptionAr,
      'processing_time': processingTime,
      'price': price,
      'active': active,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  VisaServiceModel copyWith({
    String? id,
    String? country,
    String? countryAr,
    String? visaType,
    String? description,
    String? descriptionAr,
    String? processingTime,
    double? price,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<VisaRequirementModel>? requirements,
    String? region,
    String? flagEmoji,
    String? validity,
    String? stayDuration,
    List<String>? requiredDocuments,
    List<String>? importantNotes,
    String? iconUrl,
    bool? isPopular,
  }) {
    return VisaServiceModel(
      id: id ?? this.id,
      country: country ?? this.country,
      countryAr: countryAr ?? this.countryAr,
      visaType: visaType ?? this.visaType,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      processingTime: processingTime ?? this.processingTime,
      price: price ?? this.price,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      requirements: requirements ?? this.requirements,
      region: region ?? this.region,
      flagEmoji: flagEmoji ?? this.flagEmoji,
      validity: validity ?? this.validity,
      stayDuration: stayDuration ?? this.stayDuration,
      requiredDocuments: requiredDocuments ?? this.requiredDocuments,
      importantNotes: importantNotes ?? this.importantNotes,
      iconUrl: iconUrl ?? this.iconUrl,
      isPopular: isPopular ?? this.isPopular,
    );
  }

  @override
  List<Object?> get props => [
        id,
        country,
        countryAr,
        visaType,
        description,
        descriptionAr,
        processingTime,
        price,
        active,
        stayDuration,
        requiredDocuments,
        importantNotes,
      ];
}

/// Backward compatibility alias
typedef VisaCountryModel = VisaServiceModel;

/// Service feature card for Visa processing UI
class VisaServiceFeature {
  final String title;
  final String description;
  final String iconCode;

  const VisaServiceFeature({
    required this.title,
    required this.description,
    required this.iconCode,
  });
}

/// Application statuses
class VisaApplicationStatus {
  static const String pending = 'pending';
  static const String underReview = 'under_review';
  static const String missingDocuments = 'missing_documents';
  static const String approved = 'approved';
  static const String rejected = 'rejected';
  static const String completed = 'completed';

  static const List<String> all = [
    pending,
    underReview,
    missingDocuments,
    approved,
    rejected,
    completed,
  ];

  static String displayName(String status, bool isArabic) {
    switch (status.toLowerCase()) {
      case 'under_review':
        return isArabic ? 'قيد المراجعة والتدقيق' : 'Under Review';
      case 'missing_documents':
        return isArabic ? 'مستندات ناقصة' : 'Missing Documents';
      case 'approved':
        return isArabic ? 'تمت الموافقة' : 'Approved';
      case 'rejected':
        return isArabic ? 'مرفوض' : 'Rejected';
      case 'completed':
        return isArabic ? 'مكتمل' : 'Completed';
      case 'pending':
      default:
        return isArabic ? 'قيد الانتظار' : 'Pending';
    }
  }
}

/// Model for Visa Application stored in Supabase public.visa_applications table
class VisaApplicationModel extends Equatable {
  final String id;
  final String? userId;
  final String referenceNumber;
  final String country;
  final String visaType;
  final String? visaServiceId;
  final DateTime expectedTravelDate;
  final DateTime? returnDate;
  final String travelPurpose; // Tourism, Business, Family Visit, Transit, Medical, Study
  final String fullName;
  final String email;
  final String phone;
  final String nationality;
  final String passportNumber;
  final DateTime dateOfBirth;
  final Map<String, dynamic> documents; // Map of document name/key to storage path/URL
  final String status; // pending, under_review, missing_documents, approved, rejected, completed
  final double estimatedFee;
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const VisaApplicationModel({
    required this.id,
    this.userId,
    required this.referenceNumber,
    required this.country,
    required this.visaType,
    this.visaServiceId,
    required this.expectedTravelDate,
    this.returnDate,
    required this.travelPurpose,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.nationality,
    required this.passportNumber,
    required this.dateOfBirth,
    this.documents = const {},
    this.status = VisaApplicationStatus.pending,
    this.estimatedFee = 0.0,
    this.adminNotes,
    required this.createdAt,
    this.updatedAt,
  });

  factory VisaApplicationModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> docMap = {};
    if (json['documents'] != null) {
      if (json['documents'] is Map) {
        docMap = Map<String, dynamic>.from(json['documents'] as Map);
      }
    }

    return VisaApplicationModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String?,
      referenceNumber: json['reference_number'] as String? ?? '',
      country: json['country'] as String? ?? '',
      visaType: json['visa_type'] as String? ?? 'Tourist Visa',
      visaServiceId: json['visa_service_id'] as String?,
      expectedTravelDate: json['expected_travel_date'] != null
          ? DateTime.parse(json['expected_travel_date'].toString())
          : DateTime.now().add(const Duration(days: 30)),
      returnDate: json['return_date'] != null
          ? DateTime.tryParse(json['return_date'].toString())
          : null,
      travelPurpose: json['travel_purpose'] as String? ?? 'Tourism',
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      nationality: json['nationality'] as String? ?? '',
      passportNumber: json['passport_number'] as String? ?? '',
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'].toString())
          : DateTime(1995, 1, 1),
      documents: docMap,
      status: json['status'] as String? ?? VisaApplicationStatus.pending,
      estimatedFee: (json['estimated_fee'] as num?)?.toDouble() ?? 0.0,
      adminNotes: json['admin_notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (userId != null) 'user_id': userId,
      'reference_number': referenceNumber,
      'country': country,
      'visa_type': visaType,
      if (visaServiceId != null) 'visa_service_id': visaServiceId,
      'expected_travel_date': expectedTravelDate.toIso8601String().split('T').first,
      if (returnDate != null)
        'return_date': returnDate!.toIso8601String().split('T').first,
      'travel_purpose': travelPurpose,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'nationality': nationality,
      'passport_number': passportNumber,
      'date_of_birth': dateOfBirth.toIso8601String().split('T').first,
      'documents': documents,
      'status': status,
      'estimated_fee': estimatedFee,
      if (adminNotes != null) 'admin_notes': adminNotes,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  VisaApplicationModel copyWith({
    String? id,
    String? userId,
    String? referenceNumber,
    String? country,
    String? visaType,
    String? visaServiceId,
    DateTime? expectedTravelDate,
    DateTime? returnDate,
    String? travelPurpose,
    String? fullName,
    String? email,
    String? phone,
    String? nationality,
    String? passportNumber,
    DateTime? dateOfBirth,
    Map<String, dynamic>? documents,
    String? status,
    double? estimatedFee,
    String? adminNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VisaApplicationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      country: country ?? this.country,
      visaType: visaType ?? this.visaType,
      visaServiceId: visaServiceId ?? this.visaServiceId,
      expectedTravelDate: expectedTravelDate ?? this.expectedTravelDate,
      returnDate: returnDate ?? this.returnDate,
      travelPurpose: travelPurpose ?? this.travelPurpose,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      nationality: nationality ?? this.nationality,
      passportNumber: passportNumber ?? this.passportNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      documents: documents ?? this.documents,
      status: status ?? this.status,
      estimatedFee: estimatedFee ?? this.estimatedFee,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        referenceNumber,
        country,
        visaType,
        visaServiceId,
        expectedTravelDate,
        returnDate,
        travelPurpose,
        fullName,
        email,
        phone,
        nationality,
        passportNumber,
        dateOfBirth,
        documents,
        status,
        estimatedFee,
        adminNotes,
        createdAt,
        updatedAt,
      ];
}


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
    this.iconUrl = '',
    this.isPopular = false,
  });

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

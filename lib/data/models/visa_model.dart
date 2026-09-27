/// Model for visa assistance services and countries
class VisaCountryModel {
  final String id;
  final String countryName;
  final String region; // 'Europe (Schengen)', 'Asia', 'Middle East', 'UK & USA', 'Americas'
  final String flagEmoji;
  final String processingTime;
  final String validity;
  final double fee;
  final String iconUrl;
  final List<String> requirements;
  final bool isPopular;

  const VisaCountryModel({
    required this.id,
    required this.countryName,
    required this.region,
    required this.flagEmoji,
    required this.processingTime,
    required this.validity,
    required this.fee,
    required this.iconUrl,
    this.requirements = const [],
    this.isPopular = false,
  });

  factory VisaCountryModel.fromJson(Map<String, dynamic> json) {
    return VisaCountryModel(
      id: json['id'] as String? ?? '',
      countryName: json['country_name'] as String? ?? '',
      region: json['region'] as String? ?? 'General',
      flagEmoji: json['flag_emoji'] as String? ?? '✈️',
      processingTime: json['processing_time'] as String? ?? '10-15 Days',
      validity: json['validity'] as String? ?? '90 Days',
      fee: (json['fee'] as num?)?.toDouble() ?? 0.0,
      iconUrl: json['icon_url'] as String? ?? '',
      requirements: (json['requirements'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isPopular: json['is_popular'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'country_name': countryName,
      'region': region,
      'flag_emoji': flagEmoji,
      'processing_time': processingTime,
      'validity': validity,
      'fee': fee,
      'icon_url': iconUrl,
      'requirements': requirements,
      'is_popular': isPopular,
    };
  }
}

/// Service feature card for Visa processing
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

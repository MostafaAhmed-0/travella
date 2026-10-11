import 'package:equatable/equatable.dart';

/// Application site settings data model including verified social links & contact parameters
class SiteSettingsModel extends Equatable {
  final String id;
  final String siteName;
  final String siteNameAr;
  final String supportEmail;
  final String phoneNumber;
  final String cairoAddress;
  final String cairoAddressAr;
  final String facebookUrl;
  final String instagramUrl;
  final String whatsappNumber;
  final String youtubeUrl;
  final String tiktokUrl;
  final DateTime? updatedAt;

  const SiteSettingsModel({
    this.id = 'default',
    this.siteName = 'Travella Tour & Travel',
    this.siteNameAr = 'ترافيلا للسياحة والسفر',
    this.supportEmail = 'info@travella.com',
    this.phoneNumber = '+20 100 123 4567',
    this.cairoAddress = 'Zamalek, Cairo, Egypt',
    this.cairoAddressAr = 'الزمالك، القاهرة، جمهورية مصر العربية',
    this.facebookUrl = 'https://facebook.com/travella',
    this.instagramUrl = 'https://instagram.com/travella',
    this.whatsappNumber = '+20 100 123 4567',
    this.youtubeUrl = 'https://youtube.com/@travella',
    this.tiktokUrl = 'https://tiktok.com/@travella',
    this.updatedAt,
  });

  /// Default baseline settings
  factory SiteSettingsModel.initial() => const SiteSettingsModel();

  /// Check whether individual social links are populated & active
  bool get hasFacebook => facebookUrl.trim().isNotEmpty;
  bool get hasInstagram => instagramUrl.trim().isNotEmpty;
  bool get hasWhatsapp => whatsappNumber.trim().isNotEmpty;
  bool get hasYoutube => youtubeUrl.trim().isNotEmpty;
  bool get hasTiktok => tiktokUrl.trim().isNotEmpty;

  /// Returns true if at least one social media link is active
  bool get hasAnySocialLink =>
      hasFacebook || hasInstagram || hasWhatsapp || hasYoutube || hasTiktok;

  /// Generate a valid web-ready WhatsApp URL with optional pre-filled message
  String getWhatsAppUrl([String? prefilledMessage]) {
    final raw = whatsappNumber.trim();
    if (raw.isEmpty) return '';

    final encodedMsg = prefilledMessage != null && prefilledMessage.isNotEmpty
        ? '?text=${Uri.encodeComponent(prefilledMessage)}'
        : '';

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      if (prefilledMessage != null && !raw.contains('text=')) {
        final separator = raw.contains('?') ? '&' : '?';
        return '$raw${separator}text=${Uri.encodeComponent(prefilledMessage)}';
      }
      return raw;
    }

    // Clean phone number: remove spaces, dashes, parentheses
    String cleanDigits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    // If user provided leading zero for Egypt, convert 010... -> 2010...
    if (cleanDigits.startsWith('01') && cleanDigits.length == 11) {
      cleanDigits = '2$cleanDigits';
    } else if (cleanDigits.startsWith('00')) {
      cleanDigits = cleanDigits.substring(2);
    }

    return 'https://wa.me/$cleanDigits$encodedMsg';
  }

  factory SiteSettingsModel.fromJson(Map<String, dynamic> json) {
    return SiteSettingsModel(
      id: json['id'] as String? ?? 'default',
      siteName: json['site_name'] as String? ?? 'Travella Tour & Travel',
      siteNameAr: json['site_name_ar'] as String? ?? 'ترافيلا للسياحة والسفر',
      supportEmail: json['support_email'] as String? ?? 'info@travella.com',
      phoneNumber: json['phone_number'] as String? ?? '+20 100 123 4567',
      cairoAddress: json['cairo_address'] as String? ?? 'Zamalek, Cairo, Egypt',
      cairoAddressAr: json['cairo_address_ar'] as String? ?? 'الزمالك، القاهرة، جمهورية مصر العربية',
      facebookUrl: json['facebook_url'] as String? ?? 'https://facebook.com/travella',
      instagramUrl: json['instagram_url'] as String? ?? 'https://instagram.com/travella',
      whatsappNumber: json['whatsapp_number'] as String? ?? '+20 100 123 4567',
      youtubeUrl: json['youtube_url'] as String? ?? 'https://youtube.com/@travella',
      tiktokUrl: json['tiktok_url'] as String? ?? 'https://tiktok.com/@travella',
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'site_name': siteName,
      'site_name_ar': siteNameAr,
      'support_email': supportEmail,
      'phone_number': phoneNumber,
      'cairo_address': cairoAddress,
      'cairo_address_ar': cairoAddressAr,
      'facebook_url': facebookUrl,
      'instagram_url': instagramUrl,
      'whatsapp_number': whatsappNumber,
      'youtube_url': youtubeUrl,
      'tiktok_url': tiktokUrl,
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  SiteSettingsModel copyWith({
    String? id,
    String? siteName,
    String? siteNameAr,
    String? supportEmail,
    String? phoneNumber,
    String? cairoAddress,
    String? cairoAddressAr,
    String? facebookUrl,
    String? instagramUrl,
    String? whatsappNumber,
    String? youtubeUrl,
    String? tiktokUrl,
    DateTime? updatedAt,
  }) {
    return SiteSettingsModel(
      id: id ?? this.id,
      siteName: siteName ?? this.siteName,
      siteNameAr: siteNameAr ?? this.siteNameAr,
      supportEmail: supportEmail ?? this.supportEmail,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      cairoAddress: cairoAddress ?? this.cairoAddress,
      cairoAddressAr: cairoAddressAr ?? this.cairoAddressAr,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      tiktokUrl: tiktokUrl ?? this.tiktokUrl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        siteName,
        siteNameAr,
        supportEmail,
        phoneNumber,
        cairoAddress,
        cairoAddressAr,
        facebookUrl,
        instagramUrl,
        whatsappNumber,
        youtubeUrl,
        tiktokUrl,
        updatedAt,
      ];
}

import 'package:equatable/equatable.dart';

/// Model representing a travel or airline partner matching Supabase public.partners table
class PartnerModel extends Equatable {
  final String id;
  final String name;
  final String logoUrl;
  final String? website;
  final bool active;

  // Additional UI fields
  final String category;

  const PartnerModel({
    required this.id,
    required this.name,
    required this.logoUrl,
    this.website,
    this.active = true,
    this.category = 'Partners',
  });

  factory PartnerModel.fromJson(Map<String, dynamic> json) {
    return PartnerModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      logoUrl: json['logo_url'] as String? ?? '',
      website: json['website'] as String?,
      active: (json['active'] as bool?) ?? true,
      category: json['category'] as String? ?? 'Partners',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo_url': logoUrl,
      'website': website,
      'active': active,
    };
  }

  @override
  List<Object?> get props => [id, name, logoUrl, website, active];
}

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/partner_model.dart';
import '../services/supabase_service.dart';

abstract class PartnerRemoteDataSource {
  Future<List<PartnerModel>> getPartners({bool activeOnly = true});
  Future<PartnerModel> createPartner(PartnerModel partner);
  Future<PartnerModel> updatePartner(PartnerModel partner);
  Future<void> deletePartner(String id);
}

class PartnerRemoteDataSourceImpl implements PartnerRemoteDataSource {
  final SupabaseClient _client;

  PartnerRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  @override
  Future<List<PartnerModel>> getPartners({bool activeOnly = true}) async {
    try {
      var query = _client.from(SupabaseService.tablePartners).select();
      if (activeOnly) {
        query = query.eq('active', true);
      }
      final response = await query.order('name');
      return (response as List)
          .map((json) => PartnerModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<PartnerModel> createPartner(PartnerModel partner) async {
    try {
      final map = partner.toJson()..remove('id');
      final response = await _client
          .from(SupabaseService.tablePartners)
          .insert(map)
          .select()
          .single();
      return PartnerModel.fromJson(response);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<PartnerModel> updatePartner(PartnerModel partner) async {
    try {
      final map = partner.toJson()..remove('id');
      final response = await _client
          .from(SupabaseService.tablePartners)
          .update(map)
          .eq('id', partner.id)
          .select()
          .single();
      return PartnerModel.fromJson(response);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<void> deletePartner(String id) async {
    try {
      await _client.from(SupabaseService.tablePartners).delete().eq('id', id);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }
}

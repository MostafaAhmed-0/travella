import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/visa_model.dart';
import '../services/supabase_service.dart';

abstract class VisaRemoteDataSource {
  Future<List<VisaServiceModel>> getVisaServices({bool activeOnly = true});
  Future<VisaServiceModel?> getVisaServiceById(String id);
  Future<VisaServiceModel> createVisaService(VisaServiceModel service);
  Future<VisaServiceModel> updateVisaService(VisaServiceModel service);
  Future<void> deleteVisaService(String id);
  Future<void> addRequirement(String visaServiceId, String requirement, String? requirementAr);
  Future<void> deleteRequirement(String requirementId);

  // Visa Applications
  Future<List<VisaApplicationModel>> getVisaApplications({String? userId, String? status});
  Future<VisaApplicationModel?> getVisaApplicationById(String id);
  Future<VisaApplicationModel> createVisaApplication(VisaApplicationModel application);
  Future<VisaApplicationModel> updateVisaApplicationStatus(String id, String status, {String? adminNotes});
  Future<void> deleteVisaApplication(String id);
}

class VisaRemoteDataSourceImpl implements VisaRemoteDataSource {
  final SupabaseClient _client;

  VisaRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  @override
  Future<List<VisaServiceModel>> getVisaServices({bool activeOnly = true}) async {
    try {
      var query = _client
          .from(SupabaseService.tableVisaServices)
          .select('*, visa_requirements(*)');

      if (activeOnly) {
        query = query.eq('active', true);
      }
      final response = await query.order('country');
      return (response as List)
          .map((json) => VisaServiceModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<VisaServiceModel?> getVisaServiceById(String id) async {
    try {
      final response = await _client
          .from(SupabaseService.tableVisaServices)
          .select('*, visa_requirements(*)')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return VisaServiceModel.fromJson(response);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<VisaServiceModel> createVisaService(VisaServiceModel service) async {
    try {
      final map = service.toJson()..remove('id');
      final response = await _client
          .from(SupabaseService.tableVisaServices)
          .insert(map)
          .select('*, visa_requirements(*)')
          .single();
      final created = VisaServiceModel.fromJson(response);

      // Persist document requirements if present
      final slots = service.effectiveDocumentSlots;
      if (slots.isNotEmpty) {
        final reqRows = slots.map((slot) => {
          'visa_service_id': created.id,
          'requirement': jsonEncode(slot.toJson()),
          'requirement_ar': slot.labelAr ?? slot.label,
        }).toList();

        await _client.from(SupabaseService.tableVisaRequirements).insert(reqRows);
        return await getVisaServiceById(created.id) ?? created;
      }

      return created;
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<VisaServiceModel> updateVisaService(VisaServiceModel service) async {
    try {
      final map = service.toJson()..remove('id');
      await _client
          .from(SupabaseService.tableVisaServices)
          .update(map)
          .eq('id', service.id);

      // Clear existing requirements for this visa
      await _client
          .from(SupabaseService.tableVisaRequirements)
          .delete()
          .eq('visa_service_id', service.id);

      // Insert updated document slots
      final slots = service.effectiveDocumentSlots;
      if (slots.isNotEmpty) {
        final reqRows = slots.map((slot) => {
          'visa_service_id': service.id,
          'requirement': jsonEncode(slot.toJson()),
          'requirement_ar': slot.labelAr ?? slot.label,
        }).toList();

        await _client.from(SupabaseService.tableVisaRequirements).insert(reqRows);
      }

      final refreshed = await getVisaServiceById(service.id);
      return refreshed ?? service;
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<void> deleteVisaService(String id) async {
    try {
      await _client
          .from(SupabaseService.tableVisaServices)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<void> addRequirement(String visaServiceId, String requirement, String? requirementAr) async {
    try {
      await _client.from(SupabaseService.tableVisaRequirements).insert({
        'visa_service_id': visaServiceId,
        'requirement': requirement,
        'requirement_ar': requirementAr,
      });
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<void> deleteRequirement(String requirementId) async {
    try {
      await _client
          .from(SupabaseService.tableVisaRequirements)
          .delete()
          .eq('id', requirementId);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<List<VisaApplicationModel>> getVisaApplications({String? userId, String? status}) async {
    try {
      var query = _client.from(SupabaseService.tableVisaApplications).select('*');
      if (userId != null && userId.isNotEmpty) {
        query = query.eq('user_id', userId);
      }
      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }
      final response = await query.order('created_at', ascending: false);
      return (response as List)
          .map((json) => VisaApplicationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Graceful fallback for demo or empty/not created table
      return [];
    }
  }

  @override
  Future<VisaApplicationModel?> getVisaApplicationById(String id) async {
    try {
      final response = await _client
          .from(SupabaseService.tableVisaApplications)
          .select('*')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return VisaApplicationModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<VisaApplicationModel> createVisaApplication(VisaApplicationModel application) async {
    try {
      // Remove server-managed fields from the insert payload
      final map = application.toJson()
        ..remove('id')
        ..remove('created_at')
        ..remove('updated_at');
      final response = await _client
          .from(SupabaseService.tableVisaApplications)
          .insert(map)
          .select('*')
          .single();
      return VisaApplicationModel.fromJson(response);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<VisaApplicationModel> updateVisaApplicationStatus(String id, String status, {String? adminNotes}) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (adminNotes != null) {
        updates['admin_notes'] = adminNotes;
      }
      final response = await _client
          .from(SupabaseService.tableVisaApplications)
          .update(updates)
          .eq('id', id)
          .select('*')
          .single();
      return VisaApplicationModel.fromJson(response);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<void> deleteVisaApplication(String id) async {
    try {
      await _client
          .from(SupabaseService.tableVisaApplications)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }
}

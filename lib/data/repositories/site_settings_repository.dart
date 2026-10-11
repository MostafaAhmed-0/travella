import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/site_settings_model.dart';
import '../services/supabase_service.dart';

abstract class SiteSettingsRepository {
  Future<SiteSettingsModel> getSettings();
  Future<SiteSettingsModel> updateSettings(SiteSettingsModel settings);
}

class SiteSettingsRepositoryImpl implements SiteSettingsRepository {
  static const String _cacheKey = 'travella_site_settings_cache';

  @override
  Future<SiteSettingsModel> getSettings() async {
    // 1. First, attempt to load cached settings for instant zero-latency UI
    SiteSettingsModel current = SiteSettingsModel.initial();
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJsonStr = prefs.getString(_cacheKey);
      if (cachedJsonStr != null) {
        final decoded = jsonDecode(cachedJsonStr) as Map<String, dynamic>;
        current = SiteSettingsModel.fromJson(decoded);
      }
    } catch (e) {
      debugPrint('[SiteSettingsRepository] Cache read error: $e');
    }

    // 2. Fetch latest live row from Supabase
    try {
      final response = await SupabaseService.client
          .from(SupabaseService.tableSiteSettings)
          .select()
          .eq('id', 'default')
          .maybeSingle();

      if (response != null) {
        final liveSettings = SiteSettingsModel.fromJson(response);
        // Update local cache
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, jsonEncode(liveSettings.toJson()));
        return liveSettings;
      }
    } catch (e) {
      debugPrint('[SiteSettingsRepository] Supabase fetch error (using cached/default): $e');
    }

    return current;
  }

  @override
  Future<SiteSettingsModel> updateSettings(SiteSettingsModel settings) async {
    final updated = settings.copyWith(updatedAt: DateTime.now());

    // 1. Save to local cache first
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(updated.toJson()));
    } catch (e) {
      debugPrint('[SiteSettingsRepository] Cache write error: $e');
    }

    // 2. Persist to Supabase
    try {
      await SupabaseService.client
          .from(SupabaseService.tableSiteSettings)
          .upsert(updated.toJson());
    } catch (e) {
      debugPrint('[SiteSettingsRepository] Supabase upsert error: $e');
    }

    return updated;
  }
}

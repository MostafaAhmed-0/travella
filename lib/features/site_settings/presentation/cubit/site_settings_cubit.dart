import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/models/site_settings_model.dart';
import '../../../../data/repositories/site_settings_repository.dart';
import 'site_settings_state.dart';

class SiteSettingsCubit extends Cubit<SiteSettingsState> {
  final SiteSettingsRepository _repository;

  SiteSettingsCubit({required SiteSettingsRepository repository})
      : _repository = repository,
        super(SiteSettingsState.initial()) {
    loadSettings();
  }

  SiteSettingsModel get settings => state.settings;

  Future<void> loadSettings() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final fetched = await _repository.getSettings();
      emit(state.copyWith(settings: fetched, isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load site settings: $e',
      ));
    }
  }

  Future<bool> updateSettings(SiteSettingsModel newSettings) async {
    emit(state.copyWith(isSaving: true, errorMessage: null, isSavedSuccessfully: false));
    try {
      final updated = await _repository.updateSettings(newSettings);
      emit(state.copyWith(
        settings: updated,
        isSaving: false,
        isSavedSuccessfully: true,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to save settings: $e',
        isSavedSuccessfully: false,
      ));
      return false;
    }
  }
}

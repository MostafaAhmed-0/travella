import 'package:equatable/equatable.dart';
import '../../../../data/models/site_settings_model.dart';

class SiteSettingsState extends Equatable {
  final SiteSettingsModel settings;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final bool isSavedSuccessfully;

  const SiteSettingsState({
    required this.settings,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.isSavedSuccessfully = false,
  });

  factory SiteSettingsState.initial() => SiteSettingsState(
        settings: SiteSettingsModel.initial(),
        isLoading: false,
      );

  SiteSettingsState copyWith({
    SiteSettingsModel? settings,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool? isSavedSuccessfully,
  }) {
    return SiteSettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      isSavedSuccessfully: isSavedSuccessfully ?? false,
    );
  }

  @override
  List<Object?> get props => [
        settings,
        isLoading,
        isSaving,
        errorMessage,
        isSavedSuccessfully,
      ];
}

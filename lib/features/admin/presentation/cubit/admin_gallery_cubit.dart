import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../data/models/gallery_model.dart';
import '../../../../data/repositories/gallery_repository.dart';
import '../../../../data/repositories/storage_repository.dart';

class UploadProgressItem extends Equatable {
  final String filename;
  final double progress; // 0.0 to 1.0
  final bool isCompleted;
  final String? error;

  const UploadProgressItem({
    required this.filename,
    this.progress = 0.0,
    this.isCompleted = false,
    this.error,
  });

  UploadProgressItem copyWith({
    String? filename,
    double? progress,
    bool? isCompleted,
    String? error,
  }) {
    return UploadProgressItem(
      filename: filename ?? this.filename,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [filename, progress, isCompleted, error];
}

class AdminGalleryState extends Equatable {
  final bool isLoading;
  final bool isUploading;
  final String? errorMessage;
  final String? successMessage;
  final List<GalleryModel> allItems;
  final List<GalleryModel> filteredItems;
  final String selectedCategory; // 'All', 'Hotels', 'Beaches', 'Tours', 'Cities', 'Landmarks', 'Events'
  final bool? filterFeatured;
  final List<UploadProgressItem> uploadProgress;

  const AdminGalleryState({
    this.isLoading = false,
    this.isUploading = false,
    this.errorMessage,
    this.successMessage,
    this.allItems = const [],
    this.filteredItems = const [],
    this.selectedCategory = 'All',
    this.filterFeatured,
    this.uploadProgress = const [],
  });

  AdminGalleryState copyWith({
    bool? isLoading,
    bool? isUploading,
    String? errorMessage,
    String? successMessage,
    List<GalleryModel>? allItems,
    List<GalleryModel>? filteredItems,
    String? selectedCategory,
    bool? filterFeatured,
    List<UploadProgressItem>? uploadProgress,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AdminGalleryState(
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      allItems: allItems ?? this.allItems,
      filteredItems: filteredItems ?? this.filteredItems,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      filterFeatured: filterFeatured ?? this.filterFeatured,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isUploading,
        errorMessage,
        successMessage,
        allItems,
        filteredItems,
        selectedCategory,
        filterFeatured,
        uploadProgress,
      ];
}

class AdminGalleryCubit extends Cubit<AdminGalleryState> {
  final GalleryRepository _galleryRepository;
  final StorageRepository _storageRepository;

  static const List<String> categories = [
    'All',
    'Hotels',
    'Beaches',
    'Tours',
    'Cities',
    'Landmarks',
    'Events',
  ];

  AdminGalleryCubit({
    required GalleryRepository galleryRepository,
    required StorageRepository storageRepository,
  })  : _galleryRepository = galleryRepository,
        _storageRepository = storageRepository,
        super(const AdminGalleryState());

  Future<void> loadGallery() async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      final list = await _galleryRepository.getGalleryItems();
      final filtered = _applyFilters(list, state.selectedCategory, state.filterFeatured);
      emit(state.copyWith(
        isLoading: false,
        allItems: list,
        filteredItems: filtered,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load gallery items: ${e.toString().replaceAll('Exception: ', '')}',
      ));
    }
  }

  void filterByCategory(String category) {
    final filtered = _applyFilters(state.allItems, category, state.filterFeatured);
    emit(state.copyWith(selectedCategory: category, filteredItems: filtered));
  }

  void filterByFeatured(bool? featured) {
    final filtered = _applyFilters(state.allItems, state.selectedCategory, featured);
    emit(state.copyWith(filterFeatured: featured, filteredItems: filtered));
  }

  Future<bool> uploadSingleImage({
    required Uint8List bytes,
    required String filename,
    required String title,
    required String category,
    bool featured = false,
  }) async {
    emit(state.copyWith(
      isUploading: true,
      clearError: true,
      clearSuccess: true,
      uploadProgress: [UploadProgressItem(filename: filename, progress: 0.2)],
    ));

    try {
      // Step 1: Upload to Supabase Storage
      emit(state.copyWith(
        uploadProgress: [UploadProgressItem(filename: filename, progress: 0.6)],
      ));
      final imageUrl = await _storageRepository.uploadGalleryImage(bytes, filename);

      // Step 2: Create DB Record
      emit(state.copyWith(
        uploadProgress: [UploadProgressItem(filename: filename, progress: 0.85)],
      ));
      final newItem = GalleryModel(
        id: '',
        title: title.isEmpty ? filename.split('.').first : title,
        imageUrl: imageUrl,
        category: category,
        featured: featured,
        createdAt: DateTime.now(),
      );

      final created = await _galleryRepository.createGalleryItem(newItem);
      final updatedList = [created, ...state.allItems];
      final filtered = _applyFilters(updatedList, state.selectedCategory, state.filterFeatured);

      emit(state.copyWith(
        isUploading: false,
        allItems: updatedList,
        filteredItems: filtered,
        uploadProgress: [UploadProgressItem(filename: filename, progress: 1.0, isCompleted: true)],
        successMessage: 'Image "$title" uploaded to Supabase Storage successfully.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isUploading: false,
        uploadProgress: [UploadProgressItem(filename: filename, progress: 0.0, error: e.toString())],
        errorMessage: 'Failed to upload image: ${e.toString().replaceAll('Exception: ', '')}',
      ));
      return false;
    }
  }

  Future<void> uploadMultipleImages({
    required List<({Uint8List bytes, String filename})> files,
    required String category,
    bool featured = false,
  }) async {
    if (files.isEmpty) return;

    emit(state.copyWith(
      isUploading: true,
      clearError: true,
      clearSuccess: true,
      uploadProgress: files
          .map((f) => UploadProgressItem(filename: f.filename, progress: 0.0))
          .toList(),
    ));

    final progressMap = {
      for (final f in files) f.filename: UploadProgressItem(filename: f.filename, progress: 0.1)
    };

    final createdItems = <GalleryModel>[];

    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      try {
        progressMap[file.filename] = progressMap[file.filename]!.copyWith(progress: 0.4);
        emit(state.copyWith(uploadProgress: progressMap.values.toList()));

        final url = await _storageRepository.uploadGalleryImage(file.bytes, file.filename);

        progressMap[file.filename] = progressMap[file.filename]!.copyWith(progress: 0.8);
        emit(state.copyWith(uploadProgress: progressMap.values.toList()));

        final item = GalleryModel(
          id: '',
          title: file.filename.split('.').first.replaceAll('_', ' '),
          imageUrl: url,
          category: category,
          featured: featured,
          createdAt: DateTime.now(),
        );

        final created = await _galleryRepository.createGalleryItem(item);
        createdItems.add(created);

        progressMap[file.filename] = progressMap[file.filename]!.copyWith(
          progress: 1.0,
          isCompleted: true,
        );
        emit(state.copyWith(uploadProgress: progressMap.values.toList()));
      } catch (e) {
        progressMap[file.filename] = progressMap[file.filename]!.copyWith(
          progress: 0.0,
          error: e.toString().replaceAll('Exception: ', ''),
        );
        emit(state.copyWith(uploadProgress: progressMap.values.toList()));
      }
    }

    final updatedList = [...createdItems, ...state.allItems];
    final filtered = _applyFilters(updatedList, state.selectedCategory, state.filterFeatured);

    emit(state.copyWith(
      isUploading: false,
      allItems: updatedList,
      filteredItems: filtered,
      successMessage: 'Batch upload complete. ${createdItems.length} images saved.',
    ));
  }

  Future<bool> deleteGalleryItem(String id) async {
    emit(state.copyWith(clearError: true, clearSuccess: true));
    try {
      await _galleryRepository.deleteGalleryItem(id);
      final updatedList = state.allItems.where((item) => item.id != id).toList();
      final filtered = _applyFilters(updatedList, state.selectedCategory, state.filterFeatured);
      emit(state.copyWith(
        allItems: updatedList,
        filteredItems: filtered,
        successMessage: 'Gallery image deleted.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to delete gallery item: ${e.toString().replaceAll('Exception: ', '')}',
      ));
      return false;
    }
  }

  Future<void> toggleFeatured(GalleryModel item) async {
    final updated = item.copyWith(featured: !item.featured);
    try {
      await _galleryRepository.updateGalleryItem(updated);
      final updatedList = state.allItems.map((i) => i.id == updated.id ? updated : i).toList();
      final filtered = _applyFilters(updatedList, state.selectedCategory, state.filterFeatured);
      emit(state.copyWith(
        allItems: updatedList,
        filteredItems: filtered,
        successMessage: 'Updated featured status.',
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to update item: ${e.toString().replaceAll('Exception: ', '')}',
      ));
    }
  }

  List<GalleryModel> _applyFilters(
    List<GalleryModel> list,
    String category,
    bool? featured,
  ) {
    return list.where((item) {
      if (category != 'All' && item.category.toLowerCase() != category.toLowerCase()) {
        return false;
      }
      if (featured != null && item.featured != featured) {
        return false;
      }
      return true;
    }).toList();
  }
}

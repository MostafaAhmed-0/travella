import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../data/models/blog_model.dart';
import '../../../../data/repositories/blog_repository.dart';

class AdminBlogsState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;
  final List<BlogModel> allBlogs;
  final List<BlogModel> filteredBlogs;
  final String searchQuery;
  final bool? filterPublished;

  const AdminBlogsState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.allBlogs = const [],
    this.filteredBlogs = const [],
    this.searchQuery = '',
    this.filterPublished,
  });

  AdminBlogsState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    List<BlogModel>? allBlogs,
    List<BlogModel>? filteredBlogs,
    String? searchQuery,
    bool? filterPublished,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AdminBlogsState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      allBlogs: allBlogs ?? this.allBlogs,
      filteredBlogs: filteredBlogs ?? this.filteredBlogs,
      searchQuery: searchQuery ?? this.searchQuery,
      filterPublished: filterPublished ?? this.filterPublished,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSaving,
        errorMessage,
        successMessage,
        allBlogs,
        filteredBlogs,
        searchQuery,
        filterPublished,
      ];
}

class AdminBlogsCubit extends Cubit<AdminBlogsState> {
  final BlogRepository _blogRepository;

  AdminBlogsCubit({required BlogRepository blogRepository})
      : _blogRepository = blogRepository,
        super(const AdminBlogsState());

  Future<void> loadBlogs() async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      final list = await _blogRepository.getAllBlogs();
      final filtered = _applyFilters(list, state.searchQuery, state.filterPublished);
      emit(state.copyWith(
        isLoading: false,
        allBlogs: list,
        filteredBlogs: filtered,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load blogs: ${e.toString().replaceAll('Exception: ', '')}',
      ));
    }
  }

  void searchBlogs(String query) {
    final filtered = _applyFilters(state.allBlogs, query, state.filterPublished);
    emit(state.copyWith(searchQuery: query, filteredBlogs: filtered));
  }

  void filterByPublished(bool? published) {
    final filtered = _applyFilters(state.allBlogs, state.searchQuery, published);
    emit(state.copyWith(filterPublished: published, filteredBlogs: filtered));
  }

  Future<bool> createBlog(BlogModel blog) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));
    try {
      final created = await _blogRepository.createBlog(blog);
      final updatedList = [created, ...state.allBlogs];
      final filtered = _applyFilters(updatedList, state.searchQuery, state.filterPublished);
      emit(state.copyWith(
        isSaving: false,
        allBlogs: updatedList,
        filteredBlogs: filtered,
        successMessage: 'Blog "${created.title}" created successfully.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to create blog: ${e.toString().replaceAll('Exception: ', '')}',
      ));
      return false;
    }
  }

  Future<bool> updateBlog(BlogModel blog) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));
    try {
      final updated = await _blogRepository.updateBlog(blog);
      final updatedList = state.allBlogs.map((b) => b.id == updated.id ? updated : b).toList();
      final filtered = _applyFilters(updatedList, state.searchQuery, state.filterPublished);
      emit(state.copyWith(
        isSaving: false,
        allBlogs: updatedList,
        filteredBlogs: filtered,
        successMessage: 'Blog "${updated.title}" updated successfully.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to update blog: ${e.toString().replaceAll('Exception: ', '')}',
      ));
      return false;
    }
  }

  Future<bool> deleteBlog(String id) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));
    try {
      await _blogRepository.deleteBlog(id);
      final updatedList = state.allBlogs.where((b) => b.id != id).toList();
      final filtered = _applyFilters(updatedList, state.searchQuery, state.filterPublished);
      emit(state.copyWith(
        isSaving: false,
        allBlogs: updatedList,
        filteredBlogs: filtered,
        successMessage: 'Blog deleted successfully.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to delete blog: ${e.toString().replaceAll('Exception: ', '')}',
      ));
      return false;
    }
  }

  Future<void> togglePublished(BlogModel blog) async {
    final updated = blog.copyWith(published: !blog.published);
    await updateBlog(updated);
  }

  List<BlogModel> _applyFilters(
    List<BlogModel> list,
    String query,
    bool? published,
  ) {
    return list.where((item) {
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        final matchTitle = item.title.toLowerCase().contains(q);
        final matchTitleAr = item.titleAr?.toLowerCase().contains(q) ?? false;
        final matchAuthor = item.authorName.toLowerCase().contains(q);
        if (!matchTitle && !matchTitleAr && !matchAuthor) return false;
      }
      if (published != null && item.published != published) return false;
      return true;
    }).toList();
  }
}

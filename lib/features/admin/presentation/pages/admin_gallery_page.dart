import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../data/models/gallery_model.dart';
import '../cubit/admin_gallery_cubit.dart';
import '../widgets/admin_dialogs.dart';

class AdminGalleryPage extends StatefulWidget {
  const AdminGalleryPage({super.key});

  @override
  State<AdminGalleryPage> createState() => _AdminGalleryPageState();
}

class _AdminGalleryPageState extends State<AdminGalleryPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminGalleryCubit>().loadGallery();
  }

  void _openUploadDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _GalleryUploadDialog(
        onUploaded: () {
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(context);

    return BlocConsumer<AdminGalleryCubit, AdminGalleryState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.lightGray,
          body: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Media Gallery Management', style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('Manage Supabase Storage gallery assets and categories', style: AppTextStyles.bodyMD.copyWith(color: AppColors.gray600)),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.navy,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _openUploadDialog(),
                      icon: const Icon(Icons.cloud_upload_rounded, size: 20),
                      label: const Text('Upload Images', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Category Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: AdminGalleryCubit.categories.map((category) {
                      final isSelected = state.selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          selectedColor: AppColors.navy,
                          backgroundColor: AppColors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.white : AppColors.gray700,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (_) => context.read<AdminGalleryCubit>().filterByCategory(category),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // Upload Progress Bar if currently uploading
                if (state.isUploading && state.uploadProgress.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.royalBlue.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.royalBlue),
                            ),
                            SizedBox(width: 10),
                            Text('Uploading to Supabase Storage...', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...state.uploadProgress.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(item.filename, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                    Text(
                                      item.isCompleted
                                          ? 'Done'
                                          : '${(item.progress * 100).toInt()}%',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: item.isCompleted ? AppColors.success : AppColors.royalBlue,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: item.progress,
                                  backgroundColor: AppColors.gray200,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    item.isCompleted ? AppColors.success : AppColors.royalBlue,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],

                // Gallery Grid
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                      : state.filteredItems.isEmpty
                          ? const Center(child: Text('No gallery images in this category.'))
                          : GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isMobile ? 2 : (AppBreakpoints.isTablet(context) ? 3 : 4),
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.85,
                              ),
                              itemCount: state.filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = state.filteredItems[index];
                                return _GalleryGridItem(
                                  item: item,
                                  onToggleFeatured: () => context.read<AdminGalleryCubit>().toggleFeatured(item),
                                  onDelete: () async {
                                    final confirm = await showAdminConfirmDialog(
                                      context: context,
                                      title: 'Delete Image',
                                      message: 'Are you sure you want to delete this gallery photo?',
                                    );
                                    if (confirm == true && context.mounted) {
                                      await context.read<AdminGalleryCubit>().deleteGalleryItem(item.id);
                                    }
                                  },
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GalleryGridItem extends StatelessWidget {
  final GalleryModel item;
  final VoidCallback onToggleFeatured;
  final VoidCallback onDelete;

  const _GalleryGridItem({
    required this.item,
    required this.onToggleFeatured,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.gray200,
                      child: const Icon(Icons.broken_image, color: AppColors.gray400),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.navy.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.category.toUpperCase(),
                      style: const TextStyle(color: AppColors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          iconSize: 18,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            item.featured ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: item.featured ? AppColors.gold : AppColors.gray500,
                          ),
                          onPressed: onToggleFeatured,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          iconSize: 18,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.delete_outline, color: AppColors.error),
                          onPressed: onDelete,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTextStyles.bodySM.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.destination.isNotEmpty)
                  Text(
                    item.destination,
                    style: AppTextStyles.caption.copyWith(color: AppColors.gray500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryUploadDialog extends StatefulWidget {
  final VoidCallback onUploaded;

  const _GalleryUploadDialog({required this.onUploaded});

  @override
  State<_GalleryUploadDialog> createState() => _GalleryUploadDialogState();
}

class _GalleryUploadDialogState extends State<_GalleryUploadDialog> {
  final _titleCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  String _category = 'Hotels';
  bool _featured = false;
  bool _isUploading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Upload Image to Gallery', style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            const Divider(),
            const SizedBox(height: 14),
            TextFormField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: 'Image Title',
                hintText: 'e.g. Red Sea Coral Reefs',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: InputDecoration(
                labelText: 'Category *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: ['Hotels', 'Beaches', 'Tours', 'Cities', 'Landmarks', 'Events']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _category = val ?? 'Hotels'),
            ),
            const SizedBox(height: 14),
            AdminImageField(
              label: 'Image URL / Supabase Asset *',
              controller: _urlCtrl,
            ),
            const SizedBox(height: 14),
            SwitchListTile(
              title: const Text('Featured Photo', style: TextStyle(fontWeight: FontWeight.bold)),
              value: _featured,
              activeColor: AppColors.gold,
              onChanged: (v) => setState(() => _featured = v),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  ),
                  onPressed: _isUploading
                      ? null
                      : () async {
                          final url = _urlCtrl.text.trim();
                          if (url.isEmpty) return;
                          setState(() => _isUploading = true);

                          final item = GalleryModel(
                            id: '',
                            title: _titleCtrl.text.trim().isNotEmpty ? _titleCtrl.text.trim() : 'Gallery Photo',
                            imageUrl: url,
                            category: _category,
                            featured: _featured,
                            createdAt: DateTime.now(),
                          );
                          await context.read<AdminGalleryCubit>().uploadSingleImage(
                                bytes: Uint8List(0),
                                filename: 'photo.jpg',
                                title: item.title,
                                category: item.category,
                                featured: item.featured,
                              );
                          if (mounted) {
                            setState(() => _isUploading = false);
                            widget.onUploaded();
                          }
                        },
                  child: _isUploading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Add to Gallery'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

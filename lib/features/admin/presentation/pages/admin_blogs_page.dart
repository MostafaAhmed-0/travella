import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../data/models/blog_model.dart';
import '../cubit/admin_blogs_cubit.dart';
import '../widgets/admin_dialogs.dart';

class AdminBlogsPage extends StatefulWidget {
  const AdminBlogsPage({super.key});

  @override
  State<AdminBlogsPage> createState() => _AdminBlogsPageState();
}

class _AdminBlogsPageState extends State<AdminBlogsPage> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AdminBlogsCubit>().loadBlogs();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openBlogModal({BlogModel? blog}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _BlogFormDialog(
        blog: blog,
        onSave: (toSave) async {
          final cubit = context.read<AdminBlogsCubit>();
          bool success;
          if (blog == null) {
            success = await cubit.createBlog(toSave);
          } else {
            success = await cubit.updateBlog(toSave);
          }
          if (success && mounted) {
            Navigator.of(dialogContext).pop();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(context);

    return BlocConsumer<AdminBlogsCubit, AdminBlogsState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.successMessage!), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
          );
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
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
                        Text('Editorial & Blog Management', style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('Create travel guides, packing advice, and pilgrim inspirations', style: AppTextStyles.bodyMD.copyWith(color: AppColors.gray600)),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.navy,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _openBlogModal(),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Write New Post', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Search Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (q) => context.read<AdminBlogsCubit>().searchBlogs(q),
                    decoration: InputDecoration(
                      hintText: 'Search articles by title or author...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Blog List
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                      : state.filteredBlogs.isEmpty
                          ? const Center(child: Text('No blog articles found.'))
                          : ListView.builder(
                              itemCount: state.filteredBlogs.length,
                              itemBuilder: (context, index) {
                                final blog = state.filteredBlogs[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.gray200),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          blog.imageUrl,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            width: 80,
                                            height: 80,
                                            color: AppColors.gray200,
                                            child: const Icon(Icons.article),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(blog.title, style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold)),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: blog.published
                                                        ? AppColors.success.withValues(alpha: 0.12)
                                                        : AppColors.gray400.withValues(alpha: 0.2),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    blog.published ? 'PUBLISHED' : 'DRAFT',
                                                    style: TextStyle(
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.bold,
                                                      color: blog.published ? AppColors.success : AppColors.gray600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (blog.titleAr != null && blog.titleAr!.isNotEmpty)
                                              Text(blog.titleAr!, style: const TextStyle(color: AppColors.gray600, fontSize: 12), textDirection: TextDirection.rtl),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Author: ${blog.authorName} • Category: ${blog.category} • ${blog.readTime}',
                                              style: AppTextStyles.caption.copyWith(color: AppColors.gray600),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: blog.published ? 'Unpublish Post' : 'Publish Post',
                                        icon: Icon(
                                          blog.published ? Icons.toggle_on : Icons.toggle_off,
                                          color: blog.published ? AppColors.success : AppColors.gray400,
                                          size: 30,
                                        ),
                                        onPressed: () => context.read<AdminBlogsCubit>().togglePublished(blog),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: AppColors.royalBlue),
                                        onPressed: () => _openBlogModal(blog: blog),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                                        onPressed: () async {
                                          final confirm = await showAdminConfirmDialog(
                                            context: context,
                                            title: 'Delete Article',
                                            message: 'Are you sure you want to delete "${blog.title}"?',
                                          );
                                          if (confirm == true && context.mounted) {
                                            await context.read<AdminBlogsCubit>().deleteBlog(blog.id);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
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

class _BlogFormDialog extends StatefulWidget {
  final BlogModel? blog;
  final Future<void> Function(BlogModel) onSave;

  const _BlogFormDialog({this.blog, required this.onSave});

  @override
  State<_BlogFormDialog> createState() => _BlogFormDialogState();
}

class _BlogFormDialogState extends State<_BlogFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _titleArCtrl;
  late TextEditingController _contentCtrl;
  late TextEditingController _contentArCtrl;
  late TextEditingController _imageCtrl;
  late TextEditingController _authorCtrl;
  late TextEditingController _categoryCtrl;
  late bool _published;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final b = widget.blog;
    _titleCtrl = TextEditingController(text: b?.title ?? '');
    _titleArCtrl = TextEditingController(text: b?.titleAr ?? '');
    _contentCtrl = TextEditingController(text: b?.content ?? '');
    _contentArCtrl = TextEditingController(text: b?.contentAr ?? '');
    _imageCtrl = TextEditingController(text: b?.imageUrl ?? '');
    _authorCtrl = TextEditingController(text: b?.authorName ?? 'Travella Editorial');
    _categoryCtrl = TextEditingController(text: b?.category ?? 'Destinations');
    _published = b?.published ?? true;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _titleArCtrl.dispose();
    _contentCtrl.dispose();
    _contentArCtrl.dispose();
    _imageCtrl.dispose();
    _authorCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.blog == null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 820),
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isNew ? 'Create Blog Article' : 'Edit Blog Article', style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleCtrl,
                        decoration: InputDecoration(
                          labelText: 'Article Title (English) *',
                          hintText: 'e.g. Top 10 Hidden Gems in Egypt',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _titleArCtrl,
                        textDirection: TextDirection.rtl,
                        decoration: InputDecoration(
                          labelText: 'Article Title (Arabic)',
                          hintText: 'مثال: أفضل 10 أماكن ساحرة ومخفية في مصر',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _authorCtrl,
                              decoration: InputDecoration(
                                labelText: 'Author Name',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _categoryCtrl,
                              decoration: InputDecoration(
                                labelText: 'Category',
                                hintText: 'e.g. Travel Tips',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      AdminImageField(
                        label: 'Cover Image URL *',
                        controller: _imageCtrl,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _contentCtrl,
                        maxLines: 6,
                        decoration: InputDecoration(
                          labelText: 'Article Content (English) *',
                          hintText: 'Full markdown or editorial content...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Content is required' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _contentArCtrl,
                        textDirection: TextDirection.rtl,
                        maxLines: 6,
                        decoration: InputDecoration(
                          labelText: 'Article Content (Arabic)',
                          hintText: 'محتوى المقال باللغة العربية...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SwitchListTile(
                        title: const Text('Published to Website', style: TextStyle(fontWeight: FontWeight.bold)),
                        value: _published,
                        activeColor: AppColors.success,
                        onChanged: (v) => setState(() => _published = v),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
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
                    onPressed: _isSaving
                        ? null
                        : () async {
                            if (_formKey.currentState?.validate() == true) {
                              setState(() => _isSaving = true);
                              final b = BlogModel(
                                id: widget.blog?.id ?? '',
                                title: _titleCtrl.text.trim(),
                                titleAr: _titleArCtrl.text.trim().isNotEmpty ? _titleArCtrl.text.trim() : null,
                                content: _contentCtrl.text.trim(),
                                contentAr: _contentArCtrl.text.trim().isNotEmpty ? _contentArCtrl.text.trim() : null,
                                authorName: _authorCtrl.text.trim(),
                                category: _categoryCtrl.text.trim(),
                                imageUrl: _imageCtrl.text.trim().isNotEmpty
                                    ? _imageCtrl.text.trim()
                                    : 'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?auto=format&fit=crop&w=800&q=80',
                                published: _published,
                                createdAt: widget.blog?.createdAt ?? DateTime.now(),
                                updatedAt: DateTime.now(),
                              );
                              await widget.onSave(b);
                              if (mounted) setState(() => _isSaving = false);
                            }
                          },
                    child: Text(isNew ? 'Publish Blog' : 'Save Changes'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

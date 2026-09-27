import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../data/models/testimonial_model.dart';
import '../cubit/admin_testimonials_cubit.dart';
import '../widgets/admin_dialogs.dart';

class AdminTestimonialsPage extends StatefulWidget {
  const AdminTestimonialsPage({super.key});

  @override
  State<AdminTestimonialsPage> createState() => _AdminTestimonialsPageState();
}

class _AdminTestimonialsPageState extends State<AdminTestimonialsPage> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AdminTestimonialsCubit>().loadTestimonials();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openTestimonialModal({TestimonialModel? testimonial}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _TestimonialFormDialog(
        testimonial: testimonial,
        onSave: (toSave) async {
          final cubit = context.read<AdminTestimonialsCubit>();
          bool success;
          if (testimonial == null) {
            success = await cubit.createTestimonial(toSave);
          } else {
            success = await cubit.updateTestimonial(toSave);
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

    return BlocConsumer<AdminTestimonialsCubit, AdminTestimonialsState>(
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
                        Text('Client Testimonials Management', style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('Manage traveler verified reviews and ratings displayed on homepage', style: AppTextStyles.bodyMD.copyWith(color: AppColors.gray600)),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.navy,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _openTestimonialModal(),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Add Testimonial', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    onChanged: (q) => context.read<AdminTestimonialsCubit>().searchTestimonials(q),
                    decoration: InputDecoration(
                      hintText: 'Search reviews by client name or tour...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Testimonials List
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                      : state.filteredTestimonials.isEmpty
                          ? const Center(child: Text('No testimonials found.'))
                          : ListView.builder(
                              itemCount: state.filteredTestimonials.length,
                              itemBuilder: (context, index) {
                                final item = state.filteredTestimonials[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.gray200),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: AppColors.gold.withValues(alpha: 0.2),
                                        backgroundImage: item.imageUrl.isNotEmpty ? NetworkImage(item.imageUrl) : null,
                                        child: item.imageUrl.isEmpty
                                            ? Text(item.name[0], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy))
                                            : null,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(item.name, style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold)),
                                                const SizedBox(width: 10),
                                                Row(
                                                  children: List.generate(
                                                    item.rating.toInt(),
                                                    (i) => const Icon(Icons.star, size: 14, color: AppColors.gold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              '${item.clientRole} • ${item.trip} • ${item.country}',
                                              style: AppTextStyles.caption.copyWith(color: AppColors.gray600),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              '"${item.review}"',
                                              style: AppTextStyles.bodySM.copyWith(fontStyle: FontStyle.italic),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: AppColors.royalBlue),
                                        onPressed: () => _openTestimonialModal(testimonial: item),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                                        onPressed: () async {
                                          final confirm = await showAdminConfirmDialog(
                                            context: context,
                                            title: 'Delete Review',
                                            message: 'Are you sure you want to delete this testimonial from "${item.name}"?',
                                          );
                                          if (confirm == true && context.mounted) {
                                            await context.read<AdminTestimonialsCubit>().deleteTestimonial(item.id);
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

class _TestimonialFormDialog extends StatefulWidget {
  final TestimonialModel? testimonial;
  final Future<void> Function(TestimonialModel) onSave;

  const _TestimonialFormDialog({this.testimonial, required this.onSave});

  @override
  State<_TestimonialFormDialog> createState() => _TestimonialFormDialogState();
}

class _TestimonialFormDialogState extends State<_TestimonialFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _roleCtrl;
  late TextEditingController _tripCtrl;
  late TextEditingController _countryCtrl;
  late TextEditingController _reviewCtrl;
  late TextEditingController _imageCtrl;
  double _rating = 5.0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.testimonial;
    _nameCtrl = TextEditingController(text: t?.name ?? '');
    _roleCtrl = TextEditingController(text: t?.clientRole ?? 'Traveler');
    _tripCtrl = TextEditingController(text: t?.trip ?? '');
    _countryCtrl = TextEditingController(text: t?.country ?? '');
    _reviewCtrl = TextEditingController(text: t?.review ?? '');
    _imageCtrl = TextEditingController(text: t?.imageUrl ?? '');
    _rating = t?.rating ?? 5.0;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roleCtrl.dispose();
    _tripCtrl.dispose();
    _countryCtrl.dispose();
    _reviewCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.testimonial == null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 550),
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isNew ? 'Add Testimonial' : 'Edit Testimonial', style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Client Name *',
                  hintText: 'e.g. Ahmed & Sarah Mansour',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _roleCtrl,
                      decoration: InputDecoration(
                        labelText: 'Role / Subtitle',
                        hintText: 'e.g. Honeymoon Couple',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _tripCtrl,
                      decoration: InputDecoration(
                        labelText: 'Trip Name',
                        hintText: 'e.g. Maldives Luxury Escape',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _countryCtrl,
                      decoration: InputDecoration(
                        labelText: 'Country',
                        hintText: 'e.g. Egypt',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<double>(
                      value: _rating,
                      decoration: InputDecoration(
                        labelText: 'Rating',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: [5.0, 4.5, 4.0, 3.5, 3.0].map((r) => DropdownMenuItem(value: r, child: Text('$r Stars'))).toList(),
                      onChanged: (val) => setState(() => _rating = val ?? 5.0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AdminImageField(
                label: 'Client Avatar Image URL',
                controller: _imageCtrl,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _reviewCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Review Feedback *',
                  hintText: 'Share the traveler’s experience with Travella...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Review text is required' : null,
              ),
              const SizedBox(height: 18),
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
                              final t = TestimonialModel(
                                id: widget.testimonial?.id ?? '',
                                name: _nameCtrl.text.trim(),
                                clientRole: _roleCtrl.text.trim(),
                                trip: _tripCtrl.text.trim(),
                                country: _countryCtrl.text.trim(),
                                rating: _rating,
                                review: _reviewCtrl.text.trim(),
                                imageUrl: _imageCtrl.text.trim().isNotEmpty ? _imageCtrl.text.trim() : '',
                              );
                              await widget.onSave(t);
                              if (mounted) setState(() => _isSaving = false);
                            }
                          },
                    child: Text(isNew ? 'Save Testimonial' : 'Update Review'),
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

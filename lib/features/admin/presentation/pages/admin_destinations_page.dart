import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../data/models/destination_model.dart';
import '../cubit/admin_destinations_cubit.dart';
import '../widgets/admin_dialogs.dart';

class AdminDestinationsPage extends StatefulWidget {
  const AdminDestinationsPage({super.key});

  @override
  State<AdminDestinationsPage> createState() => _AdminDestinationsPageState();
}

class _AdminDestinationsPageState extends State<AdminDestinationsPage> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AdminDestinationsCubit>().loadDestinations();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openDestinationModal({DestinationModel? destination}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _DestinationFormDialog(
        destination: destination,
        onSave: (toSave) async {
          final cubit = context.read<AdminDestinationsCubit>();
          bool success;
          if (destination == null) {
            success = await cubit.createDestination(toSave);
          } else {
            success = await cubit.updateDestination(toSave);
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

    return BlocConsumer<AdminDestinationsCubit, AdminDestinationsState>(
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
                        Text('Destination Management', style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('Add and manage worldwide travel destinations', style: AppTextStyles.bodyMD.copyWith(color: AppColors.gray600)),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.navy,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _openDestinationModal(),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Add Destination', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Search & Filter
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (q) => context.read<AdminDestinationsCubit>().searchDestinations(q),
                          decoration: InputDecoration(
                            hintText: 'Search destinations by name or country...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      IconButton(
                        tooltip: state.filterFeatured == null
                            ? 'All destinations'
                            : (state.filterFeatured! ? 'Featured only' : 'Non-featured only'),
                        icon: Icon(
                          state.filterFeatured == null ? Icons.star_border : Icons.star,
                          color: state.filterFeatured != null ? AppColors.gold : AppColors.gray600,
                        ),
                        onPressed: () {
                          if (state.filterFeatured == null) {
                            context.read<AdminDestinationsCubit>().filterByFeatured(true);
                          } else if (state.filterFeatured == true) {
                            context.read<AdminDestinationsCubit>().filterByFeatured(false);
                          } else {
                            context.read<AdminDestinationsCubit>().filterByFeatured(null);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Destination list
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                      : state.filteredDestinations.isEmpty
                          ? const Center(child: Text('No destinations found.'))
                          : ListView.builder(
                              itemCount: state.filteredDestinations.length,
                              itemBuilder: (context, index) {
                                final dest = state.filteredDestinations[index];
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
                                          dest.imageUrl,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            width: 80,
                                            height: 80,
                                            color: AppColors.gray200,
                                            child: const Icon(Icons.image),
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
                                                Text(dest.name, style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold)),
                                                if (dest.featured) ...[
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.gold.withValues(alpha: 0.2),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: const Text('FEATURED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.goldDark)),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            if (dest.nameAr != null && dest.nameAr!.isNotEmpty)
                                              Text(dest.nameAr!, style: const TextStyle(color: AppColors.gray600, fontSize: 12), textDirection: TextDirection.rtl),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${dest.country} • ${dest.description}',
                                              style: AppTextStyles.caption.copyWith(color: AppColors.gray600),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: dest.featured ? 'Unmark Featured' : 'Mark Featured',
                                        icon: Icon(dest.featured ? Icons.star_rounded : Icons.star_outline_rounded, color: dest.featured ? AppColors.gold : AppColors.gray500),
                                        onPressed: () => context.read<AdminDestinationsCubit>().toggleFeatured(dest),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: AppColors.royalBlue),
                                        onPressed: () => _openDestinationModal(destination: dest),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                                        onPressed: () async {
                                          final confirm = await showAdminConfirmDialog(
                                            context: context,
                                            title: 'Delete Destination',
                                            message: 'Are you sure you want to delete "${dest.name}"?',
                                          );
                                          if (confirm == true && context.mounted) {
                                            await context.read<AdminDestinationsCubit>().deleteDestination(dest.id);
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

class _DestinationFormDialog extends StatefulWidget {
  final DestinationModel? destination;
  final Future<void> Function(DestinationModel) onSave;

  const _DestinationFormDialog({this.destination, required this.onSave});

  @override
  State<_DestinationFormDialog> createState() => _DestinationFormDialogState();
}

class _DestinationFormDialogState extends State<_DestinationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _nameArCtrl;
  late TextEditingController _countryCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _descArCtrl;
  late TextEditingController _imageCtrl;
  late bool _featured;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.destination;
    _nameCtrl = TextEditingController(text: d?.name ?? '');
    _nameArCtrl = TextEditingController(text: d?.nameAr ?? '');
    _countryCtrl = TextEditingController(text: d?.country ?? '');
    _descCtrl = TextEditingController(text: d?.description ?? '');
    _descArCtrl = TextEditingController(text: d?.descriptionAr ?? '');
    _imageCtrl = TextEditingController(text: d?.imageUrl ?? '');
    _featured = d?.featured ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nameArCtrl.dispose();
    _countryCtrl.dispose();
    _descCtrl.dispose();
    _descArCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.destination == null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 750),
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isNew ? 'Add Destination' : 'Edit Destination', style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold)),
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
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Destination Name (English) *',
                          hintText: 'e.g. Hurghada',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _nameArCtrl,
                        textDirection: TextDirection.rtl,
                        decoration: InputDecoration(
                          labelText: 'Destination Name (Arabic)',
                          hintText: 'مثال: الغردقة',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _countryCtrl,
                        decoration: InputDecoration(
                          labelText: 'Country *',
                          hintText: 'e.g. Egypt',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Country is required' : null,
                      ),
                      const SizedBox(height: 14),
                      AdminImageField(
                        label: 'Destination Image URL *',
                        controller: _imageCtrl,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _descCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description (English) *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Description is required' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _descArCtrl,
                        textDirection: TextDirection.rtl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description (Arabic)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SwitchListTile(
                        title: const Text('Mark as Featured Destination', style: TextStyle(fontWeight: FontWeight.bold)),
                        value: _featured,
                        activeColor: AppColors.gold,
                        onChanged: (v) => setState(() => _featured = v),
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
                              final d = DestinationModel(
                                id: widget.destination?.id ?? '',
                                name: _nameCtrl.text.trim(),
                                nameAr: _nameArCtrl.text.trim().isNotEmpty ? _nameArCtrl.text.trim() : null,
                                country: _countryCtrl.text.trim(),
                                description: _descCtrl.text.trim(),
                                descriptionAr: _descArCtrl.text.trim().isNotEmpty ? _descArCtrl.text.trim() : null,
                                imageUrl: _imageCtrl.text.trim().isNotEmpty
                                    ? _imageCtrl.text.trim()
                                    : 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&w=1000&q=80',
                                featured: _featured,
                                createdAt: widget.destination?.createdAt ?? DateTime.now(),
                                updatedAt: DateTime.now(),
                              );
                              await widget.onSave(d);
                              if (mounted) setState(() => _isSaving = false);
                            }
                          },
                    child: Text(isNew ? 'Create Destination' : 'Save Changes'),
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

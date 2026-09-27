import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../data/models/partner_model.dart';
import '../cubit/admin_partners_cubit.dart';
import '../widgets/admin_dialogs.dart';

class AdminPartnersPage extends StatefulWidget {
  const AdminPartnersPage({super.key});

  @override
  State<AdminPartnersPage> createState() => _AdminPartnersPageState();
}

class _AdminPartnersPageState extends State<AdminPartnersPage> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AdminPartnersCubit>().loadPartners();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openPartnerModal({PartnerModel? partner}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _PartnerFormDialog(
        partner: partner,
        onSave: (toSave) async {
          final cubit = context.read<AdminPartnersCubit>();
          bool success;
          if (partner == null) {
            success = await cubit.createPartner(toSave);
          } else {
            success = await cubit.updatePartner(toSave);
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

    return BlocConsumer<AdminPartnersCubit, AdminPartnersState>(
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
                        Text('Partners & Affiliates', style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('Manage airline, hotel chain, and corporate travel partner logos and websites', style: AppTextStyles.bodyMD.copyWith(color: AppColors.gray600)),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.navy,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _openPartnerModal(),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Add Partner', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    onChanged: (q) => context.read<AdminPartnersCubit>().searchPartners(q),
                    decoration: InputDecoration(
                      hintText: 'Search partners by name or category...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Partners List
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                      : state.filteredPartners.isEmpty
                          ? const Center(child: Text('No partners found.'))
                          : ListView.builder(
                              itemCount: state.filteredPartners.length,
                              itemBuilder: (context, index) {
                                final partner = state.filteredPartners[index];
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
                                      Container(
                                        width: 60,
                                        height: 60,
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.lightGray,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Image.network(
                                          partner.logoUrl,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) => const Icon(Icons.business, color: AppColors.gray500),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(partner.name, style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold)),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.navy.withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(partner.category, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.navy)),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              partner.website ?? 'No website URL configured',
                                              style: AppTextStyles.caption.copyWith(color: AppColors.royalBlue),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: partner.active ? 'Deactivate Partner' : 'Activate Partner',
                                        icon: Icon(partner.active ? Icons.toggle_on : Icons.toggle_off, color: partner.active ? AppColors.success : AppColors.gray400, size: 30),
                                        onPressed: () => context.read<AdminPartnersCubit>().toggleActive(partner),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: AppColors.royalBlue),
                                        onPressed: () => _openPartnerModal(partner: partner),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                                        onPressed: () async {
                                          final confirm = await showAdminConfirmDialog(
                                            context: context,
                                            title: 'Delete Partner',
                                            message: 'Are you sure you want to delete "${partner.name}"?',
                                          );
                                          if (confirm == true && context.mounted) {
                                            await context.read<AdminPartnersCubit>().deletePartner(partner.id);
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

class _PartnerFormDialog extends StatefulWidget {
  final PartnerModel? partner;
  final Future<void> Function(PartnerModel) onSave;

  const _PartnerFormDialog({this.partner, required this.onSave});

  @override
  State<_PartnerFormDialog> createState() => _PartnerFormDialogState();
}

class _PartnerFormDialogState extends State<_PartnerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _categoryCtrl;
  late TextEditingController _logoCtrl;
  late TextEditingController _websiteCtrl;
  late bool _active;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.partner;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _categoryCtrl = TextEditingController(text: p?.category ?? 'Airlines');
    _logoCtrl = TextEditingController(text: p?.logoUrl ?? '');
    _websiteCtrl = TextEditingController(text: p?.website ?? '');
    _active = p?.active ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _logoCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.partner == null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
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
                  Text(isNew ? 'Add Partner' : 'Edit Partner', style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Partner Name *',
                  hintText: 'e.g. Emirates Airlines',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoryCtrl,
                decoration: InputDecoration(
                  labelText: 'Category (Airlines, Hotels, Transport, etc.)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              AdminImageField(
                label: 'Partner Logo URL *',
                controller: _logoCtrl,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _websiteCtrl,
                decoration: InputDecoration(
                  labelText: 'Website URL',
                  hintText: 'https://www.emirates.com',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Active Partner', style: TextStyle(fontWeight: FontWeight.bold)),
                value: _active,
                activeColor: AppColors.success,
                onChanged: (v) => setState(() => _active = v),
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
                              final p = PartnerModel(
                                id: widget.partner?.id ?? '',
                                name: _nameCtrl.text.trim(),
                                category: _categoryCtrl.text.trim(),
                                logoUrl: _logoCtrl.text.trim().isNotEmpty
                                    ? _logoCtrl.text.trim()
                                    : 'https://upload.wikimedia.org/wikipedia/commons/d/d0/Emirates_logo.svg',
                                website: _websiteCtrl.text.trim(),
                                active: _active,
                              );
                              await widget.onSave(p);
                              if (mounted) setState(() => _isSaving = false);
                            }
                          },
                    child: Text(isNew ? 'Save Partner' : 'Update Partner'),
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

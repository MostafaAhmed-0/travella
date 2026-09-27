import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../data/models/visa_model.dart';
import '../cubit/admin_visa_cubit.dart';
import '../widgets/admin_dialogs.dart';

class AdminVisaPage extends StatefulWidget {
  const AdminVisaPage({super.key});

  @override
  State<AdminVisaPage> createState() => _AdminVisaPageState();
}

class _AdminVisaPageState extends State<AdminVisaPage> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AdminVisaCubit>().loadVisaServices();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openVisaModal({VisaServiceModel? service}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _VisaFormDialog(
        service: service,
        onSave: (toSave) async {
          final cubit = context.read<AdminVisaCubit>();
          bool success;
          if (service == null) {
            success = await cubit.createVisaService(toSave);
          } else {
            success = await cubit.updateVisaService(toSave);
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

    return BlocConsumer<AdminVisaCubit, AdminVisaState>(
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
                        Text('Visa Services Management', style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('Manage visa countries, application requirements, processing speeds, and fees', style: AppTextStyles.bodyMD.copyWith(color: AppColors.gray600)),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.navy,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _openVisaModal(),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Add Visa Service', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    onChanged: (q) => context.read<AdminVisaCubit>().searchVisa(q),
                    decoration: InputDecoration(
                      hintText: 'Search visa services by country or visa type...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Visa List
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                      : state.filteredServices.isEmpty
                          ? const Center(child: Text('No visa services found.'))
                          : ListView.builder(
                              itemCount: state.filteredServices.length,
                              itemBuilder: (context, index) {
                                final service = state.filteredServices[index];
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
                                        width: 50,
                                        height: 50,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: AppColors.royalBlue.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          service.flagEmoji.isNotEmpty ? service.flagEmoji : '🌐',
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(service.country, style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold)),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.navy.withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(service.visaType, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.navy)),
                                                ),
                                              ],
                                            ),
                                            if (service.countryAr != null && service.countryAr!.isNotEmpty)
                                              Text(service.countryAr!, style: const TextStyle(color: AppColors.gray600, fontSize: 12), textDirection: TextDirection.rtl),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Processing: ${service.processingTime} • ${service.requirements.length} Requirements listed',
                                              style: AppTextStyles.caption.copyWith(color: AppColors.gray600),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Price Pill
                                      InkWell(
                                        onTap: () async {
                                          final newPrice = await showAdminPriceEditDialog(
                                            context: context,
                                            itemName: '${service.country} Visa',
                                            currentPrice: service.price,
                                          );
                                          if (newPrice != null && context.mounted) {
                                            await context.read<AdminVisaCubit>().updatePrice(service.id, newPrice);
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: AppColors.gold.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                '\$${service.price.toInt()}',
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.navyDark),
                                              ),
                                              const Text('Edit Fee', style: TextStyle(fontSize: 10, color: AppColors.gray600)),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      IconButton(
                                        tooltip: service.active ? 'Deactivate Visa' : 'Activate Visa',
                                        icon: Icon(service.active ? Icons.toggle_on : Icons.toggle_off, color: service.active ? AppColors.success : AppColors.gray400, size: 30),
                                        onPressed: () => context.read<AdminVisaCubit>().toggleActive(service),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: AppColors.royalBlue),
                                        onPressed: () => _openVisaModal(service: service),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                                        onPressed: () async {
                                          final confirm = await showAdminConfirmDialog(
                                            context: context,
                                            title: 'Delete Visa Service',
                                            message: 'Are you sure you want to delete "${service.country}" visa?',
                                          );
                                          if (confirm == true && context.mounted) {
                                            await context.read<AdminVisaCubit>().deleteVisaService(service.id);
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

class _VisaFormDialog extends StatefulWidget {
  final VisaServiceModel? service;
  final Future<void> Function(VisaServiceModel) onSave;

  const _VisaFormDialog({this.service, required this.onSave});

  @override
  State<_VisaFormDialog> createState() => _VisaFormDialogState();
}

class _VisaFormDialogState extends State<_VisaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _countryCtrl;
  late TextEditingController _countryArCtrl;
  late TextEditingController _typeCtrl;
  late TextEditingController _processingCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _descArCtrl;
  late TextEditingController _flagCtrl;
  late bool _active;
  late List<String> _requirements;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.service;
    _countryCtrl = TextEditingController(text: s?.country ?? '');
    _countryArCtrl = TextEditingController(text: s?.countryAr ?? '');
    _typeCtrl = TextEditingController(text: s?.visaType ?? 'Tourist Visa');
    _processingCtrl = TextEditingController(text: s?.processingTime ?? '3-5 Business Days');
    _priceCtrl = TextEditingController(text: s != null ? s.price.toStringAsFixed(0) : '150');
    _descCtrl = TextEditingController(text: s?.description ?? '');
    _descArCtrl = TextEditingController(text: s?.descriptionAr ?? '');
    _flagCtrl = TextEditingController(text: s?.flagEmoji ?? '✈️');
    _active = s?.active ?? true;
    _requirements = List<String>.from(
      s?.requirements.map((r) => r.requirement) ?? [
        'Valid Passport (minimum 6 months validity)',
        '2 Recent Passport-Size Photographs',
        'Bank Statement (last 3 months)',
        'Confirmed Flight & Hotel Reservation',
      ],
    );
  }

  @override
  void dispose() {
    _countryCtrl.dispose();
    _countryArCtrl.dispose();
    _typeCtrl.dispose();
    _processingCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _descArCtrl.dispose();
    _flagCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.service == null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 800),
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isNew ? 'Add Visa Service' : 'Edit Visa Service', style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _countryCtrl,
                              decoration: InputDecoration(
                                labelText: 'Country Name (English) *',
                                hintText: 'e.g. United Kingdom',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Country is required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: _flagCtrl,
                              decoration: InputDecoration(
                                labelText: 'Flag / Icon',
                                hintText: '🇬🇧',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _countryArCtrl,
                        textDirection: TextDirection.rtl,
                        decoration: InputDecoration(
                          labelText: 'Country Name (Arabic)',
                          hintText: 'مثال: المملكة المتحدة',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _typeCtrl,
                              decoration: InputDecoration(
                                labelText: 'Visa Type *',
                                hintText: 'e.g. Tourist / Business',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Visa type is required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _processingCtrl,
                              decoration: InputDecoration(
                                labelText: 'Processing Time *',
                                hintText: 'e.g. 5-7 Business Days',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Processing time required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Service Price (USD) *',
                          hintText: '180',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (v) => v == null || double.tryParse(v.trim()) == null ? 'Enter valid price' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _descCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Description (English)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _descArCtrl,
                        textDirection: TextDirection.rtl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Description (Arabic)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Dynamic Visa Requirements Editor
                      AdminBulletListEditor(
                        label: 'Visa Application Requirements *',
                        hint: 'Add requirement (e.g. Bank Statement)',
                        items: _requirements,
                        onChanged: (items) => _requirements = items,
                      ),
                      const SizedBox(height: 14),
                      SwitchListTile(
                        title: const Text('Active Service', style: TextStyle(fontWeight: FontWeight.bold)),
                        value: _active,
                        activeColor: AppColors.success,
                        onChanged: (v) => setState(() => _active = v),
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
                              final s = VisaServiceModel(
                                id: widget.service?.id ?? '',
                                country: _countryCtrl.text.trim(),
                                countryAr: _countryArCtrl.text.trim().isNotEmpty ? _countryArCtrl.text.trim() : null,
                                visaType: _typeCtrl.text.trim(),
                                processingTime: _processingCtrl.text.trim(),
                                price: double.parse(_priceCtrl.text.trim()),
                                description: _descCtrl.text.trim(),
                                descriptionAr: _descArCtrl.text.trim().isNotEmpty ? _descArCtrl.text.trim() : null,
                                flagEmoji: _flagCtrl.text.trim(),
                                requirements: _requirements.asMap().entries.map(
                                  (e) => VisaRequirementModel(
                                    id: '',
                                    visaServiceId: widget.service?.id ?? '',
                                    requirement: e.value,
                                  ),
                                ).toList(),
                                active: _active,
                                createdAt: widget.service?.createdAt ?? DateTime.now(),
                                updatedAt: DateTime.now(),
                              );
                              await widget.onSave(s);
                              if (mounted) setState(() => _isSaving = false);
                            }
                          },
                    child: Text(isNew ? 'Create Visa Service' : 'Save Changes'),
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

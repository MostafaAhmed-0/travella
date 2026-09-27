import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../data/models/hotel_model.dart';
import '../cubit/admin_hotels_cubit.dart';
import '../widgets/admin_dialogs.dart';

class AdminHotelsPage extends StatefulWidget {
  const AdminHotelsPage({super.key});

  @override
  State<AdminHotelsPage> createState() => _AdminHotelsPageState();
}

class _AdminHotelsPageState extends State<AdminHotelsPage> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AdminHotelsCubit>().loadHotels();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openHotelModal({HotelModel? hotel}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _HotelFormDialog(
        hotel: hotel,
        onSave: (toSave) async {
          final cubit = context.read<AdminHotelsCubit>();
          bool success;
          if (hotel == null) {
            success = await cubit.createHotel(toSave);
          } else {
            success = await cubit.updateHotel(toSave);
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

    return BlocConsumer<AdminHotelsCubit, AdminHotelsState>(
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
                        Text('Hotel & Resort Management', style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('Manage luxury hotel accommodations, room rates, and amenities', style: AppTextStyles.bodyMD.copyWith(color: AppColors.gray600)),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.navy,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _openHotelModal(),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Add New Hotel', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Search & Filter Bar
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
                          onChanged: (q) => context.read<AdminHotelsCubit>().searchHotels(q),
                          decoration: InputDecoration(
                            hintText: 'Search hotels by name or location...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      IconButton(
                        tooltip: state.filterActive == null
                            ? 'All active states'
                            : (state.filterActive! ? 'Active only' : 'Inactive only'),
                        icon: Icon(
                          state.filterActive == null
                              ? Icons.filter_alt_outlined
                              : (state.filterActive! ? Icons.visibility : Icons.visibility_off),
                          color: state.filterActive != null ? AppColors.royalBlue : AppColors.gray600,
                        ),
                        onPressed: () {
                          if (state.filterActive == null) {
                            context.read<AdminHotelsCubit>().filterByActive(true);
                          } else if (state.filterActive == true) {
                            context.read<AdminHotelsCubit>().filterByActive(false);
                          } else {
                            context.read<AdminHotelsCubit>().filterByActive(null);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Hotel List
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                      : state.filteredHotels.isEmpty
                          ? const Center(child: Text('No hotels found.'))
                          : ListView.builder(
                              itemCount: state.filteredHotels.length,
                              itemBuilder: (context, index) {
                                final hotel = state.filteredHotels[index];
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
                                          hotel.imageUrl,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            width: 80,
                                            height: 80,
                                            color: AppColors.gray200,
                                            child: const Icon(Icons.hotel),
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
                                                Text(hotel.name, style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold)),
                                                const SizedBox(width: 8),
                                                Row(
                                                  children: List.generate(
                                                    hotel.stars,
                                                    (i) => const Icon(Icons.star, size: 14, color: AppColors.gold),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                if (hotel.featured)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.gold.withValues(alpha: 0.2),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: const Text('FEATURED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.goldDark)),
                                                  ),
                                              ],
                                            ),
                                            if (hotel.nameAr != null && hotel.nameAr!.isNotEmpty)
                                              Text(hotel.nameAr!, style: const TextStyle(color: AppColors.gray600, fontSize: 12), textDirection: TextDirection.rtl),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${hotel.location} • Rating ${hotel.rating}/5.0',
                                              style: AppTextStyles.caption.copyWith(color: AppColors.gray600),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Price click to edit
                                      InkWell(
                                        onTap: () async {
                                          final newPrice = await showAdminPriceEditDialog(
                                            context: context,
                                            itemName: hotel.name,
                                            currentPrice: hotel.price,
                                            currency: hotel.currency,
                                          );
                                          if (newPrice != null && context.mounted) {
                                            await context.read<AdminHotelsCubit>().updatePrice(hotel.id, newPrice, currency: hotel.currency);
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
                                                '${hotel.currency} ${hotel.price.toInt()}/nt',
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.navyDark),
                                              ),
                                              const Text('Edit Price', style: TextStyle(fontSize: 10, color: AppColors.gray600)),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      IconButton(
                                        tooltip: hotel.active ? 'Deactivate Hotel' : 'Activate Hotel',
                                        icon: Icon(hotel.active ? Icons.toggle_on : Icons.toggle_off, color: hotel.active ? AppColors.success : AppColors.gray400, size: 30),
                                        onPressed: () => context.read<AdminHotelsCubit>().toggleActive(hotel),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: AppColors.royalBlue),
                                        onPressed: () => _openHotelModal(hotel: hotel),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                                        onPressed: () async {
                                          final confirm = await showAdminConfirmDialog(
                                            context: context,
                                            title: 'Delete Hotel',
                                            message: 'Are you sure you want to delete "${hotel.name}"?',
                                          );
                                          if (confirm == true && context.mounted) {
                                            await context.read<AdminHotelsCubit>().deleteHotel(hotel.id);
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

class _HotelFormDialog extends StatefulWidget {
  final HotelModel? hotel;
  final Future<void> Function(HotelModel) onSave;

  const _HotelFormDialog({this.hotel, required this.onSave});

  @override
  State<_HotelFormDialog> createState() => _HotelFormDialogState();
}

class _HotelFormDialogState extends State<_HotelFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _nameArCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _currencyCtrl;
  late TextEditingController _ratingCtrl;
  late TextEditingController _imageCtrl;
  late TextEditingController _descCtrl;
  late int _stars;
  late bool _featured;
  late bool _active;
  late List<String> _amenities;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final h = widget.hotel;
    _nameCtrl = TextEditingController(text: h?.name ?? '');
    _nameArCtrl = TextEditingController(text: h?.nameAr ?? '');
    _locationCtrl = TextEditingController(text: h?.location ?? '');
    _priceCtrl = TextEditingController(text: h != null ? h.price.toStringAsFixed(0) : '250');
    _currencyCtrl = TextEditingController(text: h?.currency ?? 'USD');
    _ratingCtrl = TextEditingController(text: h != null ? h.rating.toString() : '4.9');
    _imageCtrl = TextEditingController(text: h?.imageUrl ?? '');
    _descCtrl = TextEditingController(text: h?.description ?? '');
    _stars = h?.stars ?? 5;
    _featured = h?.featured ?? false;
    _active = h?.active ?? true;
    _amenities = List.from(h?.amenities ?? ['Private Beach', 'Luxury Spa', 'Free High-Speed Wi-Fi', 'Swimming Pools']);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nameArCtrl.dispose();
    _locationCtrl.dispose();
    _priceCtrl.dispose();
    _currencyCtrl.dispose();
    _ratingCtrl.dispose();
    _imageCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.hotel == null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 800),
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isNew ? 'Add Luxury Hotel' : 'Edit Hotel', style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold)),
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
                          labelText: 'Hotel Name (English) *',
                          hintText: 'e.g. Rixos Premium Seagate',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _nameArCtrl,
                        textDirection: TextDirection.rtl,
                        decoration: InputDecoration(
                          labelText: 'Hotel Name (Arabic)',
                          hintText: 'مثال: فندق ريكسوس بريميوم سيجيت',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _locationCtrl,
                        decoration: InputDecoration(
                          labelText: 'Location / Address *',
                          hintText: 'e.g. Nabq Bay, Sharm El Sheikh, Egypt',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Location is required' : null,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _priceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Price per night *',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (v) => v == null || double.tryParse(v.trim()) == null ? 'Enter valid price' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _stars,
                              decoration: InputDecoration(
                                labelText: 'Star Rating',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              items: [3, 4, 5].map((s) => DropdownMenuItem(value: s, child: Text('$s Stars'))).toList(),
                              onChanged: (val) => setState(() => _stars = val ?? 5),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _ratingCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Score (1-5)',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      AdminImageField(
                        label: 'Hotel Image URL *',
                        controller: _imageCtrl,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _descCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AdminBulletListEditor(
                        label: 'Hotel Amenities',
                        hint: 'Add amenity (e.g. Free Airport Transfer)',
                        items: _amenities,
                        onChanged: (items) => _amenities = items,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: SwitchListTile(
                              title: const Text('Featured Resort', style: TextStyle(fontWeight: FontWeight.bold)),
                              value: _featured,
                              activeColor: AppColors.gold,
                              onChanged: (v) => setState(() => _featured = v),
                            ),
                          ),
                          Expanded(
                            child: SwitchListTile(
                              title: const Text('Active', style: TextStyle(fontWeight: FontWeight.bold)),
                              value: _active,
                              activeColor: AppColors.success,
                              onChanged: (v) => setState(() => _active = v),
                            ),
                          ),
                        ],
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
                              final h = HotelModel(
                                id: widget.hotel?.id ?? '',
                                name: _nameCtrl.text.trim(),
                                nameAr: _nameArCtrl.text.trim().isNotEmpty ? _nameArCtrl.text.trim() : null,
                                location: _locationCtrl.text.trim(),
                                price: double.parse(_priceCtrl.text.trim()),
                                currency: _currencyCtrl.text.trim(),
                                rating: double.tryParse(_ratingCtrl.text.trim()) ?? 4.9,
                                stars: _stars,
                                imageUrl: _imageCtrl.text.trim().isNotEmpty
                                    ? _imageCtrl.text.trim()
                                    : 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=1000&q=80',
                                description: _descCtrl.text.trim(),
                                amenities: _amenities,
                                featured: _featured,
                                active: _active,
                                createdAt: widget.hotel?.createdAt ?? DateTime.now(),
                                updatedAt: DateTime.now(),
                              );
                              await widget.onSave(h);
                              if (mounted) setState(() => _isSaving = false);
                            }
                          },
                    child: Text(isNew ? 'Create Hotel' : 'Save Changes'),
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

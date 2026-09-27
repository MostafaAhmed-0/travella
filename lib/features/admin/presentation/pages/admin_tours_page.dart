import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../data/models/tour_model.dart';
import '../cubit/admin_tours_cubit.dart';
import '../widgets/admin_dialogs.dart';

class AdminToursPage extends StatefulWidget {
  const AdminToursPage({super.key});

  @override
  State<AdminToursPage> createState() => _AdminToursPageState();
}

class _AdminToursPageState extends State<AdminToursPage> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AdminToursCubit>().loadTours();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openTourFormModal({TourModel? tour}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _TourFormDialog(
        tour: tour,
        onSave: (tourToSave) async {
          final cubit = context.read<AdminToursCubit>();
          bool success;
          if (tour == null) {
            success = await cubit.createTour(tourToSave);
          } else {
            success = await cubit.updateTour(tourToSave);
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

    return BlocConsumer<AdminToursCubit, AdminToursState>(
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
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tour Management', style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(
                          'Create, edit, price, and publish travel packages',
                          style: AppTextStyles.bodyMD.copyWith(color: AppColors.gray600),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.navy,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _openTourFormModal(),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Add New Tour', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Filters & Search Bar
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
                          onChanged: (q) => context.read<AdminToursCubit>().searchTours(q),
                          decoration: InputDecoration(
                            hintText: 'Search by title, destination, or country...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchCtrl.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      context.read<AdminToursCubit>().searchTours('');
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Tour Type filter
                      DropdownButton<String>(
                        value: state.selectedType ?? 'all',
                        underline: const SizedBox.shrink(),
                        borderRadius: BorderRadius.circular(10),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All Types')),
                          DropdownMenuItem(value: 'domestic', child: Text('Domestic')),
                          DropdownMenuItem(value: 'international', child: Text('International')),
                          DropdownMenuItem(value: 'hajj', child: Text('Hajj')),
                          DropdownMenuItem(value: 'umrah', child: Text('Umrah')),
                        ],
                        onChanged: (val) => context.read<AdminToursCubit>().filterByType(val == 'all' ? null : val),
                      ),
                      const SizedBox(width: 10),
                      // Active filter
                      IconButton(
                        tooltip: state.filterActive == null
                            ? 'Showing all status'
                            : (state.filterActive! ? 'Showing active only' : 'Showing inactive only'),
                        icon: Icon(
                          state.filterActive == null
                              ? Icons.filter_alt_outlined
                              : (state.filterActive! ? Icons.visibility : Icons.visibility_off),
                          color: state.filterActive != null ? AppColors.royalBlue : AppColors.gray600,
                        ),
                        onPressed: () {
                          if (state.filterActive == null) {
                            context.read<AdminToursCubit>().filterByActive(true);
                          } else if (state.filterActive == true) {
                            context.read<AdminToursCubit>().filterByActive(false);
                          } else {
                            context.read<AdminToursCubit>().filterByActive(null);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Tours Content Table/Cards
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                      : state.filteredTours.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.travel_explore_rounded, size: 56, color: AppColors.gray400),
                                  const SizedBox(height: 12),
                                  Text('No tours found', style: AppTextStyles.h5),
                                  const SizedBox(height: 6),
                                  const Text('Try adjusting your search filter or add a new tour package.', style: TextStyle(color: AppColors.gray600)),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () => _openTourFormModal(),
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Tour'),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: state.filteredTours.length,
                              itemBuilder: (context, index) {
                                final tour = state.filteredTours[index];
                                return _TourAdminRowCard(
                                  tour: tour,
                                  onEdit: () => _openTourFormModal(tour: tour),
                                  onToggleActive: () => context.read<AdminToursCubit>().toggleActive(tour),
                                  onToggleFeatured: () => context.read<AdminToursCubit>().toggleFeatured(tour),
                                  onEditPrice: () async {
                                    final newPrice = await showAdminPriceEditDialog(
                                      context: context,
                                      itemName: tour.title,
                                      currentPrice: tour.price,
                                      currency: tour.currency,
                                    );
                                    if (newPrice != null && context.mounted) {
                                      await context.read<AdminToursCubit>().updatePrice(tour.id, newPrice, currency: tour.currency);
                                    }
                                  },
                                  onDelete: () async {
                                    final confirm = await showAdminConfirmDialog(
                                      context: context,
                                      title: 'Delete Tour',
                                      message: 'Are you sure you want to permanently delete "${tour.title}"? This cannot be undone.',
                                      confirmLabel: 'Delete Tour',
                                    );
                                    if (confirm == true && context.mounted) {
                                      await context.read<AdminToursCubit>().deleteTour(tour.id);
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

class _TourAdminRowCard extends StatelessWidget {
  final TourModel tour;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onToggleFeatured;
  final VoidCallback onEditPrice;
  final VoidCallback onDelete;

  const _TourAdminRowCard({
    required this.tour,
    required this.onEdit,
    required this.onToggleActive,
    required this.onToggleFeatured,
    required this.onEditPrice,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              tour.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
                color: AppColors.gray200,
                child: const Icon(Icons.broken_image, color: AppColors.gray500),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Main Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Type badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.navy.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tour.type.toDbString().toUpperCase(),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.navy),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (tour.featured)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 12, color: AppColors.goldDark),
                            SizedBox(width: 4),
                            Text('FEATURED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.goldDark)),
                          ],
                        ),
                      ),
                    const SizedBox(width: 8),
                    // Active Status
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: tour.active
                            ? AppColors.success.withValues(alpha: 0.12)
                            : AppColors.gray400.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tour.active ? 'ACTIVE' : 'INACTIVE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: tour.active ? AppColors.success : AppColors.gray600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  tour.title,
                  style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (tour.titleAr != null && tour.titleAr!.isNotEmpty)
                  Text(
                    tour.titleAr!,
                    style: const TextStyle(color: AppColors.gray600, fontSize: 12),
                    textDirection: TextDirection.rtl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 14, color: AppColors.gray500),
                    const SizedBox(width: 4),
                    Text(
                      tour.destination.isNotEmpty ? tour.destination : (tour.country.isNotEmpty ? tour.country : 'Global'),
                      style: AppTextStyles.caption.copyWith(color: AppColors.gray600),
                    ),
                    const SizedBox(width: 14),
                    const Icon(Icons.access_time_rounded, size: 14, color: AppColors.gray500),
                    const SizedBox(width: 4),
                    Text(tour.duration, style: AppTextStyles.caption.copyWith(color: AppColors.gray600)),
                  ],
                ),
              ],
            ),
          ),

          // Price Pill with quick edit
          InkWell(
            onTap: onEditPrice,
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
                    '${tour.currency} ${tour.price.toInt()}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.navyDark),
                  ),
                  const Text('Click to Edit', style: TextStyle(fontSize: 10, color: AppColors.gray600)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Actions
          Row(
            children: [
              IconButton(
                tooltip: tour.featured ? 'Unmark Featured' : 'Mark Featured',
                icon: Icon(
                  tour.featured ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: tour.featured ? AppColors.gold : AppColors.gray500,
                ),
                onPressed: onToggleFeatured,
              ),
              IconButton(
                tooltip: tour.active ? 'Deactivate Tour' : 'Activate Tour',
                icon: Icon(
                  tour.active ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
                  color: tour.active ? AppColors.success : AppColors.gray400,
                  size: 32,
                ),
                onPressed: onToggleActive,
              ),
              IconButton(
                tooltip: 'Edit Tour Details',
                icon: const Icon(Icons.edit_outlined, color: AppColors.royalBlue),
                onPressed: onEdit,
              ),
              IconButton(
                tooltip: 'Delete Tour',
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TourFormDialog extends StatefulWidget {
  final TourModel? tour;
  final Future<void> Function(TourModel) onSave;

  const _TourFormDialog({this.tour, required this.onSave});

  @override
  State<_TourFormDialog> createState() => _TourFormDialogState();
}

class _TourFormDialogState extends State<_TourFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _titleArCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _descArCtrl;
  late TextEditingController _destCtrl;
  late TextEditingController _countryCtrl;
  late TextEditingController _durationCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _currencyCtrl;
  late TextEditingController _imageCtrl;
  late TourType _selectedType;
  late bool _featured;
  late bool _active;
  late List<String> _highlights;
  late List<String> _included;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.tour;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _titleArCtrl = TextEditingController(text: t?.titleAr ?? '');
    _descCtrl = TextEditingController(text: t?.description ?? '');
    _descArCtrl = TextEditingController(text: t?.descriptionAr ?? '');
    _destCtrl = TextEditingController(text: t?.destination ?? '');
    _countryCtrl = TextEditingController(text: t?.country ?? '');
    _durationCtrl = TextEditingController(text: t?.duration ?? '5 Days / 4 Nights');
    _priceCtrl = TextEditingController(text: t != null ? t.price.toStringAsFixed(0) : '450');
    _currencyCtrl = TextEditingController(text: t?.currency ?? 'USD');
    _imageCtrl = TextEditingController(text: t?.imageUrl ?? '');
    _selectedType = t?.type ?? TourType.domestic;
    _featured = t?.featured ?? false;
    _active = t?.active ?? true;
    _highlights = List.from(t?.highlights ?? ['5-Star Accommodation', 'Guided Tours', 'Private Transport']);
    _included = List.from(t?.included ?? ['All Meals', 'Airport Transfers', 'Entry Tickets']);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _titleArCtrl.dispose();
    _descCtrl.dispose();
    _descArCtrl.dispose();
    _destCtrl.dispose();
    _countryCtrl.dispose();
    _durationCtrl.dispose();
    _priceCtrl.dispose();
    _currencyCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.tour == null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 850),
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.flight_takeoff_rounded, color: AppColors.navy, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isNew ? 'Create New Tour' : 'Edit Tour Details', style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold)),
                          Text('Changes will be synced directly to Supabase', style: AppTextStyles.bodyXS.copyWith(color: AppColors.gray500)),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(),
              const SizedBox(height: 14),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // English Title
                      TextFormField(
                        controller: _titleCtrl,
                        decoration: InputDecoration(
                          labelText: 'Tour Title (English) *',
                          hintText: 'e.g. Hurghada Red Sea & Island Adventure',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
                      ),
                      const SizedBox(height: 14),

                      // Arabic Title
                      TextFormField(
                        controller: _titleArCtrl,
                        textDirection: TextDirection.rtl,
                        decoration: InputDecoration(
                          labelText: 'Tour Title (Arabic)',
                          hintText: 'مثال: مغامرة الغردقة وجزيرة جفتون',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Row: Tour Type & Duration
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<TourType>(
                              value: _selectedType,
                              decoration: InputDecoration(
                                labelText: 'Tour Category *',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              items: TourType.values.map((t) {
                                return DropdownMenuItem(
                                  value: t,
                                  child: Text(t.toDbString().toUpperCase()),
                                );
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedType = val ?? TourType.domestic),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _durationCtrl,
                              decoration: InputDecoration(
                                labelText: 'Duration *',
                                hintText: 'e.g. 5 Days / 4 Nights',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Duration is required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Row: Price & Currency
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _priceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Price *',
                                hintText: '450',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (v) => v == null || double.tryParse(v.trim()) == null ? 'Enter valid price' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: _currencyCtrl,
                              decoration: InputDecoration(
                                labelText: 'Currency',
                                hintText: 'USD',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Row: Destination & Country
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _destCtrl,
                              decoration: InputDecoration(
                                labelText: 'Destination City',
                                hintText: 'e.g. Hurghada',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
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
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Main Image Field
                      AdminImageField(
                        label: 'Main Image URL *',
                        controller: _imageCtrl,
                      ),
                      const SizedBox(height: 14),

                      // English Description
                      TextFormField(
                        controller: _descCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description (English) *',
                          hintText: 'Comprehensive itinerary and package details...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Description is required' : null,
                      ),
                      const SizedBox(height: 14),

                      // Arabic Description
                      TextFormField(
                        controller: _descArCtrl,
                        textDirection: TextDirection.rtl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description (Arabic)',
                          hintText: 'تفاصيل الرحلة والبرنامج باللغة العربية...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Highlights List Editor
                      AdminBulletListEditor(
                        label: 'Tour Highlights',
                        hint: 'Add highlight (e.g. 5-Star Beachfront Resort)',
                        items: _highlights,
                        onChanged: (items) => _highlights = items,
                      ),
                      const SizedBox(height: 18),

                      // Included Items List Editor
                      AdminBulletListEditor(
                        label: 'Package Inclusions',
                        hint: 'Add inclusion (e.g. All-Inclusive Meals & Drinks)',
                        items: _included,
                        onChanged: (items) => _included = items,
                      ),
                      const SizedBox(height: 18),

                      // Switches: Featured & Active
                      Row(
                        children: [
                          Expanded(
                            child: SwitchListTile(
                              title: const Text('Mark as Featured', style: TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: const Text('Highlighted on homepage carousel', style: TextStyle(fontSize: 11)),
                              value: _featured,
                              activeColor: AppColors.gold,
                              onChanged: (v) => setState(() => _featured = v),
                            ),
                          ),
                          Expanded(
                            child: SwitchListTile(
                              title: const Text('Active in Catalog', style: TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: const Text('Visible to website visitors', style: TextStyle(fontSize: 11)),
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

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel', style: TextStyle(color: AppColors.gray600)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _isSaving
                        ? null
                        : () async {
                            if (_formKey.currentState?.validate() == true) {
                              setState(() => _isSaving = true);
                              final tour = TourModel(
                                id: widget.tour?.id ?? '',
                                title: _titleCtrl.text.trim(),
                                titleAr: _titleArCtrl.text.trim().isNotEmpty ? _titleArCtrl.text.trim() : null,
                                description: _descCtrl.text.trim(),
                                descriptionAr: _descArCtrl.text.trim().isNotEmpty ? _descArCtrl.text.trim() : null,
                                type: _selectedType,
                                duration: _durationCtrl.text.trim(),
                                price: double.parse(_priceCtrl.text.trim()),
                                currency: _currencyCtrl.text.trim().toUpperCase(),
                                imageUrl: _imageCtrl.text.trim().isNotEmpty
                                    ? _imageCtrl.text.trim()
                                    : 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&w=1000&q=80',
                                destination: _destCtrl.text.trim(),
                                country: _countryCtrl.text.trim(),
                                featured: _featured,
                                active: _active,
                                highlights: _highlights,
                                included: _included,
                                createdAt: widget.tour?.createdAt ?? DateTime.now(),
                                updatedAt: DateTime.now(),
                              );
                              await widget.onSave(tour);
                              if (mounted) {
                                setState(() => _isSaving = false);
                              }
                            }
                          },
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check, size: 18),
                    label: Text(isNew ? 'Create Tour' : 'Save Changes'),
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

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../data/models/airport_transfer_model.dart';
import '../cubit/admin_transfers_cubit.dart';

class AdminTransferVehicleDialog extends StatefulWidget {
  final TransferVehicleModel? vehicle;
  final AdminTransfersCubit cubit;

  const AdminTransferVehicleDialog({
    super.key,
    this.vehicle,
    required this.cubit,
  });

  static Future<void> show(
    BuildContext context, {
    TransferVehicleModel? vehicle,
    required AdminTransfersCubit cubit,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AdminTransferVehicleDialog(
        vehicle: vehicle,
        cubit: cubit,
      ),
    );
  }

  @override
  State<AdminTransferVehicleDialog> createState() => _AdminTransferVehicleDialogState();
}

class _AdminTransferVehicleDialogState extends State<AdminTransferVehicleDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _nameArController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _priceController;
  late final TextEditingController _durationController;
  late final TextEditingController _featuresController;

  late String _selectedType;
  late int _passengers;
  late int _luggage;
  late String _currency;
  late bool _active;

  static const List<String> _vehicleTypes = [
    'sedan',
    'luxury_sedan',
    'suv',
    'van',
    'minibus',
  ];

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _nameController = TextEditingController(text: v?.vehicleName ?? '');
    _nameArController = TextEditingController(text: v?.vehicleNameAr ?? '');
    _imageUrlController = TextEditingController(text: v?.imageUrl ?? '');
    _priceController = TextEditingController(text: v?.basePrice.toString() ?? '45.0');
    _durationController = TextEditingController(text: v?.estimatedDuration ?? '45-60 mins');
    _featuresController = TextEditingController(text: v?.features.join(', ') ?? 'Flight Tracking, Meet & Greet, Air Conditioned');

    _selectedType = v?.vehicleType ?? 'sedan';
    _passengers = v?.passengerCapacity ?? 3;
    _luggage = v?.luggageCapacity ?? 2;
    _currency = v?.currency ?? 'USD';
    _active = v?.active ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameArController.dispose();
    _imageUrlController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _featuresController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final parsedPrice = double.tryParse(_priceController.text) ?? 45.0;
    final featuresList = _featuresController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final vehicle = TransferVehicleModel(
      id: widget.vehicle?.id ?? '',
      vehicleName: _nameController.text.trim(),
      vehicleNameAr: _nameArController.text.trim().isNotEmpty ? _nameArController.text.trim() : null,
      vehicleType: _selectedType,
      imageUrl: _imageUrlController.text.trim().isNotEmpty ? _imageUrlController.text.trim() : null,
      passengerCapacity: _passengers,
      luggageCapacity: _luggage,
      basePrice: parsedPrice,
      currency: _currency,
      estimatedDuration: _durationController.text.trim(),
      features: featuresList.isNotEmpty ? featuresList : ['Flight Tracking', 'Meet & Greet'],
      active: _active,
    );

    final success = await widget.cubit.saveVehicle(vehicle);
    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.vehicle != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 780),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.navyDark.withValues(alpha: 0.25),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                color: AppColors.navyDark,
                child: Row(
                  children: [
                    Icon(
                      isEditing ? Icons.edit_rounded : Icons.add_circle_outline_rounded,
                      color: AppColors.gold,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isEditing ? 'Edit Transfer Vehicle' : 'Add New Transfer Vehicle',
                      style: AppTextStyles.h6.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, color: AppColors.white),
                    ),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      // Vehicle Name (EN & AR)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Vehicle Name (English) *',
                                hintText: 'e.g. Mercedes E-Class',
                                filled: true,
                                fillColor: AppColors.lightGray,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _nameArController,
                              textDirection: TextDirection.rtl,
                              decoration: InputDecoration(
                                labelText: 'اسم السيارة (عربي)',
                                hintText: 'مثال: مرسيدس الفئة E',
                                filled: true,
                                fillColor: AppColors.lightGray,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Vehicle Type & Currency
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<String>(
                              value: _selectedType,
                              decoration: InputDecoration(
                                labelText: 'Vehicle Category *',
                                filled: true,
                                fillColor: AppColors.lightGray,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                              ),
                              items: _vehicleTypes.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type.replaceAll('_', ' ').toUpperCase()),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedType = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              value: _currency,
                              decoration: InputDecoration(
                                labelText: 'Currency',
                                filled: true,
                                fillColor: AppColors.lightGray,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
                                DropdownMenuItem(value: 'EUR', child: Text('EUR (€)')),
                                DropdownMenuItem(value: 'EGP', child: Text('EGP (ج.م)')),
                                DropdownMenuItem(value: 'SAR', child: Text('SAR (ر.س)')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _currency = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Price & Duration
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Base Price *',
                                prefixText: '$_currency ',
                                filled: true,
                                fillColor: AppColors.lightGray,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                              ),
                              validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter valid price' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _durationController,
                              decoration: InputDecoration(
                                labelText: 'Est. Duration',
                                hintText: 'e.g. 45-60 mins',
                                filled: true,
                                fillColor: AppColors.lightGray,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Passenger & Luggage Capacities
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.lightGray,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Seats: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Row(
                                    children: [
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                        icon: const Icon(Icons.remove_circle_outline, size: 20),
                                        onPressed: () {
                                          if (_passengers > 1) setState(() => _passengers--);
                                        },
                                      ),
                                      Text('$_passengers', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                        icon: const Icon(Icons.add_circle_outline, size: 20),
                                        onPressed: () => setState(() => _passengers++),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.lightGray,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Luggage: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Row(
                                    children: [
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                        icon: const Icon(Icons.remove_circle_outline, size: 20),
                                        onPressed: () {
                                          if (_luggage > 0) setState(() => _luggage--);
                                        },
                                      ),
                                      Text('$_luggage', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                        icon: const Icon(Icons.add_circle_outline, size: 20),
                                        onPressed: () => setState(() => _luggage++),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Image URL
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: InputDecoration(
                          labelText: 'Vehicle Image URL',
                          hintText: 'https://images.unsplash.com/...',
                          prefixIcon: const Icon(Icons.image_outlined, color: AppColors.navy),
                          filled: true,
                          fillColor: AppColors.lightGray,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Inclusions / Features
                      TextFormField(
                        controller: _featuresController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Features & Inclusions (Comma separated)',
                          hintText: 'Flight Tracking, Meet & Greet, Free 60 min Wait, Wi-Fi',
                          prefixIcon: const Icon(Icons.star_outline_rounded, color: AppColors.gold),
                          filled: true,
                          fillColor: AppColors.lightGray,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Active Switch
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Active for Bookings', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('When disabled, customers will not see this vehicle.'),
                        value: _active,
                        activeColor: AppColors.gold,
                        onChanged: (val) => setState(() => _active = val),
                      ),
                    ],
                  ),
                ),
              ),

              // Actions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  border: Border(top: BorderSide(color: AppColors.gray200)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 2,
                      child: TravellaButton(
                        label: isEditing ? 'Update Vehicle' : 'Create Vehicle',
                        variant: TravellaButtonVariant.gold,
                        size: TravellaButtonSize.lg,
                        onPressed: _save,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

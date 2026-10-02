import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../data/models/airport_transfer_model.dart';
import '../cubit/admin_transfers_cubit.dart';
import '../cubit/admin_transfers_state.dart';
import '../widgets/admin_transfer_vehicle_dialog.dart';
import '../widgets/admin_transfer_booking_dialog.dart';

class AdminTransfersPage extends StatefulWidget {
  const AdminTransfersPage({super.key});

  @override
  State<AdminTransfersPage> createState() => _AdminTransfersPageState();
}

class _AdminTransfersPageState extends State<AdminTransfersPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<AdminTransfersCubit>().loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminTransfersCubit, AdminTransfersState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading && state.allVehicles.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.gold));
        }

        return Container(
          color: AppColors.lightGray,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tab Header Bar
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navy.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TabBar(
                        controller: _tabController,
                        labelColor: AppColors.navyDark,
                        unselectedLabelColor: AppColors.gray500,
                        indicatorColor: AppColors.gold,
                        indicatorWeight: 3,
                        labelStyle: AppTextStyles.bodyMD.copyWith(fontWeight: FontWeight.bold),
                        tabs: [
                          Tab(
                            icon: const Icon(Icons.airport_shuttle_rounded, size: 20),
                            text: 'Vehicle Fleet & Types (${state.allVehicles.length})',
                          ),
                          Tab(
                            icon: const Icon(Icons.receipt_long_rounded, size: 20),
                            text: 'Transfer Requests (${state.allBookings.length})',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      tooltip: 'Refresh Data',
                      onPressed: () => context.read<AdminTransfersCubit>().loadAllData(),
                      icon: const Icon(Icons.refresh_rounded, color: AppColors.navy),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Vehicle Fleet Management
                    _buildVehiclesTab(context, state),

                    // Tab 2: Transfer Requests Management
                    _buildBookingsTab(context, state),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Tab 1: Vehicles ────────────────────────────────────────────────────────

  Widget _buildVehiclesTab(BuildContext context, AdminTransfersState state) {
    final cubit = context.read<AdminTransfersCubit>();

    return Column(
      children: [
        // Controls Row
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: cubit.searchVehicles,
                decoration: InputDecoration(
                  hintText: 'Search vehicles by model or category...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.gray500),
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.gray300),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            DropdownButton<String>(
              value: state.vehicleTypeFilter,
              borderRadius: BorderRadius.circular(12),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Vehicle Types')),
                DropdownMenuItem(value: 'sedan', child: Text('Sedans')),
                DropdownMenuItem(value: 'luxury_sedan', child: Text('Luxury VIP Sedans')),
                DropdownMenuItem(value: 'suv', child: Text('Executive SUVs')),
                DropdownMenuItem(value: 'van', child: Text('Family Vans')),
                DropdownMenuItem(value: 'minibus', child: Text('Minibuses')),
              ],
              onChanged: (val) {
                if (val != null) cubit.filterVehicleType(val);
              },
            ),
            const SizedBox(width: 16),
            TravellaButton(
              label: 'Add Vehicle',
              variant: TravellaButtonVariant.gold,
              size: TravellaButtonSize.md,
              leadingIcon: Icons.add_rounded,
              onPressed: () => AdminTransferVehicleDialog.show(context, cubit: cubit),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Grid / List of Vehicles
        Expanded(
          child: state.filteredVehicles.isEmpty
              ? _buildEmptyState('No transfer vehicles found', 'Click "Add Vehicle" to create your first transfer offering.')
              : ListView.separated(
                  itemCount: state.filteredVehicles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final v = state.filteredVehicles[i];
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.gray200),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Vehicle Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 100,
                              height: 68,
                              child: v.imageUrl != null && v.imageUrl!.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: v.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => Container(
                                        color: AppColors.navyMedium,
                                        child: const Icon(Icons.directions_car_rounded, color: AppColors.gold),
                                      ),
                                    )
                                  : Container(
                                      color: AppColors.navyMedium,
                                      child: const Icon(Icons.directions_car_rounded, color: AppColors.gold),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Vehicle Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      v.vehicleName,
                                      style: AppTextStyles.bodyMD.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.navyDark,
                                      ),
                                    ),
                                    if (v.vehicleNameAr != null) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        '(${v.vehicleNameAr})',
                                        style: AppTextStyles.caption.copyWith(color: AppColors.gray600),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.navyDark.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        v.vehicleTypeDisplay.toUpperCase(),
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '${v.passengerCapacity} Seats  •  ${v.luggageCapacity} Luggage  •  ${v.estimatedDuration}',
                                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Price
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${v.basePrice.toStringAsFixed(0)} ${v.currency}',
                                style: AppTextStyles.h6.copyWith(
                                  color: AppColors.navyDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                v.active ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  color: v.active ? AppColors.success : AppColors.gray500,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),

                          // Switch Active
                          Switch(
                            value: v.active,
                            activeColor: AppColors.gold,
                            onChanged: (_) => cubit.toggleVehicleStatus(v),
                          ),
                          const SizedBox(width: 8),

                          // Edit & Delete Buttons
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: AppColors.navy),
                            tooltip: 'Edit Vehicle',
                            onPressed: () => AdminTransferVehicleDialog.show(context, vehicle: v, cubit: cubit),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                            tooltip: 'Delete Vehicle',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: const Text('Delete Vehicle?'),
                                  content: Text('Are you sure you want to remove ${v.vehicleName}?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                      onPressed: () => Navigator.pop(c, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) cubit.deleteVehicle(v.id);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ── Tab 2: Bookings ────────────────────────────────────────────────────────

  Widget _buildBookingsTab(BuildContext context, AdminTransfersState state) {
    final cubit = context.read<AdminTransfersCubit>();
    final dateFormat = DateFormat('MMM d, yyyy');

    return Column(
      children: [
        // Filter Bar
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: cubit.searchBookings,
                decoration: InputDecoration(
                  hintText: 'Search requests by customer, email, phone, or location...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.gray500),
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.gray300),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            DropdownButton<TransferStatus?>(
              value: state.bookingStatusFilter,
              borderRadius: BorderRadius.circular(12),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Statuses')),
                ...TransferStatus.values.map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Row(
                      children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: s.color, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Text(s.label),
                      ],
                    ),
                  ),
                ),
              ],
              onChanged: (val) => cubit.filterBookingStatus(val),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Bookings List
        Expanded(
          child: state.filteredBookings.isEmpty
              ? _buildEmptyState('No transfer requests found', 'New customer booking requests will appear here.')
              : ListView.separated(
                  itemCount: state.filteredBookings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final b = state.filteredBookings[i];
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.gray200),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Status Badge Avatar
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: b.status.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.airport_shuttle_rounded, color: b.status.color, size: 22),
                          ),
                          const SizedBox(width: 16),

                          // Customer & Route Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      b.customerName,
                                      style: AppTextStyles.bodyMD.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.navyDark,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('(${b.phone})', style: AppTextStyles.caption.copyWith(color: AppColors.gray600)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'From: ${b.pickupLocation}  ➔  To: ${b.dropoffLocation}',
                                  style: AppTextStyles.bodySM.copyWith(color: AppColors.navy, fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Date: ${dateFormat.format(b.pickupDate)} at ${b.pickupTime}  •  ${b.passengersSummary}',
                                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),

                          // Price & Status Dropdown
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${b.totalPrice.toStringAsFixed(0)} ${b.currency}',
                                style: AppTextStyles.bodyMD.copyWith(fontWeight: FontWeight.bold, color: AppColors.navyDark),
                              ),
                              const SizedBox(height: 4),
                              DropdownButton<TransferStatus>(
                                value: b.status,
                                isDense: true,
                                underline: const SizedBox.shrink(),
                                items: TransferStatus.values.map((s) {
                                  return DropdownMenuItem(
                                    value: s,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: s.color.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        s.label,
                                        style: TextStyle(color: s.color, fontWeight: FontWeight.bold, fontSize: 11),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) cubit.updateBookingStatus(b.id, val);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),

                          // Details Button
                          IconButton(
                            icon: const Icon(Icons.remove_red_eye_outlined, color: AppColors.navy),
                            tooltip: 'View Full Request',
                            onPressed: () => AdminTransferBookingDialog.show(context, booking: b, cubit: cubit),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String title, String desc) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.airport_shuttle_rounded, size: 36, color: AppColors.goldDark),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(desc, style: AppTextStyles.bodySM.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../data/models/airport_transfer_model.dart';
import '../cubit/admin_transfers_cubit.dart';

class AdminTransferBookingDialog extends StatefulWidget {
  final TransferBookingModel booking;
  final AdminTransfersCubit cubit;

  const AdminTransferBookingDialog({
    super.key,
    required this.booking,
    required this.cubit,
  });

  static Future<void> show(
    BuildContext context, {
    required TransferBookingModel booking,
    required AdminTransfersCubit cubit,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => AdminTransferBookingDialog(booking: booking, cubit: cubit),
    );
  }

  @override
  State<AdminTransferBookingDialog> createState() => _AdminTransferBookingDialogState();
}

class _AdminTransferBookingDialogState extends State<AdminTransferBookingDialog> {
  late TransferStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.booking.status;
  }

  Future<void> _updateStatus(TransferStatus newStatus) async {
    setState(() => _selectedStatus = newStatus);
    await widget.cubit.updateBookingStatus(widget.booking.id, newStatus);
  }

  Future<void> _openWhatsApp() async {
    final cleanPhone = widget.booking.phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final msg = Uri.encodeComponent(
      'Hello ${widget.booking.customerName}, this is Travella regarding your airport transfer booking (Ref: ${widget.booking.id}).',
    );
    final uri = Uri.parse('https://wa.me/$cleanPhone?text=$msg');
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
    }
  }

  Future<void> _sendEmail() async {
    final uri = Uri.parse('mailto:${widget.booking.email}?subject=Travella%20Transfer%20Booking%20Confirmation');
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMM d, yyyy');

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 750),
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _selectedStatus.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.airport_shuttle_rounded, color: _selectedStatus.color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Transfer Request Details',
                            style: AppTextStyles.h6.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Reference: ${widget.booking.id}',
                            style: AppTextStyles.caption.copyWith(color: AppColors.gold),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, color: AppColors.white),
                    ),
                  ],
                ),
              ),

              // Body
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Status Updater Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.lightGray,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.gray200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Booking Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                          DropdownButton<TransferStatus>(
                            value: _selectedStatus,
                            underline: const SizedBox.shrink(),
                            borderRadius: BorderRadius.circular(12),
                            items: TransferStatus.values.map((s) {
                              return DropdownMenuItem(
                                value: s,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(color: s.color, shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(s.label, style: TextStyle(fontWeight: FontWeight.bold, color: s.color)),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) _updateStatus(val);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Customer Contact Card
                    _buildSectionHeader('Customer Information'),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.person_rounded, 'Full Name', widget.booking.customerName),
                    _buildInfoRow(Icons.email_outlined, 'Email', widget.booking.email),
                    _buildInfoRow(Icons.phone_outlined, 'Phone / WhatsApp', widget.booking.phone),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _openWhatsApp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                          label: const Text('WhatsApp Customer'),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: _sendEmail,
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.email_outlined, size: 16),
                          label: const Text('Email Client'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Route & Schedule Card
                    _buildSectionHeader('Route & Schedule'),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.flight_land_rounded, 'Pickup', widget.booking.pickupLocation),
                    _buildInfoRow(Icons.place_rounded, 'Drop-off', widget.booking.dropoffLocation),
                    _buildInfoRow(Icons.calendar_today_rounded, 'Pickup Date & Time',
                        '${dateFormat.format(widget.booking.pickupDate)} at ${widget.booking.pickupTime}'),
                    _buildInfoRow(Icons.alt_route_rounded, 'Route Type', widget.booking.transferType.label),
                    if (widget.booking.flightNumber != null && widget.booking.flightNumber!.isNotEmpty)
                      _buildInfoRow(Icons.flight_outlined, 'Flight Number', widget.booking.flightNumber!),
                    const SizedBox(height: 20),

                    // Passengers & Vehicle Specs
                    _buildSectionHeader('Vehicle & Passengers'),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.directions_car_rounded, 'Vehicle Category', widget.booking.vehicleType.toUpperCase()),
                    if (widget.booking.vehicleName != null)
                      _buildInfoRow(Icons.directions_car_filled_outlined, 'Vehicle Model', widget.booking.vehicleName!),
                    _buildInfoRow(Icons.people_alt_rounded, 'Passengers', widget.booking.passengersSummary),
                    _buildInfoRow(Icons.luggage_rounded, 'Luggage Count', '${widget.booking.luggageCount} Bags'),
                    _buildInfoRow(Icons.attach_money_rounded, 'Total Fixed Fare', '\$${widget.booking.totalPrice.toStringAsFixed(0)} ${widget.booking.currency}'),
                    const SizedBox(height: 20),

                    // Special requests
                    if (widget.booking.specialRequests != null && widget.booking.specialRequests!.isNotEmpty) ...[
                      _buildSectionHeader('Special Requests & Notes'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.lightGray,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(widget.booking.specialRequests!, style: AppTextStyles.bodySM),
                      ),
                    ],
                  ],
                ),
              ),

              // Bottom Actions
              Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  border: Border(top: BorderSide(color: AppColors.gray200)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: AppColors.error),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Transfer Booking?'),
                            content: const Text('This action cannot be undone.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && context.mounted) {
                          await widget.cubit.deleteBooking(widget.booking.id);
                          if (context.mounted) Navigator.of(context).pop();
                        }
                      },
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text('Delete'),
                    ),
                    TravellaButton(
                      label: 'Close Details',
                      variant: TravellaButtonVariant.primary,
                      size: TravellaButtonSize.md,
                      onPressed: () => Navigator.of(context).pop(),
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.bodyMD.copyWith(fontWeight: FontWeight.bold, color: AppColors.navyDark),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.goldDark, size: 16),
          const SizedBox(width: 8),
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySM.copyWith(color: AppColors.navyDark, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

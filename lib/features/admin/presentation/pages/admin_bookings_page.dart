import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../data/models/booking_model.dart';
import '../cubit/admin_bookings_cubit.dart';
import '../widgets/admin_dialogs.dart';

class AdminBookingsPage extends StatefulWidget {
  const AdminBookingsPage({super.key});

  @override
  State<AdminBookingsPage> createState() => _AdminBookingsPageState();
}

class _AdminBookingsPageState extends State<AdminBookingsPage> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AdminBookingsCubit>().loadBookings();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showBookingDetailsDialog(BookingModel booking) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Booking Details', style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(ctx).pop()),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              _DetailRow(label: 'Booking ID', value: booking.id),
              _DetailRow(label: 'Customer Name', value: booking.customerName),
              _DetailRow(label: 'Email', value: booking.email),
              _DetailRow(label: 'Phone Number', value: booking.phone),
              _DetailRow(label: 'Package / Tour', value: booking.tourTitle ?? 'General Travel Request'),
              _DetailRow(
                label: 'Travel Date',
                value: booking.travelDate != null
                    ? DateFormat('MMMM dd, yyyy').format(booking.travelDate!)
                    : 'Flexible / Not set',
              ),
              _DetailRow(label: 'Total Travelers', value: '${booking.travelers} Guests'),
              _DetailRow(
                label: 'Created Date',
                value: booking.createdAt != null
                    ? DateFormat('MMM dd, yyyy HH:mm').format(booking.createdAt!)
                    : 'Recent',
              ),
              if (booking.notes != null && booking.notes!.isNotEmpty)
                _DetailRow(label: 'Special Notes', value: booking.notes!),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                  PopupMenuButton<BookingStatus>(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.navy,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(booking.status.label, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_drop_down, color: AppColors.white),
                        ],
                      ),
                    ),
                    onSelected: (newStatus) async {
                      Navigator.of(ctx).pop();
                      await context.read<AdminBookingsCubit>().updateStatus(booking.id, newStatus);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: BookingStatus.pending, child: Text('Pending')),
                      const PopupMenuItem(value: BookingStatus.confirmed, child: Text('Confirmed')),
                      const PopupMenuItem(value: BookingStatus.completed, child: Text('Completed')),
                      const PopupMenuItem(value: BookingStatus.cancelled, child: Text('Cancelled')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(context);

    return BlocConsumer<AdminBookingsCubit, AdminBookingsState>(
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
                        Text('Bookings & Reservations', style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('Manage all client bookings, dates, guests, and confirmation statuses', style: AppTextStyles.bodyMD.copyWith(color: AppColors.gray600)),
                      ],
                    ),
                    IconButton(
                      tooltip: 'Refresh Bookings',
                      icon: const Icon(Icons.refresh_rounded),
                      onPressed: () => context.read<AdminBookingsCubit>().loadBookings(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Controls Bar: Search, Status Filter, Sorting
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: Row(
                    children: [
                      // Search
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (q) => context.read<AdminBookingsCubit>().searchBookings(q),
                          decoration: InputDecoration(
                            hintText: 'Search customer, email, phone, or tour...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Status filter
                      DropdownButton<BookingStatus?>(
                        value: state.statusFilter,
                        hint: const Text('All Statuses'),
                        underline: const SizedBox.shrink(),
                        borderRadius: BorderRadius.circular(10),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Statuses')),
                          ...BookingStatus.values.map(
                            (s) => DropdownMenuItem(value: s, child: Text(s.label)),
                          ),
                        ],
                        onChanged: (status) => context.read<AdminBookingsCubit>().filterByStatus(status),
                      ),
                      const SizedBox(width: 14),

                      // Sort option
                      DropdownButton<BookingSortOption>(
                        value: state.sortOption,
                        underline: const SizedBox.shrink(),
                        borderRadius: BorderRadius.circular(10),
                        items: const [
                          DropdownMenuItem(value: BookingSortOption.newest, child: Text('Newest First')),
                          DropdownMenuItem(value: BookingSortOption.oldest, child: Text('Oldest First')),
                          DropdownMenuItem(value: BookingSortOption.travelersHigh, child: Text('Most Travelers')),
                        ],
                        onChanged: (opt) {
                          if (opt != null) context.read<AdminBookingsCubit>().setSortOption(opt);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Content list
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                      : state.filteredBookings.isEmpty
                          ? const Center(child: Text('No bookings match criteria.'))
                          : isMobile
                              ? ListView.builder(
                                  itemCount: state.pagedBookings.length,
                                  itemBuilder: (context, index) {
                                    final booking = state.pagedBookings[index];
                                    return _BookingMobileCard(
                                      booking: booking,
                                      onTap: () => _showBookingDetailsDialog(booking),
                                      onStatusChange: (status) => context.read<AdminBookingsCubit>().updateStatus(booking.id, status),
                                    );
                                  },
                                )
                              : _BookingDesktopTable(
                                  bookings: state.pagedBookings,
                                  onViewDetails: (b) => _showBookingDetailsDialog(b),
                                  onStatusChange: (b, s) => context.read<AdminBookingsCubit>().updateStatus(b.id, s),
                                  onDelete: (b) async {
                                    final confirm = await showAdminConfirmDialog(
                                      context: context,
                                      title: 'Delete Booking Record',
                                      message: 'Are you sure you want to delete reservation for "${b.customerName}"?',
                                    );
                                    if (confirm == true && context.mounted) {
                                      await context.read<AdminBookingsCubit>().deleteBooking(b.id);
                                    }
                                  },
                                ),
                ),

                // Pagination Controls
                if (state.totalPages > 1) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.gray200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Showing page ${state.currentPage} of ${state.totalPages} (${state.filteredBookings.length} total)',
                          style: AppTextStyles.caption.copyWith(color: AppColors.gray600),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: state.currentPage > 1
                                  ? () => context.read<AdminBookingsCubit>().setPage(state.currentPage - 1)
                                  : null,
                            ),
                            Text('${state.currentPage}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: state.currentPage < state.totalPages
                                  ? () => context.read<AdminBookingsCubit>().setPage(state.currentPage + 1)
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.gray600, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _BookingDesktopTable extends StatelessWidget {
  final List<BookingModel> bookings;
  final ValueChanged<BookingModel> onViewDetails;
  final void Function(BookingModel, BookingStatus) onStatusChange;
  final ValueChanged<BookingModel> onDelete;

  const _BookingDesktopTable({
    required this.bookings,
    required this.onViewDetails,
    required this.onStatusChange,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gray200),
      ),
      child: ListView.separated(
        itemCount: bookings.length + 1,
        separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.gray200),
        itemBuilder: (context, i) {
          if (i == 0) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppColors.lightGray,
              child: const Row(
                children: [
                  Expanded(flex: 3, child: Text('Customer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  Expanded(flex: 3, child: Text('Tour', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  Expanded(flex: 2, child: Text('Travel Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  Expanded(flex: 1, child: Text('Guests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  Expanded(flex: 2, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  Expanded(flex: 2, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                ],
              ),
            );
          }

          final booking = bookings[i - 1];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('${booking.email} • ${booking.phone}', style: const TextStyle(color: AppColors.gray500, fontSize: 11)),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(booking.tourTitle ?? 'Direct Request', style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    booking.travelDate != null
                        ? DateFormat('MMM dd, yyyy').format(booking.travelDate!)
                        : 'Not specified',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text('${booking.travelers}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: PopupMenuButton<BookingStatus>(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(booking.status).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              booking.status.label.toUpperCase(),
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _statusColor(booking.status)),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_drop_down, size: 14, color: _statusColor(booking.status)),
                          ],
                        ),
                      ),
                      onSelected: (newStatus) => onStatusChange(booking, newStatus),
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(value: BookingStatus.pending, child: Text('Pending')),
                        const PopupMenuItem(value: BookingStatus.confirmed, child: Text('Confirmed')),
                        const PopupMenuItem(value: BookingStatus.completed, child: Text('Completed')),
                        const PopupMenuItem(value: BookingStatus.cancelled, child: Text('Cancelled')),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.royalBlue),
                        onPressed: () => onViewDetails(booking),
                        tooltip: 'View Booking Info',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                        onPressed: () => onDelete(booking),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _statusColor(BookingStatus s) {
    switch (s) {
      case BookingStatus.confirmed:
        return AppColors.success;
      case BookingStatus.completed:
        return AppColors.royalBlue;
      case BookingStatus.cancelled:
        return AppColors.error;
      case BookingStatus.pending:
      default:
        return AppColors.goldDark;
    }
  }
}

class _BookingMobileCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;
  final ValueChanged<BookingStatus> onStatusChange;

  const _BookingMobileCard({
    required this.booking,
    required this.onTap,
    required this.onStatusChange,
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(booking.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
              PopupMenuButton<BookingStatus>(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.navy.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(booking.status.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ),
                onSelected: onStatusChange,
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: BookingStatus.pending, child: Text('Pending')),
                  const PopupMenuItem(value: BookingStatus.confirmed, child: Text('Confirmed')),
                  const PopupMenuItem(value: BookingStatus.completed, child: Text('Completed')),
                  const PopupMenuItem(value: BookingStatus.cancelled, child: Text('Cancelled')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(booking.tourTitle ?? 'Tour inquiry', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.navy)),
          const SizedBox(height: 4),
          Text('${booking.email} • ${booking.phone}', style: const TextStyle(color: AppColors.gray600, fontSize: 12)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${booking.travelers} Guests', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              TextButton(onPressed: onTap, child: const Text('View Full Details')),
            ],
          ),
        ],
      ),
    );
  }
}

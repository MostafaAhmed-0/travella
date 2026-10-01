import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
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

  Future<void> _openWhatsAppForCustomer(BookingModel booking) async {
    final cleanPhone = booking.phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final name = booking.customerName;
    final ref = booking.bookingReference;
    final tour = booking.tourTitle ?? 'Tour Inquiry';
    final dateStr = booking.travelDate != null
        ? DateFormat('MMMM dd, yyyy').format(booking.travelDate!)
        : 'scheduled date';

    final text = Uri.encodeComponent(
      'Hello $name, this is the Travella Travel Concierge desk regarding your booking ($ref) for "$tour" on $dateStr. We are delighted to assist you with your reservation confirmation!',
    );

    final uri = Uri.parse('https://wa.me/$cleanPhone?text=$text');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not open WhatsApp for phone: ${booking.phone}',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showBookingDetailsDialog(BookingModel booking) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 580),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                          color: AppColors.royalBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          color: AppColors.royalBlue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Booking Details',
                            style: AppTextStyles.h4.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Ref: ${booking.bookingReference}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.royalBlueDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const Divider(height: 28),
              _DetailRow(
                label: 'Booking ID',
                value: booking.id.isNotEmpty
                    ? booking.id
                    : booking.bookingReference,
              ),
              _DetailRow(label: 'Customer Name', value: booking.customerName),
              _DetailRow(label: 'Email', value: booking.email),
              _DetailRow(label: 'Phone Number', value: booking.phone),
              _DetailRow(
                label: 'Package / Tour',
                value: booking.tourTitle ?? 'Direct Travel Request',
              ),
              _DetailRow(
                label: 'Travel Date',
                value: booking.travelDate != null
                    ? DateFormat(
                        'EEEE, MMMM dd, yyyy',
                      ).format(booking.travelDate!)
                    : 'Flexible / Not set',
              ),
              _DetailRow(
                label: 'Travelers Summary',
                value: booking.formattedTravelersSummary(),
              ),
              _DetailRow(
                label: 'Adults',
                value: '${booking.adultsCount} Adult${booking.adultsCount > 1 ? 's' : ''} (18+ yrs)',
              ),
              _DetailRow(
                label: 'Children',
                value: '${booking.childrenCount} Child${booking.childrenCount != 1 ? 'ren' : ''} (0-17 yrs)',
              ),
              if (booking.childrenCount > 0)
                _DetailRow(
                  label: 'Child Ages',
                  value: booking.formattedChildAges(),
                ),
              _DetailRow(
                label: 'Status',
                value: booking.status.label.toUpperCase(),
              ),
              _DetailRow(
                label: 'Created Date',
                value: booking.createdAt != null
                    ? DateFormat(
                        'MMM dd, yyyy HH:mm',
                      ).format(booking.createdAt!)
                    : 'Recent',
              ),
              if (booking.notes != null && booking.notes!.isNotEmpty)
                _DetailRow(
                  label: 'Special Notes / Requests',
                  value: booking.notes!,
                ),
              const SizedBox(height: 20),

              // Action Buttons Row: Confirm, Cancel, Complete
              Row(
                children: [
                  const Text(
                    'Quick Action:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(width: 12),
                  if (booking.status != BookingStatus.confirmed)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_rounded, size: 16),
                        label: const Text('Confirm'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          await context.read<AdminBookingsCubit>().updateStatus(
                            booking.id,
                            BookingStatus.confirmed,
                          );
                        },
                      ),
                    ),
                  if (booking.status != BookingStatus.completed)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.task_alt_rounded, size: 16),
                        label: const Text('Complete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.royalBlue,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          await context.read<AdminBookingsCubit>().updateStatus(
                            booking.id,
                            BookingStatus.completed,
                          );
                        },
                      ),
                    ),
                  if (booking.status != BookingStatus.cancelled)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.cancel_rounded, size: 16),
                      label: const Text('Cancel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        await context.read<AdminBookingsCubit>().updateStatus(
                          booking.id,
                          BookingStatus.cancelled,
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => _openWhatsAppForCustomer(booking),
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: Color(0xFF25D366),
                    ),
                    label: const Text(
                      'Chat on WhatsApp',
                      style: TextStyle(
                        color: Color(0xFF25D366),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
        final total = state.allBookings.length;
        final pending = state.allBookings
            .where((b) => b.status == BookingStatus.pending)
            .length;
        final confirmed = state.allBookings
            .where((b) => b.status == BookingStatus.confirmed)
            .length;
        final completed = state.allBookings
            .where((b) => b.status == BookingStatus.completed)
            .length;
        final cancelled = state.allBookings
            .where((b) => b.status == BookingStatus.cancelled)
            .length;

        return Scaffold(
          backgroundColor: AppColors.lightGray,
          body: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header Row ───────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bookings & Inquiries',
                          style: AppTextStyles.h3.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Review and manage client booking requests, dates, and statuses',
                          style: AppTextStyles.bodyMD.copyWith(
                            color: AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      tooltip: 'Refresh Bookings',
                      icon: const Icon(Icons.refresh_rounded),
                      onPressed: () =>
                          context.read<AdminBookingsCubit>().loadBookings(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // ── Quick Stat Cards ─────────────────────────────────────────
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _StatCard(
                      label: 'Total Bookings',
                      value: '$total',
                      color: AppColors.navyDark,
                      icon: Icons.all_inbox_rounded,
                    ),
                    _StatCard(
                      label: 'Pending',
                      value: '$pending',
                      color: AppColors.goldDark,
                      icon: Icons.hourglass_top_rounded,
                    ),
                    _StatCard(
                      label: 'Confirmed',
                      value: '$confirmed',
                      color: AppColors.success,
                      icon: Icons.check_circle_rounded,
                    ),
                    _StatCard(
                      label: 'Completed',
                      value: '$completed',
                      color: AppColors.royalBlue,
                      icon: Icons.task_alt_rounded,
                    ),
                    _StatCard(
                      label: 'Cancelled',
                      value: '$cancelled',
                      color: AppColors.error,
                      icon: Icons.cancel_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Search & Filter Controls ─────────────────────────────────
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
                          onChanged: (q) => context
                              .read<AdminBookingsCubit>()
                              .searchBookings(q),
                          decoration: InputDecoration(
                            hintText:
                                'Search customer name, email, phone, reference, or tour...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
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
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Statuses'),
                          ),
                          ...BookingStatus.values.map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(s.label),
                            ),
                          ),
                        ],
                        onChanged: (status) => context
                            .read<AdminBookingsCubit>()
                            .filterByStatus(status),
                      ),
                      const SizedBox(width: 14),

                      // Sort option
                      DropdownButton<BookingSortOption>(
                        value: state.sortOption,
                        underline: const SizedBox.shrink(),
                        borderRadius: BorderRadius.circular(10),
                        items: const [
                          DropdownMenuItem(
                            value: BookingSortOption.newest,
                            child: Text('Newest First'),
                          ),
                          DropdownMenuItem(
                            value: BookingSortOption.oldest,
                            child: Text('Oldest First'),
                          ),
                          DropdownMenuItem(
                            value: BookingSortOption.travelersHigh,
                            child: Text('Most Travelers'),
                          ),
                        ],
                        onChanged: (opt) {
                          if (opt != null)
                            context.read<AdminBookingsCubit>().setSortOption(
                              opt,
                            );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // ── Bookings List / Table ─────────────────────────────────────
                Expanded(
                  child: state.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.gold,
                          ),
                        )
                      : state.filteredBookings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.event_busy_rounded,
                                color: AppColors.gray400,
                                size: 54,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No booking records found.',
                                style: AppTextStyles.h5.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : isMobile
                      ? ListView.builder(
                          itemCount: state.pagedBookings.length,
                          itemBuilder: (context, index) {
                            final booking = state.pagedBookings[index];
                            return _BookingMobileCard(
                              booking: booking,
                              onTap: () => _showBookingDetailsDialog(booking),
                              onStatusChange: (status) => context
                                  .read<AdminBookingsCubit>()
                                  .updateStatus(booking.id, status),
                              onWhatsApp: () =>
                                  _openWhatsAppForCustomer(booking),
                            );
                          },
                        )
                      : _BookingDesktopTable(
                          bookings: state.pagedBookings,
                          onViewDetails: (b) => _showBookingDetailsDialog(b),
                          onStatusChange: (b, s) => context
                              .read<AdminBookingsCubit>()
                              .updateStatus(b.id, s),
                          onWhatsApp: (b) => _openWhatsAppForCustomer(b),
                          onDelete: (b) async {
                            final confirm = await showAdminConfirmDialog(
                              context: context,
                              title: 'Delete Booking Record',
                              message:
                                  'Are you sure you want to delete reservation for "${b.customerName}" (${b.bookingReference})?',
                            );
                            if (confirm == true && context.mounted) {
                              await context
                                  .read<AdminBookingsCubit>()
                                  .deleteBooking(b.id);
                            }
                          },
                        ),
                ),

                // ── Pagination Controls ──────────────────────────────────────
                if (state.totalPages > 1) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.gray200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Showing page ${state.currentPage} of ${state.totalPages} (${state.filteredBookings.length} bookings)',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.gray600,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: state.currentPage > 1
                                  ? () => context
                                        .read<AdminBookingsCubit>()
                                        .setPage(state.currentPage - 1)
                                  : null,
                            ),
                            Text(
                              '${state.currentPage}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: state.currentPage < state.totalPages
                                  ? () => context
                                        .read<AdminBookingsCubit>()
                                        .setPage(state.currentPage + 1)
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.gray600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
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
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.gray600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.navyDark,
              ),
            ),
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
  final ValueChanged<BookingModel> onWhatsApp;
  final ValueChanged<BookingModel> onDelete;

  const _BookingDesktopTable({
    required this.bookings,
    required this.onViewDetails,
    required this.onStatusChange,
    required this.onWhatsApp,
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
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: AppColors.gray200),
        itemBuilder: (context, i) {
          if (i == 0) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppColors.lightGray,
              child: const Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Customer & Contact',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Tour / Package',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Travel Date',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Travelers & Ages',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Status',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Admin Actions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
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
                      Text(
                        booking.customerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${booking.email} • ${booking.phone}',
                        style: const TextStyle(
                          color: AppColors.gray500,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        'Ref: ${booking.bookingReference}',
                        style: const TextStyle(
                          color: AppColors.royalBlue,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    booking.tourTitle ?? 'Direct Request',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${booking.adultsCount} Adults${booking.childrenCount > 0 ? ', ${booking.childrenCount} Kids' : ''}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      if (booking.childrenAges.isNotEmpty)
                        Text(
                          'Ages: ${booking.childrenAges.join(", ")}',
                          style: const TextStyle(
                            color: AppColors.royalBlueDark,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: PopupMenuButton<BookingStatus>(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(
                            booking.status,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              booking.status.label.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _statusColor(booking.status),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_drop_down,
                              size: 14,
                              color: _statusColor(booking.status),
                            ),
                          ],
                        ),
                      ),
                      onSelected: (newStatus) =>
                          onStatusChange(booking, newStatus),
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: BookingStatus.pending,
                          child: Text('Pending'),
                        ),
                        const PopupMenuItem(
                          value: BookingStatus.confirmed,
                          child: Text('Confirm Booking'),
                        ),
                        const PopupMenuItem(
                          value: BookingStatus.completed,
                          child: Text('Complete Booking'),
                        ),
                        const PopupMenuItem(
                          value: BookingStatus.cancelled,
                          child: Text('Cancel Booking'),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      // Quick Confirm button
                      if (booking.status == BookingStatus.pending)
                        IconButton(
                          icon: const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 18,
                            color: AppColors.success,
                          ),
                          onPressed: () =>
                              onStatusChange(booking, BookingStatus.confirmed),
                          tooltip: 'Confirm Booking',
                        ),
                      // Quick Complete button
                      if (booking.status == BookingStatus.confirmed)
                        IconButton(
                          icon: const Icon(
                            Icons.task_alt_rounded,
                            size: 18,
                            color: AppColors.royalBlue,
                          ),
                          onPressed: () =>
                              onStatusChange(booking, BookingStatus.completed),
                          tooltip: 'Complete Booking',
                        ),
                      // WhatsApp button
                      IconButton(
                        icon: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 18,
                          color: Color(0xFF25D366),
                        ),
                        onPressed: () => onWhatsApp(booking),
                        tooltip: 'Message Customer on WhatsApp',
                      ),
                      // View Details
                      IconButton(
                        icon: const Icon(
                          Icons.visibility_outlined,
                          size: 18,
                          color: AppColors.royalBlue,
                        ),
                        onPressed: () => onViewDetails(booking),
                        tooltip: 'View Booking Info',
                      ),
                      // Delete
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: AppColors.error,
                        ),
                        onPressed: () => onDelete(booking),
                        tooltip: 'Delete Record',
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
        return AppColors.goldDark;
    }
  }
}

class _BookingMobileCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;
  final ValueChanged<BookingStatus> onStatusChange;
  final VoidCallback onWhatsApp;

  const _BookingMobileCard({
    required this.booking,
    required this.onTap,
    required this.onStatusChange,
    required this.onWhatsApp,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.customerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Ref: ${booking.bookingReference}',
                      style: const TextStyle(
                        color: AppColors.royalBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<BookingStatus>(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.navy.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    booking.status.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                onSelected: onStatusChange,
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: BookingStatus.pending,
                    child: Text('Pending'),
                  ),
                  const PopupMenuItem(
                    value: BookingStatus.confirmed,
                    child: Text('Confirm'),
                  ),
                  const PopupMenuItem(
                    value: BookingStatus.completed,
                    child: Text('Complete'),
                  ),
                  const PopupMenuItem(
                    value: BookingStatus.cancelled,
                    child: Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            booking.tourTitle ?? 'Tour inquiry',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${booking.email} • ${booking.phone}',
            style: const TextStyle(color: AppColors.gray600, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.group_outlined,
                  size: 16,
                  color: AppColors.royalBlue,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    booking.formattedTravelersSummary(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.navyDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking.travelDate != null
                    ? DateFormat('MMM dd, yyyy').format(booking.travelDate!)
                    : 'Flexible Date',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 18,
                      color: Color(0xFF25D366),
                    ),
                    onPressed: onWhatsApp,
                  ),
                  TextButton(onPressed: onTap, child: const Text('Details')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

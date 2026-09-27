import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../data/models/booking_model.dart';
import '../cubit/admin_bookings_cubit.dart';

class CustomerSummary {
  final String name;
  final String email;
  final String phone;
  final int totalBookings;
  final int totalTravelers;
  final DateTime? latestBookingDate;
  final List<String> bookedTours;

  const CustomerSummary({
    required this.name,
    required this.email,
    required this.phone,
    required this.totalBookings,
    required this.totalTravelers,
    this.latestBookingDate,
    required this.bookedTours,
  });
}

class AdminCustomersPage extends StatefulWidget {
  const AdminCustomersPage({super.key});

  @override
  State<AdminCustomersPage> createState() => _AdminCustomersPageState();
}

class _AdminCustomersPageState extends State<AdminCustomersPage> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

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

  List<CustomerSummary> _deriveCustomers(List<BookingModel> bookings) {
    final map = <String, CustomerSummary>{};

    for (final b in bookings) {
      final key = b.email.trim().toLowerCase();
      if (!map.containsKey(key)) {
        map[key] = CustomerSummary(
          name: b.customerName,
          email: b.email,
          phone: b.phone,
          totalBookings: 1,
          totalTravelers: b.travelers,
          latestBookingDate: b.createdAt,
          bookedTours: b.tourTitle != null ? [b.tourTitle!] : [],
        );
      } else {
        final existing = map[key]!;
        final tours = List<String>.from(existing.bookedTours);
        if (b.tourTitle != null && !tours.contains(b.tourTitle!)) {
          tours.add(b.tourTitle!);
        }
        map[key] = CustomerSummary(
          name: existing.name,
          email: existing.email,
          phone: existing.phone.isNotEmpty ? existing.phone : b.phone,
          totalBookings: existing.totalBookings + 1,
          totalTravelers: existing.totalTravelers + b.travelers,
          latestBookingDate: (existing.latestBookingDate != null && b.createdAt != null)
              ? (b.createdAt!.isAfter(existing.latestBookingDate!) ? b.createdAt : existing.latestBookingDate)
              : (b.createdAt ?? existing.latestBookingDate),
          bookedTours: tours,
        );
      }
    }

    var list = map.values.toList();
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((c) {
        return c.name.toLowerCase().contains(q) ||
            c.email.toLowerCase().contains(q) ||
            c.phone.toLowerCase().contains(q);
      }).toList();
    }
    list.sort((a, b) => b.totalBookings.compareTo(a.totalBookings));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(context);

    return BlocBuilder<AdminBookingsCubit, AdminBookingsState>(
      builder: (context, state) {
        final customers = _deriveCustomers(state.allBookings);

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
                        Text('Customer Directory', style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('Registered travelers and client reservation history', style: AppTextStyles.bodyMD.copyWith(color: AppColors.gray600)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.navy,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${customers.length} Verified Clients',
                        style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Search Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: InputDecoration(
                      hintText: 'Search clients by name, email, or phone...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Customer List
                Expanded(
                  child: customers.isEmpty
                      ? const Center(child: Text('No customers found.'))
                      : ListView.builder(
                          itemCount: customers.length,
                          itemBuilder: (context, index) {
                            final c = customers[index];
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
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: AppColors.royalBlue.withValues(alpha: 0.15),
                                    child: Text(
                                      c.name.isNotEmpty ? c.name[0].toUpperCase() : 'C',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.royalBlue),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(c.name, style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 2),
                                        Text('${c.email} • ${c.phone}', style: AppTextStyles.caption.copyWith(color: AppColors.gray600)),
                                        if (c.bookedTours.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            'Booked: ${c.bookedTours.join(", ")}',
                                            style: AppTextStyles.caption.copyWith(color: AppColors.navy, fontWeight: FontWeight.w500),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.gold.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${c.totalBookings} ${c.totalBookings == 1 ? "Booking" : "Bookings"}',
                                          style: const TextStyle(color: AppColors.navyDark, fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ),
                                      if (c.latestBookingDate != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Last: ${DateFormat('MMM dd, yyyy').format(c.latestBookingDate!)}',
                                          style: AppTextStyles.caption.copyWith(color: AppColors.gray500, fontSize: 10),
                                        ),
                                      ],
                                    ],
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

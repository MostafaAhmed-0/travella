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
    return BlocBuilder<AdminBookingsCubit, AdminBookingsState>(
      builder: (context, state) {
        final customers = _deriveCustomers(state.allBookings);
        final gap = _gx(context, mobile: 16, tablet: 22, desktop: 28);

        return Scaffold(
          backgroundColor: AppColors.lightGray,
          body: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppBreakpoints.horizontalPadding(context),
              vertical: AppBreakpoints.value<double>(
                context,
                mobile: 16,
                tablet: 22,
                desktop: 28,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final title = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customer Directory',
                          style: _rt(context, AppTextStyles.h3)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Registered travelers and client reservation history',
                          style: _rt(context, AppTextStyles.bodyMD)
                              .copyWith(color: AppColors.gray600),
                        ),
                      ],
                    );
                    final badge = Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.navy,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${customers.length} Verified Clients',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                          fontSize: _rs(context, 13),
                        ),
                      ),
                    );

                    if (constraints.maxWidth < 420) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          title,
                          const SizedBox(height: 12),
                          badge,
                        ],
                      );
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Expanded(child: title), badge],
                    );
                  },
                ),
                SizedBox(height: gap),

                // Search Box
                Container(
                  padding: EdgeInsets.all(
                    AppBreakpoints.value<double>(
                      context,
                      mobile: 12,
                      tablet: 16,
                      desktop: 16,
                    ),
                  ),
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
                      suffixIcon: _searchQuery.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear search',
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _searchQuery = '');
                              },
                            ),
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
                SizedBox(height: gap),

                // Customer List
                Expanded(
                  child: customers.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 420),
                              child: Text(
                                'No customers found.',
                                textAlign: TextAlign.center,
                                style: _rt(context, AppTextStyles.bodyMD),
                              ),
                            ),
                          ),
                        )
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
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final wide = constraints.maxWidth >=
                                      kTableBreakpoint;
                                  final avatar = CircleAvatar(
                                    radius: wide ? 22 : 20,
                                    backgroundColor: AppColors.royalBlue
                                        .withValues(alpha: 0.15),
                                    child: Text(
                                      c.name.isNotEmpty
                                          ? c.name[0].toUpperCase()
                                          : 'C',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.royalBlue,
                                      ),
                                    ),
                                  );
                                  final details = Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.name,
                                        style: _rt(context, AppTextStyles.h6)
                                            .copyWith(
                                                fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${c.email} • ${c.phone}',
                                        style: _rt(context, AppTextStyles.caption)
                                            .copyWith(color: AppColors.gray600),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (c.bookedTours.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Booked: ${c.bookedTours.join(", ")}',
                                          style: _rt(context, AppTextStyles.caption)
                                              .copyWith(
                                            color: AppColors.navy,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  );
                                  final stats = Column(
                                    crossAxisAlignment:
                                        wide
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.gold.withValues(
                                              alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${c.totalBookings} ${c.totalBookings == 1 ? "Booking" : "Bookings"}',
                                          style: TextStyle(
                                            color: AppColors.navyDark,
                                            fontWeight: FontWeight.bold,
                                            fontSize: _rs(context, 12),
                                          ),
                                        ),
                                      ),
                                      if (c.latestBookingDate != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Last: ${DateFormat('MMM dd, yyyy').format(c.latestBookingDate!)}',
                                          style: _rt(
                                            context,
                                            AppTextStyles.caption,
                                          ).copyWith(
                                            color: AppColors.gray500,
                                            fontSize: _rs(context, 10),
                                          ),
                                        ),
                                      ],
                                    ],
                                  );

                                  if (wide) {
                                    return Row(
                                      children: [
                                        avatar,
                                        const SizedBox(width: 16),
                                        Expanded(child: details),
                                        const SizedBox(width: 12),
                                        stats,
                                      ],
                                    );
                                  }
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          avatar,
                                          const SizedBox(width: 12),
                                          Expanded(child: details),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      stats,
                                    ],
                                  );
                                },
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

// ── Local responsive helpers ─────────────────────────────────────────────
/// Below this width, hand-built tables become stacked record cards.
const double kTableBreakpoint = 720;

/// A text style that scales down on small screens.
TextStyle _rt(BuildContext context, TextStyle base) =>
    AppTextStyles.responsive(
      base,
      isMobile: AppBreakpoints.isMobile(context),
      isTablet: AppBreakpoints.isTablet(context),
    );

/// A raw font size that scales down on small screens.
double _rs(BuildContext context, double size) =>
    AppBreakpoints.value<double>(
      context,
      mobile: size * 0.85,
      tablet: size * 0.94,
      desktop: size,
    );

/// A spacing value that follows the device size.
double _gx(
  BuildContext context, {
  double mobile = 12,
  double tablet = 16,
  double desktop = 20,
}) =>
    AppBreakpoints.value<double>(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../data/models/booking_model.dart';
import '../cubit/admin_stats_cubit.dart';
import '../cubit/admin_bookings_cubit.dart';
import '../widgets/admin_stat_card.dart';
import '../widgets/admin_charts.dart';

class AdminDashboardOverviewPage extends StatefulWidget {
  const AdminDashboardOverviewPage({super.key});

  @override
  State<AdminDashboardOverviewPage> createState() =>
      _AdminDashboardOverviewPageState();
}

class _AdminDashboardOverviewPageState
    extends State<AdminDashboardOverviewPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminStatsCubit>().loadDashboardStats();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(context);
    final isTablet = AppBreakpoints.isTablet(context);

    return BlocBuilder<AdminStatsCubit, AdminStatsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          );
        }

        return RefreshIndicator(
          onRefresh: () => context.read<AdminStatsCubit>().loadDashboardStats(),
          color: AppColors.gold,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(isMobile ? 16 : 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header with Quick Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CMS Overview',
                          style: AppTextStyles.h3.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Live system telemetry & Supabase database statistics',
                          style: AppTextStyles.bodyMD.copyWith(
                            color: AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                    if (!isMobile)
                      Row(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gold,
                              foregroundColor: AppColors.navy,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () =>
                                context.goNamed(AppRoutes.adminToursName),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text(
                              'New Tour',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => context
                                .read<AdminStatsCubit>()
                                .loadDashboardStats(),
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Refresh'),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Primary Metrics Grid
                GridView.count(
                  crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 4),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isMobile ? 2.5 : 1.65,
                  children: [
                    AdminStatCard(
                      title: 'Total Tours',
                      value: '${state.totalTours}',
                      subtitle: '${state.activeTours} Active in catalog',
                      icon: Icons.flight_takeoff_rounded,
                      accentColor: AppColors.navy,
                      trend: '+4 this month',
                      onTap: () => context.goNamed(AppRoutes.adminToursName),
                    ),
                    AdminStatCard(
                      title: 'Total Bookings',
                      value: '${state.totalBookings}',
                      subtitle: '${state.pendingBookings} Pending confirmation',
                      icon: Icons.calendar_month_rounded,
                      accentColor: AppColors.royalBlue,
                      trend: '${state.pendingBookings} awaiting',
                      isPositiveTrend: state.pendingBookings == 0,
                      onTap: () => context.goNamed(AppRoutes.adminBookingsName),
                    ),
                    AdminStatCard(
                      title: 'Destinations',
                      value: '${state.totalDestinations}',
                      subtitle: '${state.totalHotels} Luxury Hotels',
                      icon: Icons.place_rounded,
                      accentColor: AppColors.gold,
                      trend: 'Global',
                      onTap: () =>
                          context.goNamed(AppRoutes.adminDestinationsName),
                    ),
                    AdminStatCard(
                      title: 'Est. Revenue',
                      value:
                          '\$${state.totalRevenue.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                      subtitle:
                          '${state.confirmedBookings + state.completedBookings} paid bookings',
                      icon: Icons.attach_money_rounded,
                      accentColor: AppColors.success,
                      trend: '+18.4%',
                      onTap: () => context.goNamed(AppRoutes.adminBookingsName),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Secondary Row of KPI Mini-Cards
                GridView.count(
                  crossAxisCount: isMobile ? 2 : (isTablet ? 2 : 4),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isMobile ? 1.8 : 2.4,
                  children: [
                    _MiniKpiCard(
                      label: 'Hotels Catalog',
                      count: '${state.totalHotels}',
                      icon: Icons.hotel_rounded,
                      color: AppColors.royalBlue,
                      onTap: () => context.goNamed(AppRoutes.adminHotelsName),
                    ),
                    _MiniKpiCard(
                      label: 'Gallery Images',
                      count: '${state.totalGalleryImages}',
                      icon: Icons.photo_library_rounded,
                      color: AppColors.navy,
                      onTap: () => context.goNamed(AppRoutes.adminGalleryName),
                    ),
                    _MiniKpiCard(
                      label: 'Published Blogs',
                      count: '${state.totalBlogs}',
                      icon: Icons.edit_note_rounded,
                      color: AppColors.goldDark,
                      onTap: () => context.goNamed(AppRoutes.adminBlogName),
                    ),
                    _MiniKpiCard(
                      label: 'Partners & Testimonials',
                      count: '${state.totalPartners + state.totalTestimonials}',
                      icon: Icons.handshake_rounded,
                      color: AppColors.coral,
                      onTap: () => context.goNamed(AppRoutes.adminPartnersName),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // ── RESPONSIVE CHARTS ROW ─────────────────────────────────────
                if (isMobile) ...[
                  BookingsOverTimeChart(data: state.monthlyBookings),
                  const SizedBox(height: 20),
                  PopularDestinationsChart(data: state.popularDestinations),
                  const SizedBox(height: 20),
                  TourCategoriesChart(data: state.tourCategories),
                ] else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: BookingsOverTimeChart(
                          data: state.monthlyBookings,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 3,
                        child: TourCategoriesChart(data: state.tourCategories),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  PopularDestinationsChart(data: state.popularDestinations),
                ],
                const SizedBox(height: 28),

                // ── RECENT BOOKINGS TABLE ─────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gray200),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.navy.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recent Bookings',
                                style: AppTextStyles.h5.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Latest traveler reservations and status updates',
                                style: AppTextStyles.bodyXS.copyWith(
                                  color: AppColors.gray500,
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                context.goNamed(AppRoutes.adminBookingsName),
                            icon: const Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                            ),
                            label: const Text('View All Bookings'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      if (state.recentBookings.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
                          alignment: Alignment.center,
                          child: const Text(
                            'No recent bookings recorded yet.',
                            style: TextStyle(color: AppColors.gray500),
                          ),
                        )
                      else if (isMobile)
                        // Mobile Card List
                        Column(
                          children: state.recentBookings
                              .map((b) => _RecentBookingMobileCard(booking: b))
                              .toList(),
                        )
                      else
                        // Desktop Table
                        Table(
                          columnWidths: const {
                            0: FlexColumnWidth(2.5),
                            1: FlexColumnWidth(2.5),
                            2: FlexColumnWidth(2),
                            3: FlexColumnWidth(1.2),
                            4: FlexColumnWidth(1.5),
                            5: FlexColumnWidth(1.5),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                color: AppColors.lightGray,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              children: const [
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    'Customer',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    'Tour / Package',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    'Contact',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    'Travelers',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    'Status',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    'Action',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ...state.recentBookings.map((booking) {
                              return TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 12,
                                    ),
                                    child: Text(
                                      booking.customerName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 12,
                                    ),
                                    child: Text(
                                      booking.tourTitle ?? 'General Inquiry',
                                      style: const TextStyle(fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 12,
                                    ),
                                    child: Text(
                                      booking.email,
                                      style: const TextStyle(
                                        color: AppColors.gray600,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 12,
                                    ),
                                    child: Text(
                                      '${booking.travelers} Guests',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                    child: _StatusPill(status: booking.status),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    child: PopupMenuButton<BookingStatus>(
                                      tooltip: 'Change status',
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: AppColors.gray300,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Update',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_drop_down,
                                              size: 16,
                                            ),
                                          ],
                                        ),
                                      ),
                                      onSelected: (newStatus) async {
                                        await context
                                            .read<AdminBookingsCubit>()
                                            .updateStatus(
                                              booking.id,
                                              newStatus,
                                            );
                                        if (context.mounted) {
                                          context
                                              .read<AdminStatsCubit>()
                                              .loadDashboardStats();
                                        }
                                      },
                                      itemBuilder: (ctx) => [
                                        const PopupMenuItem(
                                          value: BookingStatus.pending,
                                          child: Text('Pending'),
                                        ),
                                        const PopupMenuItem(
                                          value: BookingStatus.confirmed,
                                          child: Text('Confirmed'),
                                        ),
                                        const PopupMenuItem(
                                          value: BookingStatus.completed,
                                          child: Text('Completed'),
                                        ),
                                        const PopupMenuItem(
                                          value: BookingStatus.cancelled,
                                          child: Text('Cancelled'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                    ],
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

class _MiniKpiCard extends StatelessWidget {
  final String label;
  final String count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MiniKpiCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    count,
                    style: AppTextStyles.h5.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.gray600,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final BookingStatus status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (status) {
      case BookingStatus.confirmed:
        bg = AppColors.success.withValues(alpha: 0.12);
        fg = AppColors.success;
        break;
      case BookingStatus.completed:
        bg = AppColors.royalBlue.withValues(alpha: 0.12);
        fg = AppColors.royalBlue;
        break;
      case BookingStatus.cancelled:
        bg = AppColors.error.withValues(alpha: 0.12);
        fg = AppColors.error;
        break;
      case BookingStatus.pending:
      default:
        bg = AppColors.gold.withValues(alpha: 0.15);
        fg = AppColors.goldDark;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label.toUpperCase(),
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _RecentBookingMobileCard extends StatelessWidget {
  final BookingModel booking;

  const _RecentBookingMobileCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  booking.customerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              _StatusPill(status: booking.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            booking.tourTitle ?? 'General Tour Inquiry',
            style: TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking.email,
                style: const TextStyle(color: AppColors.gray600, fontSize: 11),
              ),
              Text(
                '${booking.travelers} Travelers',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

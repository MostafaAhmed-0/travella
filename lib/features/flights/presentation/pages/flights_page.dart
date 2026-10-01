import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/animations/animation_widgets.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../data/repositories/booking_repository.dart';
import '../../../../shared/presentation/widgets/app_navbar.dart';
import '../../../../shared/presentation/widgets/app_footer.dart';
import '../cubit/flight_cubit.dart';
import '../cubit/flight_state.dart';
import '../../data/models/flight_models.dart';
import '../widgets/flight_search_section.dart';
import '../widgets/flight_filters_bar.dart';
import '../widgets/flight_result_card.dart';
import '../widgets/flight_inquiry_dialog.dart';

/// Dedicated Flights Booking & Inquiry Page for Travella (/flights)
class FlightsPage extends StatelessWidget {
  final FlightSearchQuery? initialQuery;

  const FlightsPage({super.key, this.initialQuery});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FlightCubit>(
      create: (context) {
        final query = initialQuery ?? FlightSearchQuery.defaultQuery();
        final cubit = FlightCubit(
          bookingRepository: context.read<BookingRepository>(),
          initialQuery: query,
        );
        // Automatically search if initialQuery was provided from URL / deep link
        if (initialQuery != null) {
          cubit.searchFlights(initialQuery!);
        }
        return cubit;
      },
      child: const _FlightsPageView(),
    );
  }
}

class _FlightsPageView extends StatefulWidget {
  const _FlightsPageView();

  @override
  State<_FlightsPageView> createState() => _FlightsPageState();
}

class _FlightsPageState extends State<_FlightsPageView> {
  String _sortBy = 'Recommended';

  final List<String> _sortOptions = [
    'Recommended',
    'Price: Low to High',
    'Price: High to Low',
    'Shortest Duration',
    'Earliest Departure',
  ];

  void _openMobileFilterSheet(
    BuildContext context,
    FlightLoaded state,
    FlightCubit cubit,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(ctx).height * 0.88,
        ),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: FlightFiltersSidebar(
                  filters: state.filters,
                  availableAirlines: state.availableAirlines,
                  minPrice: state.minFoundPrice,
                  maxPrice: state.maxFoundPrice,
                  onFiltersChanged: (f) {
                    cubit.updateFilters(f);
                    Navigator.pop(ctx);
                  },
                  onReset: () {
                    cubit.resetFilters();
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hPad = AppBreakpoints.horizontalPadding(context);
    final isMobile = AppBreakpoints.isMobile(context);
    final isArabic = context.isArabic;
    final cubit = context.read<FlightCubit>();

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: CustomScrollView(
        slivers: [
          // ── Navbar ────────────────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: AppNavbar(currentRoute: AppRoutes.flights),
          ),

          // ── Header Banner ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.navyDark,
              padding: EdgeInsets.symmetric(
                horizontal: hPad,
                vertical: isMobile ? 40 : 64,
              ),
              child: MaxWidthContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.flight_takeoff_rounded,
                            color: AppColors.gold,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            context.tr('flights_badge'),
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.tr('flights_hero_title'),
                      style: (isMobile ? AppTextStyles.h2 : AppTextStyles.h1)
                          .copyWith(color: AppColors.white),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.tr('flights_hero_subtitle'),
                      style: AppTextStyles.bodyLG.copyWith(
                        color: AppColors.textOnDarkMuted,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Search Section Box
                    BlocBuilder<FlightCubit, FlightState>(
                      builder: (context, state) {
                        FlightSearchQuery activeQuery =
                            FlightSearchQuery.defaultQuery();
                        if (state is FlightInitial) activeQuery = state.query;
                        if (state is FlightLoaded) activeQuery = state.query;
                        if (state is FlightNoResults) activeQuery = state.query;

                        return FlightSearchSection(
                          initialQuery: activeQuery,
                          onSearch: (newQuery) => cubit.searchFlights(newQuery),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Main Content Area with State Management ──────────────────────
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 40),
            sliver: SliverToBoxAdapter(
              child: MaxWidthContainer(
                child: BlocBuilder<FlightCubit, FlightState>(
                  builder: (context, state) {
                    // 1. Initial State
                    if (state is FlightInitial) {
                      return _buildInitialView(
                        context,
                        state.query,
                        isMobile,
                        isArabic,
                      );
                    }

                    // 2. Loading State
                    if (state is FlightLoading) {
                      return _buildLoadingView(state.message, isArabic);
                    }

                    // 3. Inquiry Submitted State (Requirements 6 & 7)
                    if (state is FlightInquirySubmitted) {
                      return _buildInquirySubmittedView(
                        context,
                        state,
                        isMobile,
                        isArabic,
                      );
                    }

                    // 4. No Results State
                    if (state is FlightNoResults) {
                      return _buildNoResultsView(
                        context,
                        state,
                        cubit,
                        isArabic,
                      );
                    }

                    // 5. Error State
                    if (state is FlightError) {
                      return _buildErrorView(context, state, cubit, isArabic);
                    }

                    // 6. Loaded Results State
                    if (state is FlightLoaded) {
                      return _buildLoadedResultsView(
                        context,
                        state,
                        cubit,
                        isMobile,
                        isArabic,
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),

          // ── Footer ────────────────────────────────────────────────────────
          const SliverToBoxAdapter(child: AppFooter()),
        ],
      ),
    );
  }

  // ── 1. Initial State View ──────────────────────────────────────────────────
  Widget _buildInitialView(
    BuildContext context,
    FlightSearchQuery query,
    bool isMobile,
    bool isArabic,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Verified Partners Banner
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.verified_user_rounded,
                    color: AppColors.gold,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isArabic
                          ? 'شراكات حصرية مع كبرى خطوط الطيران العالمية'
                          : 'Official Airline Partnerships & Verified Scheduling',
                      style: AppTextStyles.h4.copyWith(color: AppColors.navyDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                isArabic
                    ? 'يتولى مكتب الطيران في ترافيلا مراجعة جداول ومسارات الرحلات وحجز أفضل الدرجات والتذاكر المضمونة دون أسعار وهمية.'
                    : 'Travella’s certified air travel specialists verify flight schedules, direct routing, and premium seating directly with global airline desks.',
                style: AppTextStyles.bodyMD.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Feature Cards
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildBenefitPill(
                    icon: Icons.airline_seat_flat_angled_rounded,
                    title: isArabic
                        ? 'أفضل درجات السفر'
                        : 'Premium Cabin Access',
                    desc: isArabic
                        ? 'أرقى درجات الأعمال والأولى'
                        : 'First & Business class specials',
                  ),
                  _buildBenefitPill(
                    icon: Icons.support_agent_rounded,
                    title: isArabic
                        ? 'مستشار حجز خاص 24/7'
                        : '24/7 Air Concierge',
                    desc: isArabic
                        ? 'متابعة التعديلات وتحديد المقاعد'
                        : 'Seat allocation & schedule changes',
                  ),
                  _buildBenefitPill(
                    icon: Icons.luggage_rounded,
                    title: isArabic
                        ? 'أعلى وزن أمتعة مجاني'
                        : 'Generous Baggage',
                    desc: isArabic
                        ? 'عروض وزن إضافي مسبق'
                        : 'Verified allowance on direct flights',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Curated Popular Flight Routes
        Text(
          isArabic
              ? 'أشهر المسارات والرحلات الأكثر طلباً'
              : 'Popular & Curated Flight Routes',
          style: AppTextStyles.h3.copyWith(color: AppColors.navyDark),
        ),
        const SizedBox(height: 16),
        _buildPopularRoutesGrid(context, isMobile, isArabic),
      ],
    );
  }

  Widget _buildBenefitPill({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.royalBlueFaded,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.royalBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelMD.copyWith(
                    color: AppColors.navyDark,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  desc,
                  style: AppTextStyles.bodySM.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularRoutesGrid(
    BuildContext context,
    bool isMobile,
    bool isArabic,
  ) {
    final routes = [
      (
        'Cairo (CAI)',
        'Istanbul (IST)',
        'EgyptAir / Turkish Airlines',
        '3h 20m Direct',
      ),
      ('Cairo (CAI)', 'Dubai (DXB)', 'Emirates / EgyptAir', '3h 30m Direct'),
      ('Cairo (CAI)', 'Riyadh (RUH)', 'Saudia / Flynas', '2h 35m Direct'),
      (
        'Cairo (CAI)',
        'London (LHR)',
        'British Airways / EgyptAir',
        '5h 15m Direct',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 2,
        mainAxisExtent: 100,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: routes.length,
      itemBuilder: (ctx, i) {
        final r = routes[i];
        return InkWell(
          onTap: () {
            final q = FlightSearchQuery(
              origin: r.$1,
              destination: r.$2,
              departureDate: DateTime.now().add(const Duration(days: 14)),
              returnDate: DateTime.now().add(const Duration(days: 21)),
              tripType: TripType.roundTrip,
            );
            context.read<FlightCubit>().searchFlights(q);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${r.$1} ➔ ${r.$2}',
                        style: AppTextStyles.labelLG.copyWith(
                          color: AppColors.navyDark,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${r.$3} • ${r.$4}',
                        style: AppTextStyles.bodySM.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.royalBlue,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── 2. Loading State View ──────────────────────────────────────────────────
  Widget _buildLoadingView(String? message, bool isArabic) {
    return Container(
      height: 400,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.gold,
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            message ??
                (isArabic
                    ? 'جاري فحص المسارات وتوافر التذاكر...'
                    : 'Searching verified flights and availability...'),
            style: AppTextStyles.h4.copyWith(color: AppColors.navyDark),
          ),
          const SizedBox(height: 8),
          Text(
            isArabic
                ? 'نتحقق من أفضل الأسعار والمسارات المباشرة مع شركات الطيران'
                : 'Verifying schedule availability with official airline partner desks',
            style: AppTextStyles.bodyMD.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. Inquiry Submitted Success View (Requirements 6 & 7) ─────────────────
  Widget _buildInquirySubmittedView(
    BuildContext context,
    FlightInquirySubmitted state,
    bool isMobile,
    bool isArabic,
  ) {
    final df = DateFormat('EEE, dd MMM yyyy');

    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 48),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.08),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.successGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.successGreen,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            context.tr('flight_inquiry_success_title'),
            textAlign: TextAlign.center,
            style: (isMobile ? AppTextStyles.h3 : AppTextStyles.h2).copyWith(
              color: AppColors.navyDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.tr('flight_inquiry_success_desc'),
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLG.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // Reference Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.gold, width: 1.5),
            ),
            child: Column(
              children: [
                Text(
                  isArabic
                      ? 'الرقم المرجعي للاستفسار'
                      : 'FLIGHT INQUIRY REFERENCE',
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.textLightMuted,
                    letterSpacing: 2.0,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state.referenceCode,
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.navyDark,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Summary details card
          Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                _buildSummaryRow(
                  isArabic ? 'المسار المطلوب:' : 'Route:',
                  '${state.query.origin} ➔ ${state.query.destination}',
                ),
                const Divider(height: 20),
                _buildSummaryRow(
                  isArabic ? 'نوع الرحلة:' : 'Trip Type:',
                  state.query.isRoundTrip
                      ? (isArabic ? 'ذهاب وعودة' : 'Round Trip')
                      : (isArabic ? 'اتجاه واحد' : 'One Way'),
                ),
                const Divider(height: 20),
                _buildSummaryRow(
                  isArabic ? 'تاريخ الذهاب:' : 'Departure Date:',
                  df.format(state.query.departureDate),
                ),
                if (state.query.isRoundTrip &&
                    state.query.returnDate != null) ...[
                  const Divider(height: 20),
                  _buildSummaryRow(
                    isArabic ? 'تاريخ العودة:' : 'Return Date:',
                    df.format(state.query.returnDate!),
                  ),
                ],
                const Divider(height: 20),
                _buildSummaryRow(
                  isArabic ? 'المسافرون:' : 'Travelers:',
                  state.query.travelersFormattedSummary(isArabic: isArabic),
                ),
                const Divider(height: 20),
                _buildSummaryRow(
                  isArabic ? 'درجة السفر:' : 'Cabin Class:',
                  state.query.cabinClass,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Action Buttons
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  final msg = Uri.encodeComponent(
                    'Hello Travella, I just submitted flight inquiry ${state.referenceCode} (${state.query.origin} to ${state.query.destination}). Please assist me with flight options.',
                  );
                  launchUrl(
                    Uri.parse('https://wa.me/201000000000?text=$msg'),
                    mode: LaunchMode.externalApplication,
                  );
                },
                icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                label: Text(
                  isArabic ? 'متابعة عبر واتساب' : 'Chat on WhatsApp',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.successGreen,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => context.read<FlightCubit>().resetToInitial(),
                icon: const Icon(Icons.search_rounded, size: 18),
                label: Text(isArabic ? 'بحث جديد' : 'New Flight Search'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => context.goNamed(AppRoutes.homeName),
                icon: const Icon(Icons.home_rounded, size: 18),
                label: Text(isArabic ? 'العودة للرئيسية' : 'Back to Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceLight,
                  foregroundColor: AppColors.navyDark,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.borderLight),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySM.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTextStyles.labelMD.copyWith(
              color: AppColors.navyDark,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ── 4. No Results View ─────────────────────────────────────────────────────
  Widget _buildNoResultsView(
    BuildContext context,
    FlightNoResults state,
    FlightCubit cubit,
    bool isArabic,
  ) {
    return Container(
      padding: const EdgeInsets.all(40),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.flight_takeoff_rounded,
            color: AppColors.gray400,
            size: 60,
          ),
          const SizedBox(height: 18),
          Text(
            isArabic
                ? 'لا توجد رحلات مطابقة لمعايير الفلترة'
                : 'No Flights Found',
            style: AppTextStyles.h3.copyWith(color: AppColors.navyDark),
          ),
          const SizedBox(height: 8),
          Text(
            state.reason,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMD.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            children: [
              TravellaButton(
                label: context.tr('filter_reset'),
                variant: TravellaButtonVariant.secondary,
                onPressed: () => cubit.resetFilters(),
              ),
              TravellaButton(
                label: isArabic
                    ? 'طلب استفسار مخصص'
                    : 'Submit Custom Flight Request',
                variant: TravellaButtonVariant.gold,
                onPressed: () =>
                    showFlightInquiryDialog(context, query: state.query),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 5. Error View ──────────────────────────────────────────────────────────
  Widget _buildErrorView(
    BuildContext context,
    FlightError state,
    FlightCubit cubit,
    bool isArabic,
  ) {
    return Container(
      padding: const EdgeInsets.all(40),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.errorRed,
            size: 56,
          ),
          const SizedBox(height: 16),
          Text(
            isArabic ? 'حدث خطأ أثناء تحميل الرحلات' : 'Error Loading Flights',
            style: AppTextStyles.h3.copyWith(color: AppColors.navyDark),
          ),
          const SizedBox(height: 8),
          Text(
            state.message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMD.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          TravellaButton(
            label: isArabic ? 'إعادة المحاولة' : 'Retry Search',
            variant: TravellaButtonVariant.primary,
            onPressed: () {
              if (state.query != null) {
                cubit.searchFlights(state.query!);
              } else {
                cubit.resetToInitial();
              }
            },
          ),
        ],
      ),
    );
  }

  // ── 6. Loaded Results View ─────────────────────────────────────────────────
  Widget _buildLoadedResultsView(
    BuildContext context,
    FlightLoaded state,
    FlightCubit cubit,
    bool isMobile,
    bool isArabic,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results Subheader: Counts & Sorting
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${state.query.origin} ➔ ${state.query.destination}',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.navyDark,
                      fontSize: isMobile ? 16 : 22,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${state.filteredOffers.length} ${isArabic ? 'رحلات متاحة' : 'verified airline itineraries'}',
                    style: AppTextStyles.bodySM.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isMobile) ...[
                  IconButton.filledTonal(
                    onPressed: () =>
                        _openMobileFilterSheet(context, state, cubit),
                    icon: const Icon(Icons.tune_rounded, size: 20),
                    tooltip: isArabic ? 'تصفية النتائج' : 'Filter',
                  ),
                  const SizedBox(width: 8),
                ],
                DropdownButtonHideUnderline(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: DropdownButton<String>(
                      value: _sortBy,
                      icon: const Icon(
                        Icons.sort_rounded,
                        color: AppColors.royalBlue,
                        size: 18,
                      ),
                      items: _sortOptions.map((s) {
                        return DropdownMenuItem<String>(
                          value: s,
                          child: Text(s, style: AppTextStyles.labelSM),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _sortBy = val);
                          cubit.updateFilters(
                            state.filters.copyWith(sortBy: val),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Layout: Sidebar Filters + Flight Cards List
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Desktop Filters Sidebar
            if (!isMobile)
              SizedBox(
                width: 290,
                child: FlightFiltersSidebar(
                  filters: state.filters,
                  availableAirlines: state.availableAirlines,
                  minPrice: state.minFoundPrice,
                  maxPrice: state.maxFoundPrice,
                  onFiltersChanged: (f) => cubit.updateFilters(f),
                  onReset: () => cubit.resetFilters(),
                ),
              ),

            if (!isMobile) const SizedBox(width: 28),

            // Right Column: Result Cards List
            Expanded(
              child: Column(
                children: [
                  ...List.generate(state.filteredOffers.length, (i) {
                    final offer = state.filteredOffers[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: SlideInOnScroll(
                        delay: Duration(milliseconds: (i % 3) * 60),
                        child: FlightResultCard(
                          offer: offer,
                          isMobile: isMobile,
                          onSelect: () => showFlightInquiryDialog(
                            context,
                            query: state.query,
                            selectedOffer: offer,
                          ),
                          onViewDetails: () => showFlightInquiryDialog(
                            context,
                            query: state.query,
                            selectedOffer: offer,
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // Custom Route Inquiry Box
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.navyDark,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: isMobile
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.gold.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.flight_takeoff_rounded,
                                      color: AppColors.gold,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      isArabic
                                          ? 'تبحث عن رحلة خاصة أو خط طيران آخر؟'
                                          : 'Need a Custom Route?',
                                      style: AppTextStyles.h4.copyWith(
                                        color: AppColors.white,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                isArabic
                                    ? 'أرسل طلبك لفريق المستشارين للبحث في كافة جداول الطيران العالمية وتزويدك بأفضل عرض.'
                                    : 'Submit a custom flight request to our air travel desk for special charters, offline routes, or group fares.',
                                style: AppTextStyles.bodySM.copyWith(
                                  color: AppColors.textOnDarkMuted,
                                ),
                              ),
                              const SizedBox(height: 14),
                              TravellaButton(
                                label: isArabic ? 'طلب استفسار خاص' : 'Custom Request',
                                variant: TravellaButtonVariant.gold,
                                fullWidth: true,
                                onPressed: () => showFlightInquiryDialog(
                                  context,
                                  query: state.query,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.flight_takeoff_rounded,
                                  color: AppColors.gold,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isArabic
                                          ? 'تبحث عن رحلة خاصة أو خط طيران آخر؟'
                                          : 'Need a Specific Airline or Custom Routing?',
                                      style: AppTextStyles.h4.copyWith(
                                        color: AppColors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isArabic
                                          ? 'أرسل طلبك لفريق المستشارين للبحث في كافة جداول الطيران العالمية وتزويدك بأفضل عرض.'
                                          : 'Submit a custom flight request to our air travel desk for special charters, offline routes, or group fares.',
                                      style: AppTextStyles.bodySM.copyWith(
                                        color: AppColors.textOnDarkMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              TravellaButton(
                                label: isArabic ? 'طلب استفسار خاص' : 'Custom Request',
                                variant: TravellaButtonVariant.gold,
                                onPressed: () => showFlightInquiryDialog(
                                  context,
                                  query: state.query,
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

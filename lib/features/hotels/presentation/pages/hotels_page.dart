import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/traveler_selector.dart';
import '../../../../core/animations/animation_widgets.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../data/models/hotel_model.dart';
import '../../../../data/repositories/hotel_repository.dart';
import '../../../../shared/presentation/widgets/app_navbar.dart';
import '../../../../shared/presentation/widgets/app_footer.dart';
import '../../../bookings/presentation/cubit/booking_cubit.dart';
import '../cubit/hotels_cubit.dart';
import '../cubit/hotels_state.dart';
import '../widgets/hotel_search_section.dart';
import '../widgets/hotel_filters_sidebar.dart';
import '../widgets/hotel_card.dart';
import '../widgets/hotel_booking_dialog.dart';

class HotelsPage extends StatelessWidget {
  final String? initialDestination;
  final String? checkIn;
  final String? checkOut;
  final int? adults;
  final int? children;
  final int? rooms;

  const HotelsPage({
    super.key,
    this.initialDestination,
    this.checkIn,
    this.checkOut,
    this.adults,
    this.children,
    this.rooms,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = HotelsCubit(hotelRepository: HotelRepository());
        final parsedCheckIn = checkIn != null
            ? DateTime.tryParse(checkIn!)
            : null;
        final parsedCheckOut = checkOut != null
            ? DateTime.tryParse(checkOut!)
            : null;
        final travelers = TravelerSelection(
          adults: adults ?? 2,
          children: children ?? 0,
          childAges: const [],
          rooms: rooms ?? 1,
        );

        cubit.loadHotels(
          destination: initialDestination,
          checkIn: parsedCheckIn,
          checkOut: parsedCheckOut,
          travelers: travelers,
        );
        return cubit;
      },
      child: const _HotelsPageView(),
    );
  }
}

class _HotelsPageView extends StatefulWidget {
  const _HotelsPageView();

  @override
  State<_HotelsPageView> createState() => _HotelsPageViewState();
}

class _HotelsPageViewState extends State<_HotelsPageView> {
  bool _isTabletFiltersExpanded = false;

  void _openMobileFilterSheet(BuildContext context, HotelsState state) {
    final hotelsCubit = context.read<HotelsCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        final isArabic = modalCtx.isArabic;
        return BlocProvider.value(
          value: hotelsCubit,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(modalCtx).size.height * 0.88,
            ),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Modal Handle & Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.borderLight),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isArabic ? 'تصفية نتائج الفنادق' : 'Filter Hotels',
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.navyDark,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.gray500,
                          ),
                          onPressed: () => Navigator.pop(modalCtx),
                        ),
                      ],
                    ),
                  ),
                  // Filter Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: BlocBuilder<HotelsCubit, HotelsState>(
                        builder: (ctx, currentState) {
                          return HotelFiltersSidebar(
                            state: currentState,
                            isCompact: true,
                            onDestinationChanged: hotelsCubit.updateDestination,
                            onPriceRangeChanged: hotelsCubit.updatePriceRange,
                            onToggleStarRating: hotelsCubit.toggleStarRating,
                            onToggleAmenity: hotelsCubit.toggleAmenity,
                            onSortByChanged: hotelsCubit.updateSortBy,
                            onResetFilters: hotelsCubit.resetFilters,
                          );
                        },
                      ),
                    ),
                  ),
                  // Apply Button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TravellaButton(
                      label: isArabic ? 'عرض النتائج' : 'Show Results',
                      variant: TravellaButtonVariant.gold,
                      size: TravellaButtonSize.lg,
                      fullWidth: true,
                      onPressed: () => Navigator.pop(modalCtx),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openBookingDialog(
    BuildContext context,
    HotelModel hotel,
    HotelsState state,
  ) {
    final bookingCubit = context.read<BookingCubit>();
    final now = DateTime.now().add(const Duration(days: 7));
    final checkIn = state.checkIn ?? now;
    final checkOut = state.checkOut ?? checkIn.add(const Duration(days: 5));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BlocProvider.value(
        value: bookingCubit,
        child: HotelBookingDialog(
          hotel: hotel,
          checkIn: checkIn,
          checkOut: checkOut,
          travelers: state.travelers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hPad = AppBreakpoints.horizontalPadding(context);
    final isMobile = AppBreakpoints.isMobile(context);
    final isTablet = AppBreakpoints.isTablet(context);
    final isArabic = context.isArabic;

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: BlocBuilder<HotelsCubit, HotelsState>(
        builder: (context, state) {
          final cubit = context.read<HotelsCubit>();

          return CustomScrollView(
            slivers: [
              // 1. Navigation Bar
              const SliverToBoxAdapter(
                child: AppNavbar(currentRoute: AppRoutes.hotels),
              ),

              // 2. Luxury Hero Banner
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
                            color: AppColors.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.hotel_rounded,
                                color: AppColors.gold,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isArabic
                                    ? 'إقامات ومنتجعات فاخرة'
                                    : 'LUXURY ACCOMMODATIONS',
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
                          isArabic
                              ? 'أفخم الفنادق والمنتجعات العالمية'
                              : 'Luxury Hotels & Resorts',
                          style:
                              (isMobile ? AppTextStyles.h2 : AppTextStyles.h1)
                                  .copyWith(color: AppColors.white),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isArabic
                              ? 'باقة مختارة بعناية من أرقى المنتجعات الشاطئية والفلل المائية وقصور الضيافة التاريخية حول العالم.'
                              : 'Handpicked 5-star beachfront resorts, overwater villas, and historic palace sanctuaries verified by Travella.',
                          style: AppTextStyles.bodyLG.copyWith(
                            color: AppColors.textOnDarkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Search Section Bar (Overhanging hero)
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.navyDark,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 24),
                    child: MaxWidthContainer(
                      child: HotelSearchSection(
                        initialDestination: state.destination,
                        initialCheckIn: state.checkIn,
                        initialCheckOut: state.checkOut,
                        initialTravelers: state.travelers,
                        onSearch:
                            ({
                              required destination,
                              required checkIn,
                              required checkOut,
                              required travelers,
                            }) {
                              cubit.updateDates(checkIn, checkOut);
                              cubit.updateTravelers(travelers);
                              cubit.updateDestination(destination);
                            },
                      ),
                    ),
                  ),
                ),
              ),

              // 4. Tablet Filter Accordion or Mobile Trigger
              if (isTablet || isMobile)
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: hPad,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      border: Border(
                        bottom: BorderSide(color: AppColors.borderLight),
                      ),
                    ),
                    child: MaxWidthContainer(
                      child: isMobile
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      isArabic
                                          ? 'النتائج المتاحة:'
                                          : 'Available Hotels:',
                                      style: AppTextStyles.labelMD.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${state.filteredHotels.length}',
                                      style: AppTextStyles.h5.copyWith(
                                        color: AppColors.navyDark,
                                      ),
                                    ),
                                  ],
                                ),
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      _openMobileFilterSheet(context, state),
                                  icon: const Icon(
                                    Icons.tune_rounded,
                                    size: 16,
                                  ),
                                  label: Row(
                                    children: [
                                      Text(isArabic ? 'الفلاتر' : 'Filters'),
                                      if (state.totalActiveFiltersCount >
                                          0) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.royalBlue,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            '${state.totalActiveFiltersCount}',
                                            style: const TextStyle(
                                              color: AppColors.white,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.navyDark,
                                    side: const BorderSide(
                                      color: AppColors.borderLight,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          isArabic
                                              ? 'النتائج المتاحة:'
                                              : 'Available Hotels:',
                                          style: AppTextStyles.labelMD.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${state.filteredHotels.length}',
                                          style: AppTextStyles.h5.copyWith(
                                            color: AppColors.navyDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _isTabletFiltersExpanded =
                                              !_isTabletFiltersExpanded;
                                        });
                                      },
                                      icon: Icon(
                                        _isTabletFiltersExpanded
                                            ? Icons.keyboard_arrow_up_rounded
                                            : Icons.tune_rounded,
                                        size: 18,
                                      ),
                                      label: Text(
                                        _isTabletFiltersExpanded
                                            ? (isArabic
                                                  ? 'إخفاء الفلاتر'
                                                  : 'Hide Filters')
                                            : (isArabic
                                                  ? 'تعديل الفلاتر'
                                                  : 'Adjust Filters'),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.navyDark,
                                        side: const BorderSide(
                                          color: AppColors.borderLight,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_isTabletFiltersExpanded) ...[
                                  const SizedBox(height: 14),
                                  HotelFiltersSidebar(
                                    state: state,
                                    isCompact: true,
                                    onDestinationChanged:
                                        cubit.updateDestination,
                                    onPriceRangeChanged: cubit.updatePriceRange,
                                    onToggleStarRating: cubit.toggleStarRating,
                                    onToggleAmenity: cubit.toggleAmenity,
                                    onSortByChanged: cubit.updateSortBy,
                                    onResetFilters: cubit.resetFilters,
                                  ),
                                ],
                              ],
                            ),
                    ),
                  ),
                ),

              // 5. Main Content Area (Desktop Sidebar + Results / Tablet & Mobile Results)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 36),
                sliver: SliverToBoxAdapter(
                  child: MaxWidthContainer(
                    child: isMobile || isTablet
                        ? _buildResultsList(
                            context,
                            state,
                            isMobile: isMobile,
                            isArabic: isArabic,
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Desktop Filters Sidebar
                              SizedBox(
                                width: 280,
                                child: HotelFiltersSidebar(
                                  state: state,
                                  onDestinationChanged: cubit.updateDestination,
                                  onPriceRangeChanged: cubit.updatePriceRange,
                                  onToggleStarRating: cubit.toggleStarRating,
                                  onToggleAmenity: cubit.toggleAmenity,
                                  onSortByChanged: cubit.updateSortBy,
                                  onResetFilters: cubit.resetFilters,
                                ),
                              ),
                              const SizedBox(width: 28),

                              // Desktop Results Grid
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Results Count & Sorting Header
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          isArabic
                                              ? 'تم العثور على (${state.filteredHotels.length}) فندق ومنتجع'
                                              : 'Found (${state.filteredHotels.length}) Luxury Hotels & Resorts',
                                          style: AppTextStyles.h4.copyWith(
                                            color: AppColors.navyDark,
                                            fontSize: 18,
                                          ),
                                        ),
                                        if (state.totalActiveFiltersCount > 0)
                                          TextButton.icon(
                                            onPressed: cubit.resetFilters,
                                            icon: const Icon(
                                              Icons.refresh_rounded,
                                              size: 16,
                                            ),
                                            label: Text(
                                              isArabic
                                                  ? 'مسح الفلاتر'
                                                  : 'Clear Filters',
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    _buildResultsList(
                                      context,
                                      state,
                                      isMobile: false,
                                      isArabic: isArabic,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              // 6. Footer
              const SliverToBoxAdapter(child: AppFooter()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResultsList(
    BuildContext context,
    HotelsState state, {
    required bool isMobile,
    required bool isArabic,
  }) {
    // 1. Loading State
    if (state.isLoading) {
      return SizedBox(
        height: 380,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.royalBlue),
              const SizedBox(height: 18),
              Text(
                isArabic
                    ? 'جاري استرجاع أفخم الفنادق والمنتجعات من قاعدة البيانات...'
                    : 'Loading luxury hotels directly from Supabase...',
                style: AppTextStyles.bodyMD.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 2. Error State (No Silent Mock Fallback)
    if (state.hasError) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.errorRed,
                  size: 48,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                isArabic ? 'فشل تحميل بيانات الفنادق' : 'Failed to Load Hotels',
                style: AppTextStyles.h3.copyWith(color: AppColors.navyDark),
              ),
              const SizedBox(height: 8),
              Text(
                state.errorMessage ??
                    (isArabic
                        ? 'حدث خطأ في الاتصال بالخادم'
                        : 'A server error occurred.'),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMD.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              TravellaButton(
                label: isArabic ? 'إعادة المحاولة' : 'Retry',
                leadingIcon: Icons.refresh_rounded,
                variant: TravellaButtonVariant.primary,
                onPressed: () {
                  context.read<HotelsCubit>().loadHotels(
                    destination: state.destination,
                    checkIn: state.checkIn,
                    checkOut: state.checkOut,
                    travelers: state.travelers,
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    // 3. Empty / No Results State
    if (state.isNoResults || state.filteredHotels.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.royalBlueFaded,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hotel_rounded,
                  color: AppColors.royalBlue,
                  size: 48,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                isArabic
                    ? 'لا توجد فنادق مطابقة لمعايير البحث'
                    : 'No Matching Hotels Found',
                style: AppTextStyles.h3.copyWith(color: AppColors.navyDark),
              ),
              const SizedBox(height: 8),
              Text(
                isArabic
                    ? 'يرجى تجربة تعديل الوجهة أو توسيع نطاق السعر أو إزالة بعض المرافق المحددة.'
                    : 'Try broadening your destination keyword, adjusting the price range, or resetting filters.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMD.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              TravellaButton(
                label: isArabic
                    ? 'إعادة ضبط كافة الفلاتر'
                    : 'Reset All Filters',
                variant: TravellaButtonVariant.secondary,
                leadingIcon: Icons.restart_alt_rounded,
                onPressed: () => context.read<HotelsCubit>().resetFilters(),
              ),
            ],
          ),
        ),
      );
    }

    // 4. Loaded Results Grid
    final columns = isMobile ? 1 : (AppBreakpoints.isTablet(context) ? 1 : 2);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisExtent: isMobile ? 400 : 390,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: state.filteredHotels.length,
      itemBuilder: (context, i) {
        final hotel = state.filteredHotels[i];
        return ScaleInOnScroll(
          delay: Duration(milliseconds: (i % 3) * 70),
          child: HotelCard(
            hotel: hotel,
            isMobile: isMobile,
            onBook: () => _openBookingDialog(context, hotel, state),
          ),
        );
      },
    );
  }
}

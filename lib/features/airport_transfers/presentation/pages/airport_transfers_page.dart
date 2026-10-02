import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/traveler_selector.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../data/models/airport_transfer_model.dart';
import '../../../../data/repositories/airport_transfer_repository.dart';
import '../../../../shared/presentation/widgets/app_navbar.dart';
import '../../../../shared/presentation/widgets/app_footer.dart';
import '../cubit/transfers_cubit.dart';
import '../cubit/transfers_state.dart';
import '../widgets/transfer_search_section.dart';
import '../widgets/transfer_vehicle_card.dart';
import '../widgets/transfer_booking_dialog.dart';
import '../widgets/transfer_filters_sheet.dart';
import '../widgets/transfer_trust_section.dart';

class AirportTransfersPage extends StatelessWidget {
  final String? initialPickup;
  final String? initialDropoff;
  final String? initialType;
  final int? initialAdults;
  final int? initialChildren;

  const AirportTransfersPage({
    super.key,
    this.initialPickup,
    this.initialDropoff,
    this.initialType,
    this.initialAdults,
    this.initialChildren,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) {
        final repository = ctx.read<AirportTransferRepository>();
        final cubit = TransfersCubit(transferRepository: repository);

        if (initialPickup != null || initialDropoff != null) {
          cubit.updateSearchLocations(
            pickup: initialPickup ?? cubit.state.pickupLocation,
            dropoff: initialDropoff ?? cubit.state.dropoffLocation,
          );
        }

        if (initialType != null) {
          cubit.updateTransferType(TransferType.fromString(initialType));
        }

        if (initialAdults != null || initialChildren != null) {
          cubit.updatePassengers(TravelerSelection(
            adults: initialAdults ?? 2,
            children: initialChildren ?? 0,
            childAges: const [],
          ));
        }

        cubit.loadVehicles();
        return cubit;
      },
      child: const _AirportTransfersPageView(),
    );
  }
}

class _AirportTransfersPageView extends StatefulWidget {
  const _AirportTransfersPageView();

  @override
  State<_AirportTransfersPageView> createState() => _AirportTransfersPageViewState();
}

class _AirportTransfersPageViewState extends State<_AirportTransfersPageView> {
  void _openBookingModal(BuildContext context, TransferVehicleModel vehicle, TransfersState state) {
    final cubit = context.read<TransfersCubit>();
    TransferBookingDialog.show(
      context,
      vehicle: vehicle,
      state: state,
      cubit: cubit,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;
    final hPad = AppBreakpoints.horizontalPadding(context);
    final isMobile = AppBreakpoints.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: CustomScrollView(
        slivers: [
          // 1. App Navbar
          SliverToBoxAdapter(
            child: AppNavbar(currentRoute: AppRoutes.airportTransfers),
          ),

          // 2. Hero Section + Dynamic Search Box
          SliverToBoxAdapter(
            child: Stack(
              children: [
                // Hero Background
                Container(
                  width: double.infinity,
                  height: isMobile ? 380 : 440,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.navyDark,
                        AppColors.navy,
                        Color(0xFF0F2B48),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Subtle glow decoration
                      Positioned(
                        top: -60,
                        right: -60,
                        child: Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.gold.withValues(alpha: 0.12),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -40,
                        left: -40,
                        child: Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.royalBlue.withValues(alpha: 0.1),
                          ),
                        ),
                      ),

                      // Hero Content
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: isMobile ? 32 : 54),
                        child: MaxWidthContainer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                                ),
                                child: Text(
                                  context.tr('transfers_badge'),
                                  style: const TextStyle(
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                context.tr('transfers_hero_title'),
                                style: (isMobile ? AppTextStyles.h4 : AppTextStyles.h2).copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 720),
                                child: Text(
                                  context.tr('transfers_hero_subtitle'),
                                  style: AppTextStyles.bodyMD.copyWith(
                                    color: AppColors.textOnDarkMuted,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Floating Search Section Overhanging
                Padding(
                  padding: EdgeInsets.fromLTRB(hPad, isMobile ? 240 : 270, hPad, 0),
                  child: MaxWidthContainer(
                    child: BlocBuilder<TransfersCubit, TransfersState>(
                      builder: (context, state) {
                        return TransferSearchSection(
                          state: state,
                          cubit: context.read<TransfersCubit>(),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Spacing buffer below search section
          const SliverToBoxAdapter(
            child: SizedBox(height: 48),
          ),

          // 4. Results Header & Controls
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: MaxWidthContainer(
                child: BlocBuilder<TransfersCubit, TransfersState>(
                  builder: (context, state) {
                    final count = state.filteredVehicles.length;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? 'السيارات وخيارات التوصيل المتاحة' : 'Available Transfer Options',
                              style: AppTextStyles.h5.copyWith(
                                color: AppColors.navyDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isArabic
                                  ? 'تم العثور على $count خيار توصيل معتمد'
                                  : 'Showing $count verified executive options',
                              style: AppTextStyles.bodySM.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        // Filter & Sort Button
                        TravellaButton(
                          label: isArabic ? 'تصفية وترتيب' : 'Filter & Sort',
                          variant: TravellaButtonVariant.outline,
                          size: TravellaButtonSize.sm,
                          leadingIcon: Icons.tune_rounded,
                          onPressed: () => TransferFiltersSheet.show(
                            context,
                            state,
                            context.read<TransfersCubit>(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),

          // 5. Results Vehicle Cards List / Loading / Empty State
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: MaxWidthContainer(
                child: BlocBuilder<TransfersCubit, TransfersState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 60),
                          child: CircularProgressIndicator(color: AppColors.gold),
                        ),
                      );
                    }

                    if (state.errorMessage != null && state.allVehicles.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 40),
                            const SizedBox(height: 12),
                            Text(state.errorMessage!, style: AppTextStyles.bodyMD),
                            const SizedBox(height: 16),
                            TravellaButton(
                              label: isArabic ? 'إعادة المحاولة' : 'Retry',
                              variant: TravellaButtonVariant.gold,
                              size: TravellaButtonSize.sm,
                              onPressed: () => context.read<TransfersCubit>().loadVehicles(),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state.filteredVehicles.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.gray200),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.directions_car_filled_rounded, color: AppColors.goldDark, size: 32),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isArabic ? 'لا توجد سيارات مطابقة لهذه المعايير' : 'No Vehicles Match Your Exact Criteria',
                              style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold, color: AppColors.navyDark),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isArabic
                                  ? 'جرب تقليل عدد الأمتعة أو زيادة ميزانية السعر لعرض كافة الخيارات.'
                                  : 'Try adjusting your luggage count, passenger count, or price filter.',
                              style: AppTextStyles.bodySM.copyWith(color: AppColors.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            TravellaButton(
                              label: isArabic ? 'إعادة تعيين المرشحات' : 'Reset All Filters',
                              variant: TravellaButtonVariant.gold,
                              size: TravellaButtonSize.sm,
                              onPressed: () {
                                final cubit = context.read<TransfersCubit>();
                                cubit.updateVehicleTypeFilter('all');
                                cubit.updateMaxPrice(500);
                                cubit.updateLuggage(1);
                              },
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: state.filteredVehicles.map((vehicle) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: TransferVehicleCard(
                            vehicle: vehicle,
                            currentTransferType: state.transferType,
                            onBook: () => _openBookingModal(context, vehicle, state),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
          ),

          // 6. Transfer Trust & Feature Highlights
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: const MaxWidthContainer(
                child: TransferTrustSection(),
              ),
            ),
          ),

          // 7. Transfer FAQs Accordion
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 32),
              child: MaxWidthContainer(
                child: _buildTransferFAQ(isArabic),
              ),
            ),
          ),

          // 8. Footer
          const SliverToBoxAdapter(
            child: AppFooter(),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferFAQ(bool isArabic) {
    final faqs = [
      (
        isArabic ? 'كيف أجد سائقي عند الوصول للمطار؟' : 'Where will I meet my driver at the airport?',
        isArabic
            ? 'سيكون سائقك الخاص بانتظارك في صالة الوصول بعد منطقة استلام الحقائب والجمارك حاملاً لوحة باسمك بوضوح.'
            : 'Your chauffeur will be waiting inside the arrivals hall just after baggage claim, holding a personalized sign with your name.',
      ),
      (
        isArabic ? 'ماذا يحدث إذا تأخرت رحلتي الجوية؟' : 'What happens if my flight is delayed?',
        isArabic
            ? 'نحن نتابع رحلتك تلقائياً عبر رقم الرحلة. سيقوم السائق بضبط وقت وصوله مجاناً بدون أي رسوم إضافية.'
            : 'We track your flight in real-time using your flight number. Your driver will automatically adjust their arrival time free of charge.',
      ),
      (
        isArabic ? 'هل السعر يشمل رسوم الانتظار وبوابات المرور؟' : 'Are tolls and airport parking fees included in the price?',
        isArabic
            ? 'نعم، جميع الأسعار نهائية وثابتة وتشمل كافة الضرائب، رسوم الطرق، ورسوم مواقف وانتظار المطار.'
            : 'Yes, all our prices are fixed and all-inclusive. Road tolls, taxes, and airport parking fees are covered.',
      ),
      (
        isArabic ? 'هل يمكن طلب كراسي أطفال للأمان؟' : 'Can I request child booster seats?',
        isArabic
            ? 'نعم بالتأكيد! يمكنك تحديد عدد وأعمار الأطفال في نموذج الحجز وسنوفر مقاعد الأمان المناسبة.'
            : 'Absolutely! Simply specify your children’s ages during the booking step and we will equip your vehicle with certified child safety seats.',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'الأسئلة الشائعة حول توصيل المطار' : 'Frequently Asked Questions',
            style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold, color: AppColors.navyDark),
          ),
          const SizedBox(height: 16),
          ...faqs.map(
            (faq) => ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(
                faq.$1,
                style: AppTextStyles.bodyMD.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.navyDark,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    faq.$2,
                    style: AppTextStyles.bodySM.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

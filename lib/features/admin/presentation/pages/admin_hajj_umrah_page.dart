import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../data/models/tour_model.dart';
import '../cubit/admin_tours_cubit.dart';
import '../widgets/admin_dialogs.dart';

class AdminHajjUmrahPage extends StatefulWidget {
  const AdminHajjUmrahPage({super.key});

  @override
  State<AdminHajjUmrahPage> createState() => _AdminHajjUmrahPageState();
}

class _AdminHajjUmrahPageState extends State<AdminHajjUmrahPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminToursCubit>().loadTours();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(context);

    return BlocBuilder<AdminToursCubit, AdminToursState>(
      builder: (context, state) {
        final hajjUmrahTours = state.allTours
            .where((t) => t.type == TourType.hajj || t.type == TourType.umrah)
            .toList();

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
                        Text('Hajj & Umrah Pilgrimage Packages', style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('Specialized spiritual travel packages, Makkah & Madinah 5-star accommodations', style: AppTextStyles.bodyMD.copyWith(color: AppColors.gray600)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Stats Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.navyDark, AppColors.navyMedium],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.mosque_rounded, color: AppColors.gold, size: 32),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pilgrimage Service Directory',
                              style: AppTextStyles.h5.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'VIP packages with Haramain High-Speed Train, Clock Tower suites, and scholar guides.',
                              style: AppTextStyles.bodySM.copyWith(color: AppColors.gray300),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${hajjUmrahTours.length} Packages Active',
                          style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                      : hajjUmrahTours.isEmpty
                          ? const Center(child: Text('No Hajj or Umrah packages found.'))
                          : ListView.builder(
                              itemCount: hajjUmrahTours.length,
                              itemBuilder: (context, index) {
                                final tour = hajjUmrahTours[index];
                                final isHajj = tour.type == TourType.hajj;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 14),
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.gray200),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          tour.imageUrl,
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            width: 90,
                                            height: 90,
                                            color: AppColors.gray200,
                                            child: const Icon(Icons.mosque),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 18),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: (isHajj ? AppColors.navy : AppColors.goldDark).withValues(alpha: 0.15),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    isHajj ? 'HAJJ PACKAGE' : 'UMRAH PACKAGE',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      color: isHajj ? AppColors.navy : AppColors.goldDark,
                                                    ),
                                                  ),
                                                ),
                                                if (tour.badge != null) ...[
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.gold.withValues(alpha: 0.2),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      tour.badge!,
                                                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.goldDark),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(tour.title, style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold)),
                                            if (tour.titleAr != null)
                                              Text(tour.titleAr!, style: const TextStyle(color: AppColors.gray600, fontSize: 12), textDirection: TextDirection.rtl),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Duration: ${tour.duration} • Inclusions: ${tour.included.join(", ")}',
                                              style: AppTextStyles.caption.copyWith(color: AppColors.gray600),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Price click to edit
                                      InkWell(
                                        onTap: () async {
                                          final newPrice = await showAdminPriceEditDialog(
                                            context: context,
                                            itemName: tour.title,
                                            currentPrice: tour.price,
                                            currency: tour.currency,
                                          );
                                          if (newPrice != null && context.mounted) {
                                            await context.read<AdminToursCubit>().updatePrice(tour.id, newPrice, currency: tour.currency);
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: AppColors.gold.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                '${tour.currency} ${tour.price.toInt()}',
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.navyDark),
                                              ),
                                              const Text('Edit Price', style: TextStyle(fontSize: 10, color: AppColors.gray600)),
                                            ],
                                          ),
                                        ),
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

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/app_translations.dart';

class TransferTrustSection extends StatelessWidget {
  const TransferTrustSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 650 && screenWidth < 1024;

    final features = [
      (
        Icons.flight_takeoff_rounded,
        isArabic ? 'متابعة مباشرة للرحلات' : 'Flight Tracking Included',
        isArabic
            ? 'نراقب توقيت هبوط رحلتك تلقائياً ونعدل موعد السائق حتى في حال تأخر الطائرة دون أي تكلفة إضافية.'
            : 'We track your flight in real-time and adjust pickup times for delays automatically at zero extra cost.',
      ),
      (
        Icons.badge_outlined,
        isArabic ? 'استقبال شخصي بالاسم' : 'VIP Meet & Greet',
        isArabic
            ? 'سائقك المحترف ينتظرك في صالة الوصول حاملاً لوحة تحمل اسمك للمساعدة في حمل الحقائب.'
            : 'Your chauffeur awaits inside arrivals holding a personalized name board and assists with all luggage.',
      ),
      (
        Icons.price_check_rounded,
        isArabic ? 'أسعار شفافة وثابتة' : 'Fixed All-Inclusive Fares',
        isArabic
            ? 'لا توجد أي رسوم خفية أو مفاجآت في الزحام. السعر المعروض يشمل الضرائب ورسوم الانتظار.'
            : 'Transparent fixed rates with no surge pricing or hidden fees. Tolls, taxes, and airport wait time included.',
      ),
      (
        Icons.support_agent_rounded,
        isArabic ? 'خدمة عملاء 24/7' : '24/7 Dedicated Support',
        isArabic
            ? 'فريق عمليات وخدمة عملاء متواجد على مدار الساعة عبر الواتساب والهاتف لضمان راحتك.'
            : 'Our round-the-clock concierge desk is always available via WhatsApp and phone for immediate assistance.',
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
            ),
            child: Text(
              isArabic ? 'لماذا تختار ترافيلا لتوصيل المطار؟' : 'THE TRAVELLA TRANSFER ADVANTAGE',
              style: const TextStyle(
                color: AppColors.goldDark,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isArabic ? 'راحة بال من صالة الوصول إلى باب فندقك' : 'Seamless Journey From Terminal to Doorstep',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.navyDark,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),

          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: features
                  .map((f) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: _buildFeatureCard(f.$1, f.$2, f.$3),
                        ),
                      ))
                  .toList(),
            )
          else if (isTablet)
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: features
                  .map((f) => SizedBox(
                        width: (screenWidth - 72) / 2,
                        child: _buildFeatureCard(f.$1, f.$2, f.$3),
                      ))
                  .toList(),
            )
          else
            Column(
              children: features
                  .map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildFeatureCard(f.$1, f.$2, f.$3),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.navyDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.gold, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.bodyMD.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.navyDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: AppTextStyles.bodySM.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PolicyDialogs {
  PolicyDialogs._();

  static void showPrivacyPolicy(BuildContext context, {bool isArabic = false}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.royalBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.privacy_tip_rounded, color: AppColors.royalBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isArabic ? 'سياسة الخصوصية وحماية البيانات' : 'Privacy & Data Protection Policy',
                style: AppTextStyles.h5.copyWith(color: AppColors.navyDark),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 550,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic
                    ? 'في شركة ترافيلا، نلتزم بحماية خصوصية عملائنا وأمان بياناتهم الشخصية أثناء إجراء الحجوزات أو التقديم على التأشيرات.'
                    : 'At Travella Tour & Travel, we are committed to safeguarding your personal data and ensuring strict confidentiality across all travel bookings and visa processing.',
                  style: AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary, height: 1.6),
                ),
                const SizedBox(height: 16),
                _section(
                  isArabic ? '١. جمع البيانات الشخصية' : '1. Information We Collect',
                  isArabic
                    ? 'نقوم بجمع بيانات الاسم الكامل، البريد الإلكتروني، ورقم الهاتف/الواتساب لغرض إتمام وتأكيد الحجوزات وتقديم الدعم المطلوب.'
                    : 'We collect your name, email address, phone number, and passport/travel dates solely for issuing bookings, vouchers, and visa documents.',
                ),
                _section(
                  isArabic ? '٢. أمان البيانات والتشفير' : '2. Security & Confidentiality',
                  isArabic
                    ? 'يتم تخزين كافة البيانات عبر قواعد بيانات سحابية مشفرة ومحمية بأنظمة التحقق الثنائي.'
                    : 'All submitted information is transmitted via TLS encryption and stored in secure, role-guarded enterprise databases.',
                ),
                _section(
                  isArabic ? '٣. عدم مشاركة البيانات' : '3. Third-Party Policy',
                  isArabic
                    ? 'لا نقوم ببيع أو تأجير بياناتك لأي جهات إعلانية إطلاقاً.'
                    : 'We never sell or rent your personal information to third-party marketing services.',
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text(isArabic ? 'إغلاق' : 'Close'),
          ),
        ],
      ),
    );
  }

  static void showTermsOfService(BuildContext context, {bool isArabic = false}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.gavel_rounded, color: AppColors.goldDark),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isArabic ? 'شروط وأحكام الخدمة' : 'Terms of Service',
                style: AppTextStyles.h5.copyWith(color: AppColors.navyDark),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 550,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic
                    ? 'تحدد هذه الوثيقة الشروط والأحكام التي تحكم حجز الجولات السياحية، تذاكر الطيران، الفنادق وتوصيل المطار لدى ترافيلا.'
                    : 'These Terms of Service govern all tour bookings, flight inquiries, hotel reservations, and VIP airport transfers arranged through Travella.',
                  style: AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary, height: 1.6),
                ),
                const SizedBox(height: 16),
                _section(
                  isArabic ? '١. تأكيد الحجوزات' : '1. Reservation Confirmations',
                  isArabic
                    ? 'تعتبر الطلبات المقدمة عبر الموقع مبدئية حتى يتم مراجعتها وتأكيدها رسمياً من فريق خدمة العملاء.'
                    : 'Inquiries submitted through the portal are pending until reviewed and confirmed with an official booking voucher.',
                ),
                _section(
                  isArabic ? '٢. سياسة الإلغاء والتعديل' : '2. Cancellation & Modifications',
                  isArabic
                    ? 'تخضع شروط الإلغاء لسياسات الفنادق وشركات الطيران المنظمة لكل برنامج سياحي على حدة.'
                    : 'Cancellation and refund policies are subject to individual airline and partner hotel terms communicated upon confirmation.',
                ),
                _section(
                  isArabic ? '٣. خدمات التأشيرات وتوصيل المطار' : '3. Visa Services & Transfers',
                  isArabic
                    ? 'تقوم ترافيلا بتجهيز ومراجعة ملفات التأشيرات وفق المتطلبات الرسمية للسفارات.'
                    : 'Travella prepares and verifies visa requirements according to official embassy guidelines.',
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.navyDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text(isArabic ? 'إغلاق' : 'Close'),
          ),
        ],
      ),
    );
  }

  static Widget _section(String heading, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.navyDark)),
          const SizedBox(height: 4),
          Text(text, style: const TextStyle(fontSize: 13, color: AppColors.gray700, height: 1.5)),
        ],
      ),
    );
  }
}

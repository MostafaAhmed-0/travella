import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/animations/animation_widgets.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/utils/external_link_helper.dart';
import '../../../../data/models/site_settings_model.dart';
import '../../../site_settings/presentation/cubit/site_settings_cubit.dart';
import '../../../../shared/presentation/widgets/app_navbar.dart';
import '../../../../shared/presentation/widgets/app_footer.dart';
import '../../../../shared/presentation/widgets/social_links_bar.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  String _selectedService = 'General Inquiry';
  bool _isSubmitting = false;

  final List<String> _serviceOptions = [
    'General Inquiry',
    'Tour Packages & Bespoke Trips',
    'Flight Booking Assistance',
    'Luxury Hotel Reservation',
    'VIP Airport Transfers',
    'Visa Services & Documents',
    'Hajj & Umrah Packages',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitMessage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    // Simulate server response
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    final isAr = context.isArabic;
    final name = _nameCtrl.text.trim();

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
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isAr ? 'تم استلام رسالتك بنجاح' : 'Message Sent Successfully',
                style: AppTextStyles.h5.copyWith(color: AppColors.navyDark),
              ),
            ),
          ],
        ),
        content: Text(
          isAr
              ? 'شكراً لك، $name! تم إرسال رسالتك إلى مستشاري السفر لدى ترافيلا. سنقوم بالرد عليك خلال ساعات العمل الرسمية.'
              : 'Thank you, $name! Your message has been received by our travel concierge desk. We will respond promptly within official business hours.',
          style: AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.navyDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _nameCtrl.clear();
              _emailCtrl.clear();
              _phoneCtrl.clear();
              _messageCtrl.clear();
            },
            child: Text(isAr ? 'حسناً' : 'Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hPad = AppBreakpoints.horizontalPadding(context);
    final isMobile = AppBreakpoints.isMobile(context);
    final settings = context.watch<SiteSettingsCubit?>()?.state.settings ??
        SiteSettingsModel.initial();

    final isAr = context.isArabic;

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: AppNavbar(currentRoute: AppRoutes.contact),
          ),

          // ── Header Hero Banner ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: hPad,
                vertical: isMobile ? 48 : 80,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF071224),
                    AppColors.navyDark,
                    AppColors.royalBlueDark,
                    AppColors.navy,
                  ],
                ),
              ),
              child: MaxWidthContainer(
                child: SlideInOnScroll(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionBadge(
                        text: isAr ? 'خدمة العملاء والاستشارات' : 'Concierge & Inquiries',
                        color: AppColors.gold.withValues(alpha: 0.15),
                        textColor: AppColors.gold,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isAr ? 'تواصل مع خبراء السفر لدى ترافيلا' : 'Get in Touch with Travella',
                        style: (isMobile ? AppTextStyles.h2 : AppTextStyles.displayLG)
                            .copyWith(color: AppColors.white, height: 1.2),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isAr
                            ? 'سواء كنت ترغب في حجز رحلة جديدة، الاستفسار عن تأشيرة، أو تصميم برنامج سياحي مخصص، فريقنا هنا لمساعدتك على مدار الساعة.'
                            : 'Whether you are planning a bespoke itinerary, inquiring about visa requirements, or need private transfers, our travel specialists are ready to help.',
                        style: AppTextStyles.bodyLG.copyWith(
                          color: AppColors.textOnDarkMuted,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Main Content Body ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: hPad,
                vertical: isMobile ? 40 : 64,
              ),
              child: MaxWidthContainer(
                child: Column(
                  children: [
                    // 1. Quick Communication Cards Grid
                    _buildContactCardsGrid(context, settings, isMobile, isAr),
                    const SizedBox(height: 56),

                    // 2. Dedicated Social Media Hub
                    _buildSocialMediaSection(context, settings, isMobile, isAr),
                    const SizedBox(height: 56),

                    // 3. Message Inquiry Form & Office Details
                    if (isMobile) ...[
                      _buildInquiryForm(context, isAr),
                      const SizedBox(height: 36),
                      _buildOfficeDetailsCard(context, settings, isAr),
                    ] else ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 7, child: _buildInquiryForm(context, isAr)),
                          const SizedBox(width: 32),
                          Expanded(flex: 5, child: _buildOfficeDetailsCard(context, settings, isAr)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: AppFooter(),
          ),
        ],
      ),
    );
  }

  // ── Quick Contact Cards ──────────────────────────────────────────────────
  Widget _buildContactCardsGrid(
    BuildContext context,
    SiteSettingsModel settings,
    bool isMobile,
    bool isAr,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = isMobile ? 1 : (constraints.maxWidth < 900 ? 2 : 4);

        final items = [
          _QuickContactCard(
            icon: Icons.chat_bubble_rounded,
            title: isAr ? 'واتساب المباشر' : 'WhatsApp Concierge',
            value: settings.whatsappNumber,
            actionLabel: isAr ? 'محادثة فورية' : 'Chat on WhatsApp',
            color: const Color(0xFF25D366),
            onAction: () => ExternalLinkHelper.openWhatsApp(
              rawPhoneOrUrl: settings.whatsappNumber,
              message: 'Hello Travella! I would like to inquire about your travel services.',
            ),
          ),
          _QuickContactCard(
            icon: Icons.phone_in_talk_rounded,
            title: isAr ? 'الاتصال الهاتفي' : 'Phone Support',
            value: settings.phoneNumber,
            actionLabel: isAr ? 'اتصل الآن' : 'Call Support',
            color: AppColors.royalBlue,
            onAction: () => ExternalLinkHelper.openPhone(settings.phoneNumber),
          ),
          _QuickContactCard(
            icon: Icons.email_rounded,
            title: isAr ? 'البريد الإلكتروني' : 'Official Email',
            value: settings.supportEmail,
            actionLabel: isAr ? 'إرسال بريد' : 'Send Email',
            color: AppColors.navy,
            onAction: () => ExternalLinkHelper.openEmail(settings.supportEmail),
          ),
          _QuickContactCard(
            icon: Icons.location_on_rounded,
            title: isAr ? 'المقر الرئيسي' : 'Headquarters',
            value: isAr ? settings.cairoAddressAr : settings.cairoAddress,
            actionLabel: isAr ? 'حجز موعد' : 'Book Consultation',
            color: AppColors.goldDark,
            onAction: () => context.goNamed(AppRoutes.bookingName),
          ),
        ];

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isMobile ? 2.5 : 1.3,
          children: items,
        );
      },
    );
  }

  // ── Social Media Section ─────────────────────────────────────────────────
  Widget _buildSocialMediaSection(
    BuildContext context,
    SiteSettingsModel settings,
    bool isMobile,
    bool isAr,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 24 : 36),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyDark.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.share_rounded, color: AppColors.goldDark, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'منصات التواصل الاجتماعي الرسمية' : 'Connect on Social Media',
                      style: AppTextStyles.h4.copyWith(color: AppColors.navyDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAr
                          ? 'تابعنا لمشاهدة أحدث العروض، الوجهات السياحية وتجارب المسافرين اليومية'
                          : 'Follow Travella across verified channels for real-time promotions and travel stories',
                      style: AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Verified Facebook Card highlight
          if (settings.hasFacebook)
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1877F2).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1877F2).withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1877F2),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: FaIcon(FontAwesomeIcons.facebookF, color: Colors.white, size: 22),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              isAr ? 'الصفحة الرسمية على فيسبوك' : 'Official Facebook Page',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppColors.navyDark,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.verified_rounded, color: Color(0xFF1877F2), size: 16),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          settings.facebookUrl,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.gray600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1877F2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onPressed: () => ExternalLinkHelper.openExternalUrl(settings.facebookUrl),
                    icon: const Icon(Icons.open_in_new_rounded, size: 16),
                    label: Text(isAr ? 'زيارة الصفحة' : 'Open Page'),
                  ),
                ],
              ),
            ),

          // Complete dynamic social links bar
          Wrap(
            spacing: 16,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                isAr ? 'روابط المنصات السريعة:' : 'Quick Social Links:',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navyDark),
              ),
              SocialLinksBar(
                variant: SocialLinksVariant.card,
                iconSize: 18,
                spacing: 12,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Inquiry Form ─────────────────────────────────────────────────────────
  Widget _buildInquiryForm(BuildContext context, bool isAr) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyDark.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAr ? 'أرسل استفسارك وسنعاود الاتصال بك' : 'Send an Inquiry / Custom Request',
              style: AppTextStyles.h4.copyWith(color: AppColors.navyDark),
            ),
            const SizedBox(height: 6),
            Text(
              isAr
                  ? 'يرجى تزويدنا ببياناتك وتفاصيل رحلتك وسيقوم مستشارك السياحي بالرد خلال ٢٤ ساعة.'
                  : 'Fill in your details below and a Travella travel advisor will contact you within 24 hours.',
              style: AppTextStyles.bodyMD.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // Name
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: isAr ? 'الاسم بالكامل *' : 'Full Name *',
                prefixIcon: const Icon(Icons.person_outline_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? (isAr ? 'يرجى إدخال الاسم' : 'Please enter your name')
                  : null,
            ),
            const SizedBox(height: 16),

            // Email & Phone
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _emailCtrl,
                    decoration: InputDecoration(
                      labelText: isAr ? 'البريد الإلكتروني *' : 'Email Address *',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return isAr ? 'يرجى إدخال البريد الإلكتروني' : 'Email is required';
                      }
                      if (!v.contains('@')) {
                        return isAr ? 'بريد إلكتروني غير صالح' : 'Invalid email format';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TextFormField(
                    controller: _phoneCtrl,
                    decoration: InputDecoration(
                      labelText: isAr ? 'رقم الهاتف / واتساب *' : 'Phone / WhatsApp *',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? (isAr ? 'يرجى إدخال رقم الهاتف' : 'Phone is required')
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Service Dropdown
            DropdownButtonFormField<String>(
              value: _selectedService,
              decoration: InputDecoration(
                labelText: isAr ? 'نوع الخدمة المطلوبة' : 'Interested Service',
                prefixIcon: const Icon(Icons.category_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _serviceOptions
                  .map((svc) => DropdownMenuItem(value: svc, child: Text(svc)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedService = val);
              },
            ),
            const SizedBox(height: 16),

            // Message
            TextFormField(
              controller: _messageCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: isAr ? 'تفاصيل الاستفسار أو الرحلة *' : 'Inquiry / Trip Details *',
                hintText: isAr
                    ? 'مثال: عدد المسافرين، تواريخ السفر المقترحة، والوجهة المرغوبة...'
                    : 'E.g., Number of travelers, estimated travel dates, dream destinations...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => (v == null || v.trim().length < 8)
                  ? (isAr ? 'يرجى كتابة تفاصيل الاستفسار' : 'Please provide more details')
                  : null,
            ),
            const SizedBox(height: 24),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.navyDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                onPressed: _isSubmitting ? null : _submitMessage,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.navyDark),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(
                  isAr ? 'إرسال الاستفسار الآن' : 'Submit Travel Inquiry',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Office Details Card ──────────────────────────────────────────────────
  Widget _buildOfficeDetailsCard(
    BuildContext context,
    SiteSettingsModel settings,
    bool isAr,
  ) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.navyDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.business_rounded, color: AppColors.navyDark, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                isAr ? 'ساعات العمل والمقر' : 'Headquarters & Hours',
                style: AppTextStyles.h5.copyWith(color: AppColors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.navyMedium),
          const SizedBox(height: 16),

          _officeDetailRow(
            Icons.access_time_rounded,
            isAr ? 'ساعات العمل' : 'Working Hours',
            isAr
                ? 'الأحد - الخميس: 9:00 ص - 9:00 م\nالجمعة والسبت: 10:00 ص - 6:00 م'
                : 'Sun - Thu: 9:00 AM - 9:00 PM\nFri - Sat: 10:00 AM - 6:00 PM',
          ),
          const SizedBox(height: 16),

          _officeDetailRow(
            Icons.support_agent_rounded,
            isAr ? 'دعم الطوارئ 24/7' : '24/7 VIP Concierge',
            isAr
                ? 'خدمة الاستجابة السريعة متوفرة على مدار الساعة للعملاء المسافرين عبر واتساب'
                : 'Emergency in-transit assistance available 24/7 via dedicated WhatsApp line',
          ),
          const SizedBox(height: 16),

          _officeDetailRow(
            Icons.pin_drop_rounded,
            isAr ? 'العنوان' : 'Office Location',
            isAr ? settings.cairoAddressAr : settings.cairoAddress,
          ),
          const SizedBox(height: 28),

          // Direct WhatsApp button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: const BorderSide(color: Color(0xFF25D366)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => ExternalLinkHelper.openWhatsApp(
              rawPhoneOrUrl: settings.whatsappNumber,
              message: 'Hello Travella VIP concierge desk!',
            ),
            icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Color(0xFF25D366), size: 18),
            label: Text(
              isAr ? 'تواصل معنا مباشرة عبر واتساب' : 'Direct WhatsApp Chat',
              style: const TextStyle(color: Color(0xFF25D366), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _officeDetailRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.gold, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(color: AppColors.textOnDarkMuted, fontSize: 12, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickContactCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;
  final String actionLabel;
  final Color color;
  final VoidCallback onAction;

  const _QuickContactCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.actionLabel,
    required this.color,
    required this.onAction,
  });

  @override
  State<_QuickContactCard> createState() => _QuickContactCardState();
}

class _QuickContactCardState extends State<_QuickContactCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _hovered ? widget.color.withValues(alpha: 0.5) : AppColors.borderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: _hovered
                  ? widget.color.withValues(alpha: 0.12)
                  : AppColors.navyDark.withValues(alpha: 0.04),
              blurRadius: _hovered ? 20 : 10,
              offset: Offset(0, _hovered ? 6 : 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.navyDark),
                  ),
                ),
              ],
            ),
            Text(
              widget.value,
              style: AppTextStyles.bodyMD.copyWith(fontWeight: FontWeight.w600, color: AppColors.navyDark),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            InkWell(
              onTap: widget.onAction,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.actionLabel,
                      style: TextStyle(
                        color: widget.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, color: widget.color, size: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

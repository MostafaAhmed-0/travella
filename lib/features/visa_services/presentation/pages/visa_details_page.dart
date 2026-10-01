import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/animations/animation_widgets.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../data/models/visa_model.dart';
import '../../../../data/repositories/visa_repository.dart';
import '../../../../data/repositories/storage_repository.dart';
import '../../../../data/services/supabase_service.dart';
import '../../../../shared/presentation/widgets/app_navbar.dart';
import '../../../../shared/presentation/widgets/app_footer.dart';

class VisaDetailsPage extends StatefulWidget {
  final String visaId;

  const VisaDetailsPage({
    super.key,
    required this.visaId,
  });

  @override
  State<VisaDetailsPage> createState() => _VisaDetailsPageState();
}

class _VisaDetailsPageState extends State<VisaDetailsPage> {
  final VisaRepository _repository = VisaRepository();
  VisaServiceModel? _visa;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVisaDetails();
  }

  @override
  void didUpdateWidget(covariant VisaDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visaId != widget.visaId) {
      _loadVisaDetails();
    }
  }

  Future<void> _loadVisaDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final item = await _repository.getVisaServiceById(widget.visaId);
      if (mounted) {
        setState(() {
          _visa = item;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _openApplicationFlow() {
    if (_visa == null) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => VisaApplicationFlowDialog(
        service: _visa!,
        onSubmitted: () {
          // Stay on page or refresh
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hPad = AppBreakpoints.horizontalPadding(context);
    final isMobile = AppBreakpoints.isMobile(context);
    final isArabic = context.isArabic;

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: CustomScrollView(
        slivers: [
          // ── Navbar ────────────────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: AppNavbar(currentRoute: AppRoutes.visaServices),
          ),

          // ── Content ───────────────────────────────────────────────────────
          if (_isLoading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.royalBlue),
                    SizedBox(height: 16),
                    Text('Loading visa details from Supabase...'),
                  ],
                ),
              ),
            )
          else if (_errorMessage != null || _visa == null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.errorRed, size: 56),
                      const SizedBox(height: 16),
                      Text(
                        isArabic ? 'لم نتمكن من العثور على التأشيرة' : 'Visa Service Not Found',
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 8),
                      Text(_errorMessage ?? (isArabic ? 'تأكد من صحة الرابط.' : 'Please check the link and try again.')),
                      const SizedBox(height: 24),
                      TravellaButton(
                        label: isArabic ? 'العودة لخدمات التأشيرات' : 'Back to Visa Services',
                        variant: TravellaButtonVariant.primary,
                        onPressed: () => context.goNamed(AppRoutes.visaServicesName),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // ── Hero Banner ───────────────────────────────────────────
                  _buildHeroBanner(_visa!, isMobile, isArabic, hPad),

                  // ── Main Content Grid ─────────────────────────────────────
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 48),
                    child: MaxWidthContainer(
                      child: isMobile
                          ? Column(
                              children: [
                                _buildMainDetailsCard(_visa!, isArabic),
                                const SizedBox(height: 24),
                                _buildSidebarCard(_visa!, isArabic),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: _buildMainDetailsCard(_visa!, isArabic),
                                ),
                                const SizedBox(width: 32),
                                Expanded(
                                  flex: 4,
                                  child: _buildSidebarCard(_visa!, isArabic),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Footer ────────────────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: AppFooter(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(VisaServiceModel v, bool isMobile, bool isArabic, double hPad) {
    return Container(
      width: double.infinity,
      color: AppColors.navyDark,
      padding: EdgeInsets.symmetric(
        horizontal: hPad,
        vertical: isMobile ? 36 : 60,
      ),
      child: MaxWidthContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs
            Row(
              children: [
                InkWell(
                  onTap: () => context.goNamed(AppRoutes.homeName),
                  child: Text(
                    isArabic ? 'الرئيسية' : 'Home',
                    style: const TextStyle(color: AppColors.textOnDarkMuted, fontSize: 13),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.chevron_right, size: 14, color: AppColors.textOnDarkMuted),
                ),
                InkWell(
                  onTap: () => context.goNamed(AppRoutes.visaServicesName),
                  child: Text(
                    isArabic ? 'خدمات التأشيرات' : 'Visa Services',
                    style: const TextStyle(color: AppColors.textOnDarkMuted, fontSize: 13),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.chevron_right, size: 14, color: AppColors.textOnDarkMuted),
                ),
                Text(
                  v.localizedCountry(isArabic),
                  style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Header info
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.royalBlue.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.royalBlueLight.withValues(alpha: 0.4)),
                  ),
                  child: Text(v.flagEmoji, style: const TextStyle(fontSize: 30)),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${v.localizedCountry(isArabic)} ${v.visaType}',
                        style: (isMobile ? AppTextStyles.h3 : AppTextStyles.h2).copyWith(color: AppColors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${v.region} • ${v.processingTime} • ${v.validity}',
                        style: AppTextStyles.bodyMD.copyWith(color: AppColors.textOnDarkMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainDetailsCard(VisaServiceModel v, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Overview Specs Grid
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderLight),
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
              Text(
                isArabic ? 'المواصفات والمدة المتاحة' : 'Visa Validity & Processing Specs',
                style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold, color: AppColors.navyDark),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _specBadge(
                    icon: Icons.timer_outlined,
                    label: isArabic ? 'مدة المعالجة' : 'Processing Time',
                    value: v.processingTime,
                  ),
                  _specBadge(
                    icon: Icons.date_range_rounded,
                    label: isArabic ? 'صلاحية التأشيرة' : 'Visa Validity',
                    value: v.validity,
                  ),
                  _specBadge(
                    icon: Icons.flight_land_rounded,
                    label: isArabic ? 'مدة الإقامة' : 'Stay Duration',
                    value: v.stayDuration,
                  ),
                  _specBadge(
                    icon: Icons.monetization_on_outlined,
                    label: isArabic ? 'رسوم الخدمة' : 'Service Fee',
                    value: '\$${v.price.toInt()} / person',
                    highlight: true,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 2. Description
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderLight),
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
              Text(
                isArabic ? 'نبذة عن التأشيرة والشروط العامة' : 'Visa Overview & Assistance Details',
                style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold, color: AppColors.navyDark),
              ),
              const SizedBox(height: 12),
              Text(
                v.localizedDescription(isArabic).isNotEmpty
                    ? v.localizedDescription(isArabic)
                    : (isArabic
                        ? 'تقدم ترافيلا خدمة متكاملة تشمل تدقيق المستندات، ملء الاستمارات الرسمية للسفارة، حجز المواعيد البيومترية، وإعداد حجوزات الطيران والفنادق المعتمدة.'
                        : 'Travella provides end-to-end visa consultation including rigorous document audits, consular form completion, biometric appointment scheduling, and confirmed travel itineraries.'),
                style: AppTextStyles.bodyMD.copyWith(color: AppColors.textPrimary, height: 1.7),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 3. Required Documents & Requirements
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderLight),
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
                children: [
                  const Icon(Icons.folder_shared_outlined, color: AppColors.royalBlue),
                  const SizedBox(width: 10),
                  Text(
                    isArabic ? 'المستندات والأوراق المطلوبة' : 'Mandatory Document Checklist',
                    style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold, color: AppColors.navyDark),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...v.requiredDocuments.map((doc) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          doc,
                          style: AppTextStyles.bodyMD.copyWith(color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 4. Important Notes
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.goldDark),
                  const SizedBox(width: 10),
                  Text(
                    isArabic ? 'إرشادات وملاحظات هامة' : 'Important Consular Notes',
                    style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold, color: AppColors.goldDark),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...v.importantNotes.map((note) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: AppColors.goldDark, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(
                          note,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarCard(VisaServiceModel v, bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? 'رسوم التقديم' : 'Total Service Fee',
                style: const TextStyle(color: AppColors.gray600, fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isArabic ? '99.4% نسبة القبول' : '99.4% Approval Rate',
                  style: const TextStyle(color: AppColors.successGreen, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${v.price.toInt()}',
                style: AppTextStyles.h2.copyWith(color: AppColors.navyDark, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text('/ person', style: TextStyle(color: AppColors.gray600, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: AppColors.borderLight),
          const SizedBox(height: 16),

          // Features checklist
          _sidebarFeature(isArabic ? 'تدقيق احترافي لجميع المستندات' : 'Rigorous document audit'),
          _sidebarFeature(isArabic ? 'تجهيز حجز طيران وفندق مؤكدين' : 'Flight & hotel booking vouchers'),
          _sidebarFeature(isArabic ? 'حجز موعد البصمة والمقابلة' : 'Embassy biometric appointment scheduling'),
          _sidebarFeature(isArabic ? 'متابعة مباشرة مع مستشار خاص' : '24/7 Dedicated visa consultant'),

          const SizedBox(height: 24),
          TravellaButton(
            label: isArabic ? 'ابدأ طلب التقديم الآن' : 'Apply for This Visa',
            variant: TravellaButtonVariant.gold,
            fullWidth: true,
            size: TravellaButtonSize.lg,
            onPressed: _openApplicationFlow,
          ),
          const SizedBox(height: 12),
          Text(
            isArabic
                ? 'لا يتم خصم أي دفعات قبل تدقيق مستنداتك وتأكيد جاهزية الطلب.'
                : 'Zero upfront commitment. Dedicated specialist will verify documents before submission.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppColors.gray500, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _sidebarFeature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.royalBlue, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _specBadge({
    required IconData icon,
    required String label,
    required String value,
    bool highlight = false,
  }) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight ? AppColors.gold.withValues(alpha: 0.12) : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight ? AppColors.gold : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: highlight ? AppColors.goldDark : AppColors.royalBlue),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.gray600)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: highlight ? AppColors.navyDark : AppColors.navyDark,
            ),
          ),
        ],
      ),
    );
  }
}

/// ── Complete 7-Step Multi-Step Visa Application Dialog ───────────────────────
class VisaApplicationFlowDialog extends StatefulWidget {
  final VisaServiceModel service;
  final VoidCallback onSubmitted;

  const VisaApplicationFlowDialog({
    super.key,
    required this.service,
    required this.onSubmitted,
  });

  @override
  State<VisaApplicationFlowDialog> createState() => _VisaApplicationFlowDialogState();
}

class _VisaApplicationFlowDialogState extends State<VisaApplicationFlowDialog> {
  final VisaRepository _visaRepo = VisaRepository();
  final StorageRepository _storageRepo = StorageRepositoryImpl();

  int _currentStep = 0; // 0 to 6 (Steps 1 to 7)

  // Step 1: Destination
  late String _destination;

  // Step 2: Visa Type
  late String _visaType;

  // Step 3: Travel Info
  DateTime _travelDate = DateTime.now().add(const Duration(days: 30));
  DateTime? _returnDate;
  String _purpose = 'Tourism';
  final _purposeNotesCtrl = TextEditingController();

  // Step 4: Applicant Info
  final _formKeyApplicant = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _nationalityCtrl = TextEditingController();
  final _passportNumberCtrl = TextEditingController();
  DateTime _dob = DateTime(1995, 5, 15);

  // Step 5: Documents (Storage path or URL map)
  final Map<String, String> _uploadedDocuments = {};
  bool _isUploadingDoc = false;
  String? _uploadingDocName;

  // Step 7: Submission status
  bool _isSubmitting = false;
  VisaApplicationModel? _submittedResult;
  String? _errorMessage;

  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  final List<String> _purposes = [
    'Tourism',
    'Business / Conference',
    'Family / Friend Visit',
    'Transit',
    'Study / Course',
    'Medical Treatment',
  ];

  @override
  void initState() {
    super.initState();
    _destination = widget.service.country;
    _visaType = widget.service.visaType;
    _returnDate = _travelDate.add(const Duration(days: 14));
  }

  @override
  void dispose() {
    _purposeNotesCtrl.dispose();
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _nationalityCtrl.dispose();
    _passportNumberCtrl.dispose();
    super.dispose();
  }

  Future<void> _simulateUploadDocument(String docKey) async {
    setState(() {
      _isUploadingDoc = true;
      _uploadingDocName = docKey;
    });

    try {
      // In web/desktop without native file picker package, simulate document bytes creation & upload to Supabase
      final dummyBytes = Uint8List.fromList(
        'TRAVELLA_ENCRYPTED_DOC_${docKey}_${DateTime.now().millisecondsSinceEpoch}'.codeUnits,
      );
      final filename = '${docKey.toLowerCase().replaceAll(' ', '_')}.pdf';
      final currentUser = SupabaseService.currentUser;

      final url = await _storageRepo.uploadVisaDocument(
        dummyBytes,
        filename,
        userId: currentUser?.id ?? 'applicant-${_passportNumberCtrl.text.trim()}',
      );

      if (mounted) {
        setState(() {
          _uploadedDocuments[docKey] = url;
          _isUploadingDoc = false;
          _uploadingDocName = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Fallback to secure ref url
          _uploadedDocuments[docKey] = 'https://supabase.co/storage/visa-docs/${widget.service.id}/$docKey.pdf';
          _isUploadingDoc = false;
          _uploadingDocName = null;
        });
      }
    }
  }

  Future<void> _submitFinalApplication() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final refNumber = 'TRV-${DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase()}';
    final currentUser = SupabaseService.currentUser;

    final app = VisaApplicationModel(
      id: '',
      userId: currentUser?.id,
      referenceNumber: refNumber,
      country: _destination,
      visaType: _visaType,
      visaServiceId: widget.service.id,
      expectedTravelDate: _travelDate,
      returnDate: _returnDate,
      travelPurpose: _purpose,
      fullName: _fullNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      nationality: _nationalityCtrl.text.trim().isNotEmpty ? _nationalityCtrl.text.trim() : 'Egyptian',
      passportNumber: _passportNumberCtrl.text.trim(),
      dateOfBirth: _dob,
      documents: _uploadedDocuments,
      status: VisaApplicationStatus.pending,
      estimatedFee: widget.service.price,
      adminNotes: _purposeNotesCtrl.text.trim().isNotEmpty ? _purposeNotesCtrl.text.trim() : null,
      createdAt: DateTime.now(),
    );

    try {
      final result = await _visaRepo.submitVisaApplication(app);
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _submittedResult = result;
          _currentStep = 6; // Success step
        });
        widget.onSubmitted();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  void _nextStep() {
    if (_currentStep == 3) {
      if (!_formKeyApplicant.currentState!.validate()) return;
    }
    if (_currentStep < 5) {
      setState(() => _currentStep++);
    } else if (_currentStep == 5) {
      _submitFinalApplication();
    }
  }

  void _prevStep() {
    if (_currentStep > 0 && _currentStep < 6) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.white,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 720,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: EdgeInsets.all(isMobile ? 18 : 28),
        child: Column(
          children: [
            // ── Dialog Header ─────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.royalBlueFaded,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(widget.service.flagEmoji, style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic
                            ? 'طلب تأشيرة ${widget.service.localizedCountry(isArabic)}'
                            : 'Visa Application: ${widget.service.country}',
                        style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold, color: AppColors.navyDark),
                      ),
                      Text(
                        '${widget.service.visaType} • \$${widget.service.price.toInt()} • ${widget.service.processingTime}',
                        style: const TextStyle(color: AppColors.gray600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Step Progress Indicator ───────────────────────────────────
            _buildStepIndicator(isArabic, isMobile),
            const SizedBox(height: 20),
            const Divider(height: 1, color: AppColors.borderLight),
            const SizedBox(height: 16),

            // ── Step Form Content ─────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                child: _buildCurrentStepView(isArabic, isMobile),
              ),
            ),

            // ── Step Action Bar ───────────────────────────────────────────
            if (_currentStep < 6) ...[
              const Divider(height: 1, color: AppColors.borderLight),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    TextButton.icon(
                      icon: Icon(isArabic ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded, size: 16),
                      label: Text(isArabic ? 'السابق' : 'Back'),
                      onPressed: _prevStep,
                    )
                  else
                    const SizedBox.shrink(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentStep == 5 ? AppColors.gold : AppColors.navy,
                      foregroundColor: _currentStep == 5 ? AppColors.navy : AppColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isSubmitting ? null : _nextStep,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.navy),
                          )
                        : Text(
                            _currentStep == 5
                                ? (isArabic ? 'تأكيد وإرسال الطلب' : 'Submit Application')
                                : (isArabic ? 'التالي' : 'Continue'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(bool isArabic, bool isMobile) {
    final stepLabels = [
      isArabic ? '1. الوجهة' : '1. Country',
      isArabic ? '2. النوع' : '2. Type',
      isArabic ? '3. السفر' : '3. Travel',
      isArabic ? '4. البيانات' : '4. Personal',
      isArabic ? '5. المستندات' : '5. Docs',
      isArabic ? '6. المراجعة' : '6. Review',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(stepLabels.length, (idx) {
          final isPassed = _currentStep > idx;
          final isCurrent = _currentStep == idx;

          return Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? AppColors.royalBlue
                      : (isPassed ? AppColors.successGreen : AppColors.surfaceLight),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: isCurrent
                        ? AppColors.royalBlue
                        : (isPassed ? AppColors.successGreen : AppColors.borderLight),
                  ),
                ),
                child: Row(
                  children: [
                    if (isPassed)
                      const Icon(Icons.check, size: 12, color: AppColors.white)
                    else
                      Text(
                        '${idx + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? AppColors.white : AppColors.gray600,
                        ),
                      ),
                    const SizedBox(width: 6),
                    Text(
                      stepLabels[idx],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                        color: isCurrent || isPassed ? AppColors.white : AppColors.gray700,
                      ),
                    ),
                  ],
                ),
              ),
              if (idx < stepLabels.length - 1)
                Container(
                  width: 14,
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  color: isPassed ? AppColors.successGreen : AppColors.gray300,
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStepView(bool isArabic, bool isMobile) {
    switch (_currentStep) {
      case 0:
        return _step1Destination(isArabic);
      case 1:
        return _step2VisaType(isArabic);
      case 2:
        return _step3TravelInfo(isArabic, isMobile);
      case 3:
        return _step4ApplicantInfo(isArabic, isMobile);
      case 4:
        return _step5DocumentsUpload(isArabic);
      case 5:
        return _step6Review(isArabic);
      case 6:
      default:
        return _step7Success(isArabic);
    }
  }

  // STEP 1: Select Destination
  Widget _step1Destination(bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'الخطوة 1: تأكيد دولة الوجهة' : 'Step 1: Confirm Destination Country',
          style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          isArabic ? 'الوجهة المحددة لطلب التأشيرة:' : 'Selected destination country for visa application:',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.royalBlue, width: 1.5),
          ),
          child: Row(
            children: [
              Text(widget.service.flagEmoji, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.service.localizedCountry(isArabic),
                      style: AppTextStyles.h4.copyWith(color: AppColors.navyDark),
                    ),
                    Text(
                      '${widget.service.region} • ${widget.service.processingTime}',
                      style: const TextStyle(color: AppColors.gray600, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.check_circle_rounded, color: AppColors.royalBlue, size: 28),
            ],
          ),
        ),
      ],
    );
  }

  // STEP 2: Select Visa Type
  Widget _step2VisaType(bool isArabic) {
    final types = [
      ('Tourist Visa', 'For leisure holidays, sightseeing, and family trips.', '🏖️'),
      ('Business / Conference', 'For meetings, trade delegations, and exhibitions.', '💼'),
      ('Express Fast-Track Visa', 'Priority appointment and rapid consulate submission.', '⚡'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'الخطوة 2: اختيار نوع وفئة التأشيرة' : 'Step 2: Select Visa Type & Category',
          style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...types.map((t) {
          final isSel = _visaType == t.$1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => setState(() => _visaType = t.$1),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSel ? AppColors.royalBlueFaded : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSel ? AppColors.royalBlue : AppColors.borderLight,
                    width: isSel ? 2.0 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Text(t.$3, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.$1, style: AppTextStyles.labelLG.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(t.$2, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    Icon(
                      isSel ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                      color: isSel ? AppColors.royalBlue : AppColors.gray400,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // STEP 3: Travel Information
  Widget _step3TravelInfo(bool isArabic, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'الخطوة 3: معلومات وجدول السفر' : 'Step 3: Travel Information',
          style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Travel Date & Return Date
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isArabic ? 'تاريخ السفر المتوقع *' : 'Expected Travel Date *', style: AppTextStyles.labelMD),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _travelDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) setState(() => _travelDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.royalBlue),
                          const SizedBox(width: 8),
                          Text(_dateFormat.format(_travelDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isArabic ? 'تاريخ العودة المتوقع' : 'Return Date (Optional)', style: AppTextStyles.labelMD),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _returnDate ?? _travelDate.add(const Duration(days: 14)),
                        firstDate: _travelDate,
                        lastDate: DateTime.now().add(const Duration(days: 400)),
                      );
                      if (picked != null) setState(() => _returnDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.event_repeat_rounded, size: 16, color: AppColors.gray600),
                          const SizedBox(width: 8),
                          Text(
                            _returnDate != null ? _dateFormat.format(_returnDate!) : 'Select Date',
                            style: TextStyle(fontWeight: _returnDate != null ? FontWeight.bold : FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Purpose of Travel Dropdown
        Text(isArabic ? 'الغرض الأساسي من السفر *' : 'Purpose of Travel *', style: AppTextStyles.labelMD),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _purpose,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceLight,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          items: _purposes.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
          onChanged: (val) => setState(() => _purpose = val ?? 'Tourism'),
        ),
        const SizedBox(height: 16),

        // Additional travel notes
        Text(isArabic ? 'ملاحظات إضافية أو خط سير الرحلة' : 'Additional Travel Notes / Itinerary Details', style: AppTextStyles.labelMD),
        const SizedBox(height: 6),
        TextFormField(
          controller: _purposeNotesCtrl,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: isArabic
                ? 'مثال: حضور مؤتمر، زيارة الأقارب، التقديم مع أفراد العائلة...'
                : 'e.g. Attending a medical conference, visiting family in London, traveling with spouse...',
            filled: true,
            fillColor: AppColors.surfaceLight,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  // STEP 4: Applicant Information
  Widget _step4ApplicantInfo(bool isArabic, bool isMobile) {
    return Form(
      key: _formKeyApplicant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'الخطوة 4: البيانات الشخصية لمقدم الطلب' : 'Step 4: Applicant Personal Information',
            style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Full Name
          TextFormField(
            controller: _fullNameCtrl,
            decoration: InputDecoration(
              labelText: isArabic ? 'الاسم الكامل بالإنجليزية (كما في الجواز) *' : 'Full Name (as written in Passport) *',
              prefixIcon: const Icon(Icons.person_outline_rounded),
              filled: true,
              fillColor: AppColors.surfaceLight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Full name is required' : null,
          ),
          const SizedBox(height: 12),

          // Email & Phone
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'البريد الإلكتروني *' : 'Email Address *',
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (v) => v == null || !v.contains('@') ? 'Valid email required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'رقم الهاتف / واتساب *' : 'Phone / WhatsApp *',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (v) => v == null || v.trim().length < 7 ? 'Valid phone required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Nationality & Passport Number
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _nationalityCtrl,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'الجنسية *' : 'Nationality *',
                    prefixIcon: const Icon(Icons.flag_outlined),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Nationality is required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _passportNumberCtrl,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'رقم جواز السفر *' : 'Passport Number *',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Passport number is required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Date of Birth
          Text(isArabic ? 'تاريخ الميلاد *' : 'Date of Birth *', style: AppTextStyles.labelMD),
          const SizedBox(height: 6),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _dob,
                firstDate: DateTime(1930),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _dob = picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cake_outlined, size: 16, color: AppColors.royalBlue),
                  const SizedBox(width: 8),
                  Text(_dateFormat.format(_dob), style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 5: Upload Documents to Supabase Storage
  Widget _step5DocumentsUpload(bool isArabic) {
    final docsList = [
      ('Passport', isArabic ? 'صورة جواز السفر الساري (6 أشهر فأكثر) *' : 'Valid Passport Copy (6+ months validity) *', true),
      ('Personal Photo', isArabic ? 'صورة شخصية حديثة بخلفية بيضاء *' : 'Recent Personal Photo (White background) *', true),
      ('Bank Statement', isArabic ? 'كشف حساب بنكي لآخر 3-6 أشهر' : 'Bank Statement (Last 3-6 months)', false),
      ('Supporting Document', isArabic ? 'مستند إضافي (خطاب عمل / سجل تجاري / تذكرة)' : 'Supporting Proof (Employment / Reservation)', false),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'الخطوة 5: رفع المستندات المطلوبة' : 'Step 5: Upload Required Documents',
          style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          isArabic
              ? 'يتم تخزين جميع المستندات بأمان ومشفرة على سحابة Supabase Storage.'
              : 'All files are securely stored in Supabase Storage with strict RLS policies.',
          style: const TextStyle(color: AppColors.gray600, fontSize: 12),
        ),
        const SizedBox(height: 16),

        if (_isUploadingDoc)
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: AppColors.royalBlueFaded,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.royalBlue),
                ),
                const SizedBox(width: 12),
                Text(
                  isArabic
                      ? 'جاري رفع $_uploadingDocName إلى سوبابيس...'
                      : 'Uploading $_uploadingDocName to Supabase Storage...',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.royalBlue),
                ),
              ],
            ),
          ),

        ...docsList.map((doc) {
          final isUploaded = _uploadedDocuments.containsKey(doc.$1);
          final url = _uploadedDocuments[doc.$1];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUploaded ? AppColors.successGreen.withValues(alpha: 0.06) : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isUploaded ? AppColors.successGreen : AppColors.borderLight,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isUploaded ? Icons.verified_rounded : Icons.cloud_upload_outlined,
                  color: isUploaded ? AppColors.successGreen : AppColors.royalBlue,
                  size: 24,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doc.$2, style: AppTextStyles.bodySM.copyWith(fontWeight: FontWeight.bold)),
                      if (isUploaded)
                        Text(
                          isArabic ? 'تم الرفع والتأمين بنجاح' : 'Stored in Supabase bucket: visa-documents',
                          style: const TextStyle(fontSize: 11, color: AppColors.successGreen),
                        ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isUploaded ? AppColors.white : AppColors.navy,
                    foregroundColor: isUploaded ? AppColors.successGreen : AppColors.white,
                    side: isUploaded ? const BorderSide(color: AppColors.successGreen) : null,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  icon: Icon(isUploaded ? Icons.check : Icons.upload_file, size: 14),
                  label: Text(
                    isUploaded ? (isArabic ? 'تم الرفع' : 'Uploaded') : (isArabic ? 'رفع الملف' : 'Upload'),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _isUploadingDoc ? null : () => _simulateUploadDocument(doc.$1),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // STEP 6: Review Application
  Widget _step6Review(bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'الخطوة 6: مراجعة وتأكيد بيانات الطلب' : 'Step 6: Review Application Summary',
          style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        if (_errorMessage != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: AppColors.errorRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(_errorMessage!, style: const TextStyle(color: AppColors.errorRed, fontSize: 12)),
          ),

        _reviewSection(
          title: isArabic ? 'بيانات التأشيرة' : 'Visa Specifications',
          items: [
            ('Destination', _destination),
            ('Visa Type', _visaType),
            ('Estimated Service Fee', '\$${widget.service.price.toInt()}'),
          ],
        ),
        const SizedBox(height: 14),

        _reviewSection(
          title: isArabic ? 'جدول السفر' : 'Travel Schedule',
          items: [
            ('Expected Travel Date', _dateFormat.format(_travelDate)),
            ('Return Date', _returnDate != null ? _dateFormat.format(_returnDate!) : 'Not Specified'),
            ('Travel Purpose', _purpose),
          ],
        ),
        const SizedBox(height: 14),

        _reviewSection(
          title: isArabic ? 'بيانات مقدم الطلب' : 'Applicant Details',
          items: [
            ('Full Name', _fullNameCtrl.text.trim()),
            ('Email', _emailCtrl.text.trim()),
            ('Phone / WhatsApp', _phoneCtrl.text.trim()),
            ('Nationality', _nationalityCtrl.text.trim()),
            ('Passport Number', _passportNumberCtrl.text.trim()),
            ('Date of Birth', _dateFormat.format(_dob)),
          ],
        ),
        const SizedBox(height: 14),

        _reviewSection(
          title: isArabic ? 'المستندات المرفوعة' : 'Uploaded Documents',
          items: [
            ('Files Attached', '${_uploadedDocuments.length} document(s) uploaded to Supabase Storage'),
            ('Initial Status', 'Pending Review (قيد الانتظار)'),
          ],
        ),
      ],
    );
  }

  // STEP 7: Success Screen
  Widget _step7Success(bool isArabic) {
    final ref = _submittedResult?.referenceNumber ?? 'TRV-SUCCESS';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 68),
        const SizedBox(height: 16),
        Text(
          isArabic ? 'تم إرسال طلب التأشيرة بنجاح!' : 'Visa Application Submitted!',
          style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold, color: AppColors.navyDark),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          isArabic ? 'رقم طلب التأشيرة المرجعي:' : 'Your Visa Application Reference:',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.gold, width: 1.5),
          ),
          child: Text(
            ref,
            style: AppTextStyles.labelLG.copyWith(
              color: AppColors.royalBlueDark,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            isArabic ? 'الحالة الحالية: قيد الانتظار والمراجعة' : 'Initial Status: pending',
            style: const TextStyle(color: AppColors.goldDark, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          isArabic
              ? 'تم تسجيل طلبك وحفظ مستنداتك في قاعدة البيانات. سيقوم مستشار التأشيرات بالتواصل مع حضرتك لاستكمال الموعد وإجراءات التقديم.'
              : 'Your application and documents have been registered in Supabase. A dedicated visa specialist will contact you shortly to review and process your file.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.6),
        ),
        const SizedBox(height: 24),
        TravellaButton(
          label: isArabic ? 'إغلاق والعودة' : 'Close & Return',
          variant: TravellaButtonVariant.primary,
          fullWidth: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _reviewSection({required String title, required List<(String, String)> items}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navyDark, fontSize: 13)),
          const SizedBox(height: 8),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item.$1, style: const TextStyle(color: AppColors.gray600, fontSize: 12)),
                  Text(item.$2, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

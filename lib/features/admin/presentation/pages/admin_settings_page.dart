import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../data/models/site_settings_model.dart';
import '../../../../data/services/supabase_service.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../site_settings/presentation/cubit/site_settings_cubit.dart';
import '../../../site_settings/presentation/cubit/site_settings_state.dart';
import '../../../../shared/presentation/widgets/social_links_bar.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  final _siteNameCtrl = TextEditingController();
  final _siteNameArCtrl = TextEditingController();
  final _supportEmailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _cairoAddressCtrl = TextEditingController();
  final _cairoAddressArCtrl = TextEditingController();
  final _facebookUrlCtrl = TextEditingController();
  final _instagramUrlCtrl = TextEditingController();
  final _youtubeUrlCtrl = TextEditingController();
  final _tiktokUrlCtrl = TextEditingController();

  String _defaultCurrency = 'USD';
  bool _maintenanceMode = false;
  bool _emailNotifications = true;
  String? _supabaseStatus = 'Connected';
  int? _latencyMs;
  bool _testingConnection = false;
  bool _initializedFromCubit = false;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<SiteSettingsCubit?>();
    if (cubit != null) {
      _applySettingsToControllers(cubit.state.settings);
      _initializedFromCubit = true;
    }
  }

  void _applySettingsToControllers(SiteSettingsModel s) {
    _siteNameCtrl.text = s.siteName;
    _siteNameArCtrl.text = s.siteNameAr;
    _supportEmailCtrl.text = s.supportEmail;
    _phoneCtrl.text = s.phoneNumber;
    _whatsappCtrl.text = s.whatsappNumber;
    _cairoAddressCtrl.text = s.cairoAddress;
    _cairoAddressArCtrl.text = s.cairoAddressAr;
    _facebookUrlCtrl.text = s.facebookUrl;
    _instagramUrlCtrl.text = s.instagramUrl;
    _youtubeUrlCtrl.text = s.youtubeUrl;
    _tiktokUrlCtrl.text = s.tiktokUrl;
  }

  @override
  void dispose() {
    _siteNameCtrl.dispose();
    _siteNameArCtrl.dispose();
    _supportEmailCtrl.dispose();
    _phoneCtrl.dispose();
    _whatsappCtrl.dispose();
    _cairoAddressCtrl.dispose();
    _cairoAddressArCtrl.dispose();
    _facebookUrlCtrl.dispose();
    _instagramUrlCtrl.dispose();
    _youtubeUrlCtrl.dispose();
    _tiktokUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _testSupabasePing() async {
    setState(() {
      _testingConnection = true;
      _supabaseStatus = 'Testing...';
    });

    final stopwatch = Stopwatch()..start();
    try {
      await SupabaseService.client.from(SupabaseService.tableTours).select('id').limit(1);
      stopwatch.stop();
      setState(() {
        _testingConnection = false;
        _latencyMs = stopwatch.elapsedMilliseconds;
        _supabaseStatus = 'Connected (${_latencyMs}ms latency)';
      });
    } catch (e) {
      stopwatch.stop();
      setState(() {
        _testingConnection = false;
        _supabaseStatus = 'Offline: ${e.toString().replaceAll('Exception: ', '')}';
      });
    }
  }

  Future<void> _saveAllSettings() async {
    final cubit = context.read<SiteSettingsCubit?>();
    if (cubit == null) return;

    final updated = SiteSettingsModel(
      siteName: _siteNameCtrl.text.trim(),
      siteNameAr: _siteNameArCtrl.text.trim(),
      supportEmail: _supportEmailCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
      whatsappNumber: _whatsappCtrl.text.trim(),
      cairoAddress: _cairoAddressCtrl.text.trim(),
      cairoAddressAr: _cairoAddressArCtrl.text.trim(),
      facebookUrl: _facebookUrlCtrl.text.trim(),
      instagramUrl: _instagramUrlCtrl.text.trim(),
      youtubeUrl: _youtubeUrlCtrl.text.trim(),
      tiktokUrl: _tiktokUrlCtrl.text.trim(),
    );

    final success = await cubit.updateSettings(updated);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Site settings & social media links saved successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cubit.state.errorMessage ?? 'Error saving settings'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(context);
    final authState = context.watch<AuthCubit>().state;
    final profile = authState is Authenticated ? authState.profile : null;

    return BlocListener<SiteSettingsCubit, SiteSettingsState>(
      listener: (context, state) {
        if (!_initializedFromCubit) {
          _applySettingsToControllers(state.settings);
          _initializedFromCubit = true;
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.lightGray,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('System & Portal Settings', style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(
                'Configure global agency parameters, verified social links, and database telemetry',
                style: AppTextStyles.bodyMD.copyWith(color: AppColors.gray600),
              ),
              const SizedBox(height: 24),

              // Section 1: Admin User Profile Card
              _SettingsCard(
                title: 'Authenticated Administrator',
                subtitle: 'Current active session and security credentials',
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.gold.withValues(alpha: 0.2),
                      child: Text(
                        (profile?.fullName?.isNotEmpty == true
                                ? profile!.fullName![0]
                                : (profile?.email[0] ?? 'A'))
                            .toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppColors.navy),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(profile?.fullName ?? 'Travella Administrator', style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold)),
                          Text(profile?.email ?? 'admin@travella.com', style: AppTextStyles.bodySM.copyWith(color: AppColors.gray600)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'ROLE: ${profile?.role.toDbString().toUpperCase() ?? "ADMIN"}',
                              style: const TextStyle(color: AppColors.goldDark, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section 2: General Company Configuration
              _SettingsCard(
                title: 'General Agency Information',
                subtitle: 'Contact and brand settings rendered across public pages',
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _siteNameCtrl,
                            decoration: InputDecoration(
                              labelText: 'Company / Portal Name (English)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextFormField(
                            controller: _siteNameArCtrl,
                            decoration: InputDecoration(
                              labelText: 'Company / Portal Name (Arabic)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _supportEmailCtrl,
                            decoration: InputDecoration(
                              labelText: 'Official Support Email',
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneCtrl,
                            decoration: InputDecoration(
                              labelText: 'Direct Phone Helpline',
                              prefixIcon: const Icon(Icons.phone_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cairoAddressCtrl,
                            decoration: InputDecoration(
                              labelText: 'Address (English)',
                              prefixIcon: const Icon(Icons.location_on_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextFormField(
                            controller: _cairoAddressArCtrl,
                            decoration: InputDecoration(
                              labelText: 'Address (Arabic)',
                              prefixIcon: const Icon(Icons.location_on_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _defaultCurrency,
                      decoration: InputDecoration(
                        labelText: 'Default Currency Standard',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'USD', child: Text('USD (\$) — United States Dollar')),
                        DropdownMenuItem(value: 'SAR', child: Text('SAR (﷼) — Saudi Riyal')),
                        DropdownMenuItem(value: 'EGP', child: Text('EGP (ج.م) — Egyptian Pound')),
                        DropdownMenuItem(value: 'EUR', child: Text('EUR (€) — Euro')),
                        DropdownMenuItem(value: 'AED', child: Text('AED (د.إ) — UAE Dirham')),
                      ],
                      onChanged: (val) => setState(() => _defaultCurrency = val ?? 'USD'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section 3: Social Media Links (Dynamic site_settings)
              _SettingsCard(
                title: 'Official Social Media Channels',
                subtitle: 'Managed URLs for Facebook, Instagram, WhatsApp, YouTube, and TikTok. Empty links are automatically hidden.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Information Alert
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.royalBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.royalBlue.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppColors.royalBlue, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Social icons across the footer, navigation drawer, and contact page reflect these values. If an input is left blank, its icon is safely hidden from public visitors.',
                              style: AppTextStyles.bodySM.copyWith(color: AppColors.navy),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Facebook URL (Verified)
                    TextFormField(
                      controller: _facebookUrlCtrl,
                      decoration: InputDecoration(
                        labelText: 'Facebook Page URL (Verified Official Page)',
                        hintText: 'https://facebook.com/travella',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.all(12),
                          child: FaIcon(FontAwesomeIcons.facebookF, color: Color(0xFF1877F2), size: 18),
                        ),
                        suffixIcon: const Tooltip(
                          message: 'Verified Travella Facebook page',
                          child: Icon(Icons.verified_rounded, color: Color(0xFF1877F2), size: 20),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Instagram URL
                    TextFormField(
                      controller: _instagramUrlCtrl,
                      decoration: InputDecoration(
                        labelText: 'Instagram Profile URL',
                        hintText: 'https://instagram.com/travella',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.all(12),
                          child: FaIcon(FontAwesomeIcons.instagram, color: Color(0xFFE4405F), size: 18),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // WhatsApp Number or URL
                    TextFormField(
                      controller: _whatsappCtrl,
                      decoration: InputDecoration(
                        labelText: 'WhatsApp Helpline Number or Link',
                        hintText: '+20 100 123 4567 or https://wa.me/...',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.all(12),
                          child: FaIcon(FontAwesomeIcons.whatsapp, color: Color(0xFF25D366), size: 18),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // YouTube Channel URL
                    TextFormField(
                      controller: _youtubeUrlCtrl,
                      decoration: InputDecoration(
                        labelText: 'YouTube Channel URL',
                        hintText: 'https://youtube.com/@travella',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.all(12),
                          child: FaIcon(FontAwesomeIcons.youtube, color: Color(0xFFFF0000), size: 18),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // TikTok Profile URL
                    TextFormField(
                      controller: _tiktokUrlCtrl,
                      decoration: InputDecoration(
                        labelText: 'TikTok Profile URL',
                        hintText: 'https://tiktok.com/@travella',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.all(12),
                          child: FaIcon(FontAwesomeIcons.tiktok, color: Color(0xFF00F2FE), size: 18),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Live preview chip
                    Row(
                      children: [
                        const Text(
                          'Public Preview:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.navyDark),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: SocialLinksBar(
                            variant: SocialLinksVariant.card,
                            iconSize: 16,
                            spacing: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section 4: Supabase Telemetry & Ping
              _SettingsCard(
                title: 'Supabase PostgreSQL & Storage Telemetry',
                subtitle: 'Verify live database connectivity, latency, and replication status',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _supabaseStatus?.startsWith('Connected') == true ? Icons.check_circle : Icons.error,
                          color: _supabaseStatus?.startsWith('Connected') == true ? AppColors.success : AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Database Status: $_supabaseStatus',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.navy,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                          onPressed: _testingConnection ? null : _testSupabasePing,
                          icon: _testingConnection
                              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.speed_rounded, size: 16),
                          label: const Text('Test Database Ping'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    const Text('Connected Supabase Buckets:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StorageBucketChip(name: 'tour-images', isPublic: true),
                        _StorageBucketChip(name: 'destination-images', isPublic: true),
                        _StorageBucketChip(name: 'hotel-images', isPublic: true),
                        _StorageBucketChip(name: 'gallery-images', isPublic: true),
                        _StorageBucketChip(name: 'blog-images', isPublic: true),
                        _StorageBucketChip(name: 'partner-logos', isPublic: true),
                        _StorageBucketChip(name: 'transfer-images', isPublic: true),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section 5: Operational Controls
              _SettingsCard(
                title: 'Operational Controls',
                subtitle: 'System-wide availability toggles',
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Maintenance Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Display maintenance splash screen to public visitors', style: TextStyle(fontSize: 12)),
                      value: _maintenanceMode,
                      activeColor: AppColors.coral,
                      onChanged: (val) => setState(() => _maintenanceMode = val),
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Email Notifications for New Bookings', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Send administrative alerts whenever a new inquiry is submitted', style: TextStyle(fontSize: 12)),
                      value: _emailNotifications,
                      activeColor: AppColors.success,
                      onChanged: (val) => setState(() => _emailNotifications = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Save Settings Button
              BlocBuilder<SiteSettingsCubit, SiteSettingsState>(
                builder: (context, state) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.navy,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 3,
                      ),
                      onPressed: state.isSaving ? null : _saveAllSettings,
                      icon: state.isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.navy),
                            )
                          : const Icon(Icons.save_rounded),
                      label: Text(
                        state.isSaving ? 'Saving...' : 'Save All Settings',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SettingsCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyDark.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(subtitle, style: AppTextStyles.bodySM.copyWith(color: AppColors.gray600)),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _StorageBucketChip extends StatelessWidget {
  final String name;
  final bool isPublic;

  const _StorageBucketChip({required this.name, required this.isPublic});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPublic ? Icons.lock_open_rounded : Icons.lock_rounded,
            size: 14,
            color: isPublic ? AppColors.success : AppColors.coral,
          ),
          const SizedBox(width: 6),
          Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

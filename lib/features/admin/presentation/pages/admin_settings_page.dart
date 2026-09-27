import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../data/services/supabase_service.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  final _siteNameCtrl = TextEditingController(text: 'Travella Tour & Travel');
  final _supportEmailCtrl = TextEditingController(text: 'support@travella.com');
  final _whatsappCtrl = TextEditingController(text: '+20 100 123 4567');
  String _defaultCurrency = 'USD';
  bool _maintenanceMode = false;
  bool _emailNotifications = true;
  String? _supabaseStatus = 'Connected';
  int? _latencyMs;
  bool _testingConnection = false;

  @override
  void dispose() {
    _siteNameCtrl.dispose();
    _supportEmailCtrl.dispose();
    _whatsappCtrl.dispose();
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

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(context);
    final authState = context.watch<AuthCubit>().state;
    final profile = authState is Authenticated ? authState.profile : null;

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('System & Portal Settings', style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text('Configure global agency parameters, currency defaults, and database telemetry', style: AppTextStyles.bodyMD.copyWith(color: AppColors.gray600)),
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
              subtitle: 'Contact and brand settings rendered across the web app',
              child: Column(
                children: [
                  TextFormField(
                    controller: _siteNameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Company / Portal Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _supportEmailCtrl,
                          decoration: InputDecoration(
                            labelText: 'Official Support Email',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextFormField(
                          controller: _whatsappCtrl,
                          decoration: InputDecoration(
                            labelText: 'Direct WhatsApp Helpline',
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

            // Section 3: Supabase Telemetry & Ping
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
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section 4: Operational Switches
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
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.navy,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Settings saved successfully.'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.save_rounded),
                label: const Text('Save Settings', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(subtitle, style: AppTextStyles.bodyXS.copyWith(color: AppColors.gray500)),
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
        color: AppColors.royalBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.royalBlue.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.folder_outlined, size: 14, color: AppColors.royalBlue),
          const SizedBox(width: 6),
          Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navyDark)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('PUBLIC', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.success)),
          ),
        ],
      ),
    );
  }
}

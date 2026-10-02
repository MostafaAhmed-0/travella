import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../data/models/visa_model.dart';
import '../cubit/admin_visa_cubit.dart';
import '../widgets/admin_dialogs.dart';

class AdminVisaPage extends StatefulWidget {
  const AdminVisaPage({super.key});

  @override
  State<AdminVisaPage> createState() => _AdminVisaPageState();
}

class _AdminVisaPageState extends State<AdminVisaPage>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  final _appSearchCtrl = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<AdminVisaCubit>().loadVisaData();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _appSearchCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _openVisaModal({VisaServiceModel? service}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _VisaFormDialog(
        service: service,
        onSave: (toSave) async {
          final cubit = context.read<AdminVisaCubit>();
          bool success;
          if (service == null) {
            success = await cubit.createVisaService(toSave);
          } else {
            success = await cubit.updateVisaService(toSave);
          }
          if (success && mounted) {
            Navigator.of(dialogContext).pop();
          }
        },
      ),
    );
  }

  void _showApplicationDetailsDialog(VisaApplicationModel app) {
    showDialog(
      context: context,
      builder: (ctx) => _ApplicationDetailsDialog(application: app),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(context);

    return BlocConsumer<AdminVisaCubit, AdminVisaState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.lightGray,
          body: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Visa Services & Applications',
                          style: AppTextStyles.h3.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Manage visa destinations catalog, applicant requests, documents, and status',
                          style: AppTextStyles.bodyMD.copyWith(
                            color: AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Refresh Data',
                          icon: const Icon(
                            Icons.refresh_rounded,
                            color: AppColors.navy,
                          ),
                          onPressed: () =>
                              context.read<AdminVisaCubit>().loadVisaData(),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.navy,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => _openVisaModal(),
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text(
                            'Add Visa Service',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Tab Bar
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.navy,
                    unselectedLabelColor: AppColors.gray600,
                    indicatorColor: AppColors.gold,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    tabs: [
                      Tab(
                        icon: const Icon(
                          Icons.assignment_ind_rounded,
                          size: 18,
                        ),
                        text: 'Applications (${state.allApplications.length})',
                      ),
                      Tab(
                        icon: const Icon(Icons.public_rounded, size: 18),
                        text:
                            'Visa Services Catalog (${state.allServices.length})',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // ── Tab 1: Visa Applications ──────────────────────────
                      _buildApplicationsTab(state, isMobile),

                      // ── Tab 2: Visa Services Catalog ──────────────────────
                      _buildServicesTab(state, isMobile),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildApplicationsTab(AdminVisaState state, bool isMobile) {
    const statuses = [
      'All',
      'pending',
      'under_review',
      'missing_documents',
      'approved',
      'rejected',
      'completed',
    ];

    return Column(
      children: [
        // Filter and Search Row
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Column(
            children: [
              TextField(
                controller: _appSearchCtrl,
                onChanged: (q) =>
                    context.read<AdminVisaCubit>().searchApplications(q),
                decoration: InputDecoration(
                  hintText:
                      'Search applications by reference number, applicant name, email, country or passport...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: statuses.map((st) {
                    final isSel = state.selectedStatusFilter == st;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          st == 'All'
                              ? 'All Statuses'
                              : VisaApplicationStatus.displayName(st, false),
                        ),
                        selected: isSel,
                        onSelected: (_) => context
                            .read<AdminVisaCubit>()
                            .filterApplicationsByStatus(st),
                        selectedColor: AppColors.navy,
                        checkmarkColor: AppColors.white,
                        labelStyle: TextStyle(
                          color: isSel ? AppColors.white : AppColors.navyDark,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12,
                        ),
                        backgroundColor: AppColors.lightGray,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                          side: BorderSide(
                            color: isSel ? AppColors.navy : AppColors.gray300,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Applications List
        Expanded(
          child: state.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                )
              : state.filteredApplications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.inbox_outlined,
                        size: 56,
                        color: AppColors.gray400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No visa applications found',
                        style: AppTextStyles.h5,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Submitted applicant requests will appear here in real-time.',
                        style: TextStyle(color: AppColors.gray600),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: state.filteredApplications.length,
                  itemBuilder: (context, idx) {
                    final app = state.filteredApplications[idx];
                    return _VisaApplicationAdminCard(
                      application: app,
                      onView: () => _showApplicationDetailsDialog(app),
                      onStatusChanged: (newStatus) {
                        context.read<AdminVisaCubit>().updateApplicationStatus(
                          app.id,
                          newStatus,
                        );
                      },
                      onDelete: () async {
                        final confirm = await showAdminConfirmDialog(
                          context: context,
                          title: 'Delete Application',
                          message:
                              'Are you sure you want to delete application ${app.referenceNumber}?',
                        );
                        if (confirm == true && context.mounted) {
                          context.read<AdminVisaCubit>().deleteApplication(
                            app.id,
                          );
                        }
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildServicesTab(AdminVisaState state, bool isMobile) {
    return Column(
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.gray200),
          ),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (q) => context.read<AdminVisaCubit>().searchVisa(q),
            decoration: InputDecoration(
              hintText: 'Search visa services by country or visa type...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Visa Catalog List
        Expanded(
          child: state.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                )
              : state.filteredServices.isEmpty
              ? const Center(child: Text('No visa services found.'))
              : ListView.builder(
                  itemCount: state.filteredServices.length,
                  itemBuilder: (context, index) {
                    final service = state.filteredServices[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.gray200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.royalBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              service.flagEmoji.isNotEmpty
                                  ? service.flagEmoji
                                  : '🌐',
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      service.country,
                                      style: AppTextStyles.h6.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.navy.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        service.visaType,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.navy,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (service.countryAr != null &&
                                    service.countryAr!.isNotEmpty)
                                  Text(
                                    service.countryAr!,
                                    style: const TextStyle(
                                      color: AppColors.gray600,
                                      fontSize: 12,
                                    ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  'Processing: ${service.processingTime} • ${service.requirements.length} Requirements listed • Fee: \$${service.price.toInt()}',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.gray600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Price Pill
                          InkWell(
                            onTap: () async {
                              final newPrice = await showAdminPriceEditDialog(
                                context: context,
                                itemName: '${service.country} Visa',
                                currentPrice: service.price,
                              );
                              if (newPrice != null && context.mounted) {
                                await context
                                    .read<AdminVisaCubit>()
                                    .updatePrice(service.id, newPrice);
                              }
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.gold.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '\$${service.price.toInt()}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColors.navyDark,
                                    ),
                                  ),
                                  const Text(
                                    'Edit Fee',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.gray600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            tooltip: service.active
                                ? 'Deactivate Visa'
                                : 'Activate Visa',
                            icon: Icon(
                              service.active
                                  ? Icons.toggle_on
                                  : Icons.toggle_off,
                              color: service.active
                                  ? AppColors.success
                                  : AppColors.gray400,
                              size: 30,
                            ),
                            onPressed: () => context
                                .read<AdminVisaCubit>()
                                .toggleActive(service),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: AppColors.royalBlue,
                            ),
                            onPressed: () => _openVisaModal(service: service),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.error,
                            ),
                            onPressed: () async {
                              final confirm = await showAdminConfirmDialog(
                                context: context,
                                title: 'Delete Visa Service',
                                message:
                                    'Are you sure you want to delete "${service.country}" visa?',
                              );
                              if (confirm == true && context.mounted) {
                                await context
                                    .read<AdminVisaCubit>()
                                    .deleteVisaService(service.id);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Card component for an applicant request in Admin Dashboard
class _VisaApplicationAdminCard extends StatelessWidget {
  final VisaApplicationModel application;
  final VoidCallback onView;
  final ValueChanged<String> onStatusChanged;
  final VoidCallback onDelete;

  const _VisaApplicationAdminCard({
    required this.application,
    required this.onView,
    required this.onStatusChanged,
    required this.onDelete,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'completed':
        return AppColors.success;
      case 'under_review':
        return AppColors.royalBlue;
      case 'missing_documents':
        return Colors.orange;
      case 'rejected':
        return AppColors.error;
      case 'pending':
      default:
        return AppColors.goldDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = application;
    final statusColor = _getStatusColor(a.status);
    final docsCount = a.documents.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reference & Status icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.description_rounded,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Main Applicant info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      a.fullName,
                      style: AppTextStyles.h6.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.navy.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        a.referenceNumber,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Status Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.4),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: a.status,
                          isDense: true,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: statusColor,
                            size: 20,
                          ),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          items: VisaApplicationStatus.all.map((st) {
                            return DropdownMenuItem(
                              value: st,
                              child: Text(
                                VisaApplicationStatus.displayName(st, false),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null && val != a.status) {
                              onStatusChanged(val);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '${a.country} • ${a.visaType}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.royalBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Travel: ${a.expectedTravelDate.toIso8601String().split('T').first}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.gray600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Purpose: ${a.travelPurpose}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      size: 14,
                      color: AppColors.gray500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      a.email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.gray600,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Icon(
                      Icons.phone_outlined,
                      size: 14,
                      color: AppColors.gray500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      a.phone,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.gray600,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Icon(
                      Icons.attachment_rounded,
                      size: 14,
                      color: AppColors.gray500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$docsCount Document${docsCount == 1 ? '' : 's'} Uploaded',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.royalBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // Actions
          Row(
            children: [
              IconButton(
                tooltip: 'View Full Application & Documents',
                icon: const Icon(
                  Icons.visibility_outlined,
                  color: AppColors.royalBlue,
                ),
                onPressed: onView,
              ),
              IconButton(
                tooltip: 'Delete Application',
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Dialog presenting full application details & documents uploaded to Supabase Storage
class _ApplicationDetailsDialog extends StatefulWidget {
  final VisaApplicationModel application;

  const _ApplicationDetailsDialog({required this.application});

  @override
  State<_ApplicationDetailsDialog> createState() =>
      _ApplicationDetailsDialogState();
}

class _ApplicationDetailsDialogState extends State<_ApplicationDetailsDialog> {
  late String _currentStatus;
  late TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.application.status;
    _notesCtrl = TextEditingController(
      text: widget.application.adminNotes ?? '',
    );
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.application;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 850),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Visa Application Details',
                      style: AppTextStyles.h4.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Reference: ${a.referenceNumber} • Created ${a.createdAt.toIso8601String().split('T').first}',
                      style: const TextStyle(
                        color: AppColors.gray600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 14),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status & Quick Update Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.lightGray,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.gray300),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Application Status:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 14),
                          DropdownButton<String>(
                            value: _currentStatus,
                            items: VisaApplicationStatus.all.map((s) {
                              return DropdownMenuItem(
                                value: s,
                                child: Text(
                                  VisaApplicationStatus.displayName(s, false),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null)
                                setState(() => _currentStatus = val);
                            },
                          ),
                          const Spacer(),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.navy,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              await context
                                  .read<AdminVisaCubit>()
                                  .updateApplicationStatus(
                                    a.id,
                                    _currentStatus,
                                    adminNotes: _notesCtrl.text.trim(),
                                  );
                              if (context.mounted) Navigator.of(context).pop();
                            },
                            child: const Text('Update Status'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Section 1: Applicant Information
                    Text(
                      'Applicant Personal Information',
                      style: AppTextStyles.labelLG.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _infoGrid([
                      ('Full Legal Name', a.fullName),
                      ('Email Address', a.email),
                      ('Phone / WhatsApp', a.phone),
                      ('Nationality', a.nationality),
                      ('Passport Number', a.passportNumber),
                      (
                        'Date of Birth',
                        a.dateOfBirth.toIso8601String().split('T').first,
                      ),
                    ]),
                    const SizedBox(height: 18),

                    // Section 2: Visa & Travel Schedule
                    Text(
                      'Visa & Travel Schedule',
                      style: AppTextStyles.labelLG.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _infoGrid([
                      ('Destination Country', a.country),
                      ('Visa Category', a.visaType),
                      (
                        'Expected Travel Date',
                        a.expectedTravelDate.toIso8601String().split('T').first,
                      ),
                      (
                        'Return Date',
                        a.returnDate != null
                            ? a.returnDate!.toIso8601String().split('T').first
                            : 'Not Specified',
                      ),
                      ('Purpose of Travel', a.travelPurpose),
                      ('Estimated Fees', '\$${a.estimatedFee.toInt()}'),
                    ]),
                    const SizedBox(height: 18),

                    // Section 3: Uploaded Documents in Supabase Storage
                    Text(
                      'Uploaded Documents (${a.documents.length})',
                      style: AppTextStyles.labelLG.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (a.documents.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.lightGray,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'No digital documents uploaded by applicant yet.',
                          style: TextStyle(color: AppColors.gray600),
                        ),
                      )
                    else
                      Column(
                        children: a.documents.entries.map((doc) {
                          final docKey = doc.key;
                          final docVal = doc.value.toString();
                          final isNetworkUrl =
                              docVal.startsWith('http://') ||
                              docVal.startsWith('https://');
                          // Extract filename from URL for download
                          final downloadName = Uri.decodeFull(
                            docVal.contains('/')
                                ? docVal.split('/').last
                                : '$docKey-file',
                          );
                          final isPdf = downloadName.toLowerCase().endsWith(
                            '.pdf',
                          );
                          // Supabase ?download= forces browser to download (works cross-origin)
                          final downloadUrl = '$docVal?download=$downloadName';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.lightGray,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.gray300),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isPdf
                                      ? Icons.picture_as_pdf_rounded
                                      : Icons.insert_drive_file_rounded,
                                  color: isPdf
                                      ? AppColors.errorRed
                                      : AppColors.royalBlue,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        docKey,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        downloadName,
                                        style: const TextStyle(
                                          color: AppColors.gray600,
                                          fontSize: 11,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (isNetworkUrl) ...[
                                  // Open in new tab (for images); PDFs open via download to avoid MIME issue
                                  if (!isPdf)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.open_in_new_rounded,
                                        color: AppColors.navy,
                                        size: 18,
                                      ),
                                      tooltip: 'View in New Tab',
                                      onPressed: () =>
                                          html.window.open(docVal, '_blank'),
                                    ),
                                  // Download button — uses ?download= (cross-origin safe)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.download_rounded,
                                      color: AppColors.successGreen,
                                      size: 20,
                                    ),
                                    tooltip: 'Download $downloadName',
                                    onPressed: () =>
                                        html.window.open(downloadUrl, '_self'),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 18),

                    // Section 4: Internal Admin Notes
                    Text(
                      'Internal Consular Review Notes',
                      style: AppTextStyles.labelLG.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText:
                            'Add internal processing notes, embassy appointment date/time, or missing document list...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: AppColors.lightGray,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoGrid(List<(String, String)> items) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        children: items.map((item) {
          return SizedBox(
            width: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.$1,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.gray600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.$2,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.navyDark,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _VisaFormDialog extends StatefulWidget {
  final VisaServiceModel? service;
  final Future<void> Function(VisaServiceModel) onSave;

  const _VisaFormDialog({this.service, required this.onSave});

  @override
  State<_VisaFormDialog> createState() => _VisaFormDialogState();
}

class _VisaFormDialogState extends State<_VisaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _countryCtrl;
  late TextEditingController _countryArCtrl;
  late TextEditingController _typeCtrl;
  late TextEditingController _processingCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _descArCtrl;
  late TextEditingController _flagCtrl;
  late bool _active;
  late List<String> _requirements;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.service;
    _countryCtrl = TextEditingController(text: s?.country ?? '');
    _countryArCtrl = TextEditingController(text: s?.countryAr ?? '');
    _typeCtrl = TextEditingController(text: s?.visaType ?? 'Tourist Visa');
    _processingCtrl = TextEditingController(
      text: s?.processingTime ?? '3-5 Business Days',
    );
    _priceCtrl = TextEditingController(
      text: s != null ? s.price.toStringAsFixed(0) : '150',
    );
    _descCtrl = TextEditingController(text: s?.description ?? '');
    _descArCtrl = TextEditingController(text: s?.descriptionAr ?? '');
    _flagCtrl = TextEditingController(text: s?.flagEmoji ?? '✈️');
    _active = s?.active ?? true;
    _requirements = List<String>.from(
      s?.requirements.map((r) => r.requirement) ??
          [
            'Valid Passport (minimum 6 months validity)',
            '2 Recent Passport-Size Photographs',
            'Bank Statement (last 3 months)',
            'Confirmed Flight & Hotel Reservation',
          ],
    );
  }

  @override
  void dispose() {
    _countryCtrl.dispose();
    _countryArCtrl.dispose();
    _typeCtrl.dispose();
    _processingCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _descArCtrl.dispose();
    _flagCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.service == null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 800),
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isNew ? 'Add Visa Service' : 'Edit Visa Service',
                    style: AppTextStyles.h4.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _countryCtrl,
                              decoration: InputDecoration(
                                labelText: 'Country Name (English) *',
                                hintText: 'e.g. United Kingdom',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Country is required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: _flagCtrl,
                              decoration: InputDecoration(
                                labelText: 'Flag / Icon',
                                hintText: '🇬🇧',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _countryArCtrl,
                        textDirection: TextDirection.rtl,
                        decoration: InputDecoration(
                          labelText: 'Country Name (Arabic)',
                          hintText: 'مثال: المملكة المتحدة',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _typeCtrl,
                              decoration: InputDecoration(
                                labelText: 'Visa Type *',
                                hintText: 'e.g. Tourist / Business',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Visa type is required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _processingCtrl,
                              decoration: InputDecoration(
                                labelText: 'Processing Time *',
                                hintText: 'e.g. 5-7 Business Days',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Processing time required'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Service Price (USD) *',
                          hintText: '180',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (v) =>
                            v == null || double.tryParse(v.trim()) == null
                            ? 'Enter valid price'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _descCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Description (English)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _descArCtrl,
                        textDirection: TextDirection.rtl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Description (Arabic)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Dynamic Visa Requirements Editor
                      AdminBulletListEditor(
                        label: 'Visa Application Requirements *',
                        hint: 'Add requirement (e.g. Bank Statement)',
                        items: _requirements,
                        onChanged: (items) => _requirements = items,
                      ),
                      const SizedBox(height: 14),
                      SwitchListTile(
                        title: const Text(
                          'Active Service',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        value: _active,
                        activeColor: AppColors.success,
                        onChanged: (v) => setState(() => _active = v),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                    ),
                    onPressed: _isSaving
                        ? null
                        : () async {
                            if (_formKey.currentState?.validate() == true) {
                              setState(() => _isSaving = true);
                              final s = VisaServiceModel(
                                id: widget.service?.id ?? '',
                                country: _countryCtrl.text.trim(),
                                countryAr: _countryArCtrl.text.trim().isNotEmpty
                                    ? _countryArCtrl.text.trim()
                                    : null,
                                visaType: _typeCtrl.text.trim(),
                                processingTime: _processingCtrl.text.trim(),
                                price: double.parse(_priceCtrl.text.trim()),
                                description: _descCtrl.text.trim(),
                                descriptionAr:
                                    _descArCtrl.text.trim().isNotEmpty
                                    ? _descArCtrl.text.trim()
                                    : null,
                                flagEmoji: _flagCtrl.text.trim(),
                                requirements: _requirements
                                    .asMap()
                                    .entries
                                    .map(
                                      (e) => VisaRequirementModel(
                                        id: '',
                                        visaServiceId: widget.service?.id ?? '',
                                        requirement: e.value,
                                      ),
                                    )
                                    .toList(),
                                active: _active,
                                createdAt:
                                    widget.service?.createdAt ?? DateTime.now(),
                                updatedAt: DateTime.now(),
                              );
                              await widget.onSave(s);
                              if (mounted) setState(() => _isSaving = false);
                            }
                          },
                    child: Text(isNew ? 'Create Visa Service' : 'Save Changes'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

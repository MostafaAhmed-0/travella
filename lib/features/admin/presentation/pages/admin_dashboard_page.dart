import 'package:flutter/material.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common_widgets.dart';

/// Admin dashboard placeholder
class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  static const _stats = <_DashboardStatData>[
    _DashboardStatData(
      title: 'Total Bookings',
      value: '248',
      icon: Icons.calendar_month_rounded,
      color: AppColors.royalBlue,
    ),
    _DashboardStatData(
      title: 'Active Tours',
      value: '36',
      icon: Icons.flight_takeoff_rounded,
      color: AppColors.navy,
    ),
    _DashboardStatData(
      title: 'Total Revenue',
      value: '\$128K',
      icon: Icons.attach_money_rounded,
      color: AppColors.gold,
    ),
    _DashboardStatData(
      title: 'Happy Clients',
      value: '1,420',
      icon: Icons.people_alt_rounded,
      color: AppColors.success,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(context);
    final gap = _gx(context, mobile: 12, tablet: 16, desktop: 20);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: AppBreakpoints.horizontalPadding(context),
        vertical: AppBreakpoints.value<double>(
          context,
          mobile: 20,
          tablet: 28,
          desktop: 32,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard', style: _rt(context, AppTextStyles.h2)),
          SizedBox(height: _gx(context, mobile: 4, desktop: 6)),
          Text(
            'Welcome back, Admin',
            style: _rt(context, AppTextStyles.bodyMD),
          ),
          SizedBox(height: _gx(context, mobile: 20, tablet: 28, desktop: 32)),
          // Stats grid — column count follows the width actually available
          LayoutBuilder(
            builder: (context, constraints) {
              final columns =
                  (constraints.maxWidth / 190).floor().clamp(1, 4);
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: gap,
                mainAxisSpacing: gap,
                childAspectRatio: isMobile ? 2.1 : 1.6,
                children: [
                  for (final stat in _stats)
                    _DashboardStatCard(
                      data: stat,
                      compact: columns == 1,
                    ),
                ],
              );
            },
          ),
          SizedBox(height: _gx(context, mobile: 20, tablet: 28, desktop: 32)),
          TravellaCard(
            padding: EdgeInsets.all(_gx(context, mobile: 16, desktop: 24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Bookings',
                  style: _rt(context, AppTextStyles.h5),
                ),
                SizedBox(height: _gx(context, mobile: 10, desktop: 16)),
                Text(
                  'Booking management will be implemented in a future phase.',
                  style: _rt(context, AppTextStyles.bodyMD),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardStatData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _DashboardStatData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _DashboardStatCard extends StatelessWidget {
  final _DashboardStatData data;
  final bool compact;

  const _DashboardStatCard({required this.data, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final iconSize = AppBreakpoints.isMobile(context) ? 40.0 : 48.0;

    return TravellaCard(
      padding: EdgeInsets.all(
        AppBreakpoints.value<double>(context, mobile: 12, tablet: 16, desktop: 20),
      ),
      child: Row(
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: data.color, size: iconSize / 2),
          ),
          SizedBox(
            width: AppBreakpoints.value<double>(
              context,
              mobile: 10,
              tablet: 14,
              desktop: 16,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.value,
                  style: _rt(context, AppTextStyles.h3).copyWith(
                    fontSize: compact ? AppTextStyles.h4.fontSize : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  data.title,
                  style: _rt(context, AppTextStyles.bodyXS),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Local responsive helpers ─────────────────────────────────────────────
/// Below this width, hand-built tables become stacked record cards.
const double kTableBreakpoint = 720;

/// A text style that scales down on small screens.
TextStyle _rt(BuildContext context, TextStyle base) =>
    AppTextStyles.responsive(
      base,
      isMobile: AppBreakpoints.isMobile(context),
      isTablet: AppBreakpoints.isTablet(context),
    );

/// A spacing value that follows the device size.
double _gx(
  BuildContext context, {
  double mobile = 12,
  double tablet = 16,
  double desktop = 20,
}) =>
    AppBreakpoints.value<double>(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );

/// Lays the children out in a [Row] when there is room, otherwise stacks
/// them vertically. Each child gets an equal share of the width.
Widget _stackBelowWidth(
  BuildContext context, {
  required double width,
  double breakpoint = 560,
  required List<Widget> children,
  double spacing = 12,
  CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
}) {
  if (width >= breakpoint) {
    return Row(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          Expanded(child: children[i]),
        ],
      ],
    );
  }
  return Column(
    crossAxisAlignment: crossAxisAlignment,
    children: [
      for (var i = 0; i < children.length; i++) ...[
        if (i > 0) SizedBox(height: spacing),
        SizedBox(width: double.infinity, child: children[i]),
      ],
    ],
  );
}
import 'package:flutter/material.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../shared/presentation/widgets/placeholder_page.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'Book a Tour',
        subtitle: 'Start planning your perfect getaway today',
        icon: Icons.calendar_month_rounded,
        currentRoute: AppRoutes.booking,
      );
}

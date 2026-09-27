import 'package:flutter/material.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../shared/presentation/widgets/placeholder_page.dart';

class VisaServicesPage extends StatelessWidget {
  const VisaServicesPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'Visa Services',
        subtitle: 'Fast, reliable visa assistance for your global journeys',
        icon: Icons.article_rounded,
        currentRoute: AppRoutes.visaServices,
      );
}

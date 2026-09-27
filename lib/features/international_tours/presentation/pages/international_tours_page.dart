import 'package:flutter/material.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../shared/presentation/widgets/placeholder_page.dart';

class InternationalToursPage extends StatelessWidget {
  const InternationalToursPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'International Tours',
        subtitle: 'Curated international experiences across 5 continents',
        icon: Icons.flight_takeoff_rounded,
        currentRoute: AppRoutes.internationalTours,
      );
}

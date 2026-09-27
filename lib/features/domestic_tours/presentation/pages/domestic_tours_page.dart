import 'package:flutter/material.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../shared/presentation/widgets/placeholder_page.dart';

class DomesticToursPage extends StatelessWidget {
  const DomesticToursPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'Domestic Tours',
        subtitle: 'Explore the beauty of your homeland with our curated packages',
        icon: Icons.landscape_rounded,
        currentRoute: AppRoutes.domesticTours,
      );
}

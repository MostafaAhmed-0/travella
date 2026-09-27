import 'package:flutter/material.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../shared/presentation/widgets/placeholder_page.dart';

class DestinationsPage extends StatelessWidget {
  const DestinationsPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'Destinations',
        subtitle: 'Discover breathtaking destinations around the globe',
        icon: Icons.place_rounded,
        currentRoute: AppRoutes.destinations,
      );
}

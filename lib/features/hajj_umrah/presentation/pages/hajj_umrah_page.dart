import 'package:flutter/material.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../shared/presentation/widgets/placeholder_page.dart';

class HajjUmrahPage extends StatelessWidget {
  const HajjUmrahPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'Hajj & Umrah',
        subtitle: 'Sacred journeys with full spiritual support and guidance',
        icon: Icons.mosque_rounded,
        currentRoute: AppRoutes.hajjUmrah,
      );
}

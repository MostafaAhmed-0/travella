import 'package:flutter/material.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../shared/presentation/widgets/placeholder_page.dart';

class HotelsPage extends StatelessWidget {
  const HotelsPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'Hotels',
        subtitle: 'Premium accommodations at competitive rates worldwide',
        icon: Icons.hotel_rounded,
        currentRoute: AppRoutes.hotels,
      );
}

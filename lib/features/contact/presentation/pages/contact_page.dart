import 'package:flutter/material.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../shared/presentation/widgets/placeholder_page.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'Contact Us',
        subtitle: 'Get in touch with our travel experts',
        icon: Icons.contact_support_rounded,
        currentRoute: AppRoutes.contact,
      );
}

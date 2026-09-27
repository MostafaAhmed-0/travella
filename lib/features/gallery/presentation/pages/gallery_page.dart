import 'package:flutter/material.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../shared/presentation/widgets/placeholder_page.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'Gallery',
        subtitle: 'Visual stories from destinations around the world',
        icon: Icons.photo_library_rounded,
        currentRoute: AppRoutes.gallery,
      );
}

import 'package:flutter/material.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../shared/presentation/widgets/placeholder_page.dart';

class BlogsPage extends StatelessWidget {
  const BlogsPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(
        title: 'Travel Blog',
        subtitle: 'Stories, tips and travel guides from around the world',
        icon: Icons.article_rounded,
        currentRoute: AppRoutes.blog,
      );
}

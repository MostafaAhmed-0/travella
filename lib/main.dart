import 'package:flutter/material.dart';
import 'package:travella/core/localization/app_locales.dart';
import 'package:travella/core/routing/app_router.dart';
import 'package:travella/core/theme/app_theme.dart';
// import 'package:travella/data/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  // await SupabaseService.initialize();

  runApp(const TravellaApp());
}

class TravellaApp extends StatefulWidget {
  const TravellaApp({super.key});

  @override
  State<TravellaApp> createState() => _TravellaAppState();
}

class _TravellaAppState extends State<TravellaApp> {
  final LocaleManager _localeManager = LocaleManager();

  @override
  void dispose() {
    _localeManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _localeManager,
      builder: (context, _) {
        return MaterialApp.router(
          // App Info
          title: 'Travella — Explore a Brighter World',
          debugShowCheckedModeBanner: false,

          // Theme
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,

          // Routing
          routerConfig: AppRouter.router,

          // Localization
          locale: _localeManager.locale,
          supportedLocales: AppLocales.supportedLocales,
          localizationsDelegates: AppLocales.delegates,

          // Directionality handled by MaterialApp via locale
          builder: (context, child) {
            return Directionality(
              textDirection: _localeManager.isRtl
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}

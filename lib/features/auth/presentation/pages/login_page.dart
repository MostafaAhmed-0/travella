import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/animations/animation_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(context);
    return Scaffold(
      backgroundColor: AppColors.navyDark,
      body: Row(
        children: [
          // Left decorative panel (desktop only)
          if (!isMobile)
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.navyDark, AppColors.navyMedium],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.flight_takeoff_rounded,
                          color: AppColors.navy,
                          size: 44,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'TRAVELLA',
                        style: AppTextStyles.displaySM.copyWith(
                          color: AppColors.white,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'EXPLORE A BRIGHTER WORLD',
                        style: AppTextStyles.labelMD.copyWith(
                          color: AppColors.gold,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Right form panel
          Expanded(
            child: Container(
              color: AppColors.white,
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 24 : 48),
                  child: MaxWidthContainer(
                    maxWidth: 420,
                    child: FadeInOnScroll(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Admin Sign In',
                            style: AppTextStyles.h2,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter your credentials to access the dashboard',
                            style: AppTextStyles.bodyMD,
                          ),
                          const SizedBox(height: 40),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _emailCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Email Address',
                                    prefixIcon: Icon(Icons.email_outlined),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) =>
                                      v?.isEmpty == true ? 'Email is required' : null,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _passwordCtrl,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                      onPressed: () => setState(
                                          () => _obscurePassword = !_obscurePassword),
                                    ),
                                  ),
                                  validator: (v) =>
                                      v?.isEmpty == true ? 'Password is required' : null,
                                ),
                                const SizedBox(height: 32),
                                TravellaButton(
                                  label: 'Sign In',
                                  fullWidth: true,
                                  isLoading: _isLoading,
                                  size: TravellaButtonSize.lg,
                                  onPressed: () {
                                    if (_formKey.currentState?.validate() == true) {
                                      setState(() => _isLoading = true);
                                      // Auth will be implemented with Supabase in Auth feature
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

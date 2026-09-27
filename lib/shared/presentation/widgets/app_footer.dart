import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/responsive/app_breakpoints.dart';

/// App footer shown on all public pages
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final hPad = AppBreakpoints.horizontalPadding(context);
    final isMobile = AppBreakpoints.isMobile(context);

    return Container(
      color: AppColors.surfaceFooter,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 64),
      child: MaxWidthContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top section
            isMobile
                ? _MobileFooterTop()
                : _DesktopFooterTop(),
            const SizedBox(height: 48),
            const Divider(color: AppColors.gray700, thickness: 1),
            const SizedBox(height: 24),
            // Bottom bar
            Wrap(
              spacing: 24,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Text(
                  '© 2024 Travella Tour & Travel. All rights reserved.',
                  style: AppTextStyles.bodyXS.copyWith(
                    color: AppColors.textOnDarkMuted,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _FooterLink(label: 'Privacy Policy', onTap: () {}),
                    const SizedBox(width: 24),
                    _FooterLink(label: 'Terms of Service', onTap: () {}),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopFooterTop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand column
        const Expanded(flex: 2, child: _BrandColumn()),
        const SizedBox(width: 48),
        // Services column
        Expanded(child: _FooterLinkColumn(
          title: 'Services',
          links: [
            ('International Tours', AppRoutes.internationalToursName),
            ('Domestic Tours', AppRoutes.domesticToursName),
            ('Visa Services', AppRoutes.visaServicesName),
            ('Hotels', AppRoutes.hotelsName),
            ('Hajj & Umrah', AppRoutes.hajjUmrahName),
          ],
        )),
        // Company column
        Expanded(child: _FooterLinkColumn(
          title: 'Company',
          links: [
            ('About Us', AppRoutes.homeName),
            ('Gallery', AppRoutes.galleryName),
            ('Blog', AppRoutes.blogName),
            ('Contact', AppRoutes.contactName),
          ],
        )),
        // Contact column
        const Expanded(child: _ContactColumn()),
      ],
    );
  }
}

class _MobileFooterTop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BrandColumn(),
        SizedBox(height: 32),
        _ContactColumn(),
      ],
    );
  }
}

class _BrandColumn extends StatelessWidget {
  const _BrandColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.flight_takeoff_rounded,
                color: AppColors.navy,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TRAVELLA',
                  style: AppTextStyles.h6.copyWith(
                    color: AppColors.white,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'TOUR & TRAVEL',
                  style: AppTextStyles.labelSM.copyWith(
                    color: AppColors.gold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Explore a Brighter World with Travella — your premium partner for unforgettable travel experiences.',
          style: AppTextStyles.bodySM.copyWith(color: AppColors.textOnDarkMuted),
        ),
        const SizedBox(height: 20),
        // Social icons
        Row(
          children: [
            _SocialIcon(icon: Icons.facebook, onTap: () {}),
            const SizedBox(width: 12),
            _SocialIcon(icon: Icons.camera_alt_rounded, onTap: () {}),
            const SizedBox(width: 12),
            _SocialIcon(icon: Icons.play_arrow_rounded, onTap: () {}),
          ],
        ),
      ],
    );
  }
}

class _ContactColumn extends StatelessWidget {
  const _ContactColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact',
          style: AppTextStyles.h6.copyWith(color: AppColors.white),
        ),
        const SizedBox(height: 16),
        _ContactItem(icon: Icons.email_rounded, text: 'info@travella.com'),
        const SizedBox(height: 10),
        _ContactItem(icon: Icons.phone_rounded, text: '+1 (800) TRAVELLA'),
        const SizedBox(height: 10),
        _ContactItem(icon: Icons.location_on_rounded, text: 'Your City, Country'),
      ],
    );
  }
}

class _FooterLinkColumn extends StatelessWidget {
  final String title;
  final List<(String, String)> links;

  const _FooterLinkColumn({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h6.copyWith(color: AppColors.white)),
        const SizedBox(height: 16),
        ...links.map((link) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _FooterLink(
                label: link.$1,
                onTap: () => context.goNamed(link.$2),
              ),
            )),
      ],
    );
  }
}

class _FooterLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterLink({required this.label, required this.onTap});

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.label,
          style: AppTextStyles.bodySM.copyWith(
            color: _hovered ? AppColors.gold : AppColors.textOnDarkMuted,
          ),
        ),
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.gold, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySM.copyWith(color: AppColors.textOnDarkMuted),
          ),
        ),
      ],
    );
  }
}

class _SocialIcon extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SocialIcon({required this.icon, required this.onTap});

  @override
  State<_SocialIcon> createState() => _SocialIconState();
}

class _SocialIconState extends State<_SocialIcon> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _hovered ? AppColors.gold : AppColors.gray700,
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.icon,
            color: _hovered ? AppColors.navy : AppColors.gray300,
            size: 18,
          ),
        ),
      ),
    );
  }
}

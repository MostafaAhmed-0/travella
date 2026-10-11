import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/external_link_helper.dart';
import '../../../../data/models/site_settings_model.dart';
import '../../../features/site_settings/presentation/cubit/site_settings_cubit.dart';

enum SocialLinksVariant {
  footer,
  card,
  prominent,
}

/// Reusable social links bar that dynamically reads URLs from site_settings.
///
/// Rules:
/// 1. URLs are NEVER hardcoded.
/// 2. If a social URL is empty, the icon is completely HIDDEN.
/// 3. Clicking any link opens it in a new browser tab (`target="_blank"`).
/// 4. Facebook link is verified and clearly identified.
class SocialLinksBar extends StatelessWidget {
  final SiteSettingsModel? customSettings;
  final SocialLinksVariant variant;
  final double iconSize;
  final double spacing;
  final MainAxisAlignment alignment;

  const SocialLinksBar({
    super.key,
    this.customSettings,
    this.variant = SocialLinksVariant.footer,
    this.iconSize = 18.0,
    this.spacing = 12.0,
    this.alignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final settings = customSettings ??
        (context.watch<SiteSettingsCubit?>()?.state.settings ??
            SiteSettingsModel.initial());

    // Build the list of active social items only
    final List<_SocialItemData> activeItems = [];

    // 1. Facebook (Verified)
    if (settings.hasFacebook) {
      activeItems.add(
        _SocialItemData(
          name: 'Facebook',
          icon: FontAwesomeIcons.facebookF,
          url: settings.facebookUrl,
          tooltip: 'Official Travella Facebook Page (Verified)',
          brandColor: const Color(0xFF1877F2),
          isVerified: true,
        ),
      );
    }

    // 2. Instagram
    if (settings.hasInstagram) {
      activeItems.add(
        _SocialItemData(
          name: 'Instagram',
          icon: FontAwesomeIcons.instagram,
          url: settings.instagramUrl,
          tooltip: 'Follow @travella on Instagram',
          brandColor: const Color(0xFFE4405F),
        ),
      );
    }

    // 3. WhatsApp
    if (settings.hasWhatsapp) {
      activeItems.add(
        _SocialItemData(
          name: 'WhatsApp',
          icon: FontAwesomeIcons.whatsapp,
          url: settings.getWhatsAppUrl('Hello Travella! I would like to inquire about your travel services.'),
          tooltip: 'Direct WhatsApp Concierge (${settings.whatsappNumber})',
          brandColor: const Color(0xFF25D366),
          isWhatsApp: true,
        ),
      );
    }

    // 4. YouTube
    if (settings.hasYoutube) {
      activeItems.add(
        _SocialItemData(
          name: 'YouTube',
          icon: FontAwesomeIcons.youtube,
          url: settings.youtubeUrl,
          tooltip: 'Subscribe to Travella YouTube Channel',
          brandColor: const Color(0xFFFF0000),
        ),
      );
    }

    // 5. TikTok
    if (settings.hasTiktok) {
      activeItems.add(
        _SocialItemData(
          name: 'TikTok',
          icon: FontAwesomeIcons.tiktok,
          url: settings.tiktokUrl,
          tooltip: 'Follow Travella on TikTok',
          brandColor: const Color(0xFF00F2FE),
        ),
      );
    }

    // If all social links are empty, render nothing (no broken icons)
    if (activeItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < activeItems.length; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          _SocialIconButton(
            data: activeItems[i],
            variant: variant,
            iconSize: iconSize,
          ),
        ],
      ],
    );
  }
}

class _SocialItemData {
  final String name;
  final IconData icon;
  final String url;
  final String tooltip;
  final Color brandColor;
  final bool isVerified;
  final bool isWhatsApp;

  const _SocialItemData({
    required this.name,
    required this.icon,
    required this.url,
    required this.tooltip,
    required this.brandColor,
    this.isVerified = false,
    this.isWhatsApp = false,
  });
}

class _SocialIconButton extends StatefulWidget {
  final _SocialItemData data;
  final SocialLinksVariant variant;
  final double iconSize;

  const _SocialIconButton({
    required this.data,
    required this.variant,
    required this.iconSize,
  });

  @override
  State<_SocialIconButton> createState() => _SocialIconButtonState();
}

class _SocialIconButtonState extends State<_SocialIconButton> {
  bool _isHovered = false;

  void _handleTap() {
    ExternalLinkHelper.openExternalUrl(widget.data.url);
  }

  @override
  Widget build(BuildContext context) {
    final double buttonSize = widget.iconSize * 2.1;

    Color bg;
    Color iconColor;
    Border? border;

    switch (widget.variant) {
      case SocialLinksVariant.footer:
        bg = _isHovered ? AppColors.gold : AppColors.gray700;
        iconColor = _isHovered ? AppColors.navyDark : AppColors.gray300;
        break;
      case SocialLinksVariant.card:
        bg = _isHovered ? widget.data.brandColor : AppColors.surfaceLight;
        iconColor = _isHovered ? AppColors.white : AppColors.navy;
        border = Border.all(
          color: _isHovered ? widget.data.brandColor : AppColors.borderLight,
        );
        break;
      case SocialLinksVariant.prominent:
        bg = _isHovered ? widget.data.brandColor : AppColors.navyMedium;
        iconColor = _isHovered ? AppColors.white : AppColors.gold;
        border = Border.all(
          color: _isHovered ? widget.data.brandColor : AppColors.gold.withValues(alpha: 0.3),
        );
        break;
    }

    return Tooltip(
      message: widget.data.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: _handleTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: border,
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: widget.data.brandColor.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                FaIcon(
                  widget.data.icon,
                  size: widget.iconSize,
                  color: iconColor,
                ),
                if (widget.data.isVerified && widget.variant != SocialLinksVariant.footer)
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

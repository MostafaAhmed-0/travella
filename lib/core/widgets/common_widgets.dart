import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_constants.dart';

// ── TravellaButton ─────────────────────────────────────────────────────────────
enum TravellaButtonVariant { primary, secondary, outline, ghost, gold }
enum TravellaButtonSize { sm, md, lg }

class TravellaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final TravellaButtonVariant variant;
  final TravellaButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool fullWidth;

  const TravellaButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = TravellaButtonVariant.primary,
    this.size = TravellaButtonSize.md,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  EdgeInsets get _padding => switch (size) {
        TravellaButtonSize.sm =>
          const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        TravellaButtonSize.md =>
          const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        TravellaButtonSize.lg =>
          const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
      };

  TextStyle get _textStyle => switch (size) {
        TravellaButtonSize.sm => AppTextStyles.buttonSM,
        TravellaButtonSize.md => AppTextStyles.buttonMD,
        TravellaButtonSize.lg => AppTextStyles.buttonLG,
      };

  double get _iconSize => switch (size) {
        TravellaButtonSize.sm => 16,
        TravellaButtonSize.md => 18,
        TravellaButtonSize.lg => 20,
      };

  @override
  Widget build(BuildContext context) {
    Widget buttonChild = _buildContent();
    if (fullWidth) buttonChild = SizedBox(width: double.infinity, child: buttonChild);

    return switch (variant) {
      TravellaButtonVariant.primary => _PrimaryButton(
          onPressed: isLoading ? null : onPressed,
          padding: _padding,
          child: buttonChild,
        ),
      TravellaButtonVariant.secondary => _SecondaryButton(
          onPressed: isLoading ? null : onPressed,
          padding: _padding,
          child: buttonChild,
        ),
      TravellaButtonVariant.outline => _OutlineButton(
          onPressed: isLoading ? null : onPressed,
          padding: _padding,
          child: buttonChild,
        ),
      TravellaButtonVariant.ghost => _GhostButton(
          onPressed: isLoading ? null : onPressed,
          padding: _padding,
          child: buttonChild,
        ),
      TravellaButtonVariant.gold => _GoldButton(
          onPressed: isLoading ? null : onPressed,
          padding: _padding,
          child: buttonChild,
        ),
    };
  }

  Widget _buildContent() {
    if (isLoading) {
      return SizedBox(
        height: _iconSize,
        width: _iconSize,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(AppColors.white),
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, size: _iconSize),
          const SizedBox(width: 8),
        ],
        Text(label, style: _textStyle),
        if (trailingIcon != null) ...[
          const SizedBox(width: 8),
          Icon(trailingIcon, size: _iconSize),
        ],
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsets padding;

  const _PrimaryButton({
    required this.child,
    required this.onPressed,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.royalBlue,
        foregroundColor: AppColors.white,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
        ),
      ),
      child: child,
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsets padding;

  const _SecondaryButton({
    required this.child,
    required this.onPressed,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
        ),
      ),
      child: child,
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsets padding;

  const _OutlineButton({
    required this.child,
    required this.onPressed,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.royalBlue,
        side: const BorderSide(color: AppColors.royalBlue, width: 1.5),
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
        ),
      ),
      child: child,
    );
  }
}

class _GhostButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsets padding;

  const _GhostButton({
    required this.child,
    required this.onPressed,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.white,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          side: const BorderSide(color: AppColors.white, width: 1.5),
        ),
      ),
      child: child,
    );
  }
}

class _GoldButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsets padding;

  const _GoldButton({
    required this.child,
    required this.onPressed,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.navy,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
        ),
      ),
      child: child,
    );
  }
}

// ── SectionBadge ───────────────────────────────────────────────────────────────
class SectionBadge extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? textColor;

  const SectionBadge({
    super.key,
    required this.text,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: color ?? AppColors.royalBlueFaded,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: (color ?? AppColors.royalBlue).withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.overline.copyWith(
          color: textColor ?? AppColors.royalBlue,
          letterSpacing: 2.0,
        ),
      ),
    );
  }
}

// ── SectionHeader ──────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String badge;
  final String title;
  final String? subtitle;
  final CrossAxisAlignment alignment;
  final bool onDark;

  const SectionHeader({
    super.key,
    required this.badge,
    required this.title,
    this.subtitle,
    this.alignment = CrossAxisAlignment.start,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = onDark ? AppColors.white : AppColors.textPrimary;
    final subtitleColor = onDark ? AppColors.textOnDarkMuted : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        SectionBadge(
          text: badge,
          color: onDark ? AppColors.white.withValues(alpha: 0.1) : null,
          textColor: onDark ? AppColors.gold : null,
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: AppTextStyles.h2.copyWith(color: titleColor),
          textAlign: alignment == CrossAxisAlignment.center
              ? TextAlign.center
              : TextAlign.start,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 12),
          Text(
            subtitle!,
            style: AppTextStyles.bodyLG.copyWith(color: subtitleColor),
            textAlign: alignment == CrossAxisAlignment.center
                ? TextAlign.center
                : TextAlign.start,
          ),
        ],
      ],
    );
  }
}

// ── TravellaCard ───────────────────────────────────────────────────────────────
class TravellaCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final bool hasShadow;
  final bool hasBorder;
  final VoidCallback? onTap;

  const TravellaCard({
    super.key,
    required this.child,
    this.color,
    this.padding,
    this.borderRadius = AppConstants.cardBorderRadius,
    this.hasShadow = true,
    this.hasBorder = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.white,
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: hasBorder
                ? Border.all(color: AppColors.borderLight)
                : null,
            boxShadow: hasShadow
                ? [
                    BoxShadow(
                      color: AppColors.navy.withValues(alpha: 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}

// ── DividerWithText ────────────────────────────────────────────────────────────
class DividerWithText extends StatelessWidget {
  final String text;

  const DividerWithText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: AppTextStyles.caption,
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

// ── LoadingOverlay ─────────────────────────────────────────────────────────────
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          const Positioned.fill(
            child: ColoredBox(
              color: AppColors.overlay50,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── GradientText ──────────────────────────────────────────────────────────────
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient gradient;
  final TextAlign? textAlign;

  const GradientText({
    super.key,
    required this.text,
    this.style,
    this.gradient = AppColors.goldGradient,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: Text(text, style: style, textAlign: textAlign),
    );
  }
}

// ── NetworkImageWithFallback ───────────────────────────────────────────────────
class NetworkImageWithFallback extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final BorderRadius? borderRadius;

  const NetworkImageWithFallback({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;

    Widget buildError() =>
        placeholder ??
        Container(
          width: width,
          height: height,
          color: AppColors.lightGray,
          child: const Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.gray300,
            size: 48,
          ),
        );

    if (url == null || url.isEmpty) return buildError();

    Widget image = Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          width: width,
          height: height,
          color: AppColors.lightGray,
          child: Center(
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                      progress.expectedTotalBytes!
                  : null,
              color: AppColors.royalBlue,
              strokeWidth: 2,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => buildError(),
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}

// ── RatingStars ────────────────────────────────────────────────────────────────
class RatingStars extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final Color activeColor;
  final Color inactiveColor;

  const RatingStars({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 16,
    this.activeColor = AppColors.gold,
    this.inactiveColor = AppColors.gray200,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (i) {
        if (i < rating.floor()) {
          return Icon(Icons.star_rounded, size: size, color: activeColor);
        } else if (i < rating) {
          return Icon(Icons.star_half_rounded, size: size, color: activeColor);
        }
        return Icon(Icons.star_outline_rounded, size: size, color: inactiveColor);
      }),
    );
  }
}

// ── TagChip ────────────────────────────────────────────────────────────────────
class TagChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const TagChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: icon != null ? 10 : 12,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.lightGray,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor ?? AppColors.textSecondary),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.labelSM.copyWith(
              color: textColor ?? AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

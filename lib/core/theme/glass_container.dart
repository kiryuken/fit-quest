import 'dart:ui';

import 'package:flutter/material.dart';

import 'colors.dart';
import 'spacing.dart';
import 'text_styles.dart';

/// App-wide aurora canvas based on the layered radial gradients in design-ctx.
class AuroraBackground extends StatelessWidget {
  final Widget child;

  const AuroraBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned(
            left: -170,
            top: -150,
            width: 430,
            height: 430,
            child: _AuroraOrb(
              color: Color(0x666366F1),
              alignment: Alignment.topLeft,
            ),
          ),
          const Positioned(
            right: -210,
            top: 70,
            width: 460,
            height: 460,
            child: _AuroraOrb(
              color: Color(0x4D2DD4BF),
              alignment: Alignment.topRight,
            ),
          ),
          const Positioned(
            right: -130,
            bottom: -230,
            width: 500,
            height: 500,
            child: _AuroraOrb(
              color: Color(0x40EC4899),
              alignment: Alignment.bottomRight,
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _MicroGridPainter()),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _AuroraOrb extends StatelessWidget {
  final Color color;
  final Alignment alignment;

  const _AuroraOrb({required this.color, required this.alignment});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: alignment,
            radius: 0.9,
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

class _MicroGridPainter extends CustomPainter {
  const _MicroGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x08FFFFFF)
      ..strokeWidth = 0.5;
    const step = 32.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// High-fidelity blurred glass for navigation, headers, and hero surfaces.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final double blurSigma;
  final Color? bgColor;
  final double? width;
  final double? height;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.borderRadius =
        const BorderRadius.all(Radius.circular(AppSpacing.glassBorderRadius)),
    this.blurSigma = 18,
    this.bgColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: const [
            BoxShadow(
              color: Color(0x5E000000),
              blurRadius: 32,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: blurSigma,
              sigmaY: blurSigma,
            ),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: bgColor,
                gradient: bgColor == null
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0x26FFFFFF), Color(0x0DFFFFFF)],
                      )
                    : null,
                borderRadius: borderRadius,
                border: Border.all(color: AppColors.glassBorder),
              ),
              foregroundDecoration: BoxDecoration(
                borderRadius: borderRadius,
                border: Border.all(color: const Color(0x18FFFFFF)),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Lightweight glass card for repeated list content.
///
/// It preserves the translucent depth and light-catching border without a
/// BackdropFilter per row, avoiding the performance trap called out by the
/// reference.
class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.borderRadius =
        const BorderRadius.all(Radius.circular(AppSpacing.cardBorderRadius)),
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: backgroundColor == null
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0x1FFFFFFF), Color(0x0AFFFFFF)],
              )
            : null,
        borderRadius: borderRadius,
        border: Border.all(color: const Color(0x2EFFFFFF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Color(0x12FFFFFF),
            blurRadius: 1,
            offset: Offset(-1, -1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: onTap == null
            ? content
            : InkWell(
                onTap: onTap,
                splashColor: AppColors.accent.withValues(alpha: 0.16),
                highlightColor: AppColors.glassStrong,
                child: content,
              ),
      ),
    );
  }
}

class AuroraScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  const AuroraScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!, style: AppTextStyles.heading3),
              leading: leading,
              actions: actions,
              centerTitle: centerTitle,
            ),
      body: body,
    );
  }
}

class PageHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const PageHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(eyebrow.toUpperCase(), style: AppTextStyles.sectionTitle),
              const SizedBox(height: AppSpacing.sm),
              Text(title, style: AppTextStyles.heading1),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(subtitle!, style: AppTextStyles.body),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.lg),
          trailing!,
        ],
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title.toUpperCase(), style: AppTextStyles.sectionTitle),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!, style: AppTextStyles.buttonLabelSmall),
          ),
      ],
    );
  }
}

class GlassPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const GlassPill({
    super.key,
    required this.label,
    this.color = AppColors.accent,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: AppTextStyles.pillLabel.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class GlassIconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;

  const GlassIconBadge({
    super.key,
    required this.icon,
    this.color = AppColors.accent,
    this.size = 48,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.24),
            color.withValues(alpha: 0.07),
          ],
        ),
        borderRadius: BorderRadius.circular(size / 3),
        border: Border.all(color: color.withValues(alpha: 0.38)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.16),
            blurRadius: 18,
          ),
        ],
      ),
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}

class LiquidProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final Color color;
  final Color endColor;

  const LiquidProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.color = AppColors.accent,
    this.endColor = AppColors.pink,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = value.clamp(0.0, 1.0);
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.xpBarBg,
        borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
        border: Border.all(color: const Color(0x18FFFFFF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return TweenAnimationBuilder<double>(
            duration: AppSpacing.standard,
            curve: Curves.easeOutCubic,
            tween: Tween(end: normalized),
            builder: (context, progress, _) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: constraints.maxWidth * progress,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color, endColor]),
                    borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.45),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class GradientActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Gradient gradient;
  final Color foregroundColor;
  final bool loading;
  final double height;

  const GradientActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.gradient = AppColors.auroraGradient,
    this.foregroundColor = AppColors.textPrimary,
    this.loading = false,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.48,
        duration: AppSpacing.quick,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(AppSpacing.buttonBorderRadius),
            border: Border.all(color: const Color(0x52FFFFFF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x526366F1),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
              BoxShadow(
                color: Color(0x35FFFFFF),
                blurRadius: 1,
                offset: Offset(-1, -1),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.buttonBorderRadius),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: enabled ? onPressed : null,
              child: Center(
                child: loading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: foregroundColor,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (icon != null) ...[
                            Icon(icon, color: foregroundColor, size: 19),
                            const SizedBox(width: AppSpacing.sm),
                          ],
                          Flexible(
                            child: Text(
                              label,
                              style: AppTextStyles.buttonLabel.copyWith(
                                color: foregroundColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color color;

  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color = AppColors.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, color: color, size: 18),
          const SizedBox(height: AppSpacing.sm),
        ],
        Text(
          value,
          style: AppTextStyles.heading2.copyWith(color: color),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: AppTextStyles.caption, textAlign: TextAlign.center),
      ],
    );
  }
}

class EmptyGlassState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  const EmptyGlassState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: PremiumCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GlassIconBadge(icon: icon, size: 56, iconSize: 26),
              const SizedBox(height: AppSpacing.lg),
              Text(title, style: AppTextStyles.heading3),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSpacing.xl),
                GradientActionButton(
                  label: actionLabel!,
                  icon: actionIcon,
                  onPressed: onAction,
                  height: 48,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

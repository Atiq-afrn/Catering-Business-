import 'package:flutter/material.dart';
import '../../app/theme.dart';

enum ButtonVariant { primary, secondary, outline, danger }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonVariant variant;
  final bool isLoading;
  final bool isDense;
  final double? width;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.isDense = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    switch (variant) {
      case ButtonVariant.primary:
        bg = AppTheme.primaryDark;
        fg = Colors.white;
        break;
      case ButtonVariant.secondary:
        bg = AppTheme.accentEmerald;
        fg = Colors.white;
        break;
      case ButtonVariant.outline:
        bg = Colors.white;
        fg = AppTheme.primaryNavy;
        border = const BorderSide(color: AppTheme.borderLight, width: 1);
        break;
      case ButtonVariant.danger:
        bg = const Color(0xFFDC2626);
        fg = Colors.white;
        break;
    }

    final child = isLoading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: isDense ? 15 : 17, color: fg),
                const SizedBox(width: 6),
              ],
              Text(
                text,
                style: TextStyle(
                  color: fg,
                  fontSize: isDense ? 12.5 : 13.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          );

    return SizedBox(
      width: width,
      height: isDense ? 36 : 42,
      child: Material(
        color: onPressed == null ? bg.withAlpha(120) : bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
          side: border,
        ),
        child: InkWell(
          onTap: (isLoading || onPressed == null) ? null : onPressed,
          borderRadius: BorderRadius.circular(9),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isDense ? 12 : 16),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

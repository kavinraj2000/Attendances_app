import 'package:flutter/material.dart';

class ReusableButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final bool isLoading;
  final bool isOutlined;

  const ReusableButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.isLoading = false,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBackgroundColor = backgroundColor ?? theme.colorScheme.primary;
    final defaultTextColor = textColor ?? Colors.white;

    if (isLoading) {
      return SizedBox(
        width: width,
        height: height ?? 48,
        child: ElevatedButton(
          onPressed: null,
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (isOutlined) {
      return SizedBox(
        width: width,
        height: height ?? 48,
        child: icon != null
            ? OutlinedButton.icon(
                onPressed: onPressed,
                icon: Icon(icon, color: defaultBackgroundColor),
                label: Text(text),
                style: OutlinedButton.styleFrom(
                  foregroundColor: defaultBackgroundColor,
                  side: BorderSide(color: defaultBackgroundColor),
                ),
              )
            : OutlinedButton(
                onPressed: onPressed,
                style: OutlinedButton.styleFrom(
                  foregroundColor: defaultBackgroundColor,
                  side: BorderSide(color: defaultBackgroundColor),
                ),
                child: Text(text),
              ),
      );
    }

    return SizedBox(
      width: width,
      height: height ?? 48,
      child: icon != null
          ? ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, color: defaultTextColor),
              label: Text(text, style: TextStyle(color: defaultTextColor)),
              style: ElevatedButton.styleFrom(
                backgroundColor: defaultBackgroundColor,
              ),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: defaultBackgroundColor,
              ),
              child: Text(text, style: TextStyle(color: defaultTextColor)),
            ),
    );
  }
}

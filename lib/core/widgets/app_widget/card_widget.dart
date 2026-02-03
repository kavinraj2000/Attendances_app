import 'package:flutter/material.dart';
import 'package:hrm/core/constants/constants.dart';

/// REUSABLE CARD WIDGET
/// A customizable card that maintains consistent styling across the app
/// 
/// Usage Examples:
/// 
/// 1. Simple Card:
///    ReusableCard(
///      child: Text('Content'),
///    )
/// 
/// 2. Card with Padding:
///    ReusableCard(
///      padding: EdgeInsets.all(20),
///      child: Column(...),
///    )
/// 
/// 3. Gradient Card:
///    ReusableCard(
///      useGradient: true,
///      gradientColors: [Colors.blue, Colors.purple],
///      child: Text('Gradient Card'),
///    )
/// 
/// 4. Clickable Card:
///    ReusableCard(
///      onTap: () => print('Card tapped'),
///      child: ListTile(...),
///    )

class ReusableCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final double? borderRadius;
  final VoidCallback? onTap;
  final bool useGradient;
  final List<Color>? gradientColors;
  final Border? border;

  const ReusableCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.useGradient = false,
    this.gradientColors,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding ?? const EdgeInsets.all(8),
      decoration: useGradient
          ? BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors ?? [Constants.color.lightColors['primary']!, Constants.color.lightColors['secondary']!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(borderRadius ?? 16),
              border: border,
            )
          : null,
      child: child,
    );

    return Card(
      margin: margin ?? const EdgeInsets.only(bottom: 8),
      elevation: elevation ?? 2,
      color: useGradient ? Colors.transparent : color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
        side: border != null ? border!.top : BorderSide.none,
      ),
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(borderRadius ?? 8),
              child: content,
            )
          : content,
    );
  }
}

/// STAT CARD - Reusable card for displaying statistics
/// 
/// Usage:
///    StatCard(
///      title: 'Total Users',
///      value: '1,234',
///      icon: Icons.people,
///      color: Colors.blue,
///    )

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ReusableCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 8),
          const SizedBox(height: 8),
          Text(
            value,
            style: Constants.app.headerblack
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Constants.app.headerblack,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// INFO CARD - Card with icon and text info
/// 
/// Usage:
///    InfoCard(
///      icon: Icons.email,
///      title: 'Email',
///      subtitle: 'user@example.com',
///    )

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;
  final VoidCallback? onTap;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ReusableCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (iconColor ?? Constants.color.lightColors['primary']!).withOpacity(0.2),
          child: Icon(icon, color: iconColor ?? Constants.color.lightColors['primary']!),
        ),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style:  TextStyle(
            fontWeight: FontWeight.w500,
            color: Constants.color.lightColors['darkLight'],
          ),
        ),
        trailing: onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
      ),
    );
  }
}

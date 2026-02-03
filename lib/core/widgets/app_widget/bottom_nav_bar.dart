import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hrm/core/constants/constants.dart';
import 'package:hrm/core/constants/route_constants.dart';


class BottomNavBarWidget extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onIndexChanged;
  final VoidCallback? onHomeRefresh;

  const BottomNavBarWidget({
    super.key,
    required this.selectedIndex,
    this.onIndexChanged,
    this.onHomeRefresh,
  });

  List<Map<String, dynamic>> get _visibleNavItems {
    return RouteConstants.navbarItems; // Fixed
  }

  Widget _navItem({
    required Map<String, dynamic> item,
    required Color unselectedColor,
  }) {
    final int index = item['index'] as int;
    final String svgPath = item['svgPath'] ?? item['icon'] as String;
    final String svgSelectedPath = item['svgSelectedPath'] ?? svgPath;
    final String label = item['label'] as String;
    
    final isSelected = selectedIndex == index;
    final iconSize = isSelected ? 24.0 : 22.0;

    return Expanded(
      child: InkWell( // Changed from GestureDetector for better tap feedback
        onTap: () {
          HapticFeedback.lightImpact();
          
          if (selectedIndex == index) {
            if (index == RouteConstants.defaultHomeIndex && 
                onHomeRefresh != null) {
              onHomeRefresh!();
            }
            return;
          }
          onIndexChanged?.call(index);
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                isSelected ? svgSelectedPath : svgPath,
                width: iconSize,
                height: iconSize,
                colorFilter: isSelected 
                  ? null 
                  : ColorFilter.mode(unselectedColor, BlendMode.srcIn),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: Constants.app.headerblack.copyWith(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.black : unselectedColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unselectedColor = Colors.grey.shade500;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -1),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 18,
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: _visibleNavItems.map((item) {
          return _navItem(
            item: item,
            unselectedColor: unselectedColor,
          );
        }).toList(),
      ),
    );
  }
}
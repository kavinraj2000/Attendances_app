import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hrm/core/constants/route_constants.dart';

class BottomNavBarWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBarWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: RouteConstants.navbarItems.map((item) {
              return _buildNavItem(
                icon: item['icon'] as String,
                label: item['label'] as String,
                index: item['index'] as int,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String icon,
    required String label,
    required int index,
  }) {
    final isActive = currentIndex == index;

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              icon,
              width: 24,
              height: 24,
              color: isActive
                  ? const Color(0xFF667EEA)
                  : const Color(0xFF9E9E9E),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? const Color(0xFF667EEA)
                    : const Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:hrm/core/constants/constants.dart';

class ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const ProfileTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Constants.color.charcoal.withOpacity(0.05),
              blurRadius: 16, offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: Constants.color.sand,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, size: 19, color: Constants.color.terracotta),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                    style:  TextStyle(
                      fontSize: 11, color: Constants.color.warmGray,
                      fontWeight: FontWeight.w500, letterSpacing: 0.4,
                    )),
                  const SizedBox(height: 3),
                  Text(value,
                    style:  TextStyle(
                      fontSize: 14.5, color: Constants.color.charcoal,
                      fontWeight: FontWeight.w600,
                    )),
                ],
              ),
            ),
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: Constants.color.sand,
                borderRadius: BorderRadius.circular(10),
              ),
              child:  Icon(Icons.arrow_forward_ios_rounded,
                  size: 13, color: Constants.color.warmGray),
            ),
          ],
        ),
      ),
    );
  }
}
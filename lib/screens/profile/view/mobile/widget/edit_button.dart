import 'package:flutter/material.dart';
import 'package:hrm/core/constants/constants.dart';

class EditButton extends StatelessWidget {
  final VoidCallback onTap;
  const EditButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity, height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient:  LinearGradient(
              colors: [Constants.color.terracotta, Constants.color.terracottaLight],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Constants.color.terracotta.withOpacity(0.4),
                blurRadius: 20, offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit_outlined, size: 18, color: Colors.white),
              SizedBox(width: 8),
              Text('Edit Profile',
                style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: Colors.white, letterSpacing: 0.3,
                )),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:hrm/core/constants/constants.dart';
import 'package:hrm/core/model/profile_model.dart';
import 'package:hrm/screens/profile/view/mobile/widget/dash_ring_painter.dart';
import 'package:hrm/screens/profile/view/mobile/widget/state_painter.dart';


class HeroSection extends StatelessWidget {
  final ProfileModel profile;
  const HeroSection({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildAvatar(),
          const SizedBox(height: 16),
          Text(profile.name,
            style:  TextStyle(
              fontSize: 26, fontWeight: FontWeight.w800,
              color: Constants.color.charcoal, letterSpacing: -0.8, height: 1.0,
            )),
          const SizedBox(height: 5),
          Text(profile.title,
            style:  TextStyle(
              fontSize: 14, color: Constants.color.warmGray,
              fontWeight: FontWeight.w400, letterSpacing: 0.2,
            )),
          const SizedBox(height: 22),
          StatsStrip(
            followers: profile.followers,
            following: profile.following,
            projects:  profile.projects,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(painter: DashedRingPainter(), size: const Size(114, 114)),
        Container(
          width: 96, height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Constants.color.terracotta.withOpacity(0.3),
                blurRadius: 20, offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipOval(
            child: Container(
              decoration:  BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Constants.color.terracotta, Constants.color.terracottaLight],
                ),
              ),
              child: const Icon(Icons.person, size: 52, color: Colors.white),
            ),
          ),
        ),
        Positioned(
          bottom: 2, right: 2,
          child: Container(
            width: 26, height: 26,
            decoration: BoxDecoration(
              color: Constants.color.terracotta,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.camera_alt_outlined, size: 12, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:hrm/core/constants/constants.dart';

class StatsStrip extends StatelessWidget {
  final int followers;
  final int following;
  final int projects;

  const StatsStrip({
    super.key,
    required this.followers,
    required this.following,
    required this.projects,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Constants.color.charcoal.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatCell(value: '$followers', label: 'Followers'),
          ),
          _VertDivider(),
          Expanded(
            child: _StatCell(value: '$following', label: 'Following'),
          ),
          _VertDivider(),
          Expanded(
            child: _StatCell(value: '$projects', label: 'Projects'),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  const _StatCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Constants.color.charcoal,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Constants.color.warmGray,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 36, color: Constants.color.divider);
}

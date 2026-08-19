import 'package:flutter/material.dart';
import '../../../domain/entities/workout_session.dart';

class WeeklyWorkoutShareCard extends StatelessWidget {
  final List<WorkoutSession> weeklySessions;

  const WeeklyWorkoutShareCard({super.key, required this.weeklySessions});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A46A0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'WEEKLY PROGRESS',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Keep Grinding',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _buildWeekDays(),
          ),
          const SizedBox(height: 32),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'GYM TRACKER',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildWeekDays() {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    // In a real app, logic would map session dateKeys to these days.
    // Here we just show a consistent UI pattern.
    return days
        .map(
          (d) => Column(
            children: [
              Text(
                d,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white12),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 20),
              ),
            ],
          ),
        )
        .toList();
  }
}

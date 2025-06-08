import 'dart:math';
import 'package:flutter/material.dart';
import 'package:taskhub/config/theme/app_theme.dart';

class TaskProgressChart extends StatelessWidget {
  final int onTimePercentage;
  final int latePercentage;
  final int notCompletedPercentage;
  final int totalTasks;

  const TaskProgressChart({
    super.key,
    required this.onTimePercentage,
    required this.latePercentage,
    required this.notCompletedPercentage,
    required this.totalTasks,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: const Size(120, 120),
          painter: CircularProgressPainter(
            onTimePercentage: onTimePercentage,
            latePercentage: latePercentage,
            notCompletedPercentage: notCompletedPercentage,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$totalTasks',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Tugas',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final int onTimePercentage;
  final int latePercentage;
  final int notCompletedPercentage;

  CircularProgressPainter({
    required this.onTimePercentage,
    required this.latePercentage,
    required this.notCompletedPercentage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    const strokeWidth = 12.0;
    
    // Background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    
    canvas.drawCircle(center, radius - strokeWidth / 2, backgroundPaint);
    
    // Calculate angles
    final totalAngle = 2 * pi;
    final onTimeAngle = totalAngle * (onTimePercentage / 100);
    final lateAngle = totalAngle * (latePercentage / 100);
    final notCompletedAngle = totalAngle * (notCompletedPercentage / 100);
    
    // Draw not completed arc (grey)
    if (notCompletedPercentage > 0) {
      final notCompletedPaint = Paint()
        ..color = Colors.grey
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      
      final notCompletedStartAngle = -pi / 2 + onTimeAngle + lateAngle;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        notCompletedStartAngle,
        notCompletedAngle,
        false,
        notCompletedPaint,
      );
    }
    
    // Draw late arc (cyan)
    if (latePercentage > 0) {
      final latePaint = Paint()
        ..color = Colors.cyan
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      
      final lateStartAngle = -pi / 2 + onTimeAngle;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        lateStartAngle,
        lateAngle,
        false,
        latePaint,
      );
    }
    
    // Draw on time arc (blue)
    if (onTimePercentage > 0) {
      final onTimePaint = Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      
      const onTimeStartAngle = -pi / 2; // Start from top
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        onTimeStartAngle,
        onTimeAngle,
        false,
        onTimePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

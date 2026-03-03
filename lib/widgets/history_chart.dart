// lib/widgets/history_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/risk_model.dart';

class PSIHistoryChart extends StatelessWidget {
  final List<PSISnapshot> history;

  const PSIHistoryChart({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: Text(
          'Awaiting data...',
          style: TextStyle(
            color: Colors.white.withOpacity(0.3),
            fontFamily: 'monospace',
            fontSize: 12,
          ),
        ),
      );
    }

    final spots = history.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.psi * 100);
    }).toList();

    // Get current color
    final lastLevel = history.last.level;
    final color = Color(lastLevel.colorValue);

    return SizedBox(
      height: 110,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.white.withOpacity(0.05),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 25,
                reservedSize: 30,
                getTitlesWidget: (v, _) => Text(
                  '${v.toInt()}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.25),
                    fontSize: 9,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: color,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                checkToShowDot: (spot, _) => spot == spots.last,
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 4,
                  color: color,
                  strokeWidth: 0,
                  strokeColor: Colors.transparent,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.3),
                    color.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          // Threshold lines
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: 60,
                color: const Color(0xFFFF9F1C).withOpacity(0.25),
                strokeWidth: 1,
                dashArray: [4, 4],
              ),
              HorizontalLine(
                y: 80,
                color: const Color(0xFFFF3366).withOpacity(0.25),
                strokeWidth: 1,
                dashArray: [4, 4],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

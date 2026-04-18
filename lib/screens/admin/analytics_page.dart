import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_resource_alloc/theme/app_theme.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Reports'),
        actions: [
          IconButton(icon: const Icon(Icons.date_range), onPressed: () {}),
          IconButton(icon: const Icon(Icons.download), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Needs Fulfilled vs Reported', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 3), FlSpot(1, 4), FlSpot(2, 6),
                        FlSpot(3, 8), FlSpot(4, 5), FlSpot(5, 9), FlSpot(6, 12),
                      ],
                      isCurved: true,
                      color: AppTheme.urgentRed,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: AppTheme.urgentRed.withOpacity(0.2)),
                    ),
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 2), FlSpot(1, 4), FlSpot(2, 5),
                        FlSpot(3, 7), FlSpot(4, 6), FlSpot(5, 8), FlSpot(6, 10),
                      ],
                      isCurved: true,
                      color: AppTheme.healthGreen,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: AppTheme.healthGreen.withOpacity(0.2)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text('Average Response Time by Zone', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
             SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 60,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                     show: true,
                     bottomTitles: AxisTitles(
                       sideTitles: SideTitles(
                         showTitles: true,
                         getTitlesWidget: (double value, TitleMeta meta) {
                           const style = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10);
                           String text;
                           switch (value.toInt()) {
                             case 0: text = 'Indiranagar'; break;
                             case 1: text = 'Koramangala'; break;
                             case 2: text = 'HSR Layout'; break;
                             default: text = ''; break;
                           }
                           return SideTitleWidget(meta: meta, child: Text(text, style: style));
                         },
                       ),
                     ),
                     leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                     topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                     rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 15, color: AppTheme.accentBlue, width: 16, borderRadius: BorderRadius.circular(4))]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 35, color: AppTheme.accentBlue, width: 16, borderRadius: BorderRadius.circular(4))]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 22, color: AppTheme.accentBlue, width: 16, borderRadius: BorderRadius.circular(4))]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

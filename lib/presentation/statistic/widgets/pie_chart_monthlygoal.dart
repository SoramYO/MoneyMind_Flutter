import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartTransaction extends StatelessWidget {
  final Map<String, double> categoryPercentages;

  const PieChartTransaction({
    super.key,
    required this.categoryPercentages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 1.2,
            child: PieChart(
              PieChartData(
                sections: categoryPercentages.entries.map((entry) {
                  return PieChartSectionData(
                    color: _getCategoryColor(entry.key),
                    value: entry.value,
                    title: '${entry.value.toStringAsFixed(1)}%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
        ),
        _buildLegend(),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "Leisure":
        return Colors.blue;
      case "Education":
        return Colors.green;
      case "Charity":
        return Colors.red;
      case "Savings":
        return Colors.purple;
      case "Necessities":
        return Colors.orange;
      case "Financial Freedom":
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categoryPercentages.keys.map((category) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getCategoryColor(category),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                category,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
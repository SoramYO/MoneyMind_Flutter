import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_project/core/constants/app_colors.dart';

class BarChartTransaction extends StatefulWidget {
  final Map<String, double> groupedAmountTransactions;

  const BarChartTransaction(
      {super.key, required this.groupedAmountTransactions});

  @override
  _BarChartTransactionState createState() => _BarChartTransactionState();
}

class _BarChartTransactionState extends State<BarChartTransaction> {
  late Map<String, double> completeTransactions;
  late List<String> dates;
  late List<double> values;
  late List<BarChartGroupData> barGroups;
  late List<int> yearChangeIndexes;
  double maxY = 100;
  double? _touchedY; // Lưu vị trí cột được chọn

  @override
  void initState() {
    super.initState();
    _processData();
  }

  @override
  void didUpdateWidget(covariant BarChartTransaction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.groupedAmountTransactions !=
        oldWidget.groupedAmountTransactions) {
      _processData();
    }
  }

  void _processData() {
    if (widget.groupedAmountTransactions.isEmpty) {
      setState(() {});
      return;
    }

    List<DateTime> parsedDates =
        widget.groupedAmountTransactions.keys.map((date) {
      return DateFormat('dd/MM/yyyy').parse(date);
    }).toList();

    parsedDates.sort();
    DateTime startDate = parsedDates.first;
    DateTime endDate = parsedDates.last;

    completeTransactions = {};
    for (DateTime date = startDate;
        date.isBefore(endDate.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      String formattedDate = DateFormat('dd/MM/yyyy').format(date);
      completeTransactions[formattedDate] =
          widget.groupedAmountTransactions[formattedDate] ?? 0.0;
    }

    dates = completeTransactions.keys.toList();
    values = completeTransactions.values.toList();
    maxY = values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 100;

    barGroups = [];
    yearChangeIndexes = [];
    String? previousYear;

    for (int i = 0; i < dates.length; i++) {
      double value = completeTransactions[dates[i]] ?? 0.0;
      DateTime dateTime = DateFormat('dd/MM/yyyy').parse(dates[i]);
      String currentYear = dateTime.year.toString();
      if (previousYear != null && currentYear != previousYear) {
        yearChangeIndexes.add(i);
      }
      previousYear = currentYear;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value,
              color: AppColors.navy,
              width: 15,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.groupedAmountTransactions.isEmpty) {
      return const Center(
        child: Text(
          'No Data',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double chartWidth = dates.length * 50;
    double minWidth = screenWidth;
    double finalWidth = chartWidth < minWidth ? minWidth : chartWidth;

    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: finalWidth,
              child: BarChart(
                BarChartData(
                  maxY: maxY * 1.1,
                  alignment: BarChartAlignment.spaceEvenly,
                  barGroups: barGroups,
                  extraLinesData: _buildExtraLinesData(),
                  titlesData: FlTitlesData(
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          int index = value.toInt();
                          return index >= 0 && index < dates.length
                              ? Text(dates[index].substring(0, 5),
                                  style: const TextStyle(fontSize: 12))
                              : const SizedBox();
                        },
                      ),
                    ),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  gridData: FlGridData(show: true),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          NumberFormat('#,###').format(rod.toY),
                          const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                    touchCallback: (event, response) {
                      if (event is FlTapUpEvent &&
                          response != null &&
                          response.spot != null) {
                        setState(() {
                          _touchedY =
                              response.spot!.touchedBarGroup.barRods.first.toY;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          width: 40,
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.only(left: 5, top: 22, bottom: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (double i = ((maxY * 1.1) / 1000).ceil() * 1000;
                  i >= 0;
                  i -= maxY * 0.1)
                Text(
                  NumberFormat.compact().format(i < maxY * 0.1 ? 0 : i),
                  style: const TextStyle(fontSize: 10),
                ),
            ],
          ),
        ),
      ],
    );
  }

  ExtraLinesData _buildExtraLinesData() {
    return ExtraLinesData(
      verticalLines: yearChangeIndexes.map((index) {
        return VerticalLine(
          x: index.toDouble(),
          color: AppColors.error,
          strokeWidth: 5.0,
          dashArray: [10, 5],
          label: VerticalLineLabel(
            show: true,
            alignment: Alignment.center,
            labelResolver: (line) => dates[index].substring(6, 10),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        );
      }).toList(),
      horizontalLines: _touchedY != null
          ? [
              HorizontalLine(
                y: _touchedY!,
                color: AppColors.error, // Màu đường cắt ngang
                strokeWidth: 2, // Độ dày của đường
                dashArray: [5, 5], // Kẻ đứt nét
              ),
            ]
          : [],
    );
  }
}

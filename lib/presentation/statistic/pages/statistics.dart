import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_project/core/constants/app_colors.dart';
import 'package:my_project/data/models/monthly_goal.dart';
import 'package:my_project/data/models/transaction.dart';
import 'package:my_project/domain/repository/monthly_goal.dart';
import 'package:my_project/domain/repository/transaction.dart';
import 'package:my_project/presentation/statistic/widgets/bar_chart_transaction.dart';
import 'package:my_project/service_locator.dart';

class Statistic extends StatefulWidget {
  final String userId;

  const Statistic({
    super.key,
    required this.userId,
  });

  @override
  State<Statistic> createState() => _StatisticState();
}

class _StatisticState extends State<Statistic> {
  List<MonthlyGoal> monthlyGoals = [];
  List<Transaction> transactions = [];
  bool isLoading = false;
  String? error;

  int curentMonth = DateTime.now().month;
  int curentYear = DateTime.now().year;

// Group amount transactions by date
  Map<String, double> get groupedAmountTransactions {
    final groups = <String, double>{};
    for (var transaction in transactions) {
      final date = DateFormat('dd/MM/yyyy').format(transaction.transactionDate);
      if (!groups.containsKey(date)) {
        groups[date] = 0;
      }
      groups[date] = (groups[date] ?? 0.0) + (transaction.amount);
    }

    // Sort the groups by date (newest first)
    final sortedKeys = groups.keys.toList()
      ..sort((a, b) => DateFormat('dd/MM/yyyy')
          .parse(a)
          .compareTo(DateFormat('dd/MM/yyyy').parse(b)));

    return Map.fromEntries(
      sortedKeys.map((key) => MapEntry(key, groups[key]!)),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadDatas();
  }

  Future<void> _loadDatas() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    final queryTransactionParams = {
      'pageIndex': '1',
      'pageSize': '500',
    };

    try {
      final transactionResult =
          await sl<TransactionRepository>().getTransactions(
        widget.userId,
        queryParams: queryTransactionParams,
      );

      transactionResult.fold(
        (errorMessage) {
          setState(() {
            error = errorMessage;
          });
        },
        (data) {
          setState(() {
            transactions = data;
          });
        },
      );
      isLoading = false;
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          title: const Text(
            'Statistic',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _loadDatas,
          child: isLoading
              ? _buildLoading()
              : Column(
                  children: [
                    // Biểu đồ cột hoặc nến
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Transaction Overview',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 300,
                      child: BarChartTransaction(
                        groupedAmountTransactions: groupedAmountTransactions,
                      ),
                    ),
                    SizedBox(height: 20),
                    // Biểu đồ tròn
                    SizedBox(
                      height: 200,
                    ),
                  ],
                ),
        ));
  }
}

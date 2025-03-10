import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_project/core/constants/app_colors.dart';
import 'package:my_project/data/models/monthly_goal.dart';
import 'package:my_project/data/models/transaction.dart';
import 'package:my_project/domain/repository/monthly_goal.dart';
import 'package:my_project/domain/repository/transaction.dart';
import 'package:my_project/presentation/statistic/widgets/bar_chart_transaction.dart';
import 'package:my_project/presentation/statistic/widgets/pie_chart_monthlygoal.dart';
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

  int currentMonth = DateTime.now().month;
  int currentYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

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

      final monthlyGoalResult = await sl<MonthlyGoalRepository>()
          .getMonthlyGoals(null, null, null, 1, 500);

      monthlyGoalResult.fold(
        (errorMessage) {
          setState(() {
            error = errorMessage;
          });
        },
        (data) {
          setState(() {
            monthlyGoals = data;
          });
        },
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
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

// Lọc MonthlyGoal theo tháng và năm đã chọn
  MonthlyGoal? get selectedMonthlyGoal {
    return monthlyGoals.firstWhere(
      (goal) => goal.month == selectedMonth && goal.year == selectedYear,
      orElse: () => MonthlyGoal(
          id: '',
          totalAmount: 0,
          status: 1,
          createAt: DateTime.now(),
          isCompleted: false,
          month: selectedMonth,
          year: selectedYear,
          goalItems: []),
    );
  }

  // Xử lý dữ liệu để vẽ Pie Chart
  Map<String, double> get categoryPercentages {
    final goalItems = selectedMonthlyGoal?.goalItems ?? [];
    double totalUsedAmount =
        goalItems.fold(0, (sum, item) => sum + item.usedAmount);

    if (totalUsedAmount == 0) return {};

    Map<String, double> percentages = {};
    for (var item in goalItems) {
      String walletTypeName = item.walletTypeName ?? 'Unknown';
      double usedAmount = item.usedAmount;
      percentages[walletTypeName] = (usedAmount / totalUsedAmount) * 100;
    }
    return percentages;
  }

  // Lọc giao dịch theo tháng/năm đã chọn
  List<Transaction> get filteredTransactions {
    return transactions.where((transaction) {
      return transaction.transactionDate.month == selectedMonth &&
          transaction.transactionDate.year == selectedYear;
    }).toList();
  }

  // Nhóm dữ liệu giao dịch theo ngày
  Map<String, double> get groupedAmountTransactions {
    final groups = <String, double>{};
    for (var transaction in filteredTransactions) {
      final date = DateFormat('dd/MM/yyyy').format(transaction.transactionDate);
      groups[date] = (groups[date] ?? 0.0) + transaction.amount;
    }

    final sortedKeys = groups.keys.toList()
      ..sort((a, b) => DateFormat('dd/MM/yyyy').parse(a).compareTo(
            DateFormat('dd/MM/yyyy').parse(b),
          ));

    return Map.fromEntries(
      sortedKeys.map((key) => MapEntry(key, groups[key]!)),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }

  // Bộ lọc chọn tháng & năm
  Row _buildMonthYearFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownButton<int>(
          value: selectedMonth,
          items: List.generate(12, (index) {
            return DropdownMenuItem(
              value: index + 1,
              child: Text('Tháng ${index + 1}'),
            );
          }),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedMonth = value;
              });
            }
          },
        ),
        const SizedBox(width: 10),
        DropdownButton<int>(
          value: selectedYear,
          items: List.generate(5, (index) {
            int year = DateTime.now().year - index;
            return DropdownMenuItem(
              value: year,
              child: Text('$year'),
            );
          }),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedYear = value;
              });
            }
          },
        ),
      ],
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
            : SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(), // Luôn có thể cuộn
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMonthYearFilter(),
                      const SizedBox(height: 10),
                      const Text(
                        'Transaction Overview',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 300,
                        child: BarChartTransaction(
                          groupedAmountTransactions: groupedAmountTransactions,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Goal Breakdown',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 200,
                        child: categoryPercentages.isEmpty
                            ? const Center(child: Text("No Data Available"))
                            : PieChartTransaction(
                                categoryPercentages: categoryPercentages),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

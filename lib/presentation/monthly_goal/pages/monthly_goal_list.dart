import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_project/core/constants/app_colors.dart';
import 'package:my_project/data/models/goal_item.dart';
import 'package:my_project/data/models/monthly_goal.dart';
import 'package:my_project/domain/repository/monthly_goal.dart';
import 'package:my_project/presentation/monthly_goal/widgets/goal_item_card.dart';
import 'package:my_project/presentation/monthly_goal/widgets/goal_item_form_dialog.dart';
import 'package:my_project/presentation/monthly_goal/widgets/monthly_goal_form_dialog.dart';
import 'package:my_project/service_locator.dart';

class MonthlyGoalListView extends StatefulWidget {
  const MonthlyGoalListView({super.key});

  @override
  State<MonthlyGoalListView> createState() => _MonthlyGoalListViewState();
}

class _MonthlyGoalListViewState extends State<MonthlyGoalListView> {
  final ScrollController _scrollController = ScrollController();
  List<MonthlyGoal> monthlyGoals = [];
  List<MonthlyGoal> allMonthlyGoals = [];
  bool isLoading = false;
  String? error;
  final int startYear = 2023; // Năm bắt đầu
  final int endYear = 2030; // Năm kết thúc
  late List<Map<String, int>> monthYearList = [];
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  int? month;
  int? year;
  int? status;
  int pageIndex = 1;
  int pageSize = 10;

  @override
  void initState() {
    super.initState();
    _generateMonthYearList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedMonth();
    });
    _loadMonthlyGoals();
    _loadAllMonthlyGoals();
  }

  void _generateMonthYearList() {
    monthYearList = [];
    for (int year = startYear; year <= endYear; year++) {
      for (int month = 1; month <= 12; month++) {
        monthYearList.add({'month': month, 'year': year});
      }
    }
  }

  void _scrollToSelectedMonth() {
    int index = monthYearList.indexWhere(
        (e) => e['month'] == selectedMonth && e['year'] == selectedYear);

    if (index != -1) {
      _scrollController.animateTo(
        index * 110, // Chiều rộng mỗi item (cần điều chỉnh theo UI)
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _loadMonthlyGoals() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final monthlyGoalResult =
          await sl<MonthlyGoalRepository>().getMonthlyGoals(
        selectedYear,
        selectedMonth,
        status,
        pageIndex,
        pageSize,
      );

      monthlyGoalResult.fold(
        (errorMessage) {
          setState(() {
            error = errorMessage;
            isLoading = false;
          });
        },
        (data) {
          setState(() {
            monthlyGoals = data;
            isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _loadAllMonthlyGoals() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final monthlyGoalResult =
          await sl<MonthlyGoalRepository>().getMonthlyGoals(
        null,
        null,
        null,
        pageIndex,
        100,
      );

      monthlyGoalResult.fold(
        (errorMessage) {
          setState(() {
            error = errorMessage;
            isLoading = false;
          });
        },
        (data) {
          setState(() {
            allMonthlyGoals = data;
            isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _onMonthSelected(int month, int year) {
    setState(() {
      selectedMonth = month;
      selectedYear = year;
    });
    _scrollToSelectedMonth();
    _loadMonthlyGoals();
  }

  // Future<void> _showCreateMonthlyGoalDialog() async {
  //   final newMonthlyGoal = await showDialog<MonthlyGoal>(
  //     context: context,
  //     builder: (context) => MonthlyGoalFormDialog(),
  //   );

  //   if (newMonthlyGoal != null) {
  //     setState(() {
  //       monthlyGoals = [...monthlyGoals, newMonthlyGoal];
  //     });
  //     _loadMonthlyGoals(); // Reload the list to get updated data
  //   }
  // }

  Future<void> _showEditMonthlyGoalDialog(MonthlyGoal monthlyGoal) async {
    final updatedMonthlyGoal = await showDialog<MonthlyGoal>(
      context: context,
      builder: (context) => MonthlyGoalFormDialog(
        monthlyGoal: monthlyGoal,
      ),
    );

    if (updatedMonthlyGoal != null) {
      setState(() {
        monthlyGoals = monthlyGoals
            .map((m) => m.id == updatedMonthlyGoal.id ? updatedMonthlyGoal : m)
            .toList();
      });

      // Optional: Reload from server to ensure data consistency
      _loadMonthlyGoals();
    }
  }

  // Future<void> _showCreateGoalItemDialog() async {
  //   final newGoalItem = await showDialog<GoalItem>(
  //     context: context,
  //     builder: (context) => GoalItemFormDialog(),
  //   );

  //   if (newGoalItem != null) {
  //     setState(() {
  //       monthlyGoals = monthlyGoals.map((m) {
  //         if (m.id == newGoalItem.monthlyGoalId) {
  //           return m.copyWith(goalItems: [...?m.goalItems, newGoalItem]);
  //         }
  //         return m;
  //       }).toList();
  //     });

  //     _loadMonthlyGoals(); // Reload the list to get updated data
  //   }
  // }

  Future<void> _showEditGoalItemDialog(GoalItem goalItem) async {
    final updatedGoalItem = await showDialog<GoalItem>(
      context: context,
      builder: (context) => GoalItemFormDialog(
        goalItem: goalItem,
      ),
    );

    if (updatedGoalItem != null) {
      setState(() {
        monthlyGoals = monthlyGoals.map((m) {
          if (m.id == updatedGoalItem.monthlyGoalId) {
            return m.copyWith(
              goalItems: m.goalItems!
                  .map((g) => g.id == updatedGoalItem.id ? updatedGoalItem : g)
                  .toList(),
            );
          }
          return m;
        }).toList();
      });
      // Optional: Reload from server to ensure data consistency
      _loadMonthlyGoals();
    }
  }

  // void _navigateToCreateMonthlyGoalPage() {
  //   _showCreateMonthlyGoalDialog();
  // }

  void _navigateToUpdateMonthlyGoalPage(MonthlyGoal monthlyGoal) {
    _showEditMonthlyGoalDialog(monthlyGoal);
  }

  // void _navigateToCreateGoalItemPage() {
  //   _showCreateGoalItemDialog();
  // }

  void _navigateToUpdateGoalItemPage(GoalItem goalItem) {
    _showEditGoalItemDialog(goalItem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Monthly Goal',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.add, color: Colors.white),
        //     onPressed: _navigateToCreateMonthlyGoalPage,
        //   ),
        // ],
      ),
      body: RefreshIndicator(
          onRefresh: _loadMonthlyGoals,
          child: Column(children: [
            // Danh sách tháng/năm cuộn ngang
            SizedBox(
              height: 70,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: monthYearList.length,
                itemBuilder: (context, index) {
                  final month = monthYearList[index]['month']!;
                  final year = monthYearList[index]['year']!;
                  final isSelected =
                      month == selectedMonth && year == selectedYear;
                  final hasMonthlyGoal = allMonthlyGoals
                      .any((goal) => goal.month == month && goal.year == year);
                  return SizedBox(
                      width: 110, // 🔥 Đặt chiều rộng cố định
                      child: GestureDetector(
                        onTap: () => _onMonthSelected(month, year),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 10),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.orange // Nếu đang chọn, màu đậm hơn
                                : hasMonthlyGoal
                                    ? AppColors
                                        .skyBlue // Nếu có MonthlyGoal, màu nổi hơn
                                    : Colors.blueGrey[
                                        200], // Không có MonthlyGoal, màu nhạt
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$month/$year',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ));
                },
              ),
            ),

            Expanded(
                child: SingleChildScrollView(
                    physics:
                        AlwaysScrollableScrollPhysics(), // Để RefreshIndicator hoạt động
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: monthlyGoals.isEmpty
                          ? Center(
                              child: Text(
                                'No Data',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...monthlyGoals.map(
                                  (monthlyGoal) => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8),
                                            child: Dismissible(
                                              key: Key(monthlyGoal.id),
                                              direction:
                                                  DismissDirection.endToStart,
                                              background: Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                padding:
                                                    const EdgeInsets.all(1.0),
                                                color: Colors.blue,
                                                child: const Icon(
                                                  Icons.edit,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              confirmDismiss:
                                                  (direction) async {
                                                _navigateToUpdateMonthlyGoalPage(
                                                    monthlyGoal);
                                                return false; // Không xóa card sau khi vuốt
                                              },
                                              child: Container(
                                                width: 350,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8),
                                                padding:
                                                    const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    // colors: monthlyGoal.isCompleted
                                                    //     ? [Colors.indigo, Colors.blue]
                                                    //     : [Colors.deepOrange, Colors.red],
                                                    colors: [
                                                      AppColors.brown,
                                                      AppColors.gold
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black12,
                                                      blurRadius: 4,
                                                      offset: Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          '${monthlyGoal.month}/${monthlyGoal.year}',
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width:
                                                                5), // Thêm khoảng cách giữa text và icon
                                                        Icon(
                                                          monthlyGoal
                                                                  .isCompleted
                                                              ? Icons
                                                                  .check_circle
                                                              : Icons.cancel,
                                                          color: monthlyGoal
                                                                  .isCompleted
                                                              ? Colors.green
                                                              : Colors.red,
                                                          size: 18,
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      'Status: ${monthlyGoal.status == 1 ? 'In Progress' : 'Completed'}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Total Amount: ${NumberFormat('#,###').format(monthlyGoal.totalAmount)} VND',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Created At: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(monthlyGoal.createAt)}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      // Danh sách Goal Items
                                      Column(
                                        children: monthlyGoal.goalItems!
                                            .map(
                                              (goalItem) => Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8),
                                                child: Dismissible(
                                                  key: Key(goalItem.id),
                                                  direction: DismissDirection
                                                      .endToStart,
                                                  background: Container(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            1.0),
                                                    color: Colors.blue,
                                                    child: const Icon(
                                                      Icons.edit,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  confirmDismiss:
                                                      (direction) async {
                                                    _navigateToUpdateGoalItemPage(
                                                        goalItem);
                                                    return false; // Không xóa card sau khi vuốt
                                                  },
                                                  child: GoalItemCard(
                                                    goalItem: goalItem,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    )))
          ])),
    );
  }
}

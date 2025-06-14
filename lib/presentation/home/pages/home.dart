import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_project/common/color_extention.dart';
import 'package:my_project/core/constants/app_colors.dart';
import 'package:my_project/data/models/transaction.dart';
import 'package:my_project/data/models/wallet.dart';
import 'package:my_project/domain/repository/goal_item.dart';
import 'package:my_project/domain/repository/monthly_goal.dart';
import 'package:my_project/domain/repository/transaction.dart';
import 'package:my_project/domain/repository/wallet.dart';
import 'package:my_project/presentation/chat/pages/chat_page.dart';
import 'package:my_project/presentation/profile/pages/user_profile.dart';
import 'package:my_project/common/widgets/custom_arc_painter.dart';
import 'package:my_project/presentation/transaction/pages/transaction_detail.dart';
import 'package:my_project/presentation/transaction/pages/transaction_list_view.dart';
import 'package:my_project/presentation/transaction/pages/transaction_update.dart';
import 'package:my_project/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/widgets/custom_line_painter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Transaction> transactions = [];
  List<Wallet> wallets = [];
  int totalRecord = 0;
  String userId = "";
  bool isLoading = false;
  String? error;
  double totalUsedAmount = 0;
  double totalBalance = 0;
  double totalAmount = 0;
  String curentMonth = DateFormat('MMMM').format(DateTime.now());
  int daysLeftOfMonth =
      DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day -
          DateTime.now().day;

  // Group wallets by lastUpdatedTime
  Map<String, List<Wallet>> get groupedWallets {
    final groups = <String, List<Wallet>>{};
    for (var wallet in wallets) {
      final date = DateFormat('dd/MM/yyyy').format(wallet.lastUpdatedTime);
      if (!groups.containsKey(date)) {
        groups[date] = [];
      }
      groups[date]!.add(wallet);
    }

    // Sort the wallets within each group by date (newest first)
    for (var wallets in groups.values) {
      wallets.sort((a, b) => b.lastUpdatedTime.compareTo(a.lastUpdatedTime));
    }

    // Sort the groups by date (newest first)
    final sortedKeys = groups.keys.toList()
      ..sort((a, b) => DateFormat('dd/MM/yyyy')
          .parse(b)
          .compareTo(DateFormat('dd/MM/yyyy').parse(a)));

    return Map.fromEntries(
      sortedKeys.map((key) => MapEntry(key, groups[key]!)),
    );
  }

  // Group transactions by date
  Map<String, List<Transaction>> get groupedTransactions {
    final groups = <String, List<Transaction>>{};
    for (var transaction in transactions) {
      final date = DateFormat('dd/MM/yyyy').format(transaction.transactionDate);
      if (!groups.containsKey(date)) {
        groups[date] = [];
      }
      groups[date]!.add(transaction);
    }

    // Sort the transactions within each group by date (newest first)
    for (var transactions in groups.values) {
      transactions
          .sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    }

    // Sort the groups by date (newest first)
    final sortedKeys = groups.keys.toList()
      ..sort((a, b) => DateFormat('dd/MM/yyyy')
          .parse(b)
          .compareTo(DateFormat('dd/MM/yyyy').parse(a)));

    return Map.fromEntries(
      sortedKeys.map((key) => MapEntry(key, groups[key]!)),
    );
  }

  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';
    });
  }

  Future<void> _handleRefresh() async {
    await _loadData();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    final queryParamsTransactions = {
      'pageIndex': "1",
      'pageSize': "10",
      'descending': "false",
    };

    final queryParamsWallets = {
      'pageIndex': "1",
      'pageSize': "5",
    };

    try {
      final resultTotalUsedAmount =
          await sl<GoalItemRepository>().getTotalUsedAmount();
      final resultTotalBalance = await sl<WalletRepository>().getTotalBalance();
      final resultTotalAmount =
          await sl<MonthlyGoalRepository>().getTotalAmount();
      final resultListTransactions =
          await sl<TransactionRepository>().getTransactions(
        userId,
        queryParams: queryParamsTransactions,
      );
      final resultListWallets = await sl<WalletRepository>().getWallets(
        queryParams: queryParamsWallets,
      );

      resultTotalUsedAmount.fold(
        (errorMessage) {
          setState(() {
            error = errorMessage;
          });
        },
        (data) {
          setState(() {
            totalUsedAmount = data;
          });
        },
      );

      resultTotalBalance.fold(
        (errorMessage) {
          setState(() {
            error = errorMessage;
          });
        },
        (data) {
          setState(() {
            totalBalance = data;
          });
        },
      );

      resultTotalAmount.fold(
        (errorMessage) {
          setState(() {
            error = errorMessage;
          });
        },
        (data) {
          setState(() {
            totalAmount = data;
          });
        },
      );

      resultListTransactions.fold(
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

      resultListWallets.fold(
        (errorMessage) {
          setState(() {
            error = errorMessage;
          });
        },
        (data) {
          setState(() {
            wallets = data;
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

  void _handleTransactionTap(Transaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetailView(
          transactionId: transaction.id,
        ),
      ),
    );
  }

  Future<void> _updateTransaction(
      BuildContext context, Transaction transaction) async {
    final updatedTransaction = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionUpdateScreen(transaction: transaction),
      ),
    );

    if (updatedTransaction != null && updatedTransaction is Transaction) {
      setState(() {
        int index =
            transactions.indexWhere((t) => t.id == updatedTransaction.id);
        if (index != -1) {
          transactions[index] =
              updatedTransaction; // Cập nhật phần tử trong danh sách
        }
      });

      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //       content: Text('Update Transaction successfully!'),
      //       backgroundColor: Colors.green),
      // );
    }
  }

  Future<void> _deleteTransaction(String id) async {
    setState(() {
      isLoading = true;
    });

    final result = await sl<TransactionRepository>().deleteTransaction(id);

    setState(() {
      isLoading = false;
      result.fold(
        (errorMessage) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        ),
        (success) {
          if (success) {
            transactions.removeWhere((transaction) => transaction.id == id);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Delete Transaction successfully!')),
            );
          }
        },
      );
    }); // deleteTransaction
  }

  @override
  Widget build(BuildContext context) {
    _getUserId();
    var media = MediaQuery.sizeOf(context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(child: Text(error!));
    }

    return Scaffold(
      backgroundColor: AppColors.grayLight,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Column(
          children: [
            SizedBox(
              // ✅ Định kích thước trước cho Stack
              height: 230, // Điều chỉnh theo thiết kế
              child: Stack(
                children: [
                  // AppBar
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: media.width * 0.4,
                      decoration: BoxDecoration(
                        color: AppColors.lightGreen, // Màu nền AppBar
                      ),
                      child: AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        title: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.person),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UserProfile()),
                                );
                              },
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total Balance'),
                                Text(
                                    '${NumberFormat('#,###').format(totalBalance)} VND',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: totalBalance < 0
                                          ? AppColors.error
                                          : AppColors.success,
                                    )),
                              ],
                            ),
                          ],
                        ),
                        actions: [
                          IconButton(
                            icon: Icon(Icons.chat),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ChatPage(userId: userId!)),
                              );
                            },
                          ),
                          // IconButton(
                          //   icon: Icon(Icons.add),
                          //   onPressed: () {
                          //     // Thêm hành động khi bấm vào nút "+"
                          //   },
                          // ),
                        ],
                      ),
                    ),
                  ),

                  // Nội dung chính
                  Positioned(
                    top: media.width * 0.2,
                    left: media.width * 0.01,
                    right: media.width * 0.01,
                    child: Column(
                      children: [
                        // Container chính
                        Container(
                          height: media.width * 0.35,
                          width: media.width * 0.9,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                top: media.width * 0.03,
                                left: media.width * 0.05,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '$curentMonth budget',
                                      style: TextStyle(
                                          color: AppColors.text,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${NumberFormat('#,###').format(totalUsedAmount)}đ / ',
                                          style: TextStyle(
                                            color:
                                                totalUsedAmount / totalAmount <
                                                        1
                                                    ? AppColors.navy
                                                    : AppColors.error,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          '${NumberFormat('#,###').format(totalAmount)}đ',
                                          style: TextStyle(
                                            color: AppColors.textLight,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Text(
                                          '${NumberFormat('#.##').format(totalUsedAmount / totalAmount > 1 ? 100 : (totalUsedAmount * 100 / totalAmount))}%',
                                          style: TextStyle(
                                            color:
                                                totalUsedAmount / totalAmount <
                                                        1
                                                    ? AppColors.textLight
                                                    : AppColors.error,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: media.width * 0.2,
                                child: SizedBox(
                                  width: media.width * 0.8,
                                  height: 10,
                                  child: CustomPaint(
                                    painter: CustomLinePainter(
                                      progress:
                                          totalUsedAmount / totalAmount > 1
                                              ? 1
                                              : totalUsedAmount / totalAmount,
                                      width: 6,
                                      blurWidth: 4,
                                      status: totalUsedAmount <= totalAmount,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: media.width * 0.25,
                                left: media.width * 0.05,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Daily budget: ${NumberFormat('#,###').format(totalAmount / 30)}đ',
                                      style: TextStyle(
                                        color: AppColors.textLight,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 0),
                                    Text(
                                      ' / $daysLeftOfMonth days left',
                                      style: TextStyle(
                                        color: AppColors.textLight,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Container Wallet
            Container(
              height: media.width * 0.1,
              width: media.width * 1,
              decoration: BoxDecoration(
                color: AppColors.grayLight,
                borderRadius: BorderRadius.circular(25),
              ),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Wallets",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  // TextButton(
                  //   onPressed: () {
                  //     Navigator.pop(context,
                  //         3); // Trả về giá trị 3 (index của WalletList)
                  //   },
                  //   child: const Text(
                  //     'See All',
                  //     style: TextStyle(
                  //       fontSize: 20,
                  //       fontWeight: FontWeight.bold,
                  //       color:
                  //           AppColors.primary, // Màu sắc có thể thay đổi tùy ý
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            // Danh sách cuộn ngang
            wallets.isEmpty
                ? Center(
                    child: Text(
                      'No Data',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                  )
                : SizedBox(
                    height: 127, // Tăng chiều cao để hiển thị đầy đủ nội dung
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: wallets.length,
                      itemBuilder: (context, index) {
                        final name = wallets.elementAt(index).name;
                        final date = DateFormat('dd/MM/yyyy')
                            .format(wallets.elementAt(index).lastUpdatedTime);
                        final balance = wallets.elementAt(index).balance;
                        final currency = wallets.elementAt(index).currency;
                        return Container(
                          width: 220,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            // Sử dụng gradient đa dạng theo index
                            gradient: LinearGradient(
                              colors: index % 2 == 0
                                  ? [Colors.indigo, Colors.blue]
                                  : [Colors.deepOrange, Colors.orange],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  color: AppColors.paleGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Balance:",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${NumberFormat('#,###').format(balance)} $currency',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Last Updated:",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                date,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

            const SizedBox(height: 10), // Khoảng cách giữa 2 danh sách
            Container(
              height: media.width * 0.1,
              width: media.width * 1,
              decoration: BoxDecoration(
                color: AppColors.grayLight,
                borderRadius: BorderRadius.circular(25),
              ),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Transactions",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
            // Danh sách cuộn dọc
            groupedTransactions.isEmpty
                ? Center(
                    child: Text(
                      'No Data',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: groupedTransactions.length,
                      itemBuilder: (context, index) {
                        final date = groupedTransactions.keys.elementAt(index);
                        final dailyTransactions = groupedTransactions[date]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                date,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            ...dailyTransactions.map(
                              (transaction) => TransactionCard(
                                transaction: transaction,
                                onTap: () => _handleTransactionTap(transaction),
                                onDelete: () =>
                                    _deleteTransaction(transaction.id),
                                onEdit: () =>
                                    _updateTransaction(context, transaction),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

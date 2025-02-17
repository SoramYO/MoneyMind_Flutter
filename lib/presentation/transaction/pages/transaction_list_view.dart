import 'package:flutter/material.dart';
import 'package:my_project/domain/repository/transaction.dart';
import 'package:my_project/data/models/transaction.dart';
import 'package:my_project/service_locator.dart';
import 'package:intl/intl.dart';
import 'package:my_project/presentation/transaction/widgets/filter_bottom_sheet.dart';
import 'package:my_project/core/utils/hex_color.dart';
class TransactionListView extends StatefulWidget {
  final String userId;
  
  const TransactionListView({
    super.key,
    required this.userId,
  });

  @override
  State<TransactionListView> createState() => _TransactionListViewState();
}

class _TransactionListViewState extends State<TransactionListView> {
  List<Transaction> transactions = [];
  bool isLoading = false;
  String? error;
  int totalRecord = 0;
  int currentPage = 1;
  int pageSize = 10;
  bool isDescending = true;
  bool? isCategorized;
  DateTime? fromDate;
  DateTime? toDate;
  
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
      transactions.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
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

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    final queryParams = {
      'pageIndex': currentPage.toString(),
      'pageSize': pageSize.toString(),
      'descending': isDescending.toString(),
      if (isCategorized != null) 'isCategorized': isCategorized.toString(),
      if (fromDate != null) 'fromDate': fromDate!.toIso8601String(),
      if (toDate != null) 'toDate': toDate!.toIso8601String(),
    };

    final result = await sl<TransactionRepository>().getTransactions(
      widget.userId,
      queryParams: queryParams,
    );

    setState(() {
      isLoading = false;
      result.fold(
        (errorMessage) => error = errorMessage,
        (data) {
          if (data is List<Transaction>) {
            transactions = data;
          } else {
            error = 'Invalid data format';
          }
        },
      );
    });
  }

  Future<void> _handleRefresh() async {
    currentPage = 1;
    await _loadTransactions();
  }

  void _clearFilters() {
    setState(() {
      isCategorized = null;
      fromDate = null;
      toDate = null;
      isDescending = true;
      currentPage = 1;
    });
    _loadTransactions();
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => FilterBottomSheet(
        isCategorized: isCategorized,
        fromDate: fromDate,
        toDate: toDate,
        isDescending: isDescending,
        onApply: (filters) {
          setState(() {
            isCategorized = filters.isCategorized;
            fromDate = filters.fromDate;
            toDate = filters.toDate;
            isDescending = filters.isDescending;
            currentPage = 1;
          });
          _loadTransactions();
        },
        onClear: _clearFilters,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : error != null
            ? Center(child: Text(error!))
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: groupedTransactions.length,
                itemBuilder: (context, index) {
                  final date = groupedTransactions.keys.elementAt(index);
                  final dailyTransactions = groupedTransactions[date]!;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          date,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      ...dailyTransactions.map((transaction) => TransactionCard(
                        transaction: transaction,
                      )),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final tag = transaction.tags.isNotEmpty ? transaction.tags.first : null;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: tag != null ? HexColor(tag.color).withOpacity(0.2) : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.receipt_outlined,
            color: tag != null ? HexColor(tag.color) : Colors.grey,
          ),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
       subtitle: Text(
          DateFormat('HH:mm dd/MM/yyyy').format(transaction.transactionDate),
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: Text(
          '-${NumberFormat('#,###').format(transaction.amount)}đ',
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
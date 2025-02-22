import 'package:flutter/material.dart';
import 'package:my_project/core/constants/app_colors.dart';
import 'package:my_project/domain/repository/sheet.dart';
import 'package:my_project/domain/repository/transaction.dart';
import 'package:my_project/data/models/transaction.dart';
import 'package:my_project/service_locator.dart';
import 'package:intl/intl.dart';
import 'package:my_project/presentation/transaction/widgets/filter_bottom_sheet.dart';
import 'package:my_project/core/utils/hex_color.dart';
import 'package:my_project/presentation/transaction/pages/transaction_detail.dart';

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
  bool hasSheetId = false;
  double offsetX = 0;
  double offsetY = 0;

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

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _checkSheetStatus();
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

    if (mounted) {
      setState(() {
        isLoading = false;
        result.fold(
          (errorMessage) => error = errorMessage,
          (data) {
            if (data is List<Transaction>) {
              transactions = data;
              // Cập nhật UI để ẩn nút thêm sheet nếu đã có dữ liệu
              if (transactions.isNotEmpty) {
                error = null;
              }
            } else {
              error = 'Invalid data format';
            }
          },
        );
      });
    }
  }

  Future<void> _checkSheetStatus() async {
    final exists = await sl<SheetRepository>().checkSheetExists(widget.userId);
    if (mounted) {
      setState(() => hasSheetId = exists);
    }
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

  Future<void> _deleteTransaction(String id) async {
    setState(() {
      isLoading = true;
    });
    print(id);
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
              const SnackBar(content: Text('Xóa giao dịch thành công')),
            );
          }
        },
      );
    }); // deleteTransaction
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

  void _navigateToCreateTransaction() {
    // Điều hướng đến màn hình tạo transaction
  }

  Future<void> _showAddSheetDialog() async {
    final sheetIdController = TextEditingController();
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Thêm Google Sheet'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: sheetIdController,
                decoration: const InputDecoration(
                  labelText: 'Sheet ID',
                  hintText: 'Nhập ID của Google Sheet',
                  border: OutlineInputBorder(),
                ),
              ),
              if (isLoading) const CircularProgressIndicator(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setState(() => isLoading = true);
                      try {
                        final result = await sl<SheetRepository>().addSheetId(
                          sheetIdController.text,
                          widget.userId,
                        );
                        
                        result.fold(
                          (error) => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error)),
                          ),
                          (success) {
                            setState(() => hasSheetId = true);
                            Navigator.pop(context);
                            _showSyncConfirmation();
                          },
                        );
                      } finally {
                        if (mounted) {
                          setState(() => isLoading = false);
                        }
                      }
                    },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSyncConfirmation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đồng bộ ngay?'),
        content: const Text('Bạn có muốn đồng bộ dữ liệu từ Google Sheet ngay bây giờ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Để sau'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đồng bộ'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final hasSheetId = await sl<SheetRepository>().checkSheetExists(widget.userId);
      if (!hasSheetId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng thêm Sheet ID trước khi đồng bộ')),
        );
        return;
      }
      setState(() => isLoading = true);
      try {
        final result = await sl<SheetRepository>().syncSheet(widget.userId);
        result.fold(
          (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error)),
            );
          },
          (success) => _loadTransactions(),
        );
      } finally {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Lịch sử giao dịch',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _handleRefresh,
            child: Container(
              color: AppColors.grayLight.withOpacity(0.3),
              child: isLoading
                  ? _buildLoading()
                  : error != null
                      ? _buildError(error!)
                      : transactions.isEmpty
                          ? _buildEmptyState()
                          : _buildTransactionListContent(),
            ),
          ),
          if (hasSheetId && transactions.isNotEmpty)
            _buildFloatingSyncButton(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.insert_drive_file_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'Chưa có giao dịch nào',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          _buildActionButton(
            hasSheetId ? 'Đồng bộ ngay' : 'Thêm Google Sheet',
            hasSheetId ? Icons.sync : Icons.add,
            hasSheetId ? _showSyncConfirmation : _showAddSheetDialog,
          ),
          const SizedBox(height: 15),
          _buildActionButton(
            'Thêm thủ công',
            Icons.add,
            _navigateToCreateTransaction,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: 250,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 20),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          error,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTransactionListContent() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedTransactions.length * 2,
      itemBuilder: (context, index) {
        if (index.isOdd) {
          final groupIndex = index ~/ 2;
          final date = groupedTransactions.keys.elementAt(groupIndex);
          final transactions = groupedTransactions[date]!;
          
          return Column(
            children: [
              _buildDateHeader(date),
              ...transactions.map((transaction) => TransactionCard(
                transaction: transaction,
                onTap: () => _handleTransactionTap(transaction),
                onDelete: () => _deleteTransaction(transaction.id),
              )),
            ],
          );
        }
        return const SizedBox(height: 16);
      },
    );
  }

  Widget _buildDateHeader(String date) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Text(
        date,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildFloatingSyncButton() {
    return Positioned(
      right: offsetX == 0 ? 20 : offsetX,
      bottom: offsetY == 0 ? 20 : offsetY,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            offsetX = details.globalPosition.dx - 28;
            offsetY = details.globalPosition.dy - 28;
          });
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.sync, color: Colors.white),
            onPressed: _showSyncConfirmation,
          ),
        ),
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const TransactionCard({
    Key? key,
    required this.transaction,
    this.onDelete,
    this.onTap,
  }) : super(key: key);

  void _showDeleteConfirmationDialog(BuildContext context) {
    if (onDelete == null) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Xác nhận xóa"),
          content: const Text("Bạn có chắc chắn muốn xóa giao dịch này không?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog trước khi xóa
                onDelete?.call(); // Gọi hàm xóa
              },
              child: const Text("Xóa", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tag = transaction.tags.isNotEmpty ? transaction.tags.first : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.lightGreen.withOpacity(0.1),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.grayLight.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                tag != null ? HexColor(tag.color) : AppColors.primary,
                tag != null
                    ? HexColor(tag.color).withOpacity(0.7)
                    : AppColors.primary.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.receipt_long_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        title: Text(
          transaction.description,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppColors.text,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            DateFormat('HH:mm dd/MM/yyyy').format(transaction.transactionDate),
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 12,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '-${NumberFormat('#,###').format(transaction.amount)}đ',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.delete_rounded,
                  color: AppColors.error.withOpacity(0.8),
                ),
                onPressed: () => _showDeleteConfirmationDialog(context),
              ),
            ],
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
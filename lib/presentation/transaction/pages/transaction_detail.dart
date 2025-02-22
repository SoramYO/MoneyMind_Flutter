import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_project/data/models/transaction.dart';
import 'package:my_project/domain/repository/transaction.dart';
import 'package:my_project/service_locator.dart';
import 'package:my_project/core/constants/app_colors.dart';
import 'package:flutter/cupertino.dart';

class TransactionDetailView extends StatefulWidget {
  final String transactionId;

  const TransactionDetailView({
    super.key,
    required this.transactionId,
  });

  @override
  State<TransactionDetailView> createState() => _TransactionDetailViewState();
}

class _TransactionDetailViewState extends State<TransactionDetailView> {
  Transaction? _transaction;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTransaction();
  }

  Future<void> _loadTransaction() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await sl<TransactionRepository>().getTransactionById(widget.transactionId);
      
      result.fold(
        (error) => setState(() {
          _error = error;
          _isLoading = false;
        }),
        (data) => setState(() {
          _transaction = data;
          _isLoading = false;
        }),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _transaction == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(_error ?? 'Không tìm thấy giao dịch')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Chi tiết giao dịch',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAmountSection(),
            const SizedBox(height: 24),
            _buildDetailSection(),
            const SizedBox(height: 16),
            _buildMetadataSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountSection() {
    final isIncome = _transaction!.amount > 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: isIncome ? AppColors.success : AppColors.error,
              ),
              const SizedBox(width: 8),
              Text(
                NumberFormat.currency(locale: 'vi', symbol: 'đ').format(_transaction!.amount.abs()),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isIncome ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _transaction!.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (isIncome ? AppColors.success : AppColors.error).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isIncome ? 'Giao dịch nhận' : 'Giao dịch chi',
              style: TextStyle(
                color: isIncome ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Thông tin giao dịch',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          const Divider(height: 1),
          _buildDetailRow('Người nhận', _transaction!.recipientName, Icons.person_outline),
          _buildDetailRow('Ví liên kết', _transaction!.walletId ?? 'Không có', Icons.account_balance_wallet_outlined),
          _buildDetailRow(
            'Thời gian',
            DateFormat('HH:mm dd/MM/yyyy').format(_transaction!.transactionDate),
            Icons.access_time,
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Chi tiết hệ thống',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          const Divider(height: 1),
          _buildDetailRow('Mã giao dịch', _transaction!.id, Icons.tag),
          _buildDetailRow(
            'Ngày tạo',
            DateFormat('HH:mm dd/MM/yyyy').format(_transaction!.createAt),
            Icons.calendar_today_outlined,
          ),
          if (_transaction!.lastUpdateAt.year > 1)
            _buildDetailRow(
              'Cập nhật cuối',
              DateFormat('HH:mm dd/MM/yyyy').format(_transaction!.lastUpdateAt),
              Icons.update,
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_project/data/models/transaction.dart';
import 'package:my_project/domain/repository/transaction.dart';
import 'package:my_project/service_locator.dart';
import 'package:my_project/core/constants/app_colors.dart';

class TransactionDetailView extends StatefulWidget {
  final String transactionId;

  const TransactionDetailView({
    Key? key,
    required this.transactionId,
  }) : super(key: key);

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
      final result = await sl<TransactionRepository>()
          .getTransactionById(widget.transactionId);
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
        appBar: AppBar(title: const Text('Transaction Details')),
        body: Center(child: Text(_error ?? 'Not found')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Transaction Details',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAmountSection(),
            const SizedBox(height: 24),
            _buildDetailSection(),
            const SizedBox(height: 16),
            _buildMetadataSection(),
            const SizedBox(height: 16),
            _buildTagsSection(),
            const SizedBox(height: 16),
            _buildActivitiesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountSection() {
    final isIncome = false;
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
                isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                color: isIncome ? AppColors.success : AppColors.error,
              ),
              const SizedBox(width: 8),
              Text(
                NumberFormat.currency(locale: 'vi', symbol: 'VND')
                    .format(_transaction!.amount.abs()),
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
              color: (isIncome ? AppColors.success : AppColors.error)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isIncome ? 'Incoming Transaction' : 'Outgoing Transaction',
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
              'Transaction Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          const Divider(height: 1),
          _buildDetailRow(
              'Recipient', _transaction!.recipientName, Icons.person_outline),
          _buildDetailRow(
            'Transaction Date',
            DateFormat('HH:mm dd/MM/yyyy')
                .format(_transaction!.transactionDate),
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
              'System Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          const Divider(height: 1),
          _buildDetailRow(
            'Created At',
            DateFormat('HH:mm dd/MM/yyyy').format(_transaction!.createAt),
            Icons.calendar_today_outlined,
          ),
          if (_transaction!.lastUpdateAt.year > 1)
            _buildDetailRow(
              'Last Updated',
              DateFormat('HH:mm dd/MM/yyyy').format(_transaction!.lastUpdateAt),
              Icons.update,
            ),
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tags',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          if (_transaction!.tags == null || _transaction!.tags!.isEmpty)
            const Text('No tags available.'),
          if (_transaction!.tags != null && _transaction!.tags!.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _transaction!.tags!.map((tag) {
                return Tooltip(
                  message: tag.description,
                  child: Chip(
                    label: Text(tag.name),
                    backgroundColor: _parseColor(tag.color) ?? Colors.grey,
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildActivitiesSection() {
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activities',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          if (_transaction!.activities == null ||
              _transaction!.activities!.isEmpty)
            const Text('No activities available.'),
          if (_transaction!.activities != null &&
              _transaction!.activities!.isNotEmpty)
            Column(
              children: _transaction!.activities!.map((activity) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(activity.name),
                  subtitle: Text(activity.description),
                  trailing: Text(DateFormat('HH:mm dd/MM/yyyy')
                      .format(activity.createdAt)),
                );
              }).toList(),
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
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Color? _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return null;
    try {
      // Remove the '#' character if present
      final hexColor = colorString.replaceAll('#', '');
      if (hexColor.length == 6) {
        return Color(int.parse('FF$hexColor', radix: 16));
      } else if (hexColor.length == 8) {
        return Color(int.parse(hexColor, radix: 16));
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}

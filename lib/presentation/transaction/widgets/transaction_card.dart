import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_project/core/utils/hex_color.dart';
import 'package:my_project/data/models/transaction.dart';

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
        leading: _buildLeadingIcon(tag),
        title: _buildTitle(),
        subtitle: _buildSubtitle(),
        trailing: _buildTrailing(),
      ),
    );
  }

  Widget _buildLeadingIcon(Tag? tag) {
    return Container(
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
    );
  }

  Widget _buildTitle() {
    return Text(
      transaction.description,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      DateFormat('HH:mm').format(transaction.transactionDate),
      style: TextStyle(color: Colors.grey[600], fontSize: 12),
    );
  }

  Widget _buildTrailing() {
    return Text(
      '-${NumberFormat('#,###').format(transaction.amount)}đ',
      style: const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }
} 
import 'package:my_project/data/models/transaction.dart';
import 'package:my_project/domain/entities/activity.dart';

class TransactionEntity {
  final String id;
  final String recipientName;
  final double amount;
  final String description;
  final DateTime transactionDate;
  final DateTime createAt;
  final DateTime lastUpdateAt;
  final String userId;
  final String? walletId;

  final List<ActivityDb>? activities;
  final List<Tag> tags;

  TransactionEntity({
    required this.id,
    required this.recipientName,
    required this.amount,
    required this.description,
    required this.transactionDate,
    required this.createAt,
    required this.lastUpdateAt,
    required this.userId,
    this.walletId,

    this.activities,
    required this.tags,
  });
}

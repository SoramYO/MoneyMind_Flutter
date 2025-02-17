import '../../domain/entities/transaction.dart';

class Tag {
  final String id;
  final String name;
  final String description;
  final String color;

  Tag({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
    };
  }
}

class TransactionModel {
  final String id;
  final String recipientName;
  final double amount;
  final String description;
  final DateTime transactionDate;
  final DateTime createAt;
  final DateTime lastUpdateAt;
  final String userId;
  final String? walletId;
  final List<Tag> tags;

  TransactionModel({
    required this.id,
    required this.recipientName,
    required this.amount,
    required this.description,
    required this.transactionDate,
    required this.createAt,
    required this.lastUpdateAt,
    required this.userId,
    this.walletId,
    required this.tags,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      recipientName: json['recipientName'],
      amount: json['amount'].toDouble(),
      description: json['description'],
      transactionDate: DateTime.parse(json['transactionDate']),
      createAt: DateTime.parse(json['createAt']),
      lastUpdateAt: DateTime.parse(json['lastUpdateAt']),
      userId: json['userId'],
      walletId: json['walletId'],
      tags: (json['tags'] as List).map((tag) => Tag.fromJson(tag)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipientName': recipientName,
      'amount': amount,
      'description': description,
      'transactionDate': transactionDate.toIso8601String(),
      'createAt': createAt.toIso8601String(),
      'lastUpdateAt': lastUpdateAt.toIso8601String(),
      'userId': userId,
      'walletId': walletId,
      'tags': tags.map((tag) => tag.toJson()).toList(),
    };
  }
}

extension TransactionXModel on TransactionModel {
  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      recipientName: recipientName,
      amount: amount,
      description: description,
      transactionDate: transactionDate,
      createAt: createAt,
      lastUpdateAt: lastUpdateAt,
      userId: userId,
      walletId: walletId,
      tags: tags,
    );
  }
}

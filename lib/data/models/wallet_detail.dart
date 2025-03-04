import 'package:my_project/data/models/wallet_category.dart';

class WalletClone {
  final String id;
  final String name;
  final String description;
  final double balance;
  final String currency;
  final DateTime createdTime;
  final DateTime lastUpdatedTime;
  final String userId;
  final WalletCategory? walletCategory; // Allow walletCategory to be null

  WalletClone({
    required this.id,
    required this.name,
    required this.description,
    required this.balance,
    required this.currency,
    required this.createdTime,
    required this.lastUpdatedTime,
    required this.userId,
    this.walletCategory, // Allow walletCategory to be null
  });

  factory WalletClone.fromJson(Map<String, dynamic> json) {
    return WalletClone(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      balance: double.tryParse(json['balance']?.toString() ?? '0') ?? 0.0,
      currency: json['currency'],
      createdTime: DateTime.parse(json['createdTime']),
      lastUpdatedTime: DateTime.parse(json['lastUpdatedTime']),
      userId: json['userId'],
      walletCategory: json['walletCategory'] != null
          ? WalletCategory.fromJson(json['walletCategory'])
          : null, // Handle null walletCategory
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'balance': balance,
      'currency': currency,
      'createdTime': createdTime.toIso8601String(),
      'lastUpdatedTime': lastUpdatedTime.toIso8601String(),
      'userId': userId,
      'walletCategory': walletCategory?.toJson(), // Handle null walletCategory
    };
  }
}
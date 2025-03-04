import 'package:my_project/data/models/wallet_category.dart';

class Tag {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final String color;
  final DateTime createdAt;
  final bool isActive;
  final String userId;
  final String? walletTypeId;
  final String? walletTypeName;
  final String? walletTypeDescription;

  Tag({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.color,
    required this.createdAt,
    required this.isActive,
    required this.userId,
    this.walletTypeId,
    this.walletTypeName,
    this.walletTypeDescription,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconPath: json['iconPath'],
      color: json['color'],
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'],
      userId: json['userId'],
      walletTypeId: json['walletTypeId'],
      walletTypeName: json['walletTypeName'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconPath': iconPath,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'userId': userId,
      'walletTypeId': walletTypeId,
      'walletTypeName': walletTypeName,
    };
  }
}

class Wallet {
  final String id;
  final String name;
  final String description;
  final double balance;
  final String currency;
  final DateTime createdTime;
  final DateTime lastUpdatedTime;
  final String userId;
  final WalletCategory walletCategory;

  Wallet({
    required this.id,
    required this.name,
    required this.description,
    required this.balance,
    required this.currency,
    required this.createdTime,
    required this.lastUpdatedTime,
    required this.userId,
    required this.walletCategory,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      balance: double.tryParse(json['balance']?.toString() ?? '0') ?? 0.0,
      currency: json['currency'],
      createdTime: DateTime.parse(json['createdTime']),
      lastUpdatedTime: DateTime.parse(json['lastUpdatedTime']),
      userId: json['userId'],
      walletCategory: WalletCategory.fromJson(json['walletCategory']),
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
      'walletCategory': walletCategory.toJson(),
    };
  }
}

import 'package:my_project/data/models/wallet_category.dart';

class WalletUpdate {
  
  final String name;
  final String description;
  final double balance;
  
 
  final String walletCategoryId;

  WalletUpdate({
   
    required this.name,
    required this.description,
    required this.balance,
    
    required this.walletCategoryId,
  });

  factory WalletUpdate.fromJson(Map<String, dynamic> json) {
    return WalletUpdate(
     
      name: json['name'],
      description: json['description'],
      balance: json['balance'],
     
      walletCategoryId: WalletCategory.fromJson(json['walletCategory']).id,
    );
  }

  Map<String, dynamic> toJson() {
    return {
     
      'name': name,
      'description': description,
      'balance': balance,
      'walletCategoryId': walletCategoryId,
    };
  }

  Map<String, dynamic> toMap() {
    return {
     
      'name': name,
      'description': description,
      'balance': balance,
      'walletCategoryId': walletCategoryId,
    };
  }

  WalletUpdate copyWith({
    String? id,
    String? name,
    String? description,
    double? balance,
    String? currency,
    DateTime? createdTime,
    DateTime? lastUpdatedTime,
    String? userId,
    WalletCategory? walletCategory,
  }) {
    return WalletUpdate(
      
      name: name ?? this.name,
      description: description ?? this.description,
      balance: balance ?? this.balance,
     
      walletCategoryId: walletCategory?.id ?? this.walletCategoryId,
    );
  }
}
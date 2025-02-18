class Activities {
  final String id;
  final String name;
  final String description;
  final DateTime createAt;

  Activities({
    required this.id,
    required this.name,
    required this.description,
    required this.createAt,
  });

  factory Activities.fromJson(Map<String, dynamic> json) {
    return Activities(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      createAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createAt.toIso8601String(),
    };
  }
}




class WalletCategory {
  final String id;
  final String name;
  final String description;
  final String? iconPath;
  final String? color;
  final DateTime createAt;
  final bool isActive;
  final String userId;
  final String? walletTypeId;
  final String? walletTypeName;
  final String? walletTypeDescription;
  final List<Activities> activities;


  WalletCategory({
    required this.id,
    required this.name,
    required this.description,
    this.iconPath,
    this.color,
    required this.createAt,
    this.isActive = true,
    required this.userId,
    this.walletTypeId,
    this.walletTypeName,
    this.walletTypeDescription,
    required this.activities,
  });

  factory WalletCategory.fromJson(Map<String, dynamic> json) {
    return WalletCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconPath: json['iconPath'] as String?,
      color: json['color'] as String?,
      createAt: DateTime.parse(json['createAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      userId: json['userId'] as String,
      walletTypeId: json['walletTypeId'] as String?,
      walletTypeName: json['walletTypeName'] as String?,
      walletTypeDescription: json['walletTypeDescription'] as String?,
      activities: (json['activities'] as List)
          .map((e) => Activities.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconPath': iconPath,
      'color': color,
      'createAt': createAt.toIso8601String(),
      'isActive': isActive,
      'userId': userId,
      'walletTypeId': walletTypeId,
      'walletTypeName': walletTypeName,
      'walletTypeDescription': walletTypeDescription,
      'activities': activities.map((activity) => activity.toJson()).toList(),
    };
  }

  factory WalletCategory.fromMap(Map<String, dynamic> map) {
    return WalletCategory(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      iconPath: map['iconPath'],
      color: map['color'],
      createAt: DateTime.parse(map['createAt']),
      isActive: map['isActive'],
      userId: map['userId'],
      walletTypeId: map['walletTypeId'],
      walletTypeName: map['walletTypeName'],
      walletTypeDescription: map['walletTypeDescription'],
      activities: map['activities'].map<Activities>((json) => Activities.fromJson(json)).toList(),
    );
  }
}
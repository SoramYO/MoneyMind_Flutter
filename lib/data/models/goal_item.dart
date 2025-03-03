class GoalItem {
  final String id;
  final String description;
  final double usedAmount;
  final double usedPercentage;
  final double minTargetPercentage;
  final double maxTargetPercentage;
  final double minAmount;
  final double maxAmount;
  final int targetMode;
  final bool isAchieved;
  final String monthlyGoalId;
  final String walletTypeId;
  final String? walletTypeName;

  GoalItem({
    required this.id,
    required this.description,
    required this.usedAmount,
    required this.usedPercentage,
    required this.minTargetPercentage,
    required this.maxTargetPercentage,
    required this.minAmount,
    required this.maxAmount,
    required this.targetMode,
    required this.isAchieved,
    required this.monthlyGoalId,
    required this.walletTypeId,
    this.walletTypeName,
  });

  factory GoalItem.fromJson(Map<String, dynamic> json) {
    return GoalItem(
      id: json['id'] as String,
      description: json['description'] as String,
      usedAmount: json['usedAmount'].toDouble(),
      usedPercentage: json['usedPercentage'].toDouble(),
      minTargetPercentage: json['minTargetPercentage'].toDouble(),
      maxTargetPercentage: json['maxTargetPercentage'].toDouble(),
      minAmount: json['minAmount'].toDouble(),
      maxAmount: json['maxAmount'].toDouble(),
      targetMode: json['targetMode'].toInt(),
      isAchieved: json['isAchieved'] as bool? ?? true,
      monthlyGoalId: json['monthlyGoalId'] as String,
      walletTypeId: json['walletTypeId'] as String,
      walletTypeName: json['walletTypeName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'description': description,
      'usedAmount': usedAmount,
      'usedPercentage': usedPercentage,
      'minTargetPercentage': minTargetPercentage,
      'maxTargetPercentage': maxTargetPercentage,
      'minAmount': minAmount,
      'maxAmount': maxAmount,
      'targetMode': targetMode,
      'isAchieved': isAchieved,
      'monthlyGoalId': monthlyGoalId,
      'walletTypeId': walletTypeId,
      'walletTypeName': walletTypeName,
    };
  }

  factory GoalItem.fromMap(Map<String, dynamic> map) {
    return GoalItem(
      id: map['id'],
      description: map['description'],
      usedAmount: map['usedAmount'].toDouble(),
      usedPercentage: map['usedPercentage'].toDouble(),
      minTargetPercentage: map['minTargetPercentage'].toDouble(),
      maxTargetPercentage: map['maxTargetPercentage'].toDouble(),
      minAmount: map['minAmount'].toDouble(),
      maxAmount: map['maxAmount'].toDouble(),
      targetMode: map['targetMode'].toInt(),
      isAchieved: map['isAchieved'],
      monthlyGoalId: map['monthlyGoalId'],
      walletTypeId: map['walletTypeId'],
      walletTypeName: map['walletTypeName'],
    );
  }
}

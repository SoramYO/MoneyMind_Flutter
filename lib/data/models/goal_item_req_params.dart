class GoalItemReqParams {
  final String description;
  final double minTargetPercentage;
  final double maxTargetPercentage;
  final double minAmount;
  final double maxAmount;
  final int targetMode;
  final String monthlyGoalId;
  final String walletTypeId;

  GoalItemReqParams({
    required this.description,
    required this.minTargetPercentage,
    required this.maxTargetPercentage,
    required this.minAmount,
    required this.maxAmount,
    required this.targetMode,
    required this.monthlyGoalId,
    required this.walletTypeId,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'description': description,
      'minTargetPercentage': minTargetPercentage,
      'maxTargetPercentage': maxTargetPercentage,
      'minAmount': minAmount,
      'maxAmount': maxAmount,
      'targetMode': targetMode,
      'monthlyGoalId': monthlyGoalId,
      'walletTypeId': walletTypeId,
    };
  }
}

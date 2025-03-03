class MonthlyGoalReqParams {
  final double totalAmount;
  final int month;
  final int year;

  MonthlyGoalReqParams({
    required this.totalAmount,
    required this.month,
    required this.year,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'totalAmount': totalAmount,
      'month': month,
      'year': year,
    };
  }
}

import 'package:my_project/data/models/goal_item.dart';

class MonthlyGoal {
  final String id;
  final int status;
  final double totalAmount;
  final int month;
  final int year;
  final DateTime createAt;
  final bool isCompleted;
  final List<GoalItem>? goalItems;

  MonthlyGoal({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.month,
    required this.year,
    required this.createAt,
    required this.isCompleted,
    required this.goalItems,
  });

  factory MonthlyGoal.fromJson(Map<String, dynamic> json) {
    return MonthlyGoal(
      id: json['id'] as String,
      status: json['status'].toInt(),
      totalAmount: json['totalAmount'].toDouble(),
      month: json['month'].toInt(),
      year: json['year'].toInt(),
      createAt: DateTime.parse(json['createAt']),
      isCompleted: json['isCompleted'] as bool? ?? true,
      goalItems: (json['goalItems'] as List)
          .map((e) => GoalItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'totalAmount': totalAmount,
      'month': month,
      'year': year,
      'createAt': createAt.toIso8601String(),
      'isCompleted': isCompleted,
      'goalItems': goalItems?.map((goalItem) => goalItem.toJson()).toList(),
    };
  }

  factory MonthlyGoal.fromMap(Map<String, dynamic> map) {
    return MonthlyGoal(
      id: map['id'] as String,
      status: map['status'].toInt(),
      totalAmount: map['totalAmount'].toDouble(),
      month: map['month'].toInt(),
      year: map['year'].toInt(),
      createAt: DateTime.parse(map['createAt']),
      isCompleted: map['isCompleted'] as bool? ?? true,
      goalItems: (map['goalItems'] as List)
          .map((e) => GoalItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  MonthlyGoal copyWith({
    String? id,
    int? status,
    double? totalAmount,
    int? month,
    int? year,
    DateTime? createAt,
    bool? isCompleted,
    List<GoalItem>? goalItems,
  }) {
    return MonthlyGoal(
      id: id ?? this.id,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      month: month ?? this.month,
      year: year ?? this.year,
      createAt: createAt ?? this.createAt,
      isCompleted: isCompleted ?? this.isCompleted,
      goalItems: goalItems ?? this.goalItems,
    );
  }
}

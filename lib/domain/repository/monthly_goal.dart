import 'package:dartz/dartz.dart';
import 'package:my_project/data/models/monthly_goal.dart';
import 'package:my_project/data/models/monthly_goal_req_params.dart';

abstract class MonthlyGoalRepository {
  Future<Either<String, double>> getTotalAmount();
  Future<Either<String, List<MonthlyGoal>>> getMonthlyGoals(
      int? year, int? month, int? status, int pageIndex, int pageSize);
  Future<Either<String, MonthlyGoal>> createMonthlyGoal(
      MonthlyGoalReqParams monthlyGoal);
  Future<Either<String, MonthlyGoal>> updateMonthlyGoal(
      String id, MonthlyGoalReqParams monthlyGoal);
}

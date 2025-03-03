import 'package:dartz/dartz.dart';
import 'package:my_project/data/models/goal_item.dart';
import 'package:my_project/data/models/goal_item_req_params.dart';

abstract class GoalItemRepository {
  Future<Either<String, double>> getTotalUsedAmount();
  Future<Either<String, GoalItem>> createGoalItem(GoalItemReqParams goalItem);
  Future<Either<String, GoalItem>> updateGoalItem(
      String id, GoalItemReqParams goalItem);
}

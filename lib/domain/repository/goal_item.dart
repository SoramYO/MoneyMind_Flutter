import 'package:dartz/dartz.dart';

abstract class GoalItemRepository {
  Future<Either<String, double>> getTotalUsedAmount();
}

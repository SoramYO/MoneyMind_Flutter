import 'package:dartz/dartz.dart';

abstract class MonthlyGoalRepository {
  Future<Either<String, double>> getTotalAmount();
}

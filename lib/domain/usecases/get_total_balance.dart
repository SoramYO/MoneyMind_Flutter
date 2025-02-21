import 'package:dartz/dartz.dart';
import 'package:my_project/core/usecase/usecase.dart';
import 'package:my_project/data/models/transaction.dart';
import 'package:my_project/domain/repository/goal_item.dart';
import 'package:my_project/domain/repository/transaction.dart';
import 'package:my_project/service_locator.dart';

class getTotalUsedAmountUseCase implements UseCase<Either, double> {
  @override
  Future<Either> call({double? param}) async {
    return sl<GoalItemRepository>().getTotalUsedAmount();
  }
}

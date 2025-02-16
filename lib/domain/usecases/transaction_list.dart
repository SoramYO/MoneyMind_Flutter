import 'package:dartz/dartz.dart';
import 'package:my_project/core/usecase/usecase.dart';
import 'package:my_project/data/models/transaction.dart';
import 'package:my_project/domain/repository/transaction.dart';
import 'package:my_project/service_locator.dart';

class TransactionListUseCase implements UseCase<Either, Transaction> {

  @override
  Future<Either> call({Transaction? param}) async {
    return sl<TransactionRepository>().getTransactions(param!.userId);
  }
}
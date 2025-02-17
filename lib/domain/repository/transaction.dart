import 'package:dartz/dartz.dart';
import '../../data/models/transaction.dart';

abstract class TransactionRepository {
  Future<Either> getTransactions(String userId);
  Future<Either> createTransaction(TransactionModel transaction);
  Future<Either> updateTransaction(TransactionModel transaction);
  Future<Either<String, bool>> deleteTransaction(String id);
}

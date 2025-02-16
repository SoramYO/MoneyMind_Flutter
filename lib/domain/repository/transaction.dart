import 'package:dartz/dartz.dart';
import '../../data/models/transaction.dart';

abstract class TransactionRepository {
  Future<Either<String, List<Transaction>>> getTransactions(String userId);
  Future<Either<String, Transaction>> createTransaction(Transaction transaction);
  Future<Either<String, Transaction>> updateTransaction(Transaction transaction);
  Future<Either<String, bool>> deleteTransaction(String id);
} 
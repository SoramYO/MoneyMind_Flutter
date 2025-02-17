import 'package:dartz/dartz.dart';
import 'package:my_project/data/models/transaction.dart';

abstract class TransactionRepository {
  Future<Either<String, List<Transaction>>> getTransactions(
    String userId, {
    Map<String, String>? queryParams,
  });
  Future<Either<String, Transaction>> createTransaction(Transaction transaction);
  Future<Either<String, Transaction>> updateTransaction(Transaction transaction);
  Future<Either<String, bool>> deleteTransaction(String id);
  
  
  
} 
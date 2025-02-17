import 'package:dartz/dartz.dart';
import '../../domain/repository/transaction.dart';
import '../../service_locator.dart';
import '../models/transaction.dart';
import '../source/transaction_api_service.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  @override
  Future<Either<String, List<Transaction>>> getTransactions(
    String userId, {
    Map<String, String>? queryParams,
  }) async {
    try {
      final result = await sl<TransactionApiService>().getTransactions(
        userId,
        queryParams: queryParams,
      );
      return result.fold(
        (error) => Left(error.toString()),
        (data) => Right(data),
      );
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Transaction>> createTransaction(Transaction transaction) async {
    try {
      final result = await sl<TransactionApiService>().createTransaction(transaction);
      return result.fold(
        (error) => Left(error.toString()),
        (data) => Right(data),
      );
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Transaction>> updateTransaction(Transaction transaction) async {
    try {
      final result = await sl<TransactionApiService>().updateTransaction(transaction);
      return result.fold(
        (error) => Left(error.toString()),
        (data) => Right(data),
      );
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, bool>> deleteTransaction(String id) async {
    try {
      final result = await sl<TransactionApiService>().deleteTransaction(id);
      return result.fold(
        (error) => Left(error.toString()),
        (data) => Right(data),
      );
    } catch (e) {
      return Left(e.toString());
    }
  }
} 
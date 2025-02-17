import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../domain/repository/transaction.dart';
import '../../service_locator.dart';
import '../models/transaction.dart';
import '../source/transaction_api_service.dart';

class TransactionRepositoryImpl extends TransactionRepository {
  @override
  Future<Either> getTransactions(String userId) async {
    try {
      Either result = await sl<TransactionApiService>().getTransactions(userId);
      return result.fold((error) {
        return Left(error);
      }, (data) {
        Response response = data;
        final List<dynamic> listDataTransaction = response.data['data']['data'];
        //   final transactions =
        //       data.map((json) => Transaction.fromJson(json)).toList();
        var transactionsModel = listDataTransaction
            .map((json) => TransactionModel.fromJson(json))
            .toList();
        var transactionsEntity = transactionsModel
            .map((transactions) => transactions.toEntity())
            .toList();
        return Right(transactionsEntity);
      });
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either> createTransaction(TransactionModel transaction) async {
    try {
      final result =
          await sl<TransactionApiService>().createTransaction(transaction);
      return result.fold(
        (error) => Left(error.toString()),
        (data) => Right(data),
      );
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either> updateTransaction(TransactionModel transaction) async {
    try {
      final result =
          await sl<TransactionApiService>().updateTransaction(transaction);
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

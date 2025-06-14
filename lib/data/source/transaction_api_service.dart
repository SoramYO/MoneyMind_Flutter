import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../core/constants/api_urls.dart';
import '../../core/network/dio_client.dart';
import '../../service_locator.dart';
import '../models/transaction.dart';

abstract class TransactionApiService {
  Future<Either<String, List<Transaction>>> getTransactions(
    String userId, {
    Map<String, String>? queryParams,
  });
  Future<Either<String, Transaction>> createTransaction(
      TransactionRequest transaction);
  Future<Either<String, Transaction>> updateTransaction(
      String transactionId, TransactionRequest transaction);
  Future<Either<String, bool>> deleteTransaction(String id);
  Future<Either<String, Transaction>> getTransactionById(String id);
}

class TransactionApiServiceIml implements TransactionApiService {
  @override
  Future<Either<String, List<Transaction>>> getTransactions(
    String userId, {
    Map<String, String>? queryParams,
  }) async {
    try {
      final response = await sl<DioClient>().get(
        '${ApiUrls.transactions}/$userId',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data']['data'];
        final transactions = data
            .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
            .toList();
        return Right(transactions);
      }
      return Left(response.data['message'] ?? 'Lỗi không xác định');
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối');
    }
  }

  @override
  Future<Either<String, Transaction>> createTransaction(
      TransactionRequest transaction) async {
    try {
      final response = await sl<DioClient>().post(
        ApiUrls.transactions,
        data: transaction.toJson(),
      );

      if (response.statusCode == 200) {
        return Right(Transaction.fromJson(response.data['data']));
      }

      return Left(response.data['message'] ?? 'Lỗi không xác định');
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối');
    }
  }

  @override
  Future<Either<String, Transaction>> updateTransaction(
      String transactionId, TransactionRequest transaction) async {
    try {
      final response = await sl<DioClient>().put(
        '${ApiUrls.transactions}/${transactionId.trim()}',
        data: transaction.toJson(),
      );

      if (response.statusCode == 200) {
        return Right(Transaction.fromJson(response.data['data']));
      }

      return Left(response.data['message'] ?? 'Lỗi không xác định');
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối');
    }
  }

  @override
  Future<Either<String, bool>> deleteTransaction(String id) async {
    try {
      final response = await sl<DioClient>().put(
        '${ApiUrls.transactions}/$id/delete',
        data: {'isActive': false},
      );

      if (response.statusCode == 200) {
        return const Right(true);
      }

      return Left(response.data['message'] ?? 'Lỗi không xác định');
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối');
    }
  }

  @override
  Future<Either<String, Transaction>> getTransactionById(String id) async {
    try {
      final response = await sl<DioClient>().get(
        '${ApiUrls.transactions}/detail/$id',
      );

      if (response.statusCode == 200) {
        return Right(Transaction.fromJson(response.data['data']));
      }
      return Left(response.data['message'] ?? 'Lỗi không xác định');
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối');
    }
  }
}

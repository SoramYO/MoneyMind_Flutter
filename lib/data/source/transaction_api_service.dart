import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_urls.dart';
import '../../core/network/dio_client.dart';
import '../../service_locator.dart';
import '../models/transaction.dart';

abstract class TransactionApiService {
  Future<Either> getTransactions(String userId);
  Future<Either> createTransaction(TransactionModel transaction);
  Future<Either> updateTransaction(TransactionModel transaction);
  Future<Either<String, bool>> deleteTransaction(String id);
}

class TransactionApiServiceIml extends TransactionApiService {
  @override
  Future<Either> getTransactions(String userId) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('accessToken');
      var response = await sl<DioClient>().get(
        '${ApiUrls.transactions}$userId',
        options: Options(headers: {
          'Authorization': 'Bearer $token ',
        }),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối');
    }
  }

  @override
  Future<Either> createTransaction(TransactionModel transaction) async {
    try {
      final response = await sl<DioClient>().post(
        ApiUrls.transactions,
        data: transaction.toJson(),
      );

      if (response.statusCode == 201) {
        return Right(TransactionModel.fromJson(response.data['data']));
      }

      return Left(response.data['message'] ?? 'Lỗi không xác định');
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối');
    }
  }

  @override
  Future<Either> updateTransaction(TransactionModel transaction) async {
    try {
      final response = await sl<DioClient>().put(
        '${ApiUrls.transactions}/${transaction.id}',
        data: transaction.toJson(),
      );

      if (response.statusCode == 200) {
        return Right(TransactionModel.fromJson(response.data['data']));
      }

      return Left(response.data['message'] ?? 'Lỗi không xác định');
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối');
    }
  }

  @override
  Future<Either<String, bool>> deleteTransaction(String id) async {
    try {
      final response = await sl<DioClient>().delete(
        '${ApiUrls.transactions}/$id',
      );

      if (response.statusCode == 200) {
        return const Right(true);
      }

      return Left(response.data['message'] ?? 'Lỗi không xác định');
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối');
    }
  }
}

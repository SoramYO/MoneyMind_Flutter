import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:my_project/data/models/wallet.dart';
import 'package:my_project/data/models/wallet_detail.dart';
import 'package:my_project/presentation/wallet/wallet_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_urls.dart';
import '../../core/network/dio_client.dart';
import '../../service_locator.dart';
import '../models/transaction.dart';

abstract class WalletApiService {
  Future<Either> getTotalBalance();
  Future<Either<String, List<Wallet>>> getWallets({
    Map<String, String>? queryParams,
  });
  Future<Either<String, List<Transaction>>> getWalletByUserId(String userId);
  Future<Either<String, List<Transaction>>> getWalletByWalletId(
      String walletId);
  Future<Either<String, Wallet>> createWallet(Map<String, dynamic> walletData);
  Future<Either<String, Transaction>> updateWallet(Wallet wallet);
  Future<Either<String, bool>> deleteWallet(String id);
  Future<Either<String, WalletClone>> getWalletById(String id);
}

class WalletApiServiceImpl implements WalletApiService {
  @override
  Future<Either<String, List<Transaction>>> getWalletByUserId(
      String userId) async {
    try {
      final response = await sl<DioClient>().get(
        '${ApiUrls.wallet}?userId=$userId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final transactions =
            data.map((json) => Transaction.fromJson(json)).toList();
        return Right(transactions);
      }

      return Left(response.data['message'] ?? 'Lỗi không xác định');
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối');
    }
  }

  @override
  Future<Either<String, List<Transaction>>> getWalletByWalletId(
      String walletId) async {
    try {
      final response = await sl<DioClient>().get(
        '${ApiUrls.wallet}?walletId=$walletId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final transactions =
            data.map((json) => Transaction.fromJson(json)).toList();
        return Right(transactions);
      }

      return Left(response.data['message'] ?? 'Lỗi không xác định');
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối');
    }
  }

  @override
  Future<Either<String, Wallet>> createWallet(Map<String, dynamic> walletData) async {
    try {
      final response = await sl<DioClient>().post(
        ApiUrls.wallet,
        data: walletData,
      );

      if (response.statusCode == 201 && response.data != null) {
        return Right(Wallet.fromJson(response.data['data']));
      }

      return Left(response.data?['message'] ?? 'Lỗi không xác định');
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối';
      print('❌ Lỗi khi tạo Wallet: $errorMessage'); // Logging lỗi
      return Left(errorMessage);
    } catch (e) {
      print('❌ Lỗi không mong muốn: $e'); // Logging lỗi không mong muốn
      return Left('Đã xảy ra lỗi không mong muốn');
    }
  }

  @override
  Future<Either<String, Transaction>> updateWallet(Wallet wallet) async {
    try {
      final response = await sl<DioClient>().put(
        '${ApiUrls.wallet}/${wallet.id}',
        data: wallet.toJson(),
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
  Future<Either<String, bool>> deleteWallet(String id) async {
    try {
      final response = await sl<DioClient>().put('${ApiUrls.wallet}/$id/delete');

      if (response.statusCode == 200) {
        return Right(true);
      }

      return Left(response.data['message'] ?? 'Lỗi không xác định');
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối');
    }
  }

  @override
  Future<Either> getTotalBalance() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var accessToken = sharedPreferences.getString('accessToken');
      var userId = sharedPreferences.getString('userId');
      var response = await sl<DioClient>().get('${ApiUrls.wallet}/$userId',
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}));
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.toString());
    }
  }

  @override
  Future<Either<String, List<Wallet>>> getWallets(
      {Map<String, String>? queryParams}) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var accessToken = sharedPreferences.getString('accessToken');
      var userId = sharedPreferences.getString('userId');
      final response = await sl<DioClient>().get(
        '${ApiUrls.wallet}/$userId',
        queryParameters: queryParams,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data']['data'];
        final wallets = data
            .map((json) => Wallet.fromJson(json as Map<String, dynamic>))
            .toList();
        return Right(wallets);
      }

      return Left(response.data['message'] ?? 'Lỗi không xác định');
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối');
    }
  }

 @override
  Future<Either<String, WalletClone>> getWalletById(String id) async {
    try {
      final url = '${ApiUrls.wallet}/detail/$id';
      final response = await sl<DioClient>().get(url);

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final wallet = WalletClone.fromJson(data);
        return Right(wallet);
      }
      return Left(response.data['message'] ?? 'Lỗi không xác định');
    } on DioException catch (e) {
      return Future.value(
          Left(e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối'));
    }
  }
}
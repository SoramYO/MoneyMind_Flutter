import 'package:dartz/dartz.dart';
import 'package:my_project/core/constants/api_urls.dart';
import 'package:my_project/core/network/dio_client.dart';
import 'package:my_project/data/models/wallet_type.dart';
import 'package:my_project/service_locator.dart';

abstract class WalletTypeApiService {
  Future<Either<String, List<WalletType>>> getWalletType(
      int pageIndex, int pageSize);

  Future<Either<String, WalletType>> getWalletTypeById(String categoryId);
  Future<Either<String, List<WalletType>>> createWalletType(
      WalletType walletType);

  Future<Either<String, WalletType>> updateWalletType(WalletType walletType);
}

class WalletTypeApiServiceImpl implements WalletTypeApiService {
  @override
  Future<Either<String, List<WalletType>>> getWalletType(
      int pageIndex, int pageSize) async {
    try {
      final url =
          '${ApiUrls.walletType}?pageIndex=$pageIndex&pageSize=$pageSize';

      final response = await sl<DioClient>().get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data']['data'];
        final walletTypes =
            data.map((json) => WalletType.fromJson(json)).toList();
        return Right(walletTypes);
      } else {
        return Left('Failed to fetch wallet types');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<WalletType>>> createWalletType(
      WalletType walletType) async {
    try {
      final url = '${ApiUrls.walletType}';
      final response =
          await sl<DioClient>().post(url, data: walletType.toJson());
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data']['data'];
        final walletTypes =
            data.map((json) => WalletType.fromJson(json)).toList();
        return Right(walletTypes);
      } else {
        return Left('Failed to create wallet type');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, WalletType>> getWalletTypeById(
      String categoryId) async {
    try {
      final url = '${ApiUrls.walletType}/$categoryId';

      final response = await sl<DioClient>().get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data['data'];
        final walletType = WalletType.fromJson(data);
        return Right(walletType);
      } else {
        return Left('Failed to fetch wallet type');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, WalletType>> updateWalletType(
      WalletType walletType) async {
    try {
      final url = '${ApiUrls.walletType}/${walletType.id}';

      final response =
          await sl<DioClient>().put(url, data: walletType.toJson());

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data['data'];
        final updatedWalletType = WalletType.fromJson(data);
        return Right(updatedWalletType);
      } else {
        return Left('Failed to update wallet type');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }
}

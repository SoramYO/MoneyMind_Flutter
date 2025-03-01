import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:my_project/data/models/wallet.dart';
import 'package:my_project/data/source/wallet_api_service.dart';
import 'package:my_project/domain/repository/wallet.dart';
import 'package:my_project/service_locator.dart';

class WalletRepositoryImpl implements WalletRepository {
  @override
  Future<Either<String, double>> getTotalBalance() async {
    Either result = await sl<WalletApiService>().getTotalBalance();
    return result.fold((error) {
      return Left(error);
    }, (data) async {
      Response response = data;
      if (response.statusCode == 200) {
        // Lấy danh sách wallet từ response
        List<dynamic> wallets = response.data["data"]["data"];
        // Tính tổng số dư
        double totalBalance = wallets.fold(0.0, (sum, item) {
          return sum + (item["balance"] as num).toDouble();
        });
        return Right(totalBalance); // Trả về message thành công
      }
      return Left("Lấy dữ liệu thất bại");
    });
  }

  @override
  Future<Either<String, List<Wallet>>> getWallets(
      {Map<String, String>? queryParams}) async {
    try {
      final result = await sl<WalletApiService>().getWallets(
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
  Future<Either<String, Wallet>> createWallet(Map<String, dynamic> walletData) async {
    try {
      final result = await sl<WalletApiService>()
          .createWallet(walletData);
      return result.fold(
        (error) => Left(error.toString()),
        (data) => Right(data),
      );
    } catch (e) {
      return Left(e.toString());
    }
  }
 
}

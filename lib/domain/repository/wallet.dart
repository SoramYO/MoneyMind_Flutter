import 'package:dartz/dartz.dart';
import 'package:my_project/data/models/wallet.dart';

abstract class WalletRepository {
  Future<Either<String, double>> getTotalBalance();
  Future<Either<String, List<Wallet>>> getWallets({
    Map<String, String>? queryParams,
  });
    Future<Either<String, Wallet>> createWallet(
     Map<String, dynamic> walletData);
}

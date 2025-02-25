import 'package:dartz/dartz.dart';
import 'package:my_project/data/models/wallet_type.dart';

abstract class WalletTypeRepository {
  Future<Either<String, List<WalletType>>> getWalletType(
      int pageIndex, int pageSize);
  Future<Either<String, WalletType>> getWalletTypeById(String typeId);
  Future<Either<String, WalletType>> createWalletType(WalletType walletType);
  Future<Either<String, WalletType>> updateWalletType(WalletType walletType);
}

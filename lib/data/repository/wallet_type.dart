import 'package:dartz/dartz.dart';
import 'package:my_project/data/models/wallet_type.dart';
import 'package:my_project/data/source/wallet_type_api_service.dart';
import 'package:my_project/domain/repository/wallet_type.dart';
import 'package:my_project/service_locator.dart';

class WalletTypeRepositoryImpl implements WalletTypeRepository {
  @override
  Future<Either<String, WalletType>> createWalletType(
      WalletType walletType) async {
    try {
      final result =
          await sl<WalletTypeApiService>().createWalletType(walletType);
      return result.fold(
        (error) => Left(error.toString()),
        (data) => Right(data as WalletType),
      );
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<WalletType>>> getWalletType(
      int pageIndex, int pageSize) async {
    try {
      final result =
          await sl<WalletTypeApiService>().getWalletType(pageIndex, pageSize);
      return result.fold(
        (error) => Left(error.toString()),
        (data) => Right(data),
      );
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, WalletType>> getWalletTypeById(String typeId) async {
    try {
      final result = await sl<WalletTypeApiService>().getWalletTypeById(typeId);
      return result.fold(
        (error) => Left(error.toString()),
        (data) => Right(data),
      );
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, WalletType>> updateWalletType(
      WalletType walletType) async {
    try {
      final result =
          await sl<WalletTypeApiService>().updateWalletType(walletType);
      return result.fold(
        (error) => Left(error.toString()),
        (data) => Right(data),
      );
    } catch (e) {
      return Left(e.toString());
    }
  }
}

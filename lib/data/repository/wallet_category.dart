import 'package:dartz/dartz.dart';
import 'package:my_project/data/models/wallet_category.dart';
import 'package:my_project/data/source/wallet_category_api_service.dart';
import 'package:my_project/domain/repository/wallet_category.dart';
import 'package:my_project/service_locator.dart';

class WalletCategoryRepositoryImpl implements WalletCategoryRepository {
  @override
  Future<Either<String, List<WalletCategory>>> getWalletCategoryByUserId(String userId, String? walletTypeId, int pageIndex, int pageSize) async {
   
   try{
     final result = await sl<WalletCategoryApiService>().getWalletCategoryByUserId(userId, walletTypeId, pageIndex, pageSize);
     return result.fold(
       (error) => Left(error.toString()),
       (data) => Right(data),
     );
   } catch (e) {
     return Left(e.toString());
   }
  }
  
 @override
  Future<Either<String, WalletCategory>> getWalletCategoryById(String categoryId) async {
    try {
      final result = await sl<WalletCategoryApiService>().getWalletCategoryById(categoryId);
      return result.fold(
        (error) => Left(error.toString()),
        (data) => Right(data),
      );
    } catch (e) {
      return Left(e.toString());
    }
  }
  @override
  Future<Either<String, List<WalletCategory>>> createWalletCategoryDefault() async {
    try {
      final result = await sl<WalletCategoryApiService>().createWalletCategoryDefault();
      return result.fold(
        (error) => Left(error.toString()),
        (data) => Right(data),
      );
    } catch (e) {
      return Left(e.toString());
    }
  }
}
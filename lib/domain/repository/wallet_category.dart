import 'package:dartz/dartz.dart';
import 'package:my_project/data/models/wallet_category.dart';

abstract class WalletCategoryRepository {
  Future<Either<String, List<WalletCategory>>> getWalletCategoryByUserId(
      String userId, String? walletTypeId, int pageIndex, int pageSize);
  Future<Either<String, WalletCategory>> getWalletCategoryById(
      String categoryId);
  Future<Either<String, List<WalletCategory>>> createWalletCategoryDefault();
  Future<Either<String, WalletCategory>> createWalletCategory(
      WalletCategory walletCategory);
  Future<Either<String, WalletCategory>> updateWalletCategory(
      WalletCategory walletCategory);
       Future<Either<String, List<WalletCategory>>> getWalletCategoryByOnlyUserId(
      String userId);
}

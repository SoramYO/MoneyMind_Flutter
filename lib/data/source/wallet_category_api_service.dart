import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:my_project/data/models/wallet_category.dart';
import 'package:my_project/core/constants/api_urls.dart';
import 'package:my_project/core/network/dio_client.dart';
import 'package:my_project/service_locator.dart';

abstract class WalletCategoryApiService {
  Future<Either<String, List<WalletCategory>>> getWalletCategoryByUserId(
    String userId, String? walletTypeId, int pageIndex , int pageSize );

  Future<Either<String, WalletCategory>> getWalletCategoryById(String categoryId);
}

class WalletCategoryApiServiceImpl implements WalletCategoryApiService {
  @override
  Future<Either<String, List<WalletCategory>>> getWalletCategoryByUserId(String userId, String? walletTypeId, int pageIndex, int pageSize) async {
    try {
      final url = '${ApiUrls.walletCategory}/$userId?'
        '${walletTypeId != null ? 'walletTypeId=$walletTypeId&' : ''}'
        'pageIndex=$pageIndex&pageSize=$pageSize';

      final response = await sl<DioClient>().get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data']['data'];
        final walletCategories = data.map((json) => WalletCategory.fromJson(json)).toList();
        return Right(walletCategories);
      }
      return Left(response.data['message'] ?? 'Lỗi không xác định');
    } on DioException catch (e) {
      return Future.value(Left(e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối'));
    }
  }
  
  @override
  Future<Either<String, WalletCategory>> getWalletCategoryById(String categoryId) async {
    try{
      final url = '${ApiUrls.walletCategory}/detail/$categoryId';
      final response = await sl<DioClient>().get(url);

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final walletCategory = WalletCategory.fromJson(data);
        return Right(walletCategory);
      }
      return Left(response.data['message'] ?? 'Lỗi không xác định');
    } on DioException catch (e) {
      return Future.value(Left(e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối'));
    }
  }
  
}
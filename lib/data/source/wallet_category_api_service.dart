import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:my_project/data/models/wallet_category.dart';
import 'package:my_project/core/constants/api_urls.dart';
import 'package:my_project/core/network/dio_client.dart';
import 'package:my_project/service_locator.dart';

abstract class WalletCategoryApiService {
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

class WalletCategoryApiServiceImpl implements WalletCategoryApiService {
  @override
  Future<Either<String, List<WalletCategory>>> getWalletCategoryByUserId(
      String userId, String? walletTypeId, int pageIndex, int pageSize) async {
    try {
      final url = '${ApiUrls.walletCategory}/$userId?'
          '${walletTypeId != null ? 'walletTypeId=$walletTypeId&' : ''}'
          'pageIndex=$pageIndex&pageSize=$pageSize';

      final response = await sl<DioClient>().get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data']['data'];
        final walletCategories =
            data.map((json) => WalletCategory.fromJson(json)).toList();
        return Right(walletCategories);
      }
      return Left(response.data['message'] ?? 'Lỗi không xác định');
    } on DioException catch (e) {
      return Future.value(
          Left(e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối'));
    }
  }

  @override
  Future<Either<String, WalletCategory>> getWalletCategoryById(
      String categoryId) async {
    try {
      final url = '${ApiUrls.walletCategory}/detail/$categoryId';
      final response = await sl<DioClient>().get(url);

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final walletCategory = WalletCategory.fromJson(data);
        return Right(walletCategory);
      }
      return Left(response.data['message'] ?? 'Lỗi không xác định');
    } on DioException catch (e) {
      return Future.value(
          Left(e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối'));
    }
  }

  @override
  Future<Either<String, List<WalletCategory>>>
      createWalletCategoryDefault() async {
    try {
      final url = '${ApiUrls.walletCategory}/create-default';
      final response = await sl<DioClient>().post(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final walletCategories =
            data.map((json) => WalletCategory.fromJson(json)).toList();
        return Right(walletCategories);
      }
      return Left(response.data['message'] ?? 'Lỗi không xác định');
    } on DioException catch (e) {
      return Future.value(
          Left(e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối'));
    }
  }

  @override
  Future<Either<String, WalletCategory>> createWalletCategory(
      WalletCategory walletCategory) async {
    try {
      final url = ApiUrls.walletCategory;
      final response =
          await sl<DioClient>().post(url, data: walletCategory.toJson());
      if (response.statusCode == 200) {
        final data = response.data['data'];
        final walletCategory = WalletCategory.fromJson(data);
        return Right(walletCategory);
      }
      return Left(response.data['message'] ?? 'Lỗi không xác định');
    } on DioException catch (e) {
      return Future.value(
          Left(e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối'));
    }
  }

  @override
  Future<Either<String, WalletCategory>> updateWalletCategory(
      WalletCategory walletCategory) async {
    try {
      final url = "${ApiUrls.walletCategory}/${walletCategory.id}";

      // Only send fields that can be updated according to backend
      final updateData = {
        'name': walletCategory.name,
        'description': walletCategory.description,
        'iconPath': walletCategory.iconPath,
        'color': walletCategory.color,
        'walletTypeId': walletCategory.walletTypeId,
      };

      print('Update URL: $url');
      print('Update Data: $updateData');

      final response = await sl<DioClient>().put(url, data: updateData);

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final updatedCategory = WalletCategory.fromJson(data);
        return Right(updatedCategory);
      }

      print('Update Error: ${response.data}');
      return Left(response.data['message'] ?? 'Lỗi không xác định');
    } on DioException catch (e) {
      print('DioException: ${e.response?.data}');
      return Left(e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối');
    }
  }

  @override
  Future<Either<String, List<WalletCategory>>> getWalletCategoryByOnlyUserId(
      String userId) async {
    try {
      final url = '${ApiUrls.walletCategory}/$userId?';

      final response = await sl<DioClient>().get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data']['data'];
        final walletCategories =
            data.map((json) => WalletCategory.fromJson(json)).toList();
        return Right(walletCategories);
      }
      return Left(response.data['message'] ?? 'Lỗi không xác định');
    } on DioException catch (e) {
      return Future.value(
          Left(e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối'));
    }
  }
}

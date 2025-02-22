import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:my_project/core/constants/api_urls.dart';
import 'package:my_project/core/network/dio_client.dart';
import 'package:my_project/service_locator.dart';

abstract class SheetApiService {
  Future<Either<String, Map<String, dynamic>>> addSheetId(String sheetId, String userId);
  Future<Either<String, Map<String, dynamic>>> syncSheet(String userId);
  Future<bool> checkSheetExists(String userId);
}

class SheetApiServiceImpl implements SheetApiService {
  @override
  Future<Either<String, Map<String, dynamic>>> addSheetId(String sheetId, String userId) async {
    try {
      final response = await sl<DioClient>().post(
        ApiUrls.addSheet,
        data: {'sheetId': sheetId, 'userId': userId},
      );
      return Right(response.data);
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối');
    }
  }

  @override
  Future<Either<String, Map<String, dynamic>>> syncSheet(String userId) async {
    try {
      final response = await sl<DioClient>().post(
        '${ApiUrls.syncSheet}/$userId',
      );
      return Right(response.data);
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối');
    }
  }

  @override
  Future<bool> checkSheetExists(String userId) async {
    try {
      final response = await sl<DioClient>().get('${ApiUrls.checkSheetExists}/$userId');
      return response.data['exists'] ?? false;
    } on DioException catch (e) {
      return false;
    }
  }
} 
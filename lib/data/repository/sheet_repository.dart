import 'package:dartz/dartz.dart';
import 'package:my_project/data/source/sheet_api_service.dart';
import 'package:my_project/domain/repository/sheet.dart';
import 'package:my_project/service_locator.dart';
class SheetRepositoryImpl implements SheetRepository {
  @override
  Future<Either<String, Map<String, dynamic>>> addSheetId(String sheetId, String userId) async {
    try {
      final result = await sl<SheetApiService>().addSheetId(sheetId, userId);
      return result;
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Map<String, dynamic>>> syncSheet(String userId) async {
    try {
      final result = await sl<SheetApiService>().syncSheet(userId);
      return result;
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<bool> checkSheetExists(String userId) async {
    try {
      final result = await sl<SheetApiService>().checkSheetExists(userId);
      return result;
    } catch (e) {
      return false;
    }
  }
} 
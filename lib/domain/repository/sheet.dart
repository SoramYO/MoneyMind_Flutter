import 'package:dartz/dartz.dart';

abstract class SheetRepository {
  Future<Either<String, Map<String, dynamic>>> addSheetId(String sheetId, String userId);
  Future<Either<String, Map<String, dynamic>>> syncSheet(String userId);
  Future<bool> checkSheetExists(String userId);
}
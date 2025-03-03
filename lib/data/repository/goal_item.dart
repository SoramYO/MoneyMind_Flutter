import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:my_project/data/models/goal_item.dart';
import 'package:my_project/data/models/goal_item_req_params.dart';
import 'package:my_project/data/source/goal_item_api_service.dart';
import 'package:my_project/domain/repository/goal_item.dart';
import '../../service_locator.dart';

class GoalItemRepositoryImpl implements GoalItemRepository {
  @override
  Future<Either<String, double>> getTotalUsedAmount() async {
    Either result = await sl<GoalItemApiService>().getTotalUsedAmount();
    return result.fold((error) {
      return Left(error);
    }, (data) async {
      Response response = data;
      if (response.statusCode == 200) {
        // Lấy danh sách goal item từ response
        List<dynamic> goalItems = response.data["data"]["data"];
        // Tính tổng usedAmount
        double totalBalance = goalItems.fold(0.0, (sum, item) {
          return sum + (item["usedAmount"] as num).toDouble();
        });
        return Right(totalBalance); // Trả về message thành công
      }
      return Left("Lấy dữ liệu thất bại");
    });
  }

  @override
  Future<Either<String, GoalItem>> createGoalItem(
      GoalItemReqParams goalItem) async {
    Either result = await sl<GoalItemApiService>().createGoalItem(goalItem);
    return result.fold((error) {
      return Left(error.toString());
    }, (data) async {
      Response response = data;
      if (response.statusCode == 200) {
        var goalItemResponse = GoalItem.fromMap(response.data['data']);
        return Right(goalItemResponse);
      }
      return Left("Create goal item fail");
    });
  }

  @override
  Future<Either<String, GoalItem>> updateGoalItem(
      String id, GoalItemReqParams goalItem) async {
    Either result = await sl<GoalItemApiService>().updateGoalItem(id, goalItem);
    return result.fold((error) {
      return Left(error.toString());
    }, (data) async {
      Response response = data;
      if (response.statusCode == 200) {
        var goalItemResponse = GoalItem.fromMap(response.data['data']);
        return Right(goalItemResponse);
      }
      return Left('Update goal item fail: ${response.data["message"]}');
    });
  }
}

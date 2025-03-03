import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:my_project/data/models/goal_item.dart';
import 'package:my_project/data/models/goal_item_req_params.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_urls.dart';
import '../../core/network/dio_client.dart';
import '../../service_locator.dart';

abstract class GoalItemApiService {
  Future<Either> getTotalUsedAmount();
  Future<Either> createGoalItem(GoalItemReqParams goalItem);
  Future<Either> updateGoalItem(String id, GoalItemReqParams goalItem);
}

class GoalItemApiServiceImpl extends GoalItemApiService {
  @override
  Future<Either> getTotalUsedAmount() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var accessToken = sharedPreferences.getString('accessToken');
      var userId = sharedPreferences.getString('userId');
      var response = await sl<DioClient>().get('${ApiUrls.goalItem}/$userId',
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}));
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.toString());
    }
  }

  @override
  Future<Either> createGoalItem(GoalItemReqParams goalItem) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var accessToken = sharedPreferences.getString('accessToken');
      var response = await sl<DioClient>().post(ApiUrls.goalItem,
          data: goalItem.toJson(),
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}));
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.toString());
    }
  }

  @override
  Future<Either> updateGoalItem(String id, GoalItemReqParams goalItem) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var accessToken = sharedPreferences.getString('accessToken');
      var response = await sl<DioClient>().put('${ApiUrls.goalItem}/$id',
          data: goalItem.toJson(),
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}));
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!);
    }
  }
}

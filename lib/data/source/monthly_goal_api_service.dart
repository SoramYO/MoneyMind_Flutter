import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:my_project/data/models/monthly_goal_req_params.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_urls.dart';
import '../../core/network/dio_client.dart';
import '../../service_locator.dart';

abstract class MonthlyGoalApiService {
  Future<Either> getTotalAmount();
  Future<Either> getMonthlyGoals(
      int? year, int? month, int? status, int pageIndex, int pageSize);
  Future<Either> createMonthlyGoal(MonthlyGoalReqParams monthlyGoal);
  Future<Either> updateMonthlyGoal(String id, MonthlyGoalReqParams monthlyGoal);
}

class MonthlyGoalApiServiceImpl extends MonthlyGoalApiService {
  @override
  Future<Either> getTotalAmount() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var accessToken = sharedPreferences.getString('accessToken');
      var userId = sharedPreferences.getString('userId');
      var response = await sl<DioClient>().get('${ApiUrls.monthlyGoal}/$userId',
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}));
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.toString());
    }
  }

  @override
  Future<Either> getMonthlyGoals(
      int? year, int? month, int? status, int pageIndex, int pageSize) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var accessToken = sharedPreferences.getString('accessToken');
      var userId = sharedPreferences.getString('userId');
      final url = '${ApiUrls.monthlyGoal}/$userId?'
          '${year != null ? 'year=$year&' : ''}'
          '${month != null ? 'month=$month&' : ''}'
          '${status != null ? 'status=$status&' : ''}'
          'pageIndex=$pageIndex&pageSize=$pageSize';

      var response = await sl<DioClient>().get(url,
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}));
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.toString());
    }
  }

  @override
  Future<Either> createMonthlyGoal(MonthlyGoalReqParams monthlyGoal) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var accessToken = sharedPreferences.getString('accessToken');
      var response = await sl<DioClient>().post(ApiUrls.monthlyGoal,
          data: monthlyGoal.toJson(),
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}));
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.toString());
    }
  }

  @override
  Future<Either> updateMonthlyGoal(
      String id, MonthlyGoalReqParams monthlyGoal) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var accessToken = sharedPreferences.getString('accessToken');
      var response = await sl<DioClient>().put('${ApiUrls.monthlyGoal}/$id',
          data: monthlyGoal.toJson(),
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}));
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!);
    }
  }
}

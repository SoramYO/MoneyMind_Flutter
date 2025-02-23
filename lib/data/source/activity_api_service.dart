import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:my_project/core/constants/api_urls.dart';
import 'package:my_project/core/network/dio_client.dart';
import 'package:my_project/data/models/activity.dart';
import 'package:my_project/data/models/activity_req_params.dart';
import 'package:my_project/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ActivityApiService {
  Future<Either<String, List<ActivityDb>>> getActivityApi({
    String? walletCategoryId,
    Map<String, String>? queryParams,
  });
  Future<Either> createActivity(ActivityReqParams createReqActivity);
  Future<Either> updateActivity(String id, ActivityReqParams updateReqActivity);
  Future<Either> deleteActivity(String id);
}

class ActivityApiServiceImpl implements ActivityApiService {
  @override
  Future<Either> deleteActivity(String id) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var accessToken = sharedPreferences.getString('accessToken');
      var response = await sl<DioClient>().put('${ApiUrls.activity}/$id/delete',
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}));
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.toString());
    }
  }

  @override
  Future<Either> updateActivity(
      String id, ActivityReqParams updateReqActivity) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var accessToken = sharedPreferences.getString('accessToken');
      var response = await sl<DioClient>().put('${ApiUrls.activity}/$id',
          data: updateReqActivity.toMap(),
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}));
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!);
    }
  }

  @override
  Future<Either<String, List<ActivityDb>>> getActivityApi(
      {String? walletCategoryId, Map<String, String>? queryParams}) async {
    walletCategoryId = '57cdf90d-17f4-4796-84f7-b107a53976a4';
    try {
      final response = await sl<DioClient>().get(
        '${ApiUrls.activity}?WalletCategoryId=$walletCategoryId',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data']['data'];
        final activities = data
            .map((json) => ActivityDb.fromJson(json as Map<String, dynamic>))
            .toList();
        return Right(activities);
      }
      return Left(response.data['message'] ?? 'Lỗi không xác định');
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối');
    }
  }

  @override
  Future<Either> createActivity(ActivityReqParams createReqActivity) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var accessToken = sharedPreferences.getString('accessToken');
      var response = await sl<DioClient>().post(ApiUrls.activity,
          data: createReqActivity.toMap(),
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}));
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.toString());
    }
  }
}

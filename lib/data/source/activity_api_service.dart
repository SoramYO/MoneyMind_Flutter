import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:googleapis/admin/reports_v1.dart';
import 'package:my_project/core/constants/api_urls.dart';
import 'package:my_project/core/network/dio_client.dart';
import 'package:my_project/data/models/activity.dart';
import 'package:my_project/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ActivityApiService {
  Future<Either<String, List<ActivityDb>>> getActivityApi({
    String? walletCategoryId,
    Map<String, String>? queryParams,
  });
  Future<Either<String, ActivityDb>> createActivity(ActivityDb activity);
  Future<Either<String, ActivityDb>> updateActivity(ActivityDb activity);
  Future<Either<String, bool>> deleteActivity(String id);
}

class ActivityServiceImpl implements ActivityApiService {
  @override
  Future<Either<String, ActivityDb>> createActivity(ActivityDb activity) {
    // TODO: implement createActivity
    throw UnimplementedError();
  }

  @override
  Future<Either<String, bool>> deleteActivity(String id) {
    // TODO: implement deleteActivity
    throw UnimplementedError();
  }

  @override
  Future<Either<String, ActivityDb>> updateActivity(ActivityDb activity) {
    // TODO: implement updateActivity
    throw UnimplementedError();
  }

@override
  Future<Either<String, List<ActivityDb>>> getActivityApi({String? walletCategoryId, Map<String, String>? queryParams}) async {
    walletCategoryId = '57cdf90d-17f4-4796-84f7-b107a53976a4';
    try {
      final response = await sl<DioClient>().get(
        '${ApiUrls.activity}?WalletCategoryId=$walletCategoryId',
        queryParameters: queryParams,
      );
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data']['data'];
        final activities = data
            .map((json) => ActivityDb.fromJson(json as Map<String, dynamic>))
            .toList();
        print('Activities: $activities');
        return Right(activities);
      }
      return Left(response.data['message'] ?? 'Lỗi không xác định');
    } on DioException catch (e) {
      print('DioException: ${e.response?.data ?? e.message}');
      return Left(e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối');
    }
  }
}
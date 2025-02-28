import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import 'package:my_project/data/models/activity.dart';
import 'package:my_project/data/models/activity_req_params.dart';
import 'package:my_project/data/source/activity_api_service.dart';

import 'package:my_project/domain/repository/activitiy.dart';
import 'package:my_project/service_locator.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  @override
  Future<Either<String, bool>> deleteActivity(String id) async {
    Either result = await sl<ActivityApiService>().deleteActivity(id);
    return result.fold((error) {
      return Left(error);
    }, (data) async {
      Response response = data;
      if (response.statusCode == 200) {
        String message = response.data["message"];
        print(message);
        return Right(true);
      }
      return Right(false);
    });
  }

  @override
  Future<Either<String, List<ActivityDb>>> getActivityDb(
      {String? walletCategoryId, Map<String, String>? queryParams}) async {
    try {
      final result = await sl<ActivityApiService>().getActivityApi(
        walletCategoryId: walletCategoryId,
        queryParams: queryParams,
      );
      return result.fold(
        (error) => Left(error.toString()),
        (data) => Right(data),
      );
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, String>> updateActivity(
      String id, ActivityReqParams updateReqActivity) async {
    Either result =
        await sl<ActivityApiService>().updateActivity(id, updateReqActivity);
    return result.fold((error) {
      return Left(error.toString());
    }, (data) async {
      Response response = data;
      if (response.statusCode == 200) {
        return Right(response.data["message"]); // Trả về message thành công
      }
      return Left('Update activity fail: ${response.data["message"]}');
    });
  }

  @override
  Future<Either<String, String>> createActivity(
      ActivityReqParams createReqActivity) async {
    Either result =
        await sl<ActivityApiService>().createActivity(createReqActivity);
    return result.fold((error) {
      return Left(error.toString());
    }, (data) async {
      Response response = data;
      if (response.statusCode == 200) {
        String message = response.data["message"];
        return Right(message); // Trả về message thành công
      }
      return Left("Create activity fail");
    });
  }
}

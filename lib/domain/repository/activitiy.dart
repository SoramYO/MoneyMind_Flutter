import 'package:dartz/dartz.dart';
import 'package:my_project/data/models/activity.dart';
import 'package:my_project/data/models/activity_req_params.dart';

abstract class ActivityRepository {
  Future<Either<String, List<ActivityDb>>> getActivityDb({
    String? walletCategoryId,
    Map<String, String>? queryParams,
  });
  Future<Either<String, String>> createActivity(
      ActivityReqParams createReqActivity);
  Future<Either<String, String>> updateActivity(
      String id, ActivityReqParams updateReqActivity);
  Future<Either<String, bool>> deleteActivity(String id);
}

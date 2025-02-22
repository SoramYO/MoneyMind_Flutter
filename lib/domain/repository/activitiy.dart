import 'package:dartz/dartz.dart';
import 'package:googleapis/admin/reports_v1.dart';
import 'package:my_project/data/models/activity.dart';

abstract class ActivityRepository {
   Future<Either<String, List<ActivityDb>>> getActivityDb({
    String? walletCategoryId,
    Map<String, String>? queryParams,
  });
  Future<Either<String, ActivityDb>> createActivity(ActivityDb activity);
  Future<Either<String, ActivityDb>> updateActivity(ActivityDb activity);
  Future<Either<String, bool>> deleteActivity(String id);
}
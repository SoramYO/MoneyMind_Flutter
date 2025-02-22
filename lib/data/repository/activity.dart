import 'package:dartz/dartz.dart';

import 'package:my_project/data/models/activity.dart';
import 'package:my_project/data/source/activity_api_service.dart';

import 'package:my_project/domain/repository/activitiy.dart';
import 'package:my_project/service_locator.dart';

class ActivityRepositoryImpl implements ActivityRepository  {
  
  

  
  @override
  Future<Either<String, bool>> deleteActivity(String id) {
    // TODO: implement deleteActivity
    throw UnimplementedError();
  }
  
  @override
  Future<Either<String, List<ActivityDb>>> getActivityDb({String? walletCategoryId, Map<String, String>? queryParams}) async{
    try {
      final result = await sl<ActivityApiService>().getActivityApi(
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
  Future<Either<String, ActivityDb>> updateActivity(ActivityDb activity) {
    // TODO: implement updateActivity
    throw UnimplementedError();
  }
  
  @override
  Future<Either<String, ActivityDb>> createActivity(ActivityDb activity) {
    // TODO: implement createActivity
    throw UnimplementedError();
  }

}
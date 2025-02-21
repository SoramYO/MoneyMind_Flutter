import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_urls.dart';
import '../../core/network/dio_client.dart';
import '../../service_locator.dart';

abstract class MonthlyGoalApiService {
  Future<Either> getTotalAmount();
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
}

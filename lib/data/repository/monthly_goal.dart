import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:my_project/data/models/monthly_goal.dart';
import 'package:my_project/data/models/monthly_goal_req_params.dart';
import 'package:my_project/data/source/monthly_goal_api_service.dart';
import 'package:my_project/domain/repository/monthly_goal.dart';
import '../../service_locator.dart';

class MonthlyGoalRepositoryImpl implements MonthlyGoalRepository {
  @override
  Future<Either<String, double>> getTotalAmount() async {
    Either result = await sl<MonthlyGoalApiService>().getTotalAmount();
    return result.fold((error) => Left(error), // Nếu lỗi, trả về lỗi
        (response) async {
      if (response.statusCode == 200) {
        try {
          final data = response.data;

          if (data != null && data["status"] == 200) {
            final now = DateTime.now();
            int currentMonth = now.month;
            int currentYear = now.year;
            List<dynamic> monthlyGoals = data["data"]["data"] ?? [];

            // Tìm Monthly Goal theo tháng/năm hiện tại và status = 1
            var matchedGoal = monthlyGoals.firstWhere(
              (goal) =>
                  goal["month"] == currentMonth &&
                  goal["year"] == currentYear &&
                  goal["status"] == 1,
              orElse: () => null,
            );

            double totalAmount = matchedGoal != null
                ? (matchedGoal["totalAmount"] ?? 6000000).toDouble()
                : 6000000.0;

            return Right(totalAmount);
          } else {
            return Left("Dữ liệu API không hợp lệ");
          }
        } catch (e) {
          return Left("Lỗi xử lý dữ liệu: ${e.toString()}");
        }
      }
      return Left("Lấy dữ liệu thất bại");
    });
  }

  @override
  Future<Either<String, List<MonthlyGoal>>> getMonthlyGoals(
      int? year, int? month, int? status, int pageIndex, int pageSize) async {
    Either result = await sl<MonthlyGoalApiService>()
        .getMonthlyGoals(year, month, status, pageIndex, pageSize);
    return result.fold((error) => Left(error), // Nếu lỗi, trả về lỗi
        (response) async {
      if (response.statusCode == 200) {
        try {
          final List<dynamic> data = response.data['data']['data'];
          final monthlyGoals = data
              .map((json) => MonthlyGoal.fromJson(json as Map<String, dynamic>))
              .toList();
          return Right(monthlyGoals);
        } catch (e) {
          return Left("Lỗi xử lý dữ liệu: ${e.toString()}");
        }
      }
      return Left("Lấy dữ liệu thất bại");
    });
  }

  @override
  Future<Either<String, MonthlyGoal>> createMonthlyGoal(
      MonthlyGoalReqParams monthlyGoal) async {
    Either result =
        await sl<MonthlyGoalApiService>().createMonthlyGoal(monthlyGoal);
    return result.fold((error) {
      return Left(error.toString());
    }, (data) async {
      Response response = data;
      if (response.statusCode == 200) {
        var monthlyGoalResponse = MonthlyGoal.fromMap(response.data['data']);
        return Right(monthlyGoalResponse);
      }
      return Left("Create monthly goal fail");
    });
  }

  @override
  Future<Either<String, MonthlyGoal>> updateMonthlyGoal(
      String id, MonthlyGoalReqParams monthlyGoal) async {
    Either result =
        await sl<MonthlyGoalApiService>().updateMonthlyGoal(id, monthlyGoal);
    return result.fold((error) {
      return Left(error.toString());
    }, (data) async {
      Response response = data;
      if (response.statusCode == 200) {
        var monthlyGoalResponse = MonthlyGoal.fromMap(response.data['data']);
        return Right(monthlyGoalResponse);
      }
      return Left('Update monthly goal fail: ${response.data["message"]}');
    });
  }
}

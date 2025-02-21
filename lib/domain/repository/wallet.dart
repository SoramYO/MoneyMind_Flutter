import 'package:dartz/dartz.dart';
import 'package:my_project/data/models/wallet_category.dart';

abstract class WalletRepository {
  Future<Either<String, double>> getTotalBalance();
}

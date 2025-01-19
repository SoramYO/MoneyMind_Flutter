import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_user.dart';
import '../../../service_locator.dart';
import 'user_display_state.dart';

class UserDisplayCubit extends Cubit<UserDisplayState> {
  UserDisplayCubit() : super(UserLoading());

  void displayUser() async {
    var result = await sl<GetUserUseCase>().call();
    result.fold((error) {
      emit(LoadUserFailure(errorMessage: error));
    }, (data) {
      emit(UserLoaded(userEntity: data));
    });
  }
}

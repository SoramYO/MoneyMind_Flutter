import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/domain/usecases/is_logged_in.dart';
import 'package:my_project/service_locator.dart';
import 'auth_state.dart';

class AuthStateCubit extends Cubit<AuthState> {
  AuthStateCubit() : super(AppInitialState());

  void appStarted() async {
    var isLoggedIn = await sl<IsLoggedInUseCase>().call();
    if (isLoggedIn) {
      emit(Authenticated());
    } else {
      emit(UnAuthenticated());
    }
  }
}

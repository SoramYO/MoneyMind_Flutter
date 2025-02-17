
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/presentation/auth/bloc/auth_state.dart';

import 'package:my_project/domain/usecases/is_logged_in.dart';
import 'package:my_project/service_locator.dart';


class AuthStateCubit extends Cubit<AuthState> {
  AuthStateCubit() : super(AuthInitialState());

  Future<void> appStarted() async {
    emit(AuthLoadingState());
    
    final result = await sl<IsLoggedInUseCase>().call();
    if (result) {
      emit(AuthenticatedState());
    } else {
      emit(UnauthenticatedState());
    }
  }

  void loggedIn() {
    emit(AuthenticatedState());
  }

  void loggedOut() {
    emit(UnauthenticatedState());
  }
} 
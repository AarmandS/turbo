import 'package:bloc/bloc.dart';
import 'package:turbo/network_service.dart';

part 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  late NetworkService _networkService;

  SignupCubit(NetworkService networkService) : super(SignupInitial()) {
    _networkService = networkService;
  }

  void signup(String username, String password, String password2) async {
    if (password != password2) {
      emit(SignupPasswordsDontMatch());
      await Future.delayed(Duration(seconds: 10));
      if (state is SignupPasswordsDontMatch) {
        emit(SignupInitial());
      }
    } else {
      var signupSuccess = await _networkService.signup(username, password);
      if (signupSuccess) {
        emit(SignupSuccesful(username, password));
        await Future.delayed(Duration(seconds: 1));
        emit(SignupInitial());
      } else {
        emit(SignupUserAlreadyExists());
        await Future.delayed(Duration(seconds: 10));
        if (state is SignupPasswordsDontMatch) {
          emit(SignupInitial());
        }
      }
    }
  }

  // void login(String username, String password) async {
  //   bool loginSuccesful =
  //       await _networkService.getAccessToken(username, password);
  //   if (loginSuccesful) {
  //     emit(AuthLoggedIn(username: username));
  //   } else {
  //     emit(AuthFailedLogin());
  //     await Future.delayed(Duration(seconds: 10));
  //     if (state is AuthFailedLogin) {
  //       emit(AuthInitial());
  //     }
  //   }
  // }

  // void logout() {
  //   _networkService.accessToken = null;
  //   emit(AuthInitial());
  // }
}

import 'package:bloc/bloc.dart';
import 'package:turbo/network_service.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  late NetworkService _networkService;

  AuthCubit(NetworkService networkService) : super(AuthInitial()) {
    _networkService = networkService;
  }

  void login(String username, String password) async {
    var loginSuccesful =
        await _networkService.getAccessToken(username, password);
    if (loginSuccesful) {
      emit(AuthLoggedIn(username: username));
    } else {
      emit(AuthFailedLogin());
      await Future.delayed(Duration(seconds: 10));
      if (state is AuthFailedLogin) {
        emit(AuthInitial());
      }
    }
  }

  void logout() {
    _networkService.accessToken = null;
    emit(AuthInitial());
  }
}

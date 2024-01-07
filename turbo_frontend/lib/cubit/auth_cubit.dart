import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turbo/models/token.dart';
import 'package:turbo/network_service.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  late NetworkService _networkService;

  AuthCubit(NetworkService networkService) : super(AuthInitial()) {
    _networkService = networkService;
  }

  void login(String username, String password, bool rememberMe) async {
    var loginSuccesful =
        await _networkService.getAccessToken(username, password);
    if (loginSuccesful) {
      if (rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('token', _networkService.accessToken!.accessToken);
      }
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

  Future<bool> tryLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      this._networkService.accessToken = AccessToken(token!);
      // store token subject
      emit(AuthLoggedIn(username: 'test'));
      return true;
    } on Exception {
      return false;
    }
  }
}

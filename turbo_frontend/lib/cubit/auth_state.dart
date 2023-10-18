part of 'auth_cubit.dart';


abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoggedIn extends AuthState {
  String username;
  AuthLoggedIn({required this.username});
}

class AuthFailedLogin extends AuthState {}
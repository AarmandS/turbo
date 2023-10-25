part of 'signup_cubit.dart';

abstract class SignupState {}

class SignupInitial extends SignupState {}

class SignupSuccesful extends SignupState {
  String username;
  String password;
  SignupSuccesful(this.username, this.password);
}

class SignupUserAlreadyExists extends SignupState {}

class SignupPasswordsDontMatch extends SignupState {}

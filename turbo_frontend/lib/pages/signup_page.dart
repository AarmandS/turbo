import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:turbo/cubit/auth_cubit.dart';
import 'package:turbo/cubit/directory_cubit.dart';
import 'package:turbo/cubit/media_cubit.dart';
import 'package:turbo/cubit/signup_cubit.dart';

import '../widgets/title_bar.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _usernameTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _password2TextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var authCubit = context.watch<AuthCubit>();
    var signupCubit = context.watch<SignupCubit>();
    var directoryCubit = context.watch<DirectoryCubit>();

    if (signupCubit.state is SignupSuccesful) {
      var state = signupCubit.state as SignupSuccesful;
      authCubit.login(state.username, state.password, false);
      if (authCubit.state is AuthLoggedIn) {
        directoryCubit
            .navigateToDirectory((authCubit.state as AuthLoggedIn).username);
        context.go('/home');
      }
    }

    return Scaffold(
        backgroundColor: Colors.blueGrey.shade50,
        body: Center(
            child: Column(children: [
          SizedBox(height: 200),
          TitleBar(),
          SizedBox(
            height: 16,
          ),
          SizedBox(
            width: 240,
            child: TextField(
                controller: _usernameTextController,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Username',
                )),
          ),
          SizedBox(height: 8),
          SizedBox(
            width: 240,
            child: TextField(
                controller: _passwordTextController,
                obscureText: true,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                )),
          ),
          SizedBox(height: 8),
          SizedBox(
            width: 240,
            child: TextField(
                controller: _password2TextController,
                obscureText: true,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password again',
                )),
          ),
          SizedBox(
            height: 16,
          ),
          ElevatedButton(
            onPressed: () {
              signupCubit.signup(_usernameTextController.text,
                  _passwordTextController.text, _password2TextController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade300,
              minimumSize: Size(240, 50),
              padding: EdgeInsets.all(2),
            ),
            child: Text('Sign up',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 8,
          ),
          ElevatedButton(
            onPressed: () {
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade400,
              minimumSize: Size(240, 50),
              padding: EdgeInsets.all(2),
            ),
            child: Text('Log in',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ),
          Column(
            children: [
              SizedBox(height: 8),
              if (signupCubit.state is SignupPasswordsDontMatch)
                Text(
                  'Passwords do not match',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.red),
                )
              else if (signupCubit.state is SignupUserAlreadyExists)
                Text(
                  'User already exists',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.red),
                ),
            ],
          ),
        ])));
  }

  @override
  void dispose() {
    _usernameTextController.dispose();
    _passwordTextController.dispose();
    super.dispose();
  }
}

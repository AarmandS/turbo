import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turbo/cubit/auth_cubit.dart';
import 'package:turbo/cubit/directory_cubit.dart';
import 'package:turbo/cubit/media_cubit.dart';

import '../widgets/title_bar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  var _isRememberMeChecked = false;

  @override
  Widget build(BuildContext context) {
    var authCubit = context.watch<AuthCubit>();
    var mediaCubit = context.watch<MediaCubit>();
    authCubit.tryLogin();

    if (authCubit.state is AuthLoggedIn) {
      context
          .read<DirectoryCubit>()
          .navigateToDirectory((authCubit.state as AuthLoggedIn).username);
      context.go('/home');
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
          SizedBox(
            height: 8,
          ),
          SizedBox(
            width: 140,
            child: Center(
              child: Row(children: [
                Checkbox(
                    value: _isRememberMeChecked,
                    onChanged: (value) {
                      setState(() {
                        if (value != null) {
                          _isRememberMeChecked = value;
                        }
                      });
                    }),
                Text(
                  'Remember me',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              ]),
            ),
          ),
          SizedBox(
            height: 8,
          ),
          ElevatedButton(
            onPressed: () {
              authCubit.login(_usernameTextController.text,
                  _passwordTextController.text, _isRememberMeChecked);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade300,
              minimumSize: Size(240, 50),
              padding: EdgeInsets.all(2),
            ),
            child: Text('Log in',
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
              context.go('/signup');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade400,
              minimumSize: Size(240, 50),
              padding: EdgeInsets.all(2),
            ),
            child: Text('Sign up',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ),
          if (authCubit.state is AuthFailedLogin)
            Column(
              children: [
                SizedBox(height: 8),
                Text(
                  'Invalid username or password',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.red),
                ),
              ],
            )
          else
            Container()
        ])));
  }

  @override
  void dispose() {
    _usernameTextController.dispose();
    _passwordTextController.dispose();
    super.dispose();
  }
}

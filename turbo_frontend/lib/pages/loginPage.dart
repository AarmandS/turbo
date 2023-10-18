import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turbo/cubit/auth_cubit.dart';

import '../widgets/title_bar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
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
        height: 16,
      ),
      ElevatedButton(
        onPressed: () {
          context.read<AuthCubit>().login(
              _usernameTextController.text, _passwordTextController.text);
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
      if (context.watch<AuthCubit>().state is AuthFailedLogin)
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
    ]);
  }

  @override
  void dispose() {
    _usernameTextController.dispose();
    _passwordTextController.dispose();
    super.dispose();
  }
}

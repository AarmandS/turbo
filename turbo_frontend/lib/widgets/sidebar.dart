import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:turbo/cubit/directory_cubit.dart';
import 'package:turbo/widgets/action_buttons.dart';
import 'package:turbo/widgets/title_bar.dart';

import '../cubit/auth_cubit.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: Colors.blueGrey.shade100,
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              SizedBox(
                height: 12,
              ),
              TitleBar(),
              SizedBox(
                height: 10,
              ),
              ActionButtons()
            ],
          ),
          Column(
            children: [
              ElevatedButton.icon(
                icon: Icon(
                  Icons.logout,
                  color: Colors.indigo.shade600,
                ),
                onPressed: () {
                  context.read<AuthCubit>().logout();
                  context.read<DirectoryCubit>().navigationPath = '';
                  context.go('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade50,
                  minimumSize: Size(190, 50),
                  padding: EdgeInsets.all(2),
                ),
                label: Text('Log out      ',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                height: 10,
              )
            ],
          ),
        ],
      ),
    );
  }
}

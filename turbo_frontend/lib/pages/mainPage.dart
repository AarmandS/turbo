import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:turbo/cubit/auth_cubit.dart';
import 'package:turbo/network_service.dart';
import 'package:turbo/widgets/title_bar.dart';

import '../cubit/directory_cubit.dart';
import '../widgets/file_grid.dart';
import '../widgets/directory_grid.dart';
import '../widgets/sidebar.dart';

class HomePage extends StatelessWidget {
  NetworkService networkService;

  HomePage({super.key, required this.networkService});

  @override
  Widget build(BuildContext context) {
    var directoryCubit = context.watch<DirectoryCubit>();
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.upload),
      ),
      appBar: AppBar(
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TitleBar(),
              SizedBox(height: 40, child: SearchBar()),
              SizedBox(
                width: 1,
              )
            ],
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                context.go('/profile');
              },
              icon: Icon(Icons.person)),
          IconButton(
              onPressed: () {
                context.read<AuthCubit>().logout();
                context.read<DirectoryCubit>().navigationPath = '';
                context.go('/login');
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(24, 12, 24, 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        directoryCubit.navigateBack();
                      },
                      icon: Icon(Icons.arrow_back)),
                  Text(
                    directoryCubit.navigationPath,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w300),
                  ),
                ],
              ),
              SizedBox(height: 12),
              DirectoryGrid(),
              FileGrid()
            ],
          ),
        ),
      ),
    );
  }
}

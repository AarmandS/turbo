import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turbo/network_service.dart';

import '../cubit/folder_cubit.dart';
import '../widgets/file_grid.dart';
import '../widgets/folder_grid.dart';
import '../widgets/sidebar.dart';

class MainPage extends StatelessWidget {
  NetworkService networkService;

  MainPage({super.key, required this.networkService});

  @override
  Widget build(BuildContext context) {
    var folderCubit = context.watch<FolderCubit>();
    return BlocBuilder<FolderCubit, FolderState>(
      builder: (context, state) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Sidebar(),
            SingleChildScrollView(
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
                              folderCubit.navigateBack();
                            },
                            icon: Icon(Icons.arrow_back)),
                        Text(
                          folderCubit.navigationPath,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    FolderGrid(),
                    FileGrid()
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

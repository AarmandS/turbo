import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turbo/cubit/directory_cubit.dart';

import 'directory.dart';

class DirectoryGrid extends StatelessWidget {
  late List<String> directories = [];
  DirectoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DirectoryCubit, DirectoryState>(
        builder: (context, state) {
      if (state is DirectoryInitial) {
        return Center(child: CircularProgressIndicator());
      } else if (state is DirectoryRefresh) {
        directories = state.directories;
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          directories.isNotEmpty
              ? Text(
                  'Directorys',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w300),
                )
              : Container(),
          Container(
              width: 1200,
              child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: directories.length,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200),
                  itemBuilder: (context, index) {
                    return Directory(name: directories[index]);
                  })),
        ],
      );
    });
  }
}

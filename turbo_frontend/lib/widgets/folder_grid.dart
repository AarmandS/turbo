import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turbo/cubit/folder_cubit.dart';

import 'folder.dart';

class FolderGrid extends StatelessWidget {
  late List<String> folders = [];
  FolderGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FolderCubit, FolderState>(builder: (context, state) {
      if (state is FolderInitial) {
        return Center(child: CircularProgressIndicator());
      } else if (state is FolderRefresh) {
        folders = state.folders;
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          folders.isNotEmpty
              ? Text(
                  'Folders',
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
                  itemCount: folders.length,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200),
                  itemBuilder: (context, index) {
                    return Folder(name: folders[index]);
                  })),
        ],
      );
    });
  }
}

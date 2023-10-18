import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/folder_cubit.dart';

class Folder extends StatelessWidget {
  final String name;

  Folder({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        var folderCubit = context.read<FolderCubit>();
        folderCubit.navigateToFolder('${folderCubit.navigationPath}/$name');
      },
      child: Container(
        margin: EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(
              Icons.folder,
              size: 140,
              color: Colors.indigo.shade300,
            ),
            Text(
              name,
              style: Theme.of(context).textTheme.bodyLarge,
            )
          ],
        ),
      ),
    );
  }
}

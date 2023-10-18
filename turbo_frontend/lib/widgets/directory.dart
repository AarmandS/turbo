import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turbo/widgets/directory_menu.dart';

import '../cubit/directory_cubit.dart';

void renameDirectoryDialog(BuildContext context, String oldName) {}

class Directory extends StatelessWidget {
  final String name;

  Directory({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        var directoryCubit = context.read<DirectoryCubit>();
        directoryCubit
            .navigateToDirectory('${directoryCubit.navigationPath}/$name');
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
            Container(
              width: 140,
              height: 36,
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                    width: 120,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          child: Text(
                            name,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        DirectoryMenu(directoryName: name)
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

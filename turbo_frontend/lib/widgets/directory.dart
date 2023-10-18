import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/directory_cubit.dart';

enum _MenuValues { SHARE, RENAME, DELETE }

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
                        PopupMenuButton<_MenuValues>(
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem(
                              value: _MenuValues.SHARE,
                              child: Text('Share'),
                            ),
                            PopupMenuItem(
                              value: _MenuValues.RENAME,
                              child: Text('Rename'),
                            ),
                            PopupMenuItem(
                              value: _MenuValues.DELETE,
                              child: Text('Delete'),
                              // ask if the user is sure to delete
                            )
                          ],
                          onSelected: (value) {
                            switch (value) {
                              case _MenuValues.SHARE:
                                // TODO: Handle this case.
                                break;
                              case _MenuValues.RENAME:
                                // TODO: Handle this case.
                                break;
                              case _MenuValues.DELETE:
                                var directoryCubit =
                                    context.read<DirectoryCubit>();
                                directoryCubit.deleteDirectory(name);
                                break;
                            }
                          },
                        )
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

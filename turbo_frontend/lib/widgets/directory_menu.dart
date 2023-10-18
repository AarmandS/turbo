import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turbo/cubit/directory_cubit.dart';

enum _MenuValues { SHARE, RENAME, DELETE }

class DirectoryMenu extends StatelessWidget {
  final String directoryName;
  final _directoryNameTextController = TextEditingController();

  DirectoryMenu({super.key, required this.directoryName});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MenuValues>(
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
        var directoryCubit = context.read<DirectoryCubit>();
        switch (value) {
          case _MenuValues.SHARE:
            // TODO: Handle this case.
            break;
          case _MenuValues.RENAME:
            var dialog = AlertDialog(
                title: Text('Rename directory'),
                content: TextField(
                  controller: _directoryNameTextController,
                  decoration: InputDecoration(hintText: "Directory new name"),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                      onPressed: () {
                        if (_directoryNameTextController.text != '') {
                          directoryCubit.renameDirectory(
                              directoryName, _directoryNameTextController.text);
                        }
                        Navigator.pop(context);
                      },
                      child: Text('Rename')),
                ]);

            showDialog(
                context: context,
                builder: (context) {
                  return dialog;
                });

            break;
          case _MenuValues.DELETE:
            directoryCubit.deleteDirectory(directoryName);
            break;
        }
      },
    );
  }
}

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/folder_cubit.dart';

class ActionButtons extends StatelessWidget {
  final _folderNameTextController = TextEditingController();
  ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    var folderCubit = context.read<FolderCubit>();
    return Column(children: [
      ElevatedButton.icon(
        icon: Icon(
          Icons.folder,
          color: Colors.indigo.shade600,
        ),
        onPressed: () {
          var dialog = AlertDialog(
              title: Text('Create folder'),
              content: TextField(
                controller: _folderNameTextController,
                decoration: InputDecoration(hintText: "Folder name"),
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
                      if (_folderNameTextController.text != '') {
                        context
                            .read<FolderCubit>()
                            .createFolder(_folderNameTextController.text);
                      }
                      Navigator.pop(context);
                    },
                    child: Text('Create')),
              ]);

          showDialog(
              context: context,
              builder: (context) {
                return dialog;
              });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo.shade300,
          minimumSize: Size(190, 50),
          padding: EdgeInsets.all(2),
        ),
        label: Text('Create folder',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
      ),
      SizedBox(
        height: 10,
      ),
      ElevatedButton.icon(
        icon: Icon(
          Icons.upload,
          color: Colors.indigo.shade600,
        ),
        onPressed: () async {
          var fileResult = await FilePicker.platform.pickFiles(
              allowMultiple: true,
              type: FileType.custom,
              // these are constants which should be in a central location
              allowedExtensions: ['jpg', 'png', 'mp4', 'mkv'],
              withData: true);
          if (fileResult != null) {
            for (var file in fileResult!.files) {
              folderCubit.uploadImage(file.name, file.extension!, file.path!);
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo.shade300,
          minimumSize: Size(190, 50),
          padding: EdgeInsets.all(2),
        ),
        label: Text('Upload file   ',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
      ),
    ]);
  }
}

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/directory_cubit.dart';

class ActionButtons extends StatelessWidget {
  final _directoryNameTextController = TextEditingController();
  ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    var directoryCubit = context.read<DirectoryCubit>();
    return Column(children: [
      ElevatedButton.icon(
        icon: Icon(
          Icons.folder,
          color: Colors.indigo.shade600,
        ),
        onPressed: () {
          var dialog = AlertDialog(
              title: Text('Create directory'),
              content: TextField(
                controller: _directoryNameTextController,
                decoration: InputDecoration(hintText: "Directory name"),
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
                        context
                            .read<DirectoryCubit>()
                            .createDirectory(_directoryNameTextController.text);
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
        label: Text('Create directory',
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
              withReadStream: true,
              // these are constants which should be in a central location
              allowedExtensions: ['jpg', 'png', 'mp4', 'mkv'],
              withData: true);
          if (fileResult != null) {
            // will handle this in a single request
            for (var file in fileResult!.files) {
              directoryCubit.uploadFile(file);
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

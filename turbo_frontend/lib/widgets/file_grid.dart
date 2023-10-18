import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turbo/models/file_model.dart';
import 'package:turbo/widgets/photo.dart';
import 'package:turbo/widgets/photo_grid.dart';
import 'package:turbo/widgets/video.dart';
import 'package:turbo/widgets/video_grid.dart';

import '../cubit/folder_cubit.dart';

class FileGrid extends StatelessWidget {
  late List<FileModel> photos = [];
  late List<FileModel> videos = [];

  FileGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1000,
        child: BlocBuilder<FolderCubit, FolderState>(builder: (context, state) {
          if (state is FolderInitial) {
            return Center(child: CircularProgressIndicator());
          } else if (state is FolderRefresh) {
            photos = state.files
                .where((file) => file.fileType == FileType.photo)
                .toList();
            videos = state.files
                .where((file) => file.fileType == FileType.video)
                .toList();
          }

          return Column(
            children: [
              PhotoGrid(photos),
              SizedBox(
                height: 50,
              ),
              VideoGrid(videos),
            ],
          );
        }));
  }
}

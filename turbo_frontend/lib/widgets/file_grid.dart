import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turbo/models/media_file.dart';
import 'package:turbo/widgets/thumbnail.dart';
import 'package:turbo/widgets/image_grid.dart';
import 'package:turbo/widgets/video.dart';
import 'package:turbo/widgets/video_grid.dart';

import '../cubit/directory_cubit.dart';

class FileGrid extends StatelessWidget {
  late List<MediaFile> photos = [];
  late List<MediaFile> videos = [];

  FileGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1000,
        child: BlocBuilder<DirectoryCubit, DirectoryState>(
            builder: (context, state) {
          if (state is DirectoryInitial) {
            return Center(child: CircularProgressIndicator());
          } else if (state is DirectoryRefresh) {
            photos = state.images;
            videos = state.videos;
          }

          return Column(
            children: [
              ImageGrid(photos),
              SizedBox(
                height: 50,
              ),
              VideoGrid(videos),
            ],
          );
        }));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turbo/models/media_file.dart';
import 'package:turbo/widgets/thumbnail.dart';
import 'package:turbo/widgets/video.dart';

import '../cubit/directory_cubit.dart';

class VideoGrid extends StatelessWidget {
  final List<MediaFile> videos;
  VideoGrid(this.videos, {super.key});

  @override
  Widget build(BuildContext context) {
    var directoryCubit = context.read<DirectoryCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        videos.isNotEmpty
            ? Text(
                'Videos',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w300),
              )
            : Container(),
        GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: videos.length,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200),
            itemBuilder: (context, index) {
              return Thumbnail(
                name: videos[index].fullSize,
                index: index,
                image: directoryCubit.getImage(videos[index].thumbnail)!,
                type: FileType
                    .video, // change this to video when video viewer page will be ready
              );
            }),
      ],
    );
  }
}

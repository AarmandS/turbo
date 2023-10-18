import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turbo/models/file_model.dart';
import 'package:turbo/widgets/photo.dart';
import 'package:turbo/widgets/video.dart';

import '../cubit/directory_cubit.dart';

class VideoGrid extends StatelessWidget {
  final List<FileModel> videos;
  VideoGrid(this.videos, {super.key});

  @override
  Widget build(BuildContext context) {
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
              // not the best null safety practice fix this
              return Video(videos[index]);
            }),
      ],
    );
  }
}

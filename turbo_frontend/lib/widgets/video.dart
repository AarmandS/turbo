import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turbo/cubit/media_cubit.dart';
import 'package:video_player/video_player.dart';

import '../models/file_model.dart';

class Video extends StatelessWidget {
  final FileModel video;
  const Video(this.video, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        body: Center(child: Text('itt lesz majd a video kepe')),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.read<MediaCubit>().playVideo(video.mediaUrl);
          },
          child: Icon(
            Icons.play_arrow,
          ),
        ),
      ),
    );
  }
}

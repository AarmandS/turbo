import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turbo/cubit/directory_cubit.dart';
import 'package:video_player/video_player.dart';

class VideoViewerPage extends StatefulWidget {
  VideoViewerPage({super.key});

  @override
  _VideoViewerPageState createState() => _VideoViewerPageState();
}

class _VideoViewerPageState extends State<VideoViewerPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    var directoryCubit = context.read<DirectoryCubit>();
    var directoryState = directoryCubit.state as DirectoryViewingVideo;
    _controller = VideoPlayerController.networkUrl(
        Uri.parse(directoryCubit.getVideoURL()),
        httpHeaders: {'Authorization': directoryCubit.getToken()})
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
        _controller.play();
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: 1.7,
                child: VideoPlayer(_controller),
              )
            : Container(),
      ),
    );
  }
}

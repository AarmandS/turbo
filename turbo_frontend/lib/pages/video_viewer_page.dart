import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turbo/cubit/directory_cubit.dart';

class VideoViewerPage extends StatelessWidget {
  VideoViewerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DirectoryCubit, DirectoryState>(
        builder: (context, state) {
      // if (state is DirectoryViewingVideos) {
      //   var directoryCubit = context.read<DirectoryCubit>();
      return Scaffold(
          backgroundColor: Colors.blueGrey.shade50, body: Text('video page')
          // return Container();
          // }
          );
    });
  }
}

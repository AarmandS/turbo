import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turbo/cubit/directory_cubit.dart';

class ImageViewerPage extends StatelessWidget {
  ImageViewerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DirectoryCubit, DirectoryState>(
        builder: (context, state) {
      if (state is DirectoryViewingImages) {
        var directoryCubit = context.read<DirectoryCubit>();
        return Scaffold(
          backgroundColor: Colors.blueGrey.shade50,
          body:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            IconButton(
                onPressed: () {
                  directoryCubit.viewPreviousImage();
                },
                icon: Icon(Icons.navigate_before)),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 1800,
                  height: 900,
                  child: Image(
                      image: directoryCubit.getImage(
                          state.images[state.selectedImageIndex].full_size)!),
                ), // ! bad
                Text(state.images[state.selectedImageIndex].full_size),
              ],
            ),
            IconButton(
                onPressed: () {
                  directoryCubit.viewNextImage();
                },
                icon: Icon(Icons.navigate_next)),
          ]),
        );
      }
      return Container();
    });
  }
}

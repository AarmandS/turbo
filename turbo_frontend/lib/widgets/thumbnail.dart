import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:turbo/cubit/directory_cubit.dart';
import 'package:turbo/widgets/directory_menu.dart';

enum FileType { image, video }

class Thumbnail extends StatelessWidget {
  final String name;
  final int index;
  final NetworkImage image;
  final FileType type;

  Thumbnail(
      {super.key,
      required this.name,
      required this.index,
      required this.image,
      required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(12),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (this.type == FileType.image) {
                context.read<DirectoryCubit>().viewImage(index);
                context.go('/image_viewer');
              } else {
                context.read<DirectoryCubit>().viewVideo(name);
                context.go('/video_viewer');
              }
            },
            child: Image(
              image: image,
              width: 140,
              height: 140,
            ),
          ),
          Container(
            width: 140,
            height: 36,
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                Container(
                  width: 120,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      DirectoryMenu(directoryName: name)
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

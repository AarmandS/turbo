import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:turbo/cubit/directory_cubit.dart';
import 'package:turbo/widgets/directory_menu.dart';

class ImageWidget extends StatelessWidget {
  final String name;
  final int index;
  final NetworkImage image;

  ImageWidget(
      {super.key,
      required this.name,
      required this.index,
      required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(12),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              context.read<DirectoryCubit>().viewImage(index);
              context.go('/image_viewer');
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
                      SizedBox(
                        child: Text(
                          name,
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

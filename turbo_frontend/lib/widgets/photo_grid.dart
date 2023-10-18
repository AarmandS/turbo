import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turbo/models/file_model.dart';
import 'package:turbo/widgets/photo.dart';

import '../cubit/folder_cubit.dart';

class PhotoGrid extends StatelessWidget {
  final List<FileModel> photos;
  PhotoGrid(this.photos, {super.key});

  @override
  Widget build(BuildContext context) {
    var folderCubit = context.read<FolderCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        photos.isNotEmpty
            ? Text(
                'Photos',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w300),
              )
            : Container(),
        GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: photos.length,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200),
            itemBuilder: (context, index) {
              // not the best null safety practice fix this
              return Photo(
                name: photos[index].mediaUrl,
                image: folderCubit.getImage(photos[index].mediaUrl)!,
              );
            }),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turbo/models/file_model.dart';
import 'package:turbo/widgets/photo.dart';

import '../cubit/directory_cubit.dart';

class ImageGrid extends StatelessWidget {
  final List<String> images;
  ImageGrid(this.images, {super.key});

  @override
  Widget build(BuildContext context) {
    var directoryCubit = context.read<DirectoryCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        images.isNotEmpty
            ? Text(
                'Images',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w300),
              )
            : Container(),
        GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: images.length,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200),
            itemBuilder: (context, index) {
              // not the best null safety practice fix this
              return ImageWidget(
                name: images[index],
                image: directoryCubit.getImage(images[index])!,
              );
            }),
      ],
    );
  }
}

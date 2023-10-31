import 'package:flutter/material.dart';
import 'package:turbo/widgets/directory_menu.dart';

class ImageWidget extends StatelessWidget {
  final String name;
  final NetworkImage image;

  ImageWidget({super.key, required this.name, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(12),
      child: Column(
        children: [
          Image(
            image: image,
            width: 140,
            height: 140,
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

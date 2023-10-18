import 'package:flutter/material.dart';

class Photo extends StatelessWidget {
  final String name;
  final NetworkImage image;

  Photo({super.key, required this.name, required this.image});

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
          Text(
            name,
            style: Theme.of(context).textTheme.bodyLarge,
          )
        ],
      ),
    );
  }
}
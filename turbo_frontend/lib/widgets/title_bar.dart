import 'package:flutter/material.dart';

class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.pets,
          color: Colors.indigo.shade600,
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          'Turbo',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}

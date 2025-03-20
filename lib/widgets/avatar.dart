import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  const Avatar({super.key, this.radius = 60, this.onPressed});

  final double radius;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: CircleAvatar(
        radius: radius,
        child: Text(
          'JH',
          style: TextStyle(fontSize: radius / 1.5),
        ),
      ),
    );
  } 
}

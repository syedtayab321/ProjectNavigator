import 'package:flutter/material.dart';
class Icon_Button extends StatelessWidget {
  final Icon icon;
  final Color? color;
  final VoidCallback onPressed;

  const Icon_Button({
    required this.icon,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: icon,
      color: color,
      onPressed: onPressed,
    );
  }
}

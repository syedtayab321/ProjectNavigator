import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class CustomTextWidget extends StatelessWidget {
  final String title;
  final Color? color;
  final double? size,spacing;
  final FontWeight? weight;

  const CustomTextWidget({
    required this.title,
    this.color,
    this.size,
    this.weight,
    this.spacing
  });
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: color,
        fontSize: size,
        fontWeight: weight,
        letterSpacing: spacing,
      ),
    );
  }
}
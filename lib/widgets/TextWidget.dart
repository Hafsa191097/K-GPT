import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/constants.dart';

class TextWidget extends StatelessWidget {
  const TextWidget(
      {Key? key,
      required this.label,
      required this.fontSize ,
      required this.color,
      required this.fontWeight})
      : super(key: key);

  final String label;
  final double fontSize;
  final Color? color;
  final FontWeight? fontWeight;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right:5.0,top:5),
      child: Text(
        textAlign: TextAlign.justify,
        label,
        style: 
    
        GoogleFonts.nunitoSans(
          color: text1Color,
            fontSize: fontSize,
            fontWeight: fontWeight ?? FontWeight.normal,
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

const kcPrimaryColor = Color(0xff026D6B);
const kcScaffoldBG = Color(0xffeff7f8);

const kdPadding = 16.0;
const kdBorderRadius = 30.0;
const white = Color.fromARGB(255, 255, 255, 255);

const Color inActiveBottomBarColor = Color(0xff73CEEB);

final Gradient kcGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    kcPrimaryColor.withOpacity(0.8),
    kcPrimaryColor,
  ],
);

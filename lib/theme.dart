import 'package:flutter/material.dart';
import "package:provider/provider.dart";
import "package:swipe/swipe.dart";
import "package:camera/camera.dart";

import "./config_page.dart";
import "./settings_page.dart";
import "./history_page.dart";
import "./choice_page.dart";

final lightTheme = ThemeData.from(
  colorScheme: ColorScheme.light(
    primary: Color.fromARGB(255, 212, 160, 97),
    secondary: Color.fromARGB(255, 32, 67, 149),
    background: Color.fromARGB(255, 239, 225, 202),
    onBackground: Colors.black,
  ),
);

final darkTheme = ThemeData.from(
  colorScheme: ColorScheme.dark(
    primary: Color.fromARGB(255, 208, 148, 74),
    secondary: Color.fromARGB(255, 87, 3, 3),
    background: Color.fromARGB(255, 46, 25, 25),
    onBackground: Colors.white,
  ),
);

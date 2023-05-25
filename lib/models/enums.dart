import 'package:flutter/material.dart';

enum RevealResult {
  hit,
  miss,
  outsideGrid,
  noBombLeft,
  alreadyRevealed,
  unrecognizedUser,
}

enum Tile {
  zero,
  one,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  bomb,
  concealed,
}

class ThemeColor {
  static const Color greenScreen = Color.fromARGB(255, 0, 255, 0);
  static const Color main =  Color.fromARGB(255, 45, 74, 168);
  static const Color conceiled = Color.fromARGB(255, 45, 74, 168);
  static const Color revealed = Color.fromARGB(255, 204, 234, 248);
}

import 'package:flutter/material.dart';
import 'package:twitch_treasure_seeker/screens/game_screen.dart';

void main() async {
  runApp(MaterialApp(
    initialRoute: GameScreen.route,
    routes: {
      GameScreen.route: (ctx) => const GameScreen(),
    },
  ));
}

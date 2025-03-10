import 'package:flutter/material.dart';
import 'package:twitch_treasure_seeker/screens/end_screen.dart';
import 'package:twitch_treasure_seeker/screens/game_screen.dart';

// TODO add credit (images)
void main() async {
  runApp(MaterialApp(
    initialRoute: GameScreen.route,
    routes: {
      GameScreen.route: (ctx) => const GameScreen(),
      EndScreen.route: (ctx) => const EndScreen(),
    },
  ));
}

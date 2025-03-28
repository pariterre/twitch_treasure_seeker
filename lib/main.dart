import 'package:common/managers/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:twitch_treasure_seeker/managers/treasure_seeker_game_manager.dart';
import 'package:twitch_treasure_seeker/managers/twitch_manager.dart';
import 'package:twitch_treasure_seeker/screens/game_screen.dart';

// TODO: Add sound effects
// TODO: Add frontend
// TODO: Add backend

void main() async {
  await ThemeManager.factory();
  TwitchManager.instance.initialize(useMock: false);

  GameManager.instance; // Force the initialization of the game manager

  runApp(MaterialApp(
    initialRoute: GameScreen.route,
    routes: {
      GameScreen.route: (ctx) => const GameScreen(),
    },
  ));
}

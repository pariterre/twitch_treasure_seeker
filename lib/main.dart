import 'package:common/managers/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:twitch_treasure_seeker/managers/twitch_manager.dart';
import 'package:twitch_treasure_seeker/screens/game_screen.dart';

// TODO: Game starts at first click
// TODO: Add sound effects
// TODO: Add Twitch manager
// TODO: Add winning condition from finding the word from the chat
// TODO: Add frontend
// TODO: Add backend

void main() async {
  await ThemeManager.initialize();

  TwitchManager.instance.initialize(useMock: true);

  runApp(MaterialApp(
    initialRoute: GameScreen.route,
    routes: {
      GameScreen.route: (ctx) => const GameScreen(),
    },
  ));
}

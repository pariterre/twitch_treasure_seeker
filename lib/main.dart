import 'package:flutter/material.dart';
import 'package:twitch_treasure_seeker/screens/configuration_room.dart';
import 'package:twitch_treasure_seeker/screens/end_screen.dart';
import 'package:twitch_treasure_seeker/screens/game_screen.dart';
import 'package:twitch_treasure_seeker/screens/idle_room.dart';
import 'package:twitch_treasure_seeker/screens/lobby_screen.dart';

// TODO add credit (images)
void main() async {
  runApp(MaterialApp(
    initialRoute: ConfigurationRoom.route,
    routes: {
      ConfigurationRoom.route: (ctx) => const ConfigurationRoom(),
      IdleRoom.route: (ctx) => const IdleRoom(),
      GameScreen.route: (ctx) => const GameScreen(),
      LobbyScreen.route: (ctx) => const LobbyScreen(),
      EndScreen.route: (ctx) => const EndScreen(),
    },
  ));
}

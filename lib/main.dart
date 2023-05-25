import 'package:flutter/material.dart';
import 'package:twitch_manager/twitch_manager.dart';
import 'package:twitched_minesweeper/screens/game_screen.dart';
import 'package:twitched_minesweeper/screens/register_player_screen.dart';
import 'package:twitched_minesweeper/screens/waiting_room.dart';

void main() async {
  runApp(MaterialApp(
    initialRoute: TwitchAuthenticationScreen.route,
    routes: {
      TwitchAuthenticationScreen.route: (ctx) =>
          const TwitchAuthenticationScreen(
            nextRoute: WaitingRoom.route,
            appId: 'eqt0u8wre5boab7thsjb6b8sh57qy3',
            scope: [
              TwitchScope.chatRead,
              TwitchScope.chatEdit,
              TwitchScope.chatters,
              TwitchScope.readFollowers,
              TwitchScope.readSubscribers,
            ],
            withModerator: true,
            forceNewAuthentication: false,
          ),
      WaitingRoom.route: (ctx) => const WaitingRoom(),
      GameScreen.route: (ctx) => const GameScreen(),
      RegisterPlayersScreen.route: (ctx) => const RegisterPlayersScreen(),
    },
  ));
}

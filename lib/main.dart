import 'package:flutter/material.dart';
import 'package:twitch_manager/twitch_manager.dart';
import 'package:twitched_minesweeper/screens/game_screen.dart';

void main() async {
  runApp(MaterialApp(
    initialRoute: GameScreen.route,
    routes: {
      // TwitchAuthenticationScreen.route: (ctx) =>
      //     const TwitchAuthenticationScreen(
      //       nextRoute: GameScreen.route,
      //       appId: 'eqt0u8wre5boab7thsjb6b8sh57qy3',
      //       scope: [
      //         TwitchScope.chatRead,
      //         TwitchScope.chatEdit,
      //         TwitchScope.chatters,
      //         TwitchScope.readFollowers,
      //         TwitchScope.readSubscribers,
      //       ],
      //       withModerator: true,
      //       forceNewAuthentication: false,
      //     ),
      GameScreen.route: (ctx) => const GameScreen(
            nbCols: 10,
            nbRows: 20,
          ),
    },
  ));
}

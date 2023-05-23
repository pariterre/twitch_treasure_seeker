import 'package:flutter/material.dart';
import 'package:twitch_manager/twitch_manager.dart';
import 'package:twitched_minesweeper/models/game_manager.dart';
import 'package:twitched_minesweeper/screens/game_screen.dart';
import 'package:twitched_minesweeper/screens/register_player_screen.dart';

void main() async {
  final gameManager = GameManager();
  gameManager.addPlayer('Moi');
  gameManager.addPlayer('Toi');

  runApp(MaterialApp(
    initialRoute: RegisterPlayersScreen.route,
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
      GameScreen.route: (ctx) => GameScreen(gameManager: gameManager),
      RegisterPlayersScreen.route: (ctx) =>
          RegisterPlayersScreen(gameManager: gameManager),
    },
  ));
}

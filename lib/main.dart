import 'package:flutter/material.dart';
import 'package:twitch_manager/twitch_manager.dart';
import 'package:twitched_minesweeper/screens/configuration_room.dart';
import 'package:twitched_minesweeper/screens/end_screen.dart';
import 'package:twitched_minesweeper/screens/game_screen.dart';
import 'package:twitched_minesweeper/screens/idle_room.dart';
import 'package:twitched_minesweeper/screens/lobby_screen.dart';

void main() async {
  runApp(MaterialApp(
    initialRoute: TwitchAuthenticationScreen.route,
    routes: {
      TwitchAuthenticationScreen.route: (ctx) => TwitchAuthenticationScreen(
            useMock: true,
            appInfo: TwitchAppInfo(
              appName: 'Minesweeper',
              twitchAppId: 'eqt0u8wre5boab7thsjb6b8sh57qy3',
              scope: [
                TwitchScope.chatRead,
                TwitchScope.chatEdit,
                TwitchScope.chatters,
                TwitchScope.readFollowers,
                TwitchScope.readSubscribers,
                TwitchScope.readModerator,
              ],
              redirectAddress: 'http://localhost:3000',
            ),
            onFinishedConnexion: (manager) => Navigator.of(ctx)
                .pushReplacementNamed(ConfigurationRoom.route,
                    arguments: manager),
            loadPreviousSession: true,
          ),
      ConfigurationRoom.route: (ctx) => const ConfigurationRoom(),
      IdleRoom.route: (ctx) => const IdleRoom(),
      GameScreen.route: (ctx) => const GameScreen(),
      LobbyScreen.route: (ctx) => const LobbyScreen(),
      EndScreen.route: (ctx) => const EndScreen(),
    },
  ));
}

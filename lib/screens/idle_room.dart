import 'package:flutter/material.dart';
import 'package:twitch_manager/twitch_manager.dart';
import 'package:twitched_minesweeper/models/game_interface.dart';
import 'package:twitched_minesweeper/models/minesweeper_theme.dart';
import 'package:twitched_minesweeper/screens/lobby_screen.dart';

class IdleRoom extends StatefulWidget {
  const IdleRoom({super.key});

  static const route = '/idle-room';

  @override
  State<IdleRoom> createState() => _IdleRoomState();
}

class _IdleRoomState extends State<IdleRoom> {
  late final GameInterface _mainInterface;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _mainInterface =
        ModalRoute.of(context)!.settings.arguments as GameInterface;
    _mainInterface.gameManager.resetPlayers();
    _mainInterface.onRequestLaunchGame = onRequestLaunchGame;
  }

  void onRequestLaunchGame() {
    _mainInterface.onRequestLaunchGame = null;

    Navigator.of(context)
        .pushReplacementNamed(LobbyScreen.route, arguments: _mainInterface);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(color: ThemeColor.greenScreen),
        child: TwitchDebugPanel(manager: _mainInterface.twitchManager),
      ),
    );
  }
}

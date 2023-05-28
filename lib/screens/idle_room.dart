import 'package:flutter/material.dart';
import 'package:twitched_minesweeper/models/main_interface.dart';
import 'package:twitched_minesweeper/models/minesweeper_theme.dart';
import 'package:twitched_minesweeper/screens/lobby_screen.dart';

class IdleRoom extends StatefulWidget {
  const IdleRoom({super.key});

  static const route = '/idle-room';

  @override
  State<IdleRoom> createState() => _IdleRoomState();
}

class _IdleRoomState extends State<IdleRoom> {
  late final MainInterface _mainInterface;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _mainInterface =
        ModalRoute.of(context)!.settings.arguments as MainInterface;
    _mainInterface.gameManager.reset();
    _mainInterface.onRequestLaunchGame = onRequestLaunchGame;
  }

  void onRequestLaunchGame() {
    _mainInterface.onRequestLaunchGame = null;

    Navigator.of(context)
        .pushReplacementNamed(LobbyScreen.route, arguments: _mainInterface);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(color: ThemeColor.greenScreen));
  }
}

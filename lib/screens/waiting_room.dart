import 'package:flutter/material.dart';
import 'package:twitch_manager/twitch_manager.dart';
import 'package:twitched_minesweeper/models/enums.dart';
import 'package:twitched_minesweeper/models/main_interface.dart';
import 'package:twitched_minesweeper/screens/register_player_screen.dart';

class WaitingRoom extends StatefulWidget {
  const WaitingRoom({super.key});

  static const route = '/waiting-room';

  @override
  State<WaitingRoom> createState() => _WaitingRoomState();
}

class _WaitingRoomState extends State<WaitingRoom> {
  late final TwitchManager _twitchManager;
  late final MainInterface _twitchInterface;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _twitchManager =
        ModalRoute.of(context)!.settings.arguments as TwitchManager;

    _twitchInterface = MainInterface(twitchManager: _twitchManager);
    _twitchInterface.onRequestGameStart = onRequestGameStart;
  }

  void onRequestGameStart() {
    Navigator.of(context).pushReplacementNamed(RegisterPlayersScreen.route,
        arguments: _twitchInterface);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(color: ThemeColor.greenScreen));
  }
}

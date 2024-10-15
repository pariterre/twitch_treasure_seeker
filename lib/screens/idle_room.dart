import 'package:flutter/material.dart';
import 'package:twitch_manager/twitch_app.dart';
import 'package:twitch_treasure_seeker/managers/game_interface.dart';
import 'package:twitch_treasure_seeker/managers/twitch_manager.dart';
import 'package:twitch_treasure_seeker/models/minesweeper_theme.dart';
import 'package:twitch_treasure_seeker/screens/configuration_room.dart';
import 'package:twitch_treasure_seeker/screens/lobby_screen.dart';

class IdleRoom extends StatefulWidget {
  const IdleRoom({super.key});

  static const route = '/idle-room';

  @override
  State<IdleRoom> createState() => _IdleRoomState();
}

class _IdleRoomState extends State<IdleRoom> {
  @override
  void initState() {
    super.initState();

    final gm = GameManager.instance;
    gm.gameLogic.resetPlayers();
    gm.onRequestSetupScreen = _onRequestSetupScreen;
    gm.onRequestLaunchGame = _onRequestLaunchGame;
  }

  void _unregisterCallbacks() {
    final gm = GameManager.instance;
    gm.onRequestSetupScreen = null;
    gm.onRequestLaunchGame = null;
  }

  void _onRequestSetupScreen() async {
    _unregisterCallbacks();
    await GameManager.instance.gameLogic.setIsGameRunningForTheFirstTime(true);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(ConfigurationRoom.route);
  }

  void _onRequestLaunchGame() {
    _unregisterCallbacks();
    Navigator.of(context).pushReplacementNamed(LobbyScreen.route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TwitchAppDebugOverlay(
        manager: TwitchManager.instance.manager,
        startingPosition: Offset(MediaQuery.of(context).size.width - 300,
            MediaQuery.of(context).size.height / 2 - 100),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(color: ThemeColor.greenScreen),
        ),
      ),
    );
  }
}
